package com.aem.prototype.towertussles
{
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	
	import com.aem.molecule.Game;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class DraggableBox extends MovieClip
	{
		
		private var originalLocation:Point;
		private var startingLocation:Point;
		private var world:b2World;
		private var game:Game;
		private var hasClick:Boolean;
		private static const CLICK_MAX_TIMER:Number = 15;
		private var clickTimer:Number;
			
		public function DraggableBox():void
		{
			clickTimer=0;
			originalLocation = new Point();
			originalLocation.x = this.x;
			originalLocation.y = this.y;
			addEventListener(MouseEvent.MOUSE_DOWN, pickup);
            addEventListener(MouseEvent.MOUSE_UP, place);
            //addEventListener(MouseEvent.DOUBLE_CLICK,submit);
            addEventListener(MouseEvent.CLICK, acknowledgeClick);
		}
		
		public function init(world:b2World,game:Game):void
		{
			this.world = world;
			this.game=game;
		}
		public function acknowledgeClick(event:MouseEvent):void
		{
			if(hasClick)
			{
			   hasClick=false;
			   submit();
			   this.x = originalLocation.x;
			   this.y = originalLocation.y;
			}
			else
			   hasClick=true;
		}
		
		public function pickup( event:MouseEvent ):void {
          var obj:Object = event.currentTarget;     
          this.parent.setChildIndex(this, this.parent.numChildren-1);          
          startingLocation = new Point(  );
          startingLocation.x = obj.x;
           startingLocation.y = obj.y;      
            obj.startDrag(  );     
        }
        
        protected function p2m(pixels:Number):Number
        {
            return pixels / 30;
        }
        
        public function submit():void
        {
        	var box:Box = new Box();
        	box.x=this.x;
        	box.y=this.y;      	
            box.init(this.world);
            game.camera.addChild(box);
        }
        
        public function place( event:MouseEvent ):void {
           this.stopDrag(  );
           this.filters = null;
        }
        public function update():void
        {
        	if(hasClick)
        	{
        		clickTimer++;
        		if(clickTimer>=30)
        		{
        			clickTimer=0;
        			hasClick=false;
        		}
        	}
        }
        
	}
} 