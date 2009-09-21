
package com.aem.molecule
{
    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;

    public class Box extends Entity 
    {

        public function Box():void
        {
            _density = 2;
            _friction = .4;
            _restitution = 0;
        }

        public override function init(world:b2World):b2Body
        {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.position.Set(p2m(x), p2m(y) );
            bodyDef.userData = this;

            var boxDef:b2PolygonDef = new b2PolygonDef();
            boxDef.SetAsBox(p2m(width / 2), p2m(height / 2));
            boxDef.friction = friction;
            boxDef.density = density;
            boxDef.restitution = restitution;

            var body:b2Body = world.CreateBody(bodyDef);
            body.CreateShape(boxDef);
            body.SetMassFromShapes();

            return body;
        }
    }
}
