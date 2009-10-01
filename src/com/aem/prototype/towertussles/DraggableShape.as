package com.aem.prototype.towertussles
{
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	
	import com.aem.molecule.entities.PhysicalEntity;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class DraggableShape extends PhysicalEntity
	{

		private var originalLocation:Point;
		private var startingLocation:Point;
		public var rotateBool:Boolean;
		public var offset:Number;
		public var dispatchEventString:String;
		private var myBody:b2Body;
		public var isPlaced:Boolean;

		public function DraggableShape():void
		{
			this.isPlaced=false;
			this.buttonMode=true;
			originalLocation=new Point();
			originalLocation.x=this.x;
			originalLocation.y=this.y;
			addEventListener(MouseEvent.MOUSE_DOWN, pickup);
			addEventListener(MouseEvent.MOUSE_UP, place);
			this.doubleClickEnabled=true;
			addEventListener(MouseEvent.DOUBLE_CLICK, submit);
		}

		public function pickup(event:MouseEvent):void
		{
			pickupItem();
		}

		public function pickupItem():void
		{
			this.parent.setChildIndex(this, this.parent.numChildren - 1);
			startingLocation=new Point();
			startingLocation.x=this.x;
			startingLocation.y=this.y;
			this.startDrag();
		}

		public function place(event:MouseEvent):void
		{
			this.stopDrag();
			dispatchEvent(new Event(Level.CHECK_DRAGGABLE_MENU_DROP));
		}


		public function submit(e:Event):void
		{
			dispatchEvent(new Event(Level.SUBMIT_SHAPE));
		}

		public function passCursor(cursor:RotatableCursor):void
		{
			for (var i:Number=0; i < this.numChildren; i++)
			{
				if (this.getChildAt(i) is Rotator)
					Rotator(this.getChildAt(i)).cursor=cursor;
			}
		}

		public function initiateRotate(e:MouseEvent):void
		{
			offset=getAngle(e) - this.rotation;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, rotate);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopRotate);
		}

		public function stopRotate(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, rotate);
            stage.removeEventListener(MouseEvent.MOUSE_UP, stopRotate);
		}

		public function getAngle(e:MouseEvent):Number
		{
			var p:Point=new Point(this.x, this.y);
			p=this.parent.localToGlobal(p);
			return Math.atan2(e.stageY - p.y, e.stageX - p.x) * 180 / Math.PI;
		}

		public function rotate(e:MouseEvent):void
		{
			var newTheta:Number=getAngle(e);
			this.rotation=newTheta - offset;
			e.updateAfterEvent();
		}

		public override function init(world:b2World):b2Body
		{
			var bodyDef:b2BodyDef=createBodyDef();

			var boxDef:b2PolygonDef=createShapeDef();
			boxDef.isSensor=true;

			var body:b2Body=world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			body.SetMassFromShapes();

			this.myBody=body;
			return body;
		}
		
		public function destroyBody(world:b2World):void
		{
			world.DestroyBody(this.myBody);
		}

		public function placeOnBoard(world:b2World):void
		{
			var child:Rotator;
			while (this.numChildren > 1)
			{
				child = Rotator(this.getChildAt(1)); //relies on fact that sensors come after initial shape    
				child.removeEventListener(MouseEvent.MOUSE_DOWN, initiateRotate);
				child.removeEventListener(MouseEvent.MOUSE_OVER, child.removeParentListener);
				this.removeChildAt(1);         
			}
			destroyBody(world);

			var bodyDef:b2BodyDef=createBodyDef();

			var boxDef:b2PolygonDef=createShapeDef();
			boxDef.isSensor=false;
			boxDef.friction=2;
			boxDef.density=.4;
			boxDef.restitution=0;

			var body:b2Body=world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			body.SetMassFromShapes();

			this.removeAllEventListeners();
			this.buttonMode=false;
			this.isPlaced=true;
		}

		private function removeAllEventListeners():void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, pickup);
			removeEventListener(MouseEvent.MOUSE_UP, place);
			removeEventListener(MouseEvent.DOUBLE_CLICK, submit);
		}

		private function createBodyDef():b2BodyDef
		{
			var bodyDef:b2BodyDef=new b2BodyDef();
			bodyDef.position.Set(p2m(x), p2m(y));
			bodyDef.angle=rotation * Math.PI / 180;
			bodyDef.userData=this;
			return bodyDef;
		}

		private function createShapeDef():b2PolygonDef
		{
			// caching the rotation so we can correctly set the width
			var r:Number=rotation;
			rotation=0;

			var boxDef:b2PolygonDef=new b2PolygonDef();
			boxDef.SetAsBox(p2m(this.getChildAt(0).width / 2), p2m(this.getChildAt(0).height / 2)); //Hackish. Actual shape is first child. Rest are sensors which distort true size.

			// setting back the shapes rotation
			rotation=r;
			return boxDef;
		}

	}
}
