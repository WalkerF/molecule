
package com.aem.molecule.entities.listeners
{
    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;

    import flash.utils.Dictionary;

    /**
     * Contact listener which allows classes to register callbacks for specific
     * collisions.
     *
     * TODO need to break this up so that it supports the other contact events
     *      as they're needed.
     */
    public class CollisionListener extends b2ContactListener
    {

        private var _callbacks:Dictionary = new Dictionary();

        /**
         * Register a callback function for collision with a given object.
         */
        public function register(object:*, callback:Function):void
        {
            var registered:Array = _callbacks[object];
            if (!registered)
                registered = [];
            registered.push(callback);
            _callbacks[object] = registered;
        }

        public override function Persist(point:b2ContactPoint):void
        {
            for each (var callback:Function in _callbacks[point.shape1.GetUserData()])
            {
                callback(point);
            }

            for each (callback in _callbacks[point.shape2.GetUserData()])
            {
                callback(point);
            }
        }
    }
}
