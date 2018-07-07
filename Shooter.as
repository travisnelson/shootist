package {
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import flash.utils.getTimer;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import Shapes.*;
	

	public class Shooter extends Shape {
		public var m_world:b2World;
		public var SpaceshipGFX;
		
		public function Shooter(m_w:b2World){
			m_world=m_w;
			var spaceship_bitmap=new Bitmap(new Spaceship(10, 10));
			spaceship_bitmap.smoothing=true;
			spaceship_bitmap.x=-spaceship_bitmap.width/2;
			spaceship_bitmap.y=-spaceship_bitmap.height/2;
			SpaceshipGFX=new Sprite();
			SpaceshipGFX.addChild(spaceship_bitmap);
			
			var circleDef:b2CircleDef;
						
			// a shape for the body
			circleDef = new b2CircleDef();
			circleDef.radius = 0.2;
			circleDef.density = 0.5;
			circleDef.friction = 0.1;
			circleDef.restitution = 0.2;
			circleDef.filter.groupIndex=-1;
			shapeDefs.push(circleDef);

			var jetDef:b2PolygonDef=new b2PolygonDef();
			jetDef.SetAsOrientedBox(0.1,0.1, new b2Vec2(-0.2,0), 0);
			jetDef.filter.groupIndex=-1;
			shapeDefs.push(jetDef);
		}
		
		public override function Draw(m_sprite:Sprite, level:int){
			SpaceshipGFX.x=(body.GetPosition().x*30);
			SpaceshipGFX.y=(body.GetPosition().y*30);
			SpaceshipGFX.rotation=(body.GetAngle()+Math.PI/2)*(180/Math.PI);
			m_sprite.addChild(SpaceshipGFX);
		}
		
		public function shoot(x:Number, y:Number):Shape{
			var bullet = new Bullet();
			bullet.toWorld(m_world, body.GetPosition().x, body.GetPosition().y, 0, 1);
			
			var center=new b2Vec2(body.GetPosition().x,body.GetPosition().y); 
			center.Subtract(new b2Vec2(x,y));
			center.Normalize();
			center=center.Negative();
			center.Multiply(7); // velocity of fired bullet
				
			bullet.body.ApplyForce(center, bullet.body.GetPosition());
			return bullet;
		}
		
		public function particle():Shape {
			var particle = new Particle();
			particle.toWorld(m_world, body.GetPosition().x, body.GetPosition().y, 0, 1);
			
			var x=-Math.sin(body.GetAngle() + (Math.PI/2) + ((Math.random()*1)-0.5));
			var y=Math.cos(body.GetAngle() + (Math.PI/2) + ((Math.random()*1)-0.5));
			var force=new b2Vec2(x,y);
			force.Normalize();
			force.Multiply(0.04);
		
			particle.body.ApplyForce(force, particle.body.GetPosition());
			return particle;			
		}
		
		public function moveForward():Shape {
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