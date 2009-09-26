
package com.aem.prototype.volcanic
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import com.aem.molecule.Game;
    import com.aem.molecule.states.GameState;
    import com.aem.molecule.view.Camera;

    public class InGameState implements GameState
    {
        private static const RESTART_KEY:uint = 82;

        private var _game:Game;
        private var _level:Level;

        public function getID():uint
        {
            return 1;
        }

        public function enter(fromState:uint):void
        {
            _game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
            restart();
        }

        public function exit(toState:uint):void
        {
            _game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
        }

        public function init(game:Game):void
        {
            _game = game;
            _game.camera.add(new Background(), Camera.BACKGROUND);
            _game.camera.add(new Foreground(), Camera.FOREGROUND);
        }

        public function update(game:Game):void
        {
            _level.update();
        }

        private function restart(e:Event = null):void
        {
            var sprites:Sprites = new Sprites();

            if (_level)
            {
                _level.removeEventListener(Level.GAME_OVER, restart);
                _level.destroy();
                _game.camera.remove(_level);
            }
            _level = new Level(sprites);
            _level.init(_game);
            _level.addEventListener(Level.GAME_OVER, restart);
            _game.camera.add(_level);
        }

        private function onKeyPress(e:KeyboardEvent):void
        {
            if (e.keyCode == RESTART_KEY)
                restart();
        }
    }
}
