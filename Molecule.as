
package
{
    import flash.display.Sprite;

    import com.aem.molecule.Level;

    [SWF(width="550", height="400", frameRate="30")]
    public class Molecule extends Sprite
    {

        private var _level:Level;

        public function Molecule():void
        {
            _level = new Level(new Sprites(), new Sliders());
            addChild(_level);
        }
    }
}
