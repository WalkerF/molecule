
package com.aem.molecule.view
{

    import flash.display.Stage;
    import flash.events.EventDispatcher;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    /**
     * Abstracts user input allowing a consumer to register for input events.
     *
     *   1) Allows you to easily configure which keys do what on the fly
     *   2) Manages multiple input sources so that multiple players can play
     */
    public class InputManager extends EventDispatcher
    {
        // player configurations
        public static const PLAYER_ONE:uint = 0;
        public static const PLAYER_TWO:uint = 1;
        public static const PLAYER_THREE:uint = 2;
        public static const PLAYER_FOUR:uint = 3;

        // movement keys
        public static const LEFT:uint = 1;
        public static const RIGHT:uint = 2;
        public static const UP:uint = 3;
        public static const DOWN:uint = 4;

        // action keys
        public static const PRIMARY:uint = 5;
        public static const SECONDARY:uint = 6;

        // option keys
        public static const SELECT:uint = 7;
        public static const CANCEL:uint = 8;

        // key mappings
        private static const PLAYER_ONE_KEYS:Object = {
            LEFT: 74, // j
            RIGHT: 76, // l
            UP: 72, // h
            DOWN: 75, // k
            PRIMARY: 73, // i
            SECONDARY: 78, // n
            SELECT: Keyboard.ENTER,
            CANCEL: Keyboard.BACKSPACE // delete/backscape
        };

        private static const PLAYER_TWO_KEYS:Object = {
            LEFT: 65, // a
            RIGHT:  68, // d
            UP: 70, // f
            DOWN: 83, // s
            PRIMARY: 87, // w
            SECONDARY: 67, // c
            SELECT: Keyboard.CAPS_LOCK, // caps lock
            CANCEL: Keyboard.ESCAPE// escape
        };

        // define the number of possible players and their keyboard controls
        // should start at player one and move forward one at a time
        private static const PLAYER_PROFILES:Array =
        [
            PLAYER_ONE_KEYS,
            PLAYER_TWO_KEYS
        ];

        private static const META_KEYS:Object = {
            LEFT: LEFT,
            RIGHT: RIGHT,
            UP: UP,
            DOWN: DOWN,
            PRIMARY: PRIMARY,
            SECONDARY: SECONDARY,
            SELECT: SELECT,
            CANCEL: CANCEL
        };

        private var _currentPlayerID:uint = 0;
        private var _players:Array = [];

        public function generatePlayerID():uint
        {
            for (var i:uint = 0; i < PLAYER_PROFILES.length; i++)
            {
                if (_players.length < i || _players[i] == null)
                    return i;
            }
            throw new Error("Failed to generate player id.");
        }

        public function register(player:uint, listener:InputListener):void
        {
            if (player >= PLAYER_PROFILES.length)
                throw new Error("Invalid player. No profile found for player " + player);

            _players[player] = listener;
        }

        public function unregister(listener:InputListener):void
        {
            for (var i:uint = 0; i < _players.length; i++) {
                if (_players[i] == listener)
                {
                    _players[i] = null;
                    break;
                }
            }
        }

        private function onKeyPress(e:KeyboardEvent):void
        {
            for (var i:uint = 0; i < PLAYER_PROFILES.length; i++) {
                var player:Object = PLAYER_PROFILES[i];
                for (var key:String in player)
                {
                    if (e.keyCode == player[key])
                    {
                        e.keyCode = META_KEYS[key];
                        _players[i].onKeyPress(e);
                        return;
                    }
                }
            }
        }

        private function onKeyRelease(e:KeyboardEvent):void
        {
            for (var i:uint = 0; i < PLAYER_PROFILES.length; i++) {
                var player:Object = PLAYER_PROFILES[i];
                for (var key:String in player)
                {
                    if (e.keyCode == player[key])
                    {
                        e.keyCode = META_KEYS[key];
                        _players[i].onKeyRelease(e);
                        return;
                    }
                }
            }
        }

        public function init(stage:Stage):void
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
        }
    }
}
