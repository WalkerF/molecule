
package com.aem.molecule.states
{

    import com.aem.molecule.Game;

    public interface GameState
    {
        // 0 is reserved for starting state
        function getID():uint;
        function enter(fromState:uint):void;
        function exit(toState:uint):void;
        function init(game:Game):void;
        function update(game:Game):void;
    }
}
