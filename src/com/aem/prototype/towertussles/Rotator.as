package com.aem.prototype.towertussles
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class Rotator extends MovieClip
	{
		public var rotateBool:Boolean;
	    public var offset:Number;
	    public var cursor:RotateCursor;

		public function Rotator()
		{
			addEventListener(MouseEvent.MOUSE_DOWN, DraggableShape(this.parent).initiateRotate);
			addEventListener(MouseEvent.MOUSE_OVER, removeParentListener);
		}
		
		public function setUpCursor(event:MouseEvent):void
		{
			cursor.overRotateSpot(event);
		}
		
		public function removeCursor(event:MouseEvent):void
		{
			cursor.offRotateSpot(event);
		}

		public function removeParentListener(e:MouseEvent):void
		{
			setUpCursor(e);
			this.parent.removeEventListener(MouseEvent.MOUSE_DOWN, DraggableShape(this.parent).pickup);
			this.addEventListener(MouseEvent.MOUSE_OUT, addParentListener);
		}

		public function addParentListener(e:MouseEvent):void
		{
			this.parent.addEventListener(MouseEvent.MOUSE_DOWN, DraggableShape(this.parent).pickup);
			this.removeEventListener(MouseEvent.MOUSE_OUT, addParentListener);
			this.removeCursor(e);
		}

	}
}