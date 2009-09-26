
package com.aem.molecule.view
{

    import flash.display.DisplayObject;

    /**
     * An entity which can be shown by the camera when off screen.
     */
    public interface Trackable
    {

        function getThumbnail():DisplayObject;
    }
}
