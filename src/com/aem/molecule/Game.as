
package com.aem.molecule
{

    import flash.display.Sprite;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import fl.controls.Slider;
    import fl.events.SliderEvent;

    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;

    public class Game extends Sprite
    {
        private static const ITERATIONS:uint = 10;
        private static const TIMESTEP:Number = 1 / 30;
        private static const STARTING_GRAVITY:Number = 30;
        private static const STARTING_SPEED:Number = 7;
        private static const STARTING_JUMP:Number = 15;

        private var _sprite:Sprites;
        private var _sliders:Sliders;
        private var _camera:Camera;

        private var _world:b2World;
        private var _listener:GroundedContactListener;
        private var _subject:b2Body;
        private var _gravity:b2Vec2 = new b2Vec2(0, STARTING_GRAVITY);
        private var _starting_body_size:Number; // in pixels
        private var _movement_speed:Number = STARTING_SPEED;
        private var _jump_speed:Number = STARTING_JUMP;

        public function Game(sprite:Sprites, sliders:Sliders):void
        {
            _camera = new Camera();
            addChild(_camera);

            _sprite = sprite;
            _camera.addChild(_sprite);
            _camera.follow(_sprite._body);

            _sprite.addEventListener(Event.ADDED_TO_STAGE, setup);

            _sliders = sliders;
            _sliders.x = 10;
            _sliders.y = 10;
            addChild(_sliders);
        }

        private function setup(e:Event):void
        {
            _sprite.addEventListener(Event.ENTER_FRAME, update);
            _sprite.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
            _sprite.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

            initWorld();
            initGround();
            initBody();
            initCrates();
            //initDebug();

            _listener = new GroundedContactListener("ground_sensor");
            _world.SetContactListener(_listener);

            setupSliders();
        }

        private function setupSliders():void
        {
            _sliders._sizeSlider.addEventListener(SliderEvent.CHANGE, changeSize);
            _sliders._sizeSlider.focusEnabled = false;

            _sliders._speedSlider.addEventListener(SliderEvent.CHANGE, changeSpeed);
            _sliders._speedSlider.focusEnabled = false;

            _sliders._jumpSlider.addEventListener(SliderEvent.CHANGE, changeJump);
            _sliders._jumpSlider.focusEnabled = false;

            _sliders._gravitySlider.addEventListener(SliderEvent.CHANGE, changeGravity);
            _sliders._gravitySlider.focusEnabled = false;
        }

        private function changeSize(e:SliderEvent):void
        {
            _world.DestroyBody(_subject);
            _subject = createBody(_starting_body_size * (e.value / 6));
            _subject.GetUserData().width = _starting_body_size * (e.value / 6);
            _subject.GetUserData().height = _starting_body_size * (e.value / 6);
        }

        private function changeSpeed(e:SliderEvent):void
        {
            _movement_speed = STARTING_SPEED * (e.value / 6);
        }

        private function changeJump(e:SliderEvent):void
        {
            _jump_speed = STARTING_JUMP * (e.value / 6);
        }

        private function changeGravity(e:SliderEvent):void
        {
            _gravity.y = STARTING_GRAVITY* (e.value / 6);
            _world.SetGravity(_gravity);
        }

        private function createBody(pixels:Number):b2Body
        {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.position.Set(p2m(_sprite._body.x), p2m(_sprite._body.y) );
            bodyDef.userData = _sprite._body;

            var boxDef:b2PolygonDef = new b2PolygonDef();
            boxDef.SetAsBox(p2m(pixels / 2), p2m(pixels / 2));
            boxDef.friction = .3;
            boxDef.density = 1;
            boxDef.restitution = 0;

            var body:b2Body = _world.CreateBody(bodyDef);
            body.CreateShape(boxDef);

            var ground_sensor:b2PolygonDef = new b2PolygonDef();
            ground_sensor.isSensor = true;
            ground_sensor.userData = "ground_sensor";
            ground_sensor.SetAsOrientedBox(p2m(pixels / 2), p2m(pixels / 16), new b2Vec2(0, p2m(pixels / 1.8)), 0);
            body.CreateShape(ground_sensor);

            body.SetMassFromShapes();

            return body;
        }

        private function initDebug():void
        {
            var debug:Sprite = new Sprite();
            _sprite.addChild(debug);

            var debugDraw:b2DebugDraw = new b2DebugDraw();
            debugDraw.m_drawScale = 30;
            debugDraw.m_sprite = debug;
            debugDraw.m_fillAlpha = .6;
            debugDraw.m_lineThickness = 1.0;
            debugDraw.m_drawFlags = b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit;

            _world.SetDebugDraw(debugDraw);

        }

        private function initWorld():void
        {
            var worldAABB:b2AABB = new b2AABB();
            worldAABB.lowerBound.Set(-300, -200);
            worldAABB.upperBound.Set(300, 200);

            _world = new b2World(worldAABB, _gravity, true);
        }

        private function p2m(pixels:Number):Number
        {
            return pixels / 30;
        }

        private function m2p(meters:Number):Number
        {
            return meters * 30;
        }

        private function initGround():void
        {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.position.Set(p2m(_sprite._ground.x), p2m(_sprite._ground.y) );
            bodyDef.userData = _sprite._ground;

            var boxDef:b2PolygonDef = new b2PolygonDef();
            boxDef.SetAsBox(p2m(_sprite._ground.width / 2), p2m(_sprite._ground.height / 2));
            boxDef.friction = .4;
            boxDef.density = 0;

            var body:b2Body = _world.CreateBody(bodyDef);
            body.CreateShape(boxDef);
            body.SetMassFromShapes();
        }

        private function initBody():void
        {
            _starting_body_size = _sprite._body.width;

            _subject = createBody(_sprite._body.width);
        }

        private function initCrates():void
        {
            for (var i:uint = 0; i < _sprite.numChildren; i++) {
                if (_sprite.getChildAt(i).name != "_body" &&
                        _sprite.getChildAt(i).name != "_ground")
                    initCrate(_sprite.getChildAt(i));
            }
        }

        private function initCrate(crate:DisplayObject):void
        {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.position.Set(p2m(crate.x), p2m(crate.y) );
            bodyDef.userData = crate;

            var boxDef:b2PolygonDef = new b2PolygonDef();
            boxDef.SetAsBox(p2m(crate.width / 2), p2m(crate.height / 2));
            boxDef.friction = .3;
            boxDef.density = 2;
            boxDef.restitution = 0;

            var body:b2Body = _world.CreateBody(bodyDef);
            body.CreateShape(boxDef);
            body.SetMassFromShapes();
        }

        private function update(e:Event):void
        {
            _world.Step(TIMESTEP, ITERATIONS);

            for (var body:b2Body = _world.m_bodyList; body; body = body.m_next)
            {
                if (body.m_userData is Sprite)
                {
                    body.m_userData.x = m2p(body.GetPosition().x);
                    body.m_userData.y = m2p(body.GetPosition().y);
                    body.m_userData.rotation = body.GetAngle() * (180 / Math.PI);
                }
            }

            if (moving)
            {
                var velocity:b2Vec2 = new b2Vec2();
                if (keysDown[Keyboard.LEFT])
                    velocity.Set(-_movement_speed, _subject.GetLinearVelocity().y);
                if (keysDown[Keyboard.RIGHT])
                    velocity.Set(_movement_speed, _subject.GetLinearVelocity().y);

                _subject.WakeUp();
                _subject.SetLinearVelocity(velocity);
            }
            _subject.m_sweep.a = 0;

            _camera.update();
        }

        private var moving:Boolean;
        private var keysDown:Array = [];

        private function onKeyPress(e:KeyboardEvent):void
        {
            keysDown[e.keyCode] = true;

            if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.RIGHT)
                moving = true;

            if (e.keyCode == Keyboard.SPACE && _listener.grounded)
            {
                _listener.grounded = false;
                _subject.WakeUp();
                _subject.ApplyImpulse(new b2Vec2(0, -_jump_speed), _subject.GetWorldCenter());
            }
        }

        private function onKeyRelease(e:KeyboardEvent):void
        {
            keysDown[e.keyCode] = false;

            if (e.keyCode == Keyboard.SPACE)
            {
                _subject.ApplyImpulse(new b2Vec2(0, _jump_speed / 2), _subject.GetWorldCenter());
            }

            if (!keysDown[Keyboard.LEFT] && !keysDown[Keyboard.RIGHT])
            {
                moving = false;
                _subject.SetLinearVelocity(new b2Vec2(0, _subject.GetLinearVelocity().y));
            }

        }
    }
}
