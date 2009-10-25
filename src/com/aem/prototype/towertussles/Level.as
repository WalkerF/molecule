
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
	import flash.events.Event;

	public class Level extends Sprite
	{
		public static const GAME_OVER:String="gameOver";
		public static const SUBMIT_BOX:String="submitBox";
		public static const SUBMIT_THIN_RECTANGLE:String="submitThinRectangle";
		public static const SUBMIT_SHAPE:String="submitShape";
		public static const CREATE_THUMB_TACK:String="createThumbTack";
		public static const CREATE_DRAGGABLE:String="createDraggable";
		public static const CHECK_DRAGGABLE_MENU_DROP:String="checkDraggableMenuDrop";
		private static const ITERATIONS:uint=10;
		private static const TIMESTEP:Number=1 / 30;
		private static const STARTING_GRAVITY:Number=30;

		private var mSprite:TowerSprites;
		private var mGameOver:Boolean;
		private var mBoundarySweeper:BoundarySweeper;
		private var mCollisionListener:CollisionListener;
		private var mGravity:b2Vec2=new b2Vec2(0, STARTING_GRAVITY);
		private var mGame:Game;
		private var mMenu:Menu;
		private var mSpriteChildren:Array=[];
		private var cursor:RotatableCursor;
		public var mHasDraggable:Boolean;

		private var _world:b2World;

		public function Level(sprite:TowerSprites):void
		{
			mSprite=sprite;
			mHasDraggable=false;
		}

		public function init(game:Game):void
		{
			mGame=game;
			mGame.camera.add(mSprite, 1);
			cursor=new RotatableCursor();
			mGame.stage.addChild(cursor);
			cursor.camera=mGame.camera;
			var child:DisplayObject;
			while (mSprite.numChildren > 0)
			{
				child=mSprite.removeChildAt(0);
				mSpriteChildren.push(child);
				mGame.camera.add(child, 1);
			}

			initWorld();
			initBodies();
			initDebug();
		}

		public function destroy():void
		{
			destroyBodies();
			destroyWorld();
		}

		private function initWorld():void
		{
			var worldAABB:b2AABB=new b2AABB();
			worldAABB.lowerBound.Set(-300, -200);
			worldAABB.upperBound.Set(300, 200);

			_world=new b2World(worldAABB, mGravity, true);

			mBoundarySweeper=new BoundarySweeper();
			_world.SetBoundaryListener(mBoundarySweeper);

			mCollisionListener=new CollisionListener();
			_world.SetContactListener(mCollisionListener);
		}

		private function initBodies():void
		{
			for (var i:uint=0; i < mSpriteChildren.length; i++)
			{
				var child:DisplayObject=mSpriteChildren[i];
				if (child is PhysicalEntity)
					PhysicalEntity(child).init(_world);
				else if (child is Menu)
				{
					mMenu=Menu(child);
					mMenu.addEventListener(CREATE_THUMB_TACK, createThumbTack);
				}
			}
		}

		private function initDebug():void
		{
			var debug:Sprite=new Sprite();
			mSprite.addChild(debug);

			var debugDraw:b2DebugDraw=new b2DebugDraw();
			debugDraw.m_drawScale=30;
			debugDraw.m_sprite=debug;
			debugDraw.m_fillAlpha=.6;
			debugDraw.m_lineThickness=1.0;
			debugDraw.m_drawFlags=b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit;

			_world.SetDebugDraw(debugDraw);
		}

		private function m2p(meters:Number):Number
		{
			return meters * 30;
		}

		private function p2m(pixels:Number):Number
		{
			return pixels / 30;
		}

		public function update():void
		{
			_world.Step(TIMESTEP, ITERATIONS);

			for (var body:b2Body=_world.m_bodyList; body; body=body.m_next)
			{
				if (body.GetUserData() is Sprite)
				{
					if (body.GetUserData() is DraggableShape && !DraggableShape(body.GetUserData()).isPlaced)
					{
						var vec:b2Vec2=new b2Vec2()
						vec.x=p2m(body.GetUserData().x);
						vec.y=p2m(body.GetUserData().y);
						body.SetXForm(vec, body.GetUserData().rotation / 180 * Math.PI);
						if(DraggableShape(body.GetUserData()).overlapping>0)
						{
						  DraggableShape(body.GetUserData()).overlapping--;
						  if(DraggableShape(body.GetUserData()).overlapping==0)
						     DraggableShape(body.GetUserData()).gotoAndStop("valid");
						}
					}
					else
					{
						body.GetUserData().x=m2p(body.GetPosition().x);
						body.GetUserData().y=m2p(body.GetPosition().y);
						body.GetUserData().rotation=body.GetAngle() * (180 / Math.PI);
					}
				}
				if (body.GetUserData() is ActiveEntity)
				{
					ActiveEntity(body.GetUserData()).update(mGame);
				}
			}

			mMenu.update();

			for each (var outOfBoundsBody:b2Body in mBoundarySweeper.bodies)
			{
				mSprite.removeChild(outOfBoundsBody.GetUserData());
				outOfBoundsBody.SetUserData(null);
				_world.DestroyBody(outOfBoundsBody);
			}
			mBoundarySweeper.clear();

		}

		private function destroyBodies():void
		{
			for (var body:b2Body=_world.m_bodyList; body; body=body.m_next)
			{
				body.SetUserData(null);
				_world.DestroyBody(body);
			}
		}

		private function destroyWorld():void
		{
			_world.SetContactListener(null); // TODO move this to Body
			_world.SetBoundaryListener(null);
			_world=null;
		}

		public function submitShape(e:Event):void
		{
			var obj:DraggableShape=DraggableShape(e.currentTarget);
			obj.placeOnBoard(_world);
			mHasDraggable=false;
		}

		public function checkMenuDrop(e:Event):void
		{
			var shape:DraggableShape=DraggableShape(e.currentTarget);
			if (shape.y> mMenu.y - mMenu.height / 2)
				if (shape.y < mMenu.y + mMenu.height / 2)
					if (shape.x > mMenu.x - mMenu.width / 2)
						if (shape.x < mMenu.x + mMenu.width / 2)
						{
							draggableToTack(shape);
						}

		}

		public function draggableToTack(shape:DraggableShape):void
		{
			mGame.camera.remove(shape, 1);
			shape.removeEventListener(SUBMIT_SHAPE, submitShape);
			shape.removeEventListener(CHECK_DRAGGABLE_MENU_DROP, checkMenuDrop);
			shape.destroyBody(_world);
			shape.rotation = 0;
			mHasDraggable=false;
			var l_tack:ThumbTack;
			if (shape is Box)
				l_tack=new BoxThumbTack();
			else if (shape is ThinRectangle)
				l_tack=new ThinRectangleThumbTack();
			l_tack.m_DraggableShape=shape;
			mMenu.addThumbTack(l_tack);
		}

		public function createThumbTack(e:Event):void
		{
			var tack:ThumbTack=Menu(e.currentTarget).m_current;
			mGame.camera.add(tack, 1);
			tack.addEventListener(CREATE_DRAGGABLE, createDraggable);
		}

		public function createDraggable(event:Event):void
		{
			if (!mHasDraggable)
			{
				var tack:ThumbTack=ThumbTack(event.currentTarget);
				tackToDraggable(tack);
			}
		}

		public function tackToDraggable(tack:ThumbTack):void
		{
			var shape:DraggableShape=tack.m_DraggableShape;
			mGame.camera.add(shape, 1);
			shape.x=shape.parent.mouseX;
			shape.y=shape.parent.mouseY;
			shape.passCursor(cursor);
			shape.addEventListener(SUBMIT_SHAPE, submitShape);
			shape.addEventListener(CHECK_DRAGGABLE_MENU_DROP, checkMenuDrop);
			shape.init(_world);
			mGame.camera.remove(tack, 1);
			mMenu.removeThumbTack(tack);
			shape.pickupItem();
			mHasDraggable=true;
		}

		private function gameOver(e:Event):void
		{
			mGameOver=true;
		}
	}
}

