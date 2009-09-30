package com.aem.prototype.towertussles
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	public class ThumbTack extends MovieClip
	{
		public function ThumbTack()
		{
			addEventListener(MouseEvent.MOUSE_DOWN, setupDraggable)
		}
		
		public function setupDraggable(e:MouseEvent):void
		{
			dispatchEvent(new Event(Level.CREATE_DRAGGABLE));
		}

	}
}