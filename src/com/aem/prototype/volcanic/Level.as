
package com.aem.prototype.volcanic
{
    import flash.display.Sprite;
    import flash.display.DisplayObject;
    import flash.events.Event;

    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;

    import com.aem.molecule.Game;
    import com.aem.molecule.entities.ActiveEntity;
    import com.aem.molecule.entities.PhysicalEntity;
    import com.aem.molecule.entities.listeners.BoundarySweeper;
    import com.aem.molecule.entities.listeners.CollisionListener;

    public class Level extends Sprite
    {
        public static const GAME_OVER:String = "gameOver";

        private static const ITERATIONS:uint = 10;
        private static const TIMESTEP:Number = 1 / 30;
        private static const STARTING_GRAVITY:Number = 30;
        private static const STARTING_SPEED:Number = 7;
        private static const STARTING_JUMP:Number = 15;

        private var _game:Game;
        private var _sprite:Sprites;

        private var _world:b2World;
        private var _boundarySweeper:BoundarySweeper;
        private var _collisionListener:CollisionListener;
        private var _subject:b2Body;
        private var _gravity:b2Vec2 = new b2Vec2(0, STARTING_GRAVITY);
        private var _starting_body_size:Number; // in pixels

        private var _game_over:Boolean;

        public function Level(sprite:Sprites):void
        {
            _sprite = sprite;
            addChild(_sprite);
        }

        public function init(game:Game):void
        {
            _game = game;

            initWorld();
            initBodies();
            //initDebug();
        }

        public function destroy():void
        {
            destroyBodies();
            destroyWorld();
        }

        private function createBody(body:Body):b2Body
        {
            return body.init(_world);
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

            _boundarySweeper = new BoundarySweeper();
            _world.SetBoundaryListener(_boundarySweeper);

            _collisionListener = new CollisionListener();
            _world.SetContactListener(_collisionListener);
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

                if (child is ActiveEntity)
                {
                    ActiveEntity(child).create(_game);
                }
            }
        }

        private function initBody(body:Body):void
        {
            _starting_body_size = body.width;

            _subject = createBody(body);
            body.movement_speed = STARTING_SPEED;
            body.jump_speed = STARTING_JUMP;
            body.addEventListener(Body.LANDED_IN_LAVA, gameOver);

            _game.camera.follow(body);
        }

        public function update():void
        {
            _world.Step(TIMESTEP, ITERATIONS);

            for (var body:b2Body = _world.m_bodyList; body; body = body.m_next)
            {
                if (body.GetUserData() is Sprite)
                {
                    body.GetUserData().x = m2p(body.GetPosition().x);
                    body.GetUserData().y = m2p(body.GetPosition().y);
                    body.GetUserData().rotation = body.GetAngle() * (180 / Math.PI);
                }
                if (body.GetUserData() is ActiveEntity)
                {
                    ActiveEntity(body.GetUserData()).update(_game);
                }
            }

            //_camera.update();

            for each (var outOfBoundsBody:b2Body in _boundarySweeper.bodies)
            {
                _sprite.removeChild(outOfBoundsBody.GetUserData());
                outOfBoundsBody.SetUserData(null);
                _world.DestroyBody(outOfBoundsBody);
            }
            _boundarySweeper.clear();

            if (_game_over)
                dispatchEvent(new Event(GAME_OVER));
        }

        private function destroyBodies():void
        {
            _subject.GetUserData().removeEventListener(Body.LANDED_IN_LAVA, gameOver);
            for (var body:b2Body = _world.m_bodyList; body; body = body.m_next)
            {
                if (body.GetUserData() is ActiveEntity)
                {
                    _game.camera.unfollow(body.GetUserData());
                    ActiveEntity(body.GetUserData()).destroy(_game);
                }

                body.SetUserData(null);
                _world.DestroyBody(body);
            }
        }

        private function destroyWorld():void
        {
            _world.SetContactListener(null); // TODO move this to Body
            _world.SetBoundaryListener(null);
            _world = null;
        }

        private function gameOver(e:Event):void
        {
            _game_over = true;
        }

    }
}
