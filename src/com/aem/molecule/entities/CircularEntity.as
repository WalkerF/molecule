
package com.aem.molecule.entities
{
    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;

    public class CircularEntity extends PhysicalEntity
    {

        public function CircularEntity():void
        {
            _density = 1;
            _friction = .8;
            _restitution = .2;
        }

        public override function init(world:b2World):b2Body
        {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.position.Set(p2m(x), p2m(y));
            bodyDef.angle = rotation * Math.PI / 180;
            bodyDef.userData = this;

            // caching the rotation so we can correctly set the width
            var r:Number = rotation;
            rotation = 0;

            var circleDef:b2CircleDef = new b2CircleDef();
            circleDef.radius = p2m(width / 2);
            circleDef.friction = friction;
            circleDef.density = density;
            circleDef.restitution = restitution;

            // setting back the shapes rotation
            rotation = r;

            var body:b2Body = world.CreateBody(bodyDef);
            body.CreateShape(circleDef);
            body.SetMassFromShapes();

            return body;
        }
    }
}
