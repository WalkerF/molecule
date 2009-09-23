
package com.aem.prototype.volcanic
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;

    import com.aem.molecule.entities.ActiveEntity;
    import com.aem.molecule.entities.PhysicalEntity;
    import com.aem.molecule.entities.listeners.CollisionListener;

    public class Body extends PhysicalEntity implements ActiveEntity
    {

        public static const LANDED_IN_LAVA:String = "landedInLava";

        private var _body:b2Body;
        private var _movement_speed:Number;
        private var _jump_speed:Number;
        private var _moving:Boolean;
        private var _jumping:uint;
        private var _burning:Boolean;
        private var _keysDown:Array = [];
        private var _temp:Number = 0;
        private var _sprite:Sprite;

        public function Body():void
        {
            _density = 1;
            _friction = .4;
            _restitution = 0;

            gotoAndStop("idle");

            addEventListener(Event.ADDED_TO_STAGE, setup);
            addEventListener(Event.REMOVED_FROM_STAGE, teardown);

            _sprite = new Sprite();
            _sprite.graphics.beginFill(0xff0000);
            _sprite.graphics.drawRect(-width / 2, -height / 2, width, height);
            addChild(_sprite);
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

            if (!_jumping)
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
            if (_burning)
            {
                _temp++;
                if (_temp > 15)
                    dispatchEvent(new Event(LANDED_IN_LAVA));
            } else {
                if (_temp > 0)
                    _temp -= .4;
                else
                    _temp = 0;
            }
            _burning = false;
            _sprite.alpha = _temp / 25;
        }

        private function onKeyPress(e:KeyboardEvent):void
        {
            _keysDown[e.keyCode] = true;

            if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.RIGHT)
                _moving = true;

            if (e.keyCode == Keyboard.SPACE && !_jumping)
            {
                gotoAndStop("jumping");
                _jumping = 6;
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

            CollisionListener(world.m_contactListener).register("ground_sensor", onGround);

            return _body;
        }

        private function onGround(point:b2ContactPoint):void
        {
            if (point.shape1.GetUserData() == "lava" ||
                point.shape2.GetUserData() == "lava")
            {
                _burning = true;
                return; // stop evaluating the event
            }

            if (point.shape1.GetUserData() == "ground_sensor" ||
                point.shape2.GetUserData() == "ground_sensor")
            {
                if (_jumping)
                    _jumping--;
            }
        }
    }
}
