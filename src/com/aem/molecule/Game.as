
package com.aem.molecule
{

    import flash.events.Event;
    import flash.display.Sprite;

    import com.aem.molecule.states.GameState;
    import com.aem.molecule.view.Camera;

    public class Game extends Sprite
    {

        private var _camera:Camera;
        private var _states:Array;
        private var _current_state:GameState;

        public function Game():void
        {
            addEventListener(Event.ENTER_FRAME, update);
            _states = [];
            _camera = new Camera();
        }

        public function init():void
        {
            for each (var state:GameState in _states)
            {
                state.init(this);
            }

            _current_state.enter(0);
            addChild(_camera);
        }

        private function update(e:Event):void
        {
            _current_state.update(this);
            _camera.update();
        }

        public function get camera():Camera
        {
            return _camera;
        }

        public function add(state:GameState):void
        {
            _states[state.getID()] = state;
            if (_current_state == null)
                _current_state = state;
        }

        public function enter(state:uint):void
        {
            var past_state:GameState = _current_state;
            _current_state = _states[state];
            past_state.exit(state);
            _current_state.enter(past_state.getID());
        }
    }
}
