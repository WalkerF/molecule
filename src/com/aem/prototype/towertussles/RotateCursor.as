package com.aem.prototype.towertussles
{
	import com.aem.molecule.view.Camera;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	public class RotateCursor extends MovieClip
	{
		private var translatedToGlobal:Boolean=false;
		public var camera:Camera;

		public function RotateCursor()
		{
			this.visible=false;
		}

		public function overRotateSpot(e:MouseEvent):void
		{
			this.parent.addChild(this);
			Mouse.hide();
			mouseEnabled=false;
			mouseChildren=false;
			this.x=stage.mouseX;
			this.y=stage.mouseY;
			startDrag();
			this.visible=true;
		}
		
		public function offRotateSpot(e:MouseEvent):void
		{
			stopDrag();
			Mouse.show();
			mouseEnabled = true;
			mouseChildren = true;		
			this.visible = false;
		}

	}
}