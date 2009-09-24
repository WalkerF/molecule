package
{
	import flash.display.Sprite;

    import com.aem.molecule.Game;
    import com.aem.prototype.towertussles.InGameState;
    
    [SWF(width="550", height="400", frameRate="30")]
	public class Towers extends Sprite
	{
		public function Towers()
		{ 
			var game:Game = new Game();
            addChild(game);
            
            game.add(new InGameState());
            game.init();
		}

	}
}