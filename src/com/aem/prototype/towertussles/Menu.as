package com.aem.prototype.towertussles
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Menu extends MovieClip
	{
		public var m_current:ThumbTack;
		private var m_counter:Number;
		private var m_thumbTackCount:Number;
		public static const THUMB_TACK_MAX:Number=10;
		public static const THUMB_TACK_INTENDED_WIDTH:Number=36;

		public function Menu()
		{
			m_counter=0;
			m_thumbTackCount=0;
		}

		public function update():void
		{
			if (m_thumbTackCount < THUMB_TACK_MAX)
			{
				m_counter++;
				if (m_counter > 150)
				{
					addThumbTack(chooseThumbTack());
					m_counter=0;
				}
			}
			var l_tack:ThumbTack=m_current;
			var l_loc:Number=m_thumbTackCount;
			var l_tackleftside:Number;
			var l_tackend:Number;
			while (l_tack != null)
			{
				l_tackleftside=l_tack.x - THUMB_TACK_INTENDED_WIDTH / 2;
				l_tackend=this.x - this.width / 2 + (THUMB_TACK_INTENDED_WIDTH + 2) * l_loc;
				if (l_tackleftside > l_tackend)
					l_tack.x--;
				l_tack=l_tack.m_next;
				l_loc--;
			}
		}

		private function chooseThumbTack():ThumbTack
		{
			var l_tack:ThumbTack;
			if (Math.random() < .5)
			{
				l_tack=new BoxThumbTack();
				l_tack.m_DraggableShape=new Box();
			}
			else
			{
				l_tack=new ThinRectangleThumbTack();
				l_tack.m_DraggableShape=new ThinRectangle();
			}
			return l_tack;
		}

		public function addThumbTack(l_tack:ThumbTack):void
		{
			m_thumbTackCount++;
			l_tack.x=this.x + this.width / 2 - l_tack.width;
			l_tack.y=this.y + this.height / 2 - l_tack.height;
			addThumbTackPointers(l_tack);
			dispatchEvent(new Event(Level.CREATE_THUMB_TACK));
		}

		private function addThumbTackPointers(tack:ThumbTack):void
		{
			tack.m_prev=null;
			tack.m_next=m_current;
			if (m_current)
			{
				m_current.m_prev=tack;
			}
			m_current=tack;
		}

		public function removeThumbTack(tack:ThumbTack):void
		{
			tack.removeEventListener(MouseEvent.MOUSE_DOWN, tack.createDraggable);
			if (tack.m_prev)
				tack.m_prev.m_next=tack.m_next;
			if (tack.m_next)
				tack.m_next.m_prev=tack.m_prev;
			if (tack == m_current)
				m_current=tack.m_next;
			m_thumbTackCount--;
		}

	}
}