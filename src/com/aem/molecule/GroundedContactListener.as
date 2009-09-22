
package com.aem.molecule
{
    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;

    import flash.display.Sprite;

    public class GroundedContactListener extends b2ContactListener
    {
        private var _subject:String;
        private var _grounded:Boolean;
        private var _burned:Boolean;
        private var _counter:uint;

        public function GroundedContactListener(subject:String):void
        {
            _subject = subject;
        }

        public function get grounded():Boolean
        {
            return _grounded;
        }

        public function set grounded(value:Boolean):void
        {
            _grounded = value;
            if (!value)
                _counter = 8;
        }

        public function get burned():Boolean
        {
            return _burned;
        }

        public function set burned(value:Boolean):void
        {
            _burned = value;
        }

        public override function Persist(point:b2ContactPoint):void
        {
            if (_counter)
            {
                _counter--;
                return;
            }

            if (point.shape1.GetUserData() == _subject && 
                point.shape2.GetUserData() != "lava")
                grounded = true;
            if (point.shape2.GetUserData() == _subject &&
                point.shape2.GetUserData() != "lava")
                grounded = true;

            if (point.shape1.GetUserData() == "lava" && 
                point.shape2.GetUserData() == _subject)
            {
                burned = true;
            }
            if (point.shape1.GetUserData() == _subject && 
                point.shape2.GetUserData() == "lava")
            {
                burned = true;
            }
        }

    }
}
