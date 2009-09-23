
package com.aem.molecule.entities.listeners
{
    import Box2D.Dynamics.*;

    public class BoundarySweeper extends b2BoundaryListener
    {

        private var _bodies:Array = [];

        public function get bodies():Array
        {
            return _bodies;
        }

        public function clear():void
        {
            _bodies = [];
        }

        public override function Violation(body:b2Body):void
        {
            _bodies.push(body);
        }
    }
}
