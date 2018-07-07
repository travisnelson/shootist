package Shapes {
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import Shapes.*;
	
	public class Asteroid extends Shape{
		public var AsteroidGFX;
		
		public function Asteroid(){
//			switch(int(Math.random()*2)){
//				case 0:
//					var shapeDef:b2PolygonDef=new b2PolygonDef();
//					shapeDef.vertexCount = 3;
//					shapeDef.vertices[0].Set(-Math.random(), 0.0);
//					shapeDef.vertices[1].Set(Math.random(), 0.0);
//					shapeDef.vertices[2].Set(0.0, Math.random()*2);
//					shapeDef.density = 1.0;
//					shapeDef.friction = 0.1;
//					shapeDef.restitution = 0.2;
//					shapeDef.filter.groupIndex=2;
//					shapeDefs.push(shapeDef);
//					break;
//				case 1:
			
			
			
			
					var circleDef:b2CircleDef;			
	
					// a shape for the body
					circleDef = new b2CircleDef();
					circleDef.radius = (Math.random()/2)+0.50;
					circleDef.density = 1.0;
					circleDef.friction = 0.1;
					circleDef.restitution = 0.2;
					circleDef.filter.groupIndex=2;
					shapeDefs.push(circleDef);	

					var bmap=new Bitmap(new AsteroidBitmap(10, 10));
					bmap.smoothing=true;
					bmap.width=(circleDef.radius*30)*2;
					bmap.height=(circleDef.radius*30)*2;
					bmap.x=-bmap.width/2;
					bmap.y=-bmap.height/2;
					AsteroidGFX=new Sprite();
					AsteroidGFX.addChild(bmap);
				
					
					
//					break;
		}
		
		public override function Draw(m_sprite:Sprite, level:int){
			AsteroidGFX.x=(body.GetPosition().x*30);
			AsteroidGFX.y=(body.GetPosition().y*30);
			AsteroidGFX.rotation=(body.GetAngle()+Math.PI/2)*(180/Math.PI);
			m_sprite.addChild(AsteroidGFX);
		}
		
	}
}