
package
{
    import flash.display.Sprite;

    import com.aem.prototype.volcanic.Game;

    [SWF(width="550", height="400", frameRate="30")]
    public class Molecule extends Sprite
    {

        public function Molecule():void
        {
            var game:Game = new Game();
            addChild(game);
        }
    }
}
