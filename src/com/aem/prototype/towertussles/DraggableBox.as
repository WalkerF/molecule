package com.aem.prototype.towertussles
{
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	
	import com.aem.molecule.Game;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class DraggableBox extends MovieClip
	{

		private var originalLocation:Point;
		private var startingLocation:Point;
		private var hasClick:Boolean;
		private static const CLICK_MAX_TIMER:Number=15;
		private var clickTimer:Number;

		public function DraggableBox():void
		{
			clickTimer=0;
			originalLocation=new Point();
			originalLocation.x=this.x;
			originalLocation.y=this.y;
			addEventListener(MouseEvent.MOUSE_DOWN, pickup);
			addEventListener(MouseEvent.MOUSE_UP, place);
			this.doubleClickEnabled = true;
			addEventListener(MouseEvent.DOUBLE_CLICK,submit);
			//addEventListener(MouseEvent.CLICK, acknowledgeClick);
		}

		public function pickup(event:MouseEvent):void
		{
			var obj:Object=event.currentTarget;
			this.parent.setChildIndex(this, this.parent.numChildren - 1); // Does not work. Parent doesn't possess other crate

			startingLocation=new Point();
			startingLocation.x=obj.x;
			startingLocation.y=obj.y;
			obj.startDrag();
		}

		public function submit(e:Event):void
		{
			dispatchEvent(new Event(Level.SUBMIT_BOX));
		}

		public function place(event:MouseEvent):void
		{
			this.stopDrag();
		}

	}
}
