
package com.aem.molecule.view
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;

	public class Camera extends Sprite
	{

		private var _targets:Array=[];

		public function follow(target:Sprite):void
		{
			_targets.push(target);
		}

		public function update():void
		{
			var center:Point=new Point();
			for each (var sprite:DisplayObject in _targets)
			{
				center.x+=sprite.x;
				center.y+=sprite.y;
			}

			center.x/=_targets.length;
			center.y/=_targets.length;

			this.x=(stage.stageWidth / 2) - center.x;
			this.y=((stage.stageHeight / 2) + 50) - center.y;
		}

	}
}
