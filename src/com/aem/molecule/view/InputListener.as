
package com.aem.molecule.view
{

    import flash.events.KeyboardEvent;

    public interface InputListener
    {

        function onKeyPress(e:KeyboardEvent):void;
        function onKeyRelease(e:KeyboardEvent):void;
    }
}
