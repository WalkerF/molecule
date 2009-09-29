package com.aem.prototype.towertussles
{
	public class DraggableThinRectangle extends DraggableShape
	{
		public function DraggableThinRectangle():void
		{
			this.dispatchEventString = Level.SUBMIT_THIN_RECTANGLE;
		}

	}
}