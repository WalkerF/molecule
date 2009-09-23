
package
{
    import flash.display.Sprite;

    import com.aem.prototype.volcanic.Game;

    [SWF(width="550", height="400", frameRate="30")]
    public class Volcanic extends Sprite
    {

        public function Volcanic():void
        {
            var game:Game = new Game();
            addChild(game);
        }
    }
}
