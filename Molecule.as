
package
{
    import flash.display.Sprite;

    import com.aem.molecule.Game;

    [SWF(width="550", height="400", frameRate="30")]
    public class Molecule extends Sprite
    {

        private var _game:Game;

        public function Molecule():void
        {
            _game = new Game(new Sprites(), new Sliders());
            addChild(_game);
        }
    }
}
