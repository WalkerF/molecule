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
			this.buttonMode = false;
			addEventListener(MouseEvent.MOUSE_DOWN, initiateRotate);
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

		public function initiateRotate(e:MouseEvent):void
		{
			offset = getAngle(e) - this.parent.rotation;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, rotate);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopRotate);
		}

		public function stopRotate(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, rotate);
		}

		public function getAngle(e:MouseEvent):Number
		{			
			var p:Point = new Point(this.parent.x, this.parent.y);
            p = localToGlobal(p);
            return Math.atan2(e.stageY - p.y, e.stageX - p.x) * 180 / Math.PI;
		}

		public function rotate(e:MouseEvent):void
		{
			var newTheta:Number =getAngle(e);
			this.parent.rotation = newTheta - offset;
			e.updateAfterEvent();
		}

	}
}