package com.aem.prototype.towertussles
{
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class DraggableShape extends MovieClip
	{

		private var originalLocation:Point;
		private var startingLocation:Point;

		public function DraggableShape():void
		{
			this.buttonMode = true;
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
			var obj:Object=event.currentTarget;
			this.parent.setChildIndex(this, this.parent.numChildren - 1); 
			startingLocation=new Point();
			startingLocation.x=obj.x;
			startingLocation.y=obj.y;
			obj.startDrag();
			  
		}
		
		public function place(event:MouseEvent):void
		{
			this.stopDrag();
		}
		

		public function submit(e:Event):void
		{
			dispatchEvent(new Event(Level.SUBMIT_BOX));
			this.x = originalLocation.x;
			this.y = originalLocation.y;
			this.rotation = 0;
		}
		public function passCursor(cursor:RotatableCursor):void
		{
			for(var i:Number=0;i<this.numChildren;i++)
			{
				if(this.getChildAt(i) is Rotator)
				   Rotator(this.getChildAt(i)).cursor = cursor;
			}
		}

	}
}
