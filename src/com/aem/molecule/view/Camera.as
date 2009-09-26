
package com.aem.molecule.view
{

    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.geom.Point;

    /**
     * Display object container which contains all of the entities in the game.
     *
     * All display objects should be sibliings
     */
    public class Camera extends Sprite
    {

        private static const SERVICE:uint = 3;
        public static const FOREGROUND:uint = 2;
        public static const STAGE:uint = 1;
        public static const BACKGROUND:uint = 0;

        private var _layers:Array = [];
        private var _targets:Array = [];
        private var _thumbnails:Array = [];

        public function Camera():void
        {
            var background:Sprite = new Sprite();
            addChild(background);
            _layers[BACKGROUND] = background;

            var stage:Sprite = new Sprite();
            addChild(stage);
            _layers[STAGE] = stage;

            var foreground:Sprite = new Sprite();
            addChild(foreground);
            _layers[FOREGROUND] = foreground;

            var service:Sprite = new Sprite();
            addChild(service);
            _layers[SERVICE] = service;
        }

        public function add(child:DisplayObject, layer:uint = STAGE):void
        {
            _layers[layer].addChild(child);
        }

        public function remove(child:DisplayObject, layer:uint = STAGE):void
        {
            _layers[layer].removeChild(child);
        }

        /**
         * Always pass in a display object. If you want to have thumbnails for
         * the object when it is offscreen then pass in a display object which
         * implements the Trackable interface.
         */
        public function follow(target:DisplayObject):void
        {
            _targets.push(target);
            var bubble:DisplayObject = new OffScreenBubble();
            bubble.visible = false;
            add(bubble, SERVICE);
            _thumbnails.push(bubble);
        }

        public function unfollow(target:DisplayObject):void
        {
            for (var i:uint = 0; i < _targets.length; i++) {
                if (_targets[i] == target)
                {
                    _targets.splice(i, 1);
                    var removed:Array = _thumbnails.splice(i, 1);
                    if (removed.length)
                        _layers[SERVICE].removeChild(removed[0]);
                    break;
                }
            }
        }

        public function update():void
        {
            if (!_targets.length)
                return; // nothing to update

            var center:Point = new Point();
            for each (var sprite:DisplayObject in _targets)
            {
                center.x += sprite.x;
                center.y += sprite.y;
            }

            center.x /= _targets.length;
            center.y /= _targets.length;

            _layers[STAGE].x = (stage.stageWidth / 2) - center.x;
            _layers[STAGE].y = ((stage.stageHeight / 2) + 50) - center.y;
            _layers[SERVICE].x = (stage.stageWidth / 2) - center.x;
            _layers[SERVICE].y = ((stage.stageHeight / 2) + 50) - center.y;
            _layers[FOREGROUND].x = 2 * ((stage.stageWidth / 2) - center.x);
            _layers[FOREGROUND].y = ((stage.stageHeight / 2) + 50) - center.y;

            updateThumbnails(center);
        }

        private function updateThumbnails(center:Point):void
        {
            for (var i:uint = 0; i < _targets.length; i++) {
                if ((_targets[i].x + _layers[STAGE].x) < 0)
                {
                    if (!_thumbnails[i].visible)
                    {
                        _thumbnails[i].addChild(_targets[i].getThumbnail());
                        _thumbnails[i].visible = true;
                    }
                    _thumbnails[i].x = center.x - (stage.stageWidth / 2);
                    _thumbnails[i].x += _thumbnails[i].width / 2;
                    _thumbnails[i].y = _targets[i].y;
                    continue;
                } else {
                    if (_thumbnails[i].visible)
                    {
                        _thumbnails[i].removeChild(_targets[i].getThumbnail());
                        _thumbnails[i].visible = false;
                    }
                }

                if ((_targets[i].x + _layers[STAGE].x) > stage.stageWidth)
                {
                    if (!_thumbnails[i].visible)
                    {
                        _thumbnails[i].addChild(_targets[i].getThumbnail());
                        _thumbnails[i].visible = true;
                    }
                    _thumbnails[i].x = center.x + (stage.stageWidth / 2);
                    _thumbnails[i].x -= _thumbnails[i].width / 2;
                    _thumbnails[i].y = _targets[i].y;
                    continue;
                } else {
                    if (_thumbnails[i].visible)
                    {
                        _thumbnails[i].removeChild(_targets[i].getThumbnail());
                        _thumbnails[i].visible = false;
                    }
                }
            }
        }

    }
}
