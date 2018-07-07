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
	
	public class Main extends MovieClip {
		public var m_world:b2World;
		public var m_iterations:int = 10;
		public var m_timeStep:Number = 1.0/30.0;
		public var m_currentTime:Number=0;
		static public var m_sprite:Sprite;
		public var m_input:Input;
 		
		public var shooter;
		public var bullets:Array=new Array();
		public var particles:Array=new Array();
		
		public function Main(){
			// Add event for main loop
			addEventListener(Event.ENTER_FRAME, Update, false, 0, true);

			m_sprite = new Sprite();
			addChild(m_sprite);
			m_input = new Input(m_sprite);

			// Create world AABB
			var worldAABB:b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(-100.0, -100.0);
			worldAABB.upperBound.Set(100.0, 100.0);

			// Define the gravity vector
//			var gravity:b2Vec2 = new b2Vec2(0.0, 10.0);
			var gravity:b2Vec2 = new b2Vec2(0.0, 0.0);
			
			// Allow bodies to sleep
			var doSleep:Boolean = true;

			// Construct a world object
			m_world = new b2World(worldAABB, gravity, doSleep);
						
			// debug drawing
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
			var dbgSprite:Sprite = new Sprite();
			addChild(dbgSprite);
			dbgDraw.m_sprite = m_sprite;
			dbgDraw.m_drawScale = 30;
			dbgDraw.m_fillAlpha = 0.6;
			dbgDraw.m_lineThickness = 1.0;
			dbgDraw.m_drawFlags = b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit;
			m_world.SetDebugDraw(dbgDraw);
			
			
			shooter=new Shooter(m_world, 9, 6.5);
			
		}

		public function randomShape(){
			switch(int(Math.random()*2)){
				case 0:
					var shapeDef:b2PolygonDef=new b2PolygonDef();
					shapeDef.vertexCount = 3;
					shapeDef.vertices[0].Set(-Math.random(), 0.0);
					shapeDef.vertices[1].Set(Math.random(), 0.0);
					shapeDef.vertices[2].Set(0.0, Math.random()*2);
					shapeDef.density = 1.0;
					shapeDef.friction = 0.1;
					shapeDef.restitution = 0.2;
					shapeDef.filter.groupIndex=2;
					return shapeDef;
				case 1:
					var circleDef:b2CircleDef;			
	
					// a shape for the body
					circleDef = new b2CircleDef();
					circleDef.radius = (Math.random()/2)+0.25;
					circleDef.density = 1.0;
					circleDef.friction = 0.1;
					circleDef.restitution = 0.2;
					circleDef.filter.groupIndex=2;
	
					return circleDef;			
			}
		}
		
		public function randomCircle(){

			var bodyDef:b2BodyDef;
			// body definition
			bodyDef = new b2BodyDef();

			var Width=stage.stageWidth/30;
			var Height=stage.stageHeight/30;
			var offStage=2;
			
			
			if(Math.round(Math.random())){
				bodyDef.position.x = Math.random()*Width;
				
				if(Math.round(Math.random())){
					bodyDef.position.y = Height + offStage;
				} else {
					bodyDef.position.y = -offStage;
				}
				
			} else {
				bodyDef.position.y = Math.random()*Height;
				
				if(Math.round(Math.random())){
					bodyDef.position.x = Width + offStage;
				} else {
					bodyDef.position.x = -offStage;
				}
			}
			
//				bodyDef.position.x = Math.random()*Width;
//				bodyDef.position.y = Math.random()*Height;
			
			bodyDef.angularDamping = 0.1;

			var body = m_world.CreateBody(bodyDef);
			body.CreateShape(randomShape());
			body.SetMassFromShapes();			
						
			var center=new b2Vec2(body.GetPosition().x,body.GetPosition().y); 
			center.Subtract(new b2Vec2(shooter.body.GetPosition().x,shooter.body.GetPosition().y));
			center.Normalize();
			center=center.Negative();
			center.Multiply((Math.random()*5)+3);

			body.SetLinearVelocity(center);
			
//			body.ApplyForce(center, body.GetPosition());			
			
			
		}
		
		public function removeOldBullets(element:*, index:int, arr:Array):Boolean {
			if((getTimer()-element.GetUserData()) > 5000){
				m_world.DestroyBody(element);
				return false;
			}
			return true;
		}
		public function removeOldParticles(element:*, index:int, arr:Array):Boolean {
			if((getTimer()-element.GetUserData()) > 500){
				m_world.DestroyBody(element);
				return false;
			}
			return true;
		}
		
		public function Update(e:Event):void{
			m_currentTime++;
			
			// Update mouse joint
			UpdateMouseWorld()
			MouseDestroy();
			MouseDrag();
			
			UpdateKeyboardWorld();

			// fade old bullets
			bullets=bullets.filter(removeOldBullets);
			particles=particles.filter(removeOldParticles);
			
			// new invaders
			var modStep:int=50 - (m_currentTime/50);
			if(!(m_currentTime % modStep))
				randomCircle();
			
			m_world.Step(m_timeStep, m_iterations);
			Input.update();
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
				particles.push(shooter.moveForward());
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
			
			if(Input.mouseDown){
				// rapid fire
				if(!(m_currentTime % 3))
					bullets.push(shooter.shoot(mouseXWorldPhys, mouseYWorldPhys));
			}
			
			if (Input.mouseDown && !mousePressed){
				mousePressed=true;
  			bullets.push(shooter.shoot(mouseXWorldPhys, mouseYWorldPhys));
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
		// Mouse Destroy
		//======================
		public function MouseDestroy():void{
			// mouse press
			if (!Input.mouseDown && Input.isKeyPressed(68/*D*/)){
				
				var body:b2Body = GetBodyAtMouse(true);
				
				if (body)
				{
					m_world.DestroyBody(body);
					return;
				}
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