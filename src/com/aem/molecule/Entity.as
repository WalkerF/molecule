package com.aem.molecule
{
    import Box2D.Dynamics.*;
    import Box2D.Collision.*;

    import flash.display.MovieClip;

    public class Entity extends MovieClip 
    {

        protected var _density:Number;
        protected var _friction:Number;
        protected var _restitution:Number;

        public function get density():Number
        {
            return _density;
        }

        public function get friction():Number
        {
            return _friction;
        }

        public function get restitution():Number
        {
            return _restitution;
        }

        public function init(world:b2World):b2Body
        {
            throw new Error("Method not overridden.");
        }

        protected function p2m(pixels:Number):Number
        {
            return pixels / 30;
        }

    }
}
