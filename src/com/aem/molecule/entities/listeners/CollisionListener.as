
package com.aem.molecule.entities.listeners
{
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Dynamics.*;
    
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

        private var _callbacks_persist:Dictionary = new Dictionary();
        private var _callbacks_add:Dictionary = new Dictionary();
        private var _callbacks_remove:Dictionary = new Dictionary();

        /**
         * Register a callback function for persistent collision with a given object.
         */
        public function registerPersist(object:*, callback:Function):void
        {
            var registered:Array = _callbacks_persist[object];
            if (!registered)
                registered = [];
            registered.push(callback);
            _callbacks_persist[object] = registered;
        }
        
        /**
        * Deletes callback function for persistent collision with a given object.
        */
        public function deletePersist(object:*, callback:Function):void
        {
        	delete _callbacks_persist[object];
        }
        
        /**
         * Register a callback function for a new collision with a given object.
         */
        public function registerAdd(object:*, callback:Function):void
        {
            var registered:Array = _callbacks_add[object];
            if (!registered)
                registered = [];
            registered.push(callback);
            _callbacks_add[object] = registered;
        }
        
        /**
        * Deletes callback function for a new collision with a given object.
        */
        public function deleteAdd(object:*, callback:Function):void
        {
        	delete _callbacks_add[object];
        }
        
        /**
         * Register a callback function for a removed collision with a given object.
         */
        public function registerRemove(object:*, callback:Function):void
        {
            var registered:Array = _callbacks_remove[object];
            if (!registered)
                registered = [];
            registered.push(callback);
            _callbacks_remove[object] = registered;
        }
        
        /**
        * Deletes callback function for a removed collision with a given object.
        */
        public function deleteRemove(object:*, callback:Function):void
        {
        	delete _callbacks_remove[object];
        }
        
        public override function Add(point:b2ContactPoint):void
        {
            for each (var callback:Function in _callbacks_add[point.shape1.GetUserData()])
            {
                callback(point);
            }

            for each (callback in _callbacks_add[point.shape2.GetUserData()])
            {
                callback(point);
            }
        }

        public override function Persist(point:b2ContactPoint):void
        {
            for each (var callback:Function in _callbacks_persist[point.shape1.GetUserData()])
            {
                callback(point);
            }

            for each (callback in _callbacks_persist[point.shape2.GetUserData()])
            {
                callback(point);
            }
        }
        public override function Remove(point:b2ContactPoint):void
        {
            for each (var callback:Function in _callbacks_remove[point.shape1.GetUserData()])
            {
                callback(point);
            }

            for each (callback in _callbacks_remove[point.shape2.GetUserData()])
            {
                callback(point);
            }
        }
    }
}
