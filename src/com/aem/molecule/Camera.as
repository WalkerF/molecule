
package com.aem.molecule
{

    import flash.display.Sprite;

    public class Camera extends Sprite
    {

        private var _target:Sprite;

        public function follow(target:Sprite):void
        {
            _target = target;
        }

        public function update():void
        {
            this.x = (stage.stageWidth / 2) - _target.x;
            this.y = ((stage.stageHeight / 2) + 50) - _target.y;
        }

    }
}
