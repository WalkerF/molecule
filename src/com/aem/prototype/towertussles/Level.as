
package com.aem.prototype.towertussles
{
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	
	import com.aem.molecule.Game;
	import com.aem.molecule.entities.ActiveEntity;
	import com.aem.molecule.entities.PhysicalEntity;
	import com.aem.molecule.entities.listeners.BoundarySweeper;
	import com.aem.molecule.entities.listeners.CollisionListener;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;

    public class Level extends Sprite
    {
    	public static const GAME_OVER:String = "gameOver";
        private static const ITERATIONS:uint = 10;
        private static const TIMESTEP:Number = 1 / 30;
        private static const STARTING_GRAVITY:Number = 30;
        
        private var _sprite:TowerSprites;
        private var _added_to_stage:Boolean;
        private var _game_over:Boolean;
        private var _boundarySweeper:BoundarySweeper;
        private var _collisionListener:CollisionListener;
        private var _gravity:b2Vec2 = new b2Vec2(0, STARTING_GRAVITY);
        private var _game:Game;
        private var _draggableBox:DraggableBox;

        private var _world:b2World;
        
        public function Level(sprite:TowerSprites):void
        { 
            _sprite = sprite;
            addChild(_sprite);
            addChild(new DraggableBox());
        }
        
        public function init(game:Game):void
        {
        	_game = game;
            if (_added_to_stage)
                return;

            _added_to_stage = true;


            initWorld();
            initBodies();
           initDebug();
        }

        public function destroy():void
        {
            destroyBodies();
            destroyWorld();
        }
        
         private function createBody(pixels:Number):b2Body
        {
            return _sprite._body.init(_world);
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
        
        private function initBodies():void
        {
            for (var i:uint = 0; i < _sprite.numChildren; i++) 
            {
                var child:DisplayObject = _sprite.getChildAt(i);
                if (child is PhysicalEntity)
                    PhysicalEntity(child).init(_world);
                else if(child is DraggableBox)
                {
                	DraggableBox(child).init(_world,_game);
                	_draggableBox = DraggableBox(child); 
                }  
            }
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
        
        private function m2p(meters:Number):Number
        {
            return meters * 30;
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
                if (body.GetUserData() is MovieClip)
                {
                    body.GetUserData().x = m2p(body.GetPosition().x);
                    body.GetUserData().y = m2p(body.GetPosition().y);
                    body.GetUserData().rotation = body.GetAngle() * (180 / Math.PI);
                }
                if (body.GetUserData() is ActiveEntity)
                {
                    ActiveEntity(body.GetUserData()).update();
                }
            }
            
            if(_draggableBox)
               _draggableBox.update();

            for each (var outOfBoundsBody:b2Body in _boundarySweeper.bodies)
            {
                _sprite.removeChild(outOfBoundsBody.GetUserData());
                outOfBoundsBody.SetUserData(null);
                _world.DestroyBody(outOfBoundsBody);
            }
            _boundarySweeper.clear();

        }
        
        private function destroyBodies():void
        {
            for (var body:b2Body = _world.m_bodyList; body; body = body.m_next)
            {
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

