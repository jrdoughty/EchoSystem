package systems;

import haxe.Timer;
import echoes.System;
import components.*;
import components.core.*;
import echoes.Entity;
import kha.Assets;
import haxe.ds.StringMap;
import nape.shape.*;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.geom.Vec2;
import kha.audio1.Audio;
import echoes.View;

class GameSystem extends System
{
    var player:View<Player>;
    var units:View<Unit>;
    public function new ()
    {
        if(Project.bgChannel == null)
            Project.bgChannel = Audio.play(Assets.sounds.carnivalrides,true);
        var numUnits:Int = 10;
        var numPeople:Int = 15;
        var numCollectors:Int = 10;
        var gameTime:Int = 15;
        var speed = 5;
        var sEntity = new Entity().add(
            new ScoreComp(0),
            new TimeData(["timer"=>new TimeComp(gameTime),"gameEndTimer"=>new TimeComp(gameTime+4)]));
        new Entity().add(
            new TimeData(["spawn"=>new TimeComp(Math.round(gameTime/2))]));
        
        new Entity().add(//Background
            new Position(0, 0),
            AnimComp.createAnimDataRange(0,0,Math.round(100)),
            new ImageComp("back"),
            new Scale(1,1),
            new Bounds2D(Main.WIDTH,Main.HEIGHT),
            new Visibility(),
            new RenderOffset2D(0.0, 0.0));


        var characterEcho = new Entity().add(
            new Position(Main.WIDTH /2 , Main.HEIGHT/2),
            new Velocity(0,0),
            new Player(),
            AnimComp.createAnimDataRange(7,7,Math.round(speed),"idle"),
            new ImageComp("main"),
            new AnimData([
                "idle"=>AnimComp.createAnimDataRange(7,7,Math.round(speed),"idle"),
                "run"=>AnimComp.createAnimDataRange(0,3,Math.round(speed),"run"),
                "throw"=>AnimComp.createAnimDataRange(4,6,Math.round(speed),"throw")]),
            new Scale(1,1),
            new Bounds2D(32,32),
            new Visibility(),
            new GamePad(0),
            new KeyboardComp(),
            new MouseComp()
        );
        var i;
        for(i in 0...numUnits)
        {
            new Entity().add(//(.4+Math.random()/8)
                Utils.findRandomPointInCircle(characterEcho.get(Position),64),
                new Velocity(0,0),
                new Scale(1,1),
                new ImageComp("unit"),
                AnimComp.createAnimDataRange(0,1,Math.round(speed)),
                new Bounds2D(32,32),
                new AnimData([
                    "idle"=>AnimComp.createAnimDataRange(0,0,Math.round(speed)),
                    "run"=>AnimComp.createAnimDataRange(0,1,Math.round(speed)),
                    "thrown"=>AnimComp.createAnimDataRange(2,3,Math.round(speed)),
                    "dazed"=>AnimComp.createAnimDataRange(4,7,Math.round(speed))]),
                new Visibility(),
                new Angle(0),
                new Unit(Math.round(120 * Math.random()))
            );
        }
        
        for(i in 0...numPeople)
        {
            new Entity().add(//(.4+Math.random()/8)
                new Position(Main.WIDTH * Math.random(), Main.PLAYAREAHEIGHT * Math.random()/2 ),
                new Velocity(0,0),
                new Scale(1,1),
                new ImageComp("peep"),
                new Enemy(),
                AnimComp.createAnimDataRange(0,3,Math.round(speed)),
                new Bounds2D(32,32),
                new AnimData([
                    "idle"=>AnimComp.createAnimDataRange(2,2,Math.round(speed)),
                    "run"=>AnimComp.createAnimDataRange(0,3,Math.round(speed))]),
                new Visibility(),
                new Angle(0)//360 * Math.random())
            );
        }
        for(i in 0...120)
        {
            var c = new Circle(5);
            var body = new Body(BodyType.STATIC, new Vec2((30 * i) % Main.WIDTH, Main.HEIGHT-100 - 30*Math.floor(i/30)));
            if(Math.floor(i/30)%2==0)
                body.position.x += 15;
            c.body = body;
            new Entity().add(c,
                new Position(body.position.x, body.position.y),
                new Bounds2D(c.radius * 2, c.radius * 2),
                new Visibility(),
                new ImageComp("peg"),
                AnimComp.createAnimDataRange(0,0,Math.round(100)),
                new Angle(0));
        }
        //floor
        var poly:Polygon = new Polygon(Polygon.rect(0,0,Main.WIDTH,10));
        poly.body = new Body(BodyType.STATIC, new Vec2(0, Main.HEIGHT));
        new Entity().add(poly);
        //walls
        poly = new Polygon(Polygon.rect(0,0,10,Main.HEIGHT));
        poly.body = new Body(BodyType.STATIC, new Vec2(-9, 0));
        new Entity().add(poly);
        poly = new Polygon(Polygon.rect(0,0,10,Main.HEIGHT));
        poly.body = new Body(BodyType.STATIC, new Vec2(Main.WIDTH, 0));
        new Entity().add(poly);

        for(i in 0...numCollectors)
        {
            if(i%6==2)
            {
                new Entity().add(
                    new Position(Main.WIDTH/numCollectors*i,Main.HEIGHT-32),
                    new Velocity(0,0),
                    new Scale(1,1),
                    new ImageComp("ogre"),
                    AnimComp.createAnimDataRange(0,0,Math.round(speed)),
                    new Bounds2D(32,64),
                    new AnimData([
                        "idle"=>AnimComp.createAnimDataRange(0,0,Math.round(speed)),
                        "run"=>AnimComp.createAnimDataRange(0,3,Math.round(speed))]),
                    new Visibility(),
                    new Angle(0),
                    new Catcher(Math.round(120),3)
                );
            }
            else if(i%6==4)
            {
                new Entity().add(
                    new Position(Main.WIDTH/numCollectors*i,Main.HEIGHT-16),
                    new Velocity(0,0),
                    new Scale(1,1),
                    new ImageComp("goblinbigbag"),
                    AnimComp.createAnimDataRange(3,5,Math.round(speed)),
                    new Bounds2D(32,32),
                    new AnimData([
                        "idle"=>AnimComp.createAnimDataRange(3,5,Math.round(speed)),
                        "run"=>AnimComp.createAnimDataRange(0,2,Math.round(speed))]),
                    new Visibility(),
                    new Angle(0),
                    new Catcher(Math.round(200),5)
                );
            }
            else 
            {
                new Entity().add(
                    new Position(Main.WIDTH/numCollectors*i,Main.HEIGHT-16),
                    new Velocity(0,0),
                    new Scale(1,1),
                    new ImageComp("alt"),
                    AnimComp.createAnimDataRange(0,0,Math.round(speed)),
                    new Bounds2D(32,32),
                    new AnimData([
                        "idle"=>AnimComp.createAnimDataRange(0,0,Math.round(speed)),
                        "run"=>AnimComp.createAnimDataRange(0,2,Math.round(speed))]),
                    new Visibility(),
                    new Angle(0),
                    new Catcher(Math.round(60),1)
                );
            }
        }
        var debimages = ["tree",
            "barrel",
            "bottle", 
            "shovel", 
            "box"];
        for(i in 0...numPeople*4)
        {
            new Entity().add(
                new Position(Math.random()*Main.WIDTH,Math.random()*Main.PLAYAREAHEIGHT),
                new Scale(1,1),
                new ImageComp(debimages[(i%debimages.length)]),
                AnimComp.createAnimDataRange(0,0,Math.round(speed)),
                new Bounds2D(AssetRepo.images.get(debimages[(i%debimages.length)]).width,
                    AssetRepo.images.get(debimages[(i%debimages.length)]).height),
                new Visibility(),
                new Debris()
            );
        }
    }
    @u function updateTimers(t:TimeData)
    {
        for(i in t.keys())
        {
            t.get(i).currentTime = Timer.stamp();
        }
        if(t.exists('spawn')&&t.get('spawn').endTime - t.get('spawn').currentTime <= 0)
        {
            var speed = 5;
            var numPeople = 10;
            for(i in 0...numPeople)
            {
                new Entity().add(//(.4+Math.random()/8)
                    new Position(Main.WIDTH * Math.random(), Main.PLAYAREAHEIGHT * Math.random() ),
                    new Velocity(0,0),
                    new Scale(1,1),
                    new ImageComp("peep"),
                    new Enemy(),
                    AnimComp.createAnimDataRange(0,3,Math.round(speed)),
                    new Bounds2D(32,32),
                    new AnimData([
                        "idle"=>AnimComp.createAnimDataRange(2,2,Math.round(speed)),
                        "run"=>AnimComp.createAnimDataRange(0,3,Math.round(speed))]),
                    new Visibility(),
                    new Angle(0)//360 * Math.random())
                );
            }
            t.remove('spawn');
        }
    }
    @u function isGameDone(t:TimeData, s:ScoreComp)
    {
        if(t.get('timer').endTime - t.get('timer').currentTime <= 0)
        {
            for(i in units.entities)
            {
                if( i.get(TargetPosition) == null)
                {
                    i.add(i.get(AnimData).get('idle'));
                    i.remove(Unit);
                 }
            }
            for(i in player.entities)
            {
                i.add(i.get(AnimData).get('idle'));
                i.remove(Player);
                Audio.play(Assets.sounds.endoflevel);//should only happen once
            }
        }
        if(t.get('gameEndTimer').endTime - t.get('gameEndTimer').currentTime <= 0)
        {
            if(s.score > Project.highScore)
            {
                Project.highScore = s.score;
            }
            Project.lastScore = s.score;
            Project.activeState = 'menu';
            Audio.play(Assets.sounds.endoflevel);//should only happen once
        }
    }
}