
package com.aem.molecule.entities
{
    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;

    public class StaticSensor extends PhysicalEntity 
    {

        public function StaticSensor():void
        {
            _density = 0;
            _friction = .4;
            _restitution = 0;
            visible = false;
        }

        public override function init(world:b2World):b2Body
        {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.position.Set(p2m(x), p2m(y));

            var sensor:b2PolygonDef = new b2PolygonDef();
            sensor.isSensor = true;
            sensor.userData = name;
            sensor.SetAsOrientedBox(p2m(width / 2), p2m(height / 2), new b2Vec2(0, 0), 0);

            var body:b2Body = world.CreateBody(bodyDef);
            body.CreateShape(sensor);

            return body;
        }

    }
}
