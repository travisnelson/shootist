package Shapes {
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import flash.display.*;
	import flash.utils.getTimer;

	public class Shape {
		public var body:b2Body;
		public var shapeDefs:Array=new Array();
		public var shapes:Array=new Array();
		public var collisionLevel:int;
		
		public function Shape(){
		}
		
		public function Update(){
		}
		
		public function Draw(m_sprite:Sprite, level:int){
			var scale=30;

			if(level==1){
				m_sprite.graphics.beginFill(0x777777);				
			} else if(level==2){
				m_sprite.graphics.beginFill(0x888888);
			} else if(level==4){
				m_sprite.graphics.beginFill(0x999999);
			} else if(level==8){
				m_sprite.graphics.beginFill(0xAAAAAA);
			} else if(level==16){
				m_sprite.graphics.beginFill(0xBBBBBB);
			} else if(level==99){
				m_sprite.graphics.beginFill(0xFFFFFF);
			}

			
			m_sprite.graphics.lineStyle(0);

			for each (var shape in shapes){
				if(shape.GetFilterData().categoryBits & level){
					if(shape is b2PolygonShape){
						var vertices:Array=shape.GetVertices();
						var vertice=body.GetWorldPoint(vertices[0]);
	
						m_sprite.graphics.moveTo(vertice.x*scale, vertice.y*scale);
			
						for each(vertice in vertices){
							vertice=body.GetWorldPoint(vertice);
							m_sprite.graphics.lineTo(vertice.x*scale, vertice.y*scale);
						}						
					} else if(shape is b2CircleShape){
						vertice=body.GetWorldPoint(shape.GetLocalPosition());
						m_sprite.graphics.drawCircle(vertice.x*scale, vertice.y*scale, shape.GetRadius()*scale);						
					}
				}
			}
			m_sprite.graphics.endFill();
		}
		
		protected function makeBody(m_world:b2World, x:Number, y:Number, angle:Number){
			var bodyDef:b2BodyDef;
			// body definition
			bodyDef = new b2BodyDef();
			bodyDef.position.x = x;
			bodyDef.position.y = y;
			bodyDef.angularDamping = 0.1;
			bodyDef.angle=angle;
			bodyDef.userData=getTimer();	

			body = m_world.CreateBody(bodyDef);
			
			for each (var shape in shapeDefs){
				shapes.push(body.CreateShape(shape));
			}
			
			body.SetMassFromShapes();
		}
		
		public function attachToGround(m_world:b2World){
			// add the joint
			var jointDef = new b2RevoluteJointDef(); 
			jointDef.Initialize(m_world.GetGroundBody(), body, body.GetWorldCenter());
			body.m_userData=m_world.CreateJoint(jointDef);			
		}
		
		public function attachToShape(m_world:b2World, shape:Shape){
			var jointDef = new b2GearJointDef();
			jointDef.body1 = shape.body;
			jointDef.body2 = body;
			jointDef.joint1 = shape.body.GetUserData();
			jointDef.joint2 = body.GetUserData();
			jointDef.ratio=-1;
			return m_world.CreateJoint(jointDef);
		}
		
		public function toWorld(m_world:b2World, x:Number, y:Number, angle:Number, cLevel:int=0){
			if(cLevel){
				for each (var shape in shapeDefs){
					if(shape.filter.categoryBits)
						shape.filter.categoryBits=shape.filter.categoryBits << ((Math.log(cLevel)/Math.log(2))+1);
					else			
						shape.filter.categoryBits=shape.filter.categoryBits | cLevel;

					shape.filter.maskBits=shape.filter.categoryBits;
					collisionLevel=collisionLevel | shape.filter.categoryBits;
				}
			}
			
			makeBody(m_world, x, y, angle);
		}
		
	}
	
}