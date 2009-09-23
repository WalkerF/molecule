
package
{
    import flash.display.Sprite;

    import com.aem.molecule.Game;
    import com.aem.prototype.volcanic.InGameState;

    [SWF(width="550", height="400", frameRate="30")]
    public class Volcanic extends Sprite
    {

        public function Volcanic():void
        {
            var game:Game = new Game();
            addChild(game);

            game.add(new InGameState());
            game.init();
        }
    }
}
