package Shapes {
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Shapes.*;

	
	public class Bullet extends Shape{		
		public function Bullet(){
			var circleDef:b2CircleDef;			
						
			// a shape for the body
			circleDef = new b2CircleDef();
			circleDef.radius = 0.1;
			circleDef.density = 1.0;
			circleDef.friction = 0.1;
			circleDef.restitution = 0.2;
			circleDef.filter.groupIndex=-1;
			shapeDefs.push(circleDef);
		}
	}
}