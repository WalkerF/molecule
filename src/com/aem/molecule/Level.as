
package com.aem.molecule
{
    import flash.display.Sprite;
    import flash.display.DisplayObject;
    import flash.events.Event;

    import fl.controls.Slider;
    import fl.events.SliderEvent;

    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;

    public class Level extends Sprite
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
        private var _listener:BoundarySweeper;
        private var _subject:b2Body;
        private var _gravity:b2Vec2 = new b2Vec2(0, STARTING_GRAVITY);
        private var _starting_body_size:Number; // in pixels

        public function Level(sprite:Sprites, sliders:Sliders):void
        {
            _camera = new Camera();
            addChild(_camera);

            _sprite = sprite;
            _camera.addChild(_sprite);
            _camera.follow(_sprite._body);

            addEventListener(Event.ADDED_TO_STAGE, setup);
            addEventListener(Event.REMOVED_FROM_STAGE, teardown);

            _sliders = sliders;
            _sliders.x = 10;
            _sliders.y = 10;
            addChild(_sliders);
        }

        private function setup(e:Event):void
        {
            addEventListener(Event.ENTER_FRAME, update);

            initWorld();
            initBodies();
            //initDebug();

            setupSliders();
        }

        private function teardown(e:Event):void
        {
            removeEventListener(Event.ENTER_FRAME, update);

            destroyBodies();
            destroyWorld();

            destroySliders();
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
            trace(e.value / 6);
            _subject.GetUserData().width  = _starting_body_size * (e.value / 6);
            _subject.GetUserData().height = _starting_body_size * (e.value / 6);
            _subject = createBody(_starting_body_size * (e.value / 6));
        }

        private function changeSpeed(e:SliderEvent):void
        {
            _subject.GetUserData().movement_speed = STARTING_SPEED * (e.value / 6);
        }

        private function changeJump(e:SliderEvent):void
        {
            _subject.GetUserData().jump_speed = STARTING_JUMP * (e.value / 6);
        }

        private function changeGravity(e:SliderEvent):void
        {
            _gravity.y = STARTING_GRAVITY* (e.value / 6);
            _world.SetGravity(_gravity);
        }

        private function createBody(pixels:Number):b2Body
        {
            return _sprite._body.init(_world);
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

            _listener = new BoundarySweeper();
            _world.SetBoundaryListener(_listener);
        }

        private function m2p(meters:Number):Number
        {
            return meters * 30;
        }

        private function initBodies():void
        {
            for (var i:uint = 0; i < _sprite.numChildren; i++) 
            {
                var child:DisplayObject = _sprite.getChildAt(i);
                if (child is Body)
                    initBody(Body(child));
                else if (child is PhysicalEntity)
                    PhysicalEntity(child).init(_world);
            }
        }

        private function initBody(body:Body):void
        {
            _starting_body_size = body.width;

            _subject = createBody(body.width);
            body.movement_speed = STARTING_SPEED;
            body.jump_speed = STARTING_JUMP;
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
                if (body.m_userData is ActiveEntity)
                {
                    ActiveEntity(body.m_userData).update();
                }
            }

            _camera.update();

            for each (var outOfBoundsBody:b2Body in _listener.bodies)
            {
                _sprite.removeChild(outOfBoundsBody.GetUserData());
                outOfBoundsBody.SetUserData(null);
                _world.DestroyBody(outOfBoundsBody);
            }
            _listener.clear();
        }

        private function destroyBodies():void
        {
            for (var body:b2Body = _world.m_bodyList; body; body = body.m_next)
            {
                body.m_userData = null;
                _world.DestroyBody(body);
            }
        }

        private function destroyWorld():void
        {
            _world.SetContactListener(null); // TODO move this to Body
            _world.SetBoundaryListener(null);
            _world = null;
        }

        private function destroySliders():void
        {
            _sliders._sizeSlider.removeEventListener(SliderEvent.CHANGE, changeSize);
            _sliders._speedSlider.removeEventListener(SliderEvent.CHANGE, changeSpeed);
            _sliders._jumpSlider.removeEventListener(SliderEvent.CHANGE, changeJump);
            _sliders._gravitySlider.removeEventListener(SliderEvent.CHANGE, changeGravity);
        }
    }
}
