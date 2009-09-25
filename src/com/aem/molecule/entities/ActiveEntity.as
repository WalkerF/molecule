
package com.aem.molecule.entities
{

    import com.aem.molecule.Game;

    /**
     * Game object which is updated along with the game loop.
     */
    public interface ActiveEntity
    {

        function create(game:Game):void;
        function destroy(game:Game):void;
        function update(game:Game):void;
    }
}
