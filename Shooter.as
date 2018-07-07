package {
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import flash.utils.getTimer;
	
	public class Shooter {
		public var body:b2Body;
		public var m_world:b2World;
		
		public function Shooter(m_w:b2World, x:Number, y:Number){
			m_world=m_w;
			
			var circleDef:b2CircleDef;			
						
			// a shape for the body
			circleDef = new b2CircleDef();
			circleDef.radius = 0.2;
			circleDef.density = 0.5;
			circleDef.friction = 0.1;
			circleDef.restitution = 0.2;
			circleDef.filter.groupIndex=-1;

			var jetDef:b2PolygonDef=new b2PolygonDef();
			jetDef.SetAsOrientedBox(0.1,0.1, new b2Vec2(-0.2,0), 0);
			jetDef.filter.groupIndex=-1;
			
			var bodyDef:b2BodyDef;
			// body definition
			bodyDef = new b2BodyDef();
			bodyDef.position.x = x;
			bodyDef.position.y = y;
			bodyDef.angularDamping = 0.1;
	
			body = m_world.CreateBody(bodyDef);
			body.CreateShape(circleDef);
			body.CreateShape(jetDef);
			body.SetMassFromShapes();			
		}
		
		public function shoot(x:Number, y:Number):b2Body{
			var circleDef:b2CircleDef;			
						
			// a shape for the body
			circleDef = new b2CircleDef();
			circleDef.radius = 0.1;
			circleDef.density = 1.0;
			circleDef.friction = 0.1;
			circleDef.restitution = 0.2;
			circleDef.filter.groupIndex=-1;

			var bodyDef:b2BodyDef;
			// body definition
			bodyDef = new b2BodyDef();
			bodyDef.position.x = body.GetPosition().x;
			bodyDef.position.y = body.GetPosition().y;
			bodyDef.angularDamping = 0.1;
			bodyDef.userData=getTimer();
	
			var bullet = m_world.CreateBody(bodyDef);
			bullet.CreateShape(circleDef);
			bullet.SetMassFromShapes();

			var center=new b2Vec2(body.GetPosition().x,body.GetPosition().y); 
			center.Subtract(new b2Vec2(x,y));
			center.Normalize();
			center=center.Negative();
			center.Multiply(5);
				
			bullet.ApplyForce(center, bullet.GetPosition());
			return bullet;
		}
		
		public function particle():b2Body {
			var circleDef:b2CircleDef;			
						
			// a shape for the body
			circleDef = new b2CircleDef();
			circleDef.radius = 0.01;
			circleDef.density = 1.0;
			circleDef.friction = 0.1;
			circleDef.restitution = 0.2;
			circleDef.filter.groupIndex=-1;

			var bodyDef:b2BodyDef;
			// body definition
			bodyDef = new b2BodyDef();
			bodyDef.position.x = body.GetPosition().x;
			bodyDef.position.y = body.GetPosition().y;
			bodyDef.angularDamping = 0.1;
			bodyDef.userData=getTimer();
	
			var bullet = m_world.CreateBody(bodyDef);
			bullet.CreateShape(circleDef);
			bullet.SetMassFromShapes();

			var x=-Math.sin(body.GetAngle() + (Math.PI/2) + ((Math.random()*1)-0.5));
			var y=Math.cos(body.GetAngle() + (Math.PI/2) + ((Math.random()*1)-0.5));
			var force=new b2Vec2(x,y);
			force.Normalize();
			force.Multiply(0.04);
		
			bullet.ApplyForce(force, bullet.GetPosition());
			return bullet;			
		}
		
		public function moveForward():b2Body{
			var x=Math.sin(body.GetAngle() + (Math.PI/2));
			var y=-Math.cos(body.GetAngle() + (Math.PI/2));
			
			body.ApplyForce(new b2Vec2(x,y), body.GetPosition());
				
			var velocity=body.GetLinearVelocity();
			velocity.MaxV(new b2Vec2(-5,-5));
			velocity.MinV(new b2Vec2(5,5));				
			body.SetLinearVelocity(velocity);
			
			return particle();
		}
		
	}
}