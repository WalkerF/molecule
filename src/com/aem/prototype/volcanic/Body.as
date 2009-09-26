
package com.aem.prototype.volcanic
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.KeyboardEvent;

    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;

    import com.aem.molecule.Game;
    import com.aem.molecule.entities.ActiveEntity;
    import com.aem.molecule.entities.PhysicalEntity;
    import com.aem.molecule.entities.listeners.CollisionListener;
    import com.aem.molecule.view.InputListener;
    import com.aem.molecule.view.InputManager;
    import com.aem.molecule.view.Trackable;

    public class Body extends PhysicalEntity implements ActiveEntity, InputListener, Trackable
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
        private var _player_id:uint;
        private var _thumbnail:MovieClip;

        public function Body():void
        {
            _density = 1;
            _friction = .4;
            _restitution = 0;

            _thumbnail = new BodyThumbnail();

            gotoAndStop("idle");
            _thumbnail.gotoAndStop("idle");

            _sprite = new Sprite();
            _sprite.graphics.beginFill(0xff0000);
            _sprite.graphics.drawRect(-width / 2, -height / 2, width, height);
            addChild(_sprite);
        }

        public function create(game:Game):void
        {
            _player_id = game.input.generatePlayerID();
            game.input.register(_player_id, this);
        }

        public function destroy(game:Game):void
        {
            game.input.unregister(this);
        }

        public function set movement_speed(value:Number):void
        {
            _movement_speed = value;
        }

        public function set jump_speed(value:Number):void
        {
            _jump_speed = value;
        }

        public function update(game:Game):void
        {
            if (_moving)
            {
                var velocity:b2Vec2 = new b2Vec2();
                if (_keysDown[InputManager.LEFT])
                    velocity.Set(-_movement_speed, _body.GetLinearVelocity().y);
                if (_keysDown[InputManager.RIGHT])
                    velocity.Set(_movement_speed, _body.GetLinearVelocity().y);

                _body.WakeUp();
                _body.SetLinearVelocity(velocity);
            }
            _body.m_sweep.a = 0;

            if (_keysDown[InputManager.LEFT] && scaleX < 0)
            {
                scaleX *= -1;
                _thumbnail.scaleX *= -1;
            }
            if (_keysDown[InputManager.RIGHT] && scaleX > 0)
            {
                scaleX *= -1;
                _thumbnail.scaleX *= -1;
            }

            if (!_jumping)
            {
                gotoAndStop("idle");
                _thumbnail.gotoAndStop("idle");
                if (_moving)
                {
                    gotoAndStop("running");
                    _thumbnail.gotoAndStop("running");
                } else if (_keysDown[InputManager.DOWN]) {
                    gotoAndStop("crouching");
                    _thumbnail.gotoAndStop("crouching");
                } else if (_keysDown[InputManager.UP]) {
                    gotoAndStop("peeking");
                    _thumbnail.gotoAndStop("peeking");
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

        public function onKeyPress(e:KeyboardEvent):void
        {
            _keysDown[e.keyCode] = true;

            if (e.keyCode == InputManager.LEFT || e.keyCode == InputManager.RIGHT)
                _moving = true;

            if (e.keyCode == InputManager.PRIMARY && !_jumping)
            {
                gotoAndStop("jumping");
                _thumbnail.gotoAndStop("jumping");
                _jumping = 6;
                _body.ApplyImpulse(new b2Vec2(0, -_jump_speed), _body.GetWorldCenter());
            }
        }

        public function onKeyRelease(e:KeyboardEvent):void
        {
            _keysDown[e.keyCode] = false;

            if (e.keyCode == InputManager.PRIMARY && _body.GetLinearVelocity().y < 0)
                _body.ApplyImpulse(new b2Vec2(0, _jump_speed / 4), _body.GetWorldCenter());

            if (!_keysDown[InputManager.LEFT] && !_keysDown[InputManager.RIGHT])
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
            ground_sensor.userData = "ground_sensor" + name;
            ground_sensor.SetAsOrientedBox(p2m(width / 2), p2m(height / 16), new b2Vec2(0, p2m(height  / 1.8)), 0);
            _body.CreateShape(ground_sensor);

            _body.SetMassFromShapes();

            CollisionListener(world.m_contactListener).register("ground_sensor" + name, onGround);

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

            if (point.shape1.GetUserData() == "ground_sensor" + name ||
                point.shape2.GetUserData() == "ground_sensor" + name)
            {
                if (_jumping)
                    _jumping--;
            }
        }

        public override function toString():String
        {
            return "Player " + _player_id;
        }

        public function getThumbnail():DisplayObject
        {
            return _thumbnail;
        }
    }
}
