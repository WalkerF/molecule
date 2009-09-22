
package com.aem.molecule
{
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;

    public class Body extends PhysicalEntity implements ActiveEntity
    {

        private var _listener:GroundedContactListener;
        private var _body:b2Body;
        private var _movement_speed:Number;
        private var _jump_speed:Number;
        private var _moving:Boolean;
        private var _keysDown:Array = [];


        public function Body():void
        {
            _density = 1;
            _friction = .4;
            _restitution = 0;

            gotoAndStop("idle");

            addEventListener(Event.ADDED_TO_STAGE, setup);
            addEventListener(Event.REMOVED_FROM_STAGE, teardown);
        }

        public function set movement_speed(value:Number):void
        {
            _movement_speed = value;
        }

        public function set jump_speed(value:Number):void
        {
            _jump_speed = value;
        }

        private function setup(e:Event):void
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
        }

        private function teardown(e:Event):void
        {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
            stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
        }

        public function update():void
        {
            if (_moving)
            {
                var velocity:b2Vec2 = new b2Vec2();
                if (_keysDown[Keyboard.LEFT])
                    velocity.Set(-_movement_speed, _body.GetLinearVelocity().y);
                if (_keysDown[Keyboard.RIGHT])
                    velocity.Set(_movement_speed, _body.GetLinearVelocity().y);

                _body.WakeUp();
                _body.SetLinearVelocity(velocity);
            }
            _body.m_sweep.a = 0;

            if (_keysDown[Keyboard.LEFT] && scaleX < 0)
                scaleX *= -1;
            if (_keysDown[Keyboard.RIGHT] && scaleX > 0)
                scaleX *= -1;

            if (_listener.grounded)
            {
                gotoAndStop("idle");
                if (_moving)
                {
                    gotoAndStop("running");
                } else if (_keysDown[Keyboard.DOWN]) {
                    gotoAndStop("crouching");
                } else if (_keysDown[Keyboard.UP]) {
                    gotoAndStop("peeking");
                }
            }
        }

        private function onKeyPress(e:KeyboardEvent):void
        {
            _keysDown[e.keyCode] = true;

            if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.RIGHT)
                _moving = true;

            if (e.keyCode == Keyboard.SPACE && _listener.grounded)
            {
                gotoAndStop("jumping");
                _listener.grounded = false;
                _body.ApplyImpulse(new b2Vec2(0, -_jump_speed), _body.GetWorldCenter());
            }
        }

        private function onKeyRelease(e:KeyboardEvent):void
        {
            _keysDown[e.keyCode] = false;

            if (e.keyCode == Keyboard.SPACE && _body.GetLinearVelocity().y < 0)
                _body.ApplyImpulse(new b2Vec2(0, _jump_speed / 4), _body.GetWorldCenter());

            if (!_keysDown[Keyboard.LEFT] && !_keysDown[Keyboard.RIGHT])
            {
                _moving = false;
                _body.SetLinearVelocity(new b2Vec2(0, _body.GetLinearVelocity().y));
            }

        }

        public override function init(world:b2World):b2Body
        {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.position.Set(p2m(x), p2m(y) );
            bodyDef.userData = this;

            var boxDef:b2PolygonDef = new b2PolygonDef();
            boxDef.SetAsBox(p2m(width / 2), p2m(height / 2));
            boxDef.friction = friction;
            boxDef.density = density;
            boxDef.restitution = restitution;

            _body = world.CreateBody(bodyDef);
            _body.CreateShape(boxDef);

            var ground_sensor:b2PolygonDef = new b2PolygonDef();
            ground_sensor.isSensor = true;
            ground_sensor.userData = "ground_sensor";
            ground_sensor.SetAsOrientedBox(p2m(width / 2), p2m(height / 16), new b2Vec2(0, p2m(height  / 1.8)), 0);
            _body.CreateShape(ground_sensor);

            _body.SetMassFromShapes();

            _listener = new GroundedContactListener("ground_sensor");
            world.SetContactListener(_listener);

            return _body;
        }
    }
}
