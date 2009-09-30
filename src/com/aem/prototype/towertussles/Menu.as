package com.aem.prototype.towertussles
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Menu extends MovieClip
	{
		public function Menu()
		{
		}
		
		public function init():void
		{
			dispatchEvent(new Event(Level.CREATE_THUMB_TACK));
		}

	}
}