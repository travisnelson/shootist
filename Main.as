package {
	import flash.display.Sprite;
	import flash.events.*;
    import flash.display.MovieClip;	
	import flash.text.TextField;
	import flash.utils.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import General.*;
	import Shapes.*
	
	public class Main extends MovieClip {
		public var m_world:b2World;
		public var m_iterations:int = 10;
		public var m_timeStep:Number = 1.0/30.0;
		public var m_currentTime:Number=0;
		static public var m_sprite:Sprite;
		public var m_input:Input;
 		
		public var Actors:Array=new Array();

		public var shooter:Shooter;
		public var bullets:Array=new Array();
		public var particles:Array=new Array();
		
		public function Main(){
			// Add event for main loop
			addEventListener(Event.ENTER_FRAME, Update, false, 0, true);

			setupBox2d();
			
			shooter=new Shooter(m_world);
			shooter.toWorld(m_world, stage.stageWidth/2/30, stage.stageHeight/2/30, -Math.PI/2, 1);
			Actors.push(shooter);
		}

		public function setupBox2d(){
			m_sprite = new Sprite();
			addChild(m_sprite);
			m_input = new Input(m_sprite);

			// Create world AABB
			var worldAABB:b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(-100.0, -100.0);
			worldAABB.upperBound.Set(100.0, 100.0);

			// Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2(0.0, 0.0);
			
			// Allow bodies to sleep
			var doSleep:Boolean = true;

			// Construct a world object
			m_world = new b2World(worldAABB, gravity, doSleep);
		}
		
		public function sendAsteroid(){
			var Width=stage.stageWidth/30;
			var Height=stage.stageHeight/30;
			var offStage=2;
			var x;
			var y;
			
			if(Math.round(Math.random())){
				x = Math.random()*Width;
				
				if(Math.round(Math.random())){
					y = Height + offStage;
				} else {
					y = -offStage;
				}
				
			} else {
				y = Math.random()*Height;
				
				if(Math.round(Math.random())){
					x = Width + offStage;
				} else {
					x = -offStage;
				}
			}
			
			var asteroid=new Asteroid();
			asteroid.toWorld(m_world, x, y, 0, 1);
			Actors.push(asteroid);
			
			var center=new b2Vec2(asteroid.body.GetPosition().x,asteroid.body.GetPosition().y); 
			center.Subtract(new b2Vec2(shooter.body.GetPosition().x,shooter.body.GetPosition().y));
			center.Normalize();
			center=center.Negative();
			center.Multiply((Math.random()*5)+3); // velocity of asteroid

			asteroid.body.SetLinearVelocity(center);
			asteroid.body.SetAngularVelocity(Math.round(Math.random()*20)-10);
		}
		
		public function garbageCollection(element:*, index:int, arr:Array):Boolean {
			var timeout=0;
			
			if(element is Bullet){
				timeout=5000;
			} else if(element is Asteroid){
				timeout=99999;
			} else if(element is Particle){
				timeout=500;
			}

			if(timeout && (getTimer()-element.body.GetUserData()) > timeout){
				m_world.DestroyBody(element.body);
				return false;
			}

			return true;
		}
		
		public function Update(e:Event):void{
			m_currentTime++;

			// Update mouse joint
			UpdateMouseWorld()
			MouseDrag();
			
			UpdateKeyboardWorld();

			Actors=Actors.filter(garbageCollection);
			
			var modStep:int=50 - (m_currentTime/50);
			if(!(m_currentTime % modStep))
				sendAsteroid();
			
			var actor;
			for each (actor in Actors){
				actor.Update();
			}
			
			m_world.Step(m_timeStep, m_iterations);
			Input.update();
			
			// scroll
            var loc:b2Vec2=shooter.body.GetPosition();
			var limit=stage.stageHeight/3;
			if((loc.y*30) < limit){
				var offset=(limit-(loc.y*30))/30;
				loc.y=(limit/30);
				shooter.body.SetXForm(loc, shooter.body.GetAngle());
				
				for each (actor in Actors){
					if(actor is Asteroid){
						loc=actor.body.GetPosition();
						loc.y+=offset;
						actor.body.SetXForm(loc, actor.body.GetAngle());
					}
				}
			}
			
			m_sprite.graphics.clear();
			for(var level=0;level<8;++level){
				for each (actor in Actors){
					if(actor.collisionLevel & Math.pow(2,level)){
						actor.Draw(m_sprite, Math.pow(2,level));
					}
				}
			}
		}

		// world mouse position
		static public var mouseXWorldPhys:Number;
		static public var mouseYWorldPhys:Number;
		static public var mouseXWorld:Number;
		static public var mouseYWorld:Number;
		public var mousePressed:Boolean=false;
		public var m_physScale:Number = 30;
		
		
		public function UpdateKeyboardWorld():void {
			if(Input.isKeyDown(87)){ // w
				Actors.push(shooter.moveForward());
			}
			if(Input.isKeyDown(65)){ // a
//				shooter.body.ApplyTorque(-0.01);
				shooter.body.SetXForm(shooter.body.GetPosition(), shooter.body.GetAngle()-0.2);
			}
			if(Input.isKeyDown(68)){ // d
//				shooter.body.ApplyTorque(0.01);
				shooter.body.SetXForm(shooter.body.GetPosition(), shooter.body.GetAngle()+0.2);
			}
			shooter.body.SetAngularVelocity(0);
		}
		
		
		//======================
		// Update mouseWorld
		//======================
		public function UpdateMouseWorld():void{
			mouseXWorldPhys = (Input.mouseX)/m_physScale; 
			mouseYWorldPhys = (Input.mouseY)/m_physScale; 
			
			mouseXWorld = (Input.mouseX); 
			mouseYWorld = (Input.mouseY); 
		}
		
		
		
		//======================
		// Mouse Drag 
		//======================
		public function MouseDrag():void{
			// mouse press
			var bullet;
			
			if(Input.mouseDown){
				// rapid fire
				if(!(m_currentTime % 3)){
					bullet=shooter.shoot(mouseXWorldPhys, mouseYWorldPhys);
					Actors.push(bullet);
				}
			}
			
			if (Input.mouseDown && !mousePressed){
				mousePressed=true;
				bullet=shooter.shoot(mouseXWorldPhys, mouseYWorldPhys);
				Actors.push(bullet);
			}
			
			
			// mouse release
			if (!Input.mouseDown && mousePressed){
				mousePressed=false;
				
//				shooter.shoot(mouseXWorldPhys, mouseYWorldPhys);				
				
			}
			
			
			// mouse move
			{
//				var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
			}
		}
		
		
		
		//======================
		// GetBodyAtMouse
		//======================
		private var mousePVec:b2Vec2 = new b2Vec2();
		public function GetBodyAtMouse(includeStatic:Boolean=false):b2Body{
			// Make a small box.
			mousePVec.Set(mouseXWorldPhys, mouseYWorldPhys);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(mouseXWorldPhys - 0.001, mouseYWorldPhys - 0.001);
			aabb.upperBound.Set(mouseXWorldPhys + 0.001, mouseYWorldPhys + 0.001);
			
			// Query the world for overlapping shapes.
			var k_maxCount:int = 10;
			var shapes:Array = new Array();
			var count:int = m_world.Query(aabb, shapes, k_maxCount);
			var body:b2Body = null;
			for (var i:int = 0; i < count; ++i)
			{
				if (shapes[i].GetBody().IsStatic() == false || includeStatic)
				{
					var tShape:b2Shape = shapes[i] as b2Shape;
					var inside:Boolean = tShape.TestPoint(tShape.GetBody().GetXForm(), mousePVec);
					if (inside)
					{
						body = tShape.GetBody();
						break;
					}
				}
			}
			return body;
		}
		

	}
	
	
}