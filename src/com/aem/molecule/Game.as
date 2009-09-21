
package com.aem.molecule
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    public class Game extends Sprite
    {
        private static const RESTART_KEY:uint = 82;

        private var _level:Level;

        public function Game():void
        {
            addEventListener(Event.ADDED_TO_STAGE, setup);
        }

        private function restart():void
        {
            var sprites:Sprites = new Sprites();
            var sliders:Sliders = new Sliders();

            if (_level)
                removeChild(_level);
            _level = new Level(sprites, sliders);
            addChild(_level);
        }

        private function setup(e:Event):void
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
            restart();
        }

        private function onKeyPress(e:KeyboardEvent):void
        {
            if (e.keyCode == RESTART_KEY)
                restart();
        }

    }
}
