package com.aem.prototype.towertussles
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	public class ThumbTack extends MovieClip
	{
		public var m_prev:ThumbTack;
		public var m_next:ThumbTack;
		public var m_DraggableShape:DraggableShape;
		public function ThumbTack()
		{
			addEventListener(MouseEvent.MOUSE_DOWN, createDraggable)
		}
		
		public function createDraggable(e:MouseEvent):void
		{
			//var p:Point = new Point(e.stageX,e.stageY);
			//p = m_DraggableShape.globalToLocal(p);
			m_DraggableShape.x = this.x;
			m_DraggableShape.y = this.y;
			dispatchEvent(new Event(Level.CREATE_DRAGGABLE));
		}

	}
}