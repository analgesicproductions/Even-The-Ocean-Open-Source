package help;
import entity.enemy.AimSpore;
import entity.enemy.BallDropper;
import entity.enemy.BatThing;
import entity.enemy.Broadcaster;
import entity.enemy.ClimbSpore;
import entity.enemy.Dasher;
import entity.enemy.ExtendStem;
import entity.enemy.FloatPod;
import entity.enemy.GhostLight;
import entity.enemy.Hopper;
import entity.enemy.Inverter;
import entity.enemy.LaunchBug;
import entity.enemy.MovePod;
import entity.enemy.ShockFloat;
import entity.enemy.ShoreBot;
import entity.enemy.ShoreSpore;
import entity.enemy.SmashHand;
import entity.enemy.SpikeExtend;
import entity.enemy.SquishBounce;
import entity.enemy.SquishyChaser;
import entity.enemy.StickySlime;
import entity.enemy.TriggeredLaser;
import entity.enemy.WalkPod;
import entity.enemy.WallBouncer;
import entity.enemy.WaterGlider;
import entity.MySprite;
import entity.npc.BugSwarm;
import entity.npc.Cauliflower;
import entity.npc.DaisyCluster;
import entity.npc.Fish;
import entity.npc.GenericNPC;
import entity.npc.GreenhousePlant;
import entity.npc.HelpTip;
import entity.npc.Mole;
import entity.npc.MoleTile;
import entity.npc.Pendulum;
import entity.npc.SetPiece;
import entity.npc.WirePoint;
import entity.player.BubbleSpawner;
import entity.tool.AmbiencePlayer;
import entity.tool.Cutscene;
import entity.tool.LightBox;
import entity.trap.BarbedWire;
import entity.trap.Dropper;
import entity.trap.FlameBlower;
import entity.trap.FlameOn;
import entity.trap.Floater;
import entity.trap.FollowLaser;
import entity.trap.HurtOutlet;
import entity.trap.MiniMoveBlock;
import entity.trap.MirrorLaser;
import entity.trap.MoveBlock;
import entity.trap.NearCannon;
import entity.trap.NewWaterShooter;
import entity.trap.OuchOutlet;
import entity.trap.Spike;
import entity.trap.WaterCharger;
import entity.trap.WaterShooter;
import entity.trap.Weed;
import entity.trap.Wind;
import entity.util.AliphItem;
import entity.util.ArmLocker;
import entity.util.Bouncer;
import entity.util.BubbleSwitch;
import entity.util.Button;
import entity.util.Checkpoint;
import entity.util.EdgeDoor;
import entity.util.Elevator;
import entity.util.FloatWall;
import entity.util.LaserBlock;
import entity.util.LineCollider;
import entity.util.Neutralizer;
import entity.util.NewCamTrig;
import entity.util.PathUnlocker;
import entity.util.PlantBlock;
import entity.util.PlantBlockAccepter;
import entity.util.PushField;
import entity.util.RevolveSpore;
import entity.util.SinkPlatform;
import entity.util.SoundZone;
import entity.util.Stopper;
import entity.util.TileFader;
import entity.util.ToneFader;
import entity.util.TrainTrigger;
import entity.trap.SapPad;
import entity.util.RaiseWall;
import entity.tool.CameraTrigger;
import entity.tool.Door;
import entity.tool.SavePoint;
import entity.tool.SongTrigger;
import entity.trap.EnergyGate;
import entity.trap.EnergyOrb;
import entity.trap.GasCloud;
import entity.trap.LavaPillar;
import entity.trap.Pew;
import entity.trap.Pod;
import entity.trap.RubberLaser;
import entity.util.OrbSlot;
import entity.util.VanishBlock;
import entity.util.WalkBlock;
import entity.util.WMScaleSprite;
import haxe.Log;
import state.MyState;

/**
 * @author Melos Han-Tani
 */

class SpriteFactory 
{

	public static function make(name:String, x:Int, y:Int, st:MyState):Dynamic {
		switch (name) {
			case "Pew":
				return new Pew(x, y, st);
			case "Door":
				return new Door(x, y, st);
			case "SavePoint":
				return new SavePoint(x, y, st);
			case "GasCloud":
				return new GasCloud(x, y, st);
			case "RubberLaser":
				return new RubberLaser(x, y, st);
			case "LavaPillar":
				return new LavaPillar(x, y, st);
			case "Pod":
				return new Pod(x, y, st);
			case "EnergyGate":
				return new EnergyGate(x, y, st);
			case "CameraTrigger":
				return new CameraTrigger(x, y, st);
			case "SongTrigger":
				return new SongTrigger(x, y, st);
			case "EnergyOrb":
				return new EnergyOrb(x, y, st);
			case "OrbSlot":
				return new OrbSlot(x, y, st);
			case "RaiseWall":
				return new RaiseWall(x, y, st);
			case "SapPad":
				return new SapPad(x, y, st);
			case "GenericNPC":
				return new GenericNPC(x, y, st);
			case "TrainTrigger":
				return new TrainTrigger(x, y, st);
			case "AliphItem":
				return new AliphItem(x, y, st);
			case "PathUnlocker":
				return new PathUnlocker(x, y, st);
			case "FollowLaser":
				return new FollowLaser(x, y, st);
			case "HelpTip":
				return new HelpTip(x, y, st);
			case "Cutscene":
				return new Cutscene(x, y, st);
			case "Wind":
				return new Wind(x, y, st);
			case "HurtOutlet":
				return new HurtOutlet(x, y, st);
			case "NearCannon":
				return new NearCannon(x, y, st);
			case "ShoreBot":
				return new ShoreBot(x, y, st);
			case "WaterShooter":
				return new WaterShooter(x, y, st);
			case "NewWaterShooter":
				return new NewWaterShooter(x, y, st);
			case "Weed":
				return new Weed(x, y, st);
			case "AmbiencePlayer":
				return new AmbiencePlayer(x, y, st);
			case "BugSwarm":
				return new BugSwarm(x, y, st);
			case "Dropper":
				return new Dropper(x, y, st);
			case "SinkPlatform":
				return new SinkPlatform(x, y, st);
			case "BubbleSpawner":
				return new BubbleSpawner(x, y, st);
			case "BubbleSwitch":
				return new BubbleSwitch(x, y, st);
			case "Spike":
				return new Spike(x, y, st);
			case "VanishBlock":
				return new VanishBlock(x, y, st);
			case "GreenhousePlant":
				return new GreenhousePlant(x, y, st);
			case "Checkpoint":
				return new Checkpoint(x, y, st);
			case "PushField":
				return new PushField(x, y, st);
			case "LaunchBug":
				return new LaunchBug(x, y, st);
			case "TileFader":
				return new TileFader(x, y, st);
			case "Dasher":
				return new Dasher(x, y, st);
			case "WaterGlider":
				return new WaterGlider(x, y, st);
			case "NewWaterGlider":
				return new ExtendStem(x, y, st);
			case "ExtendStem":
				return new ExtendStem(x, y, st);
			case "Neutralizer":
				return new Neutralizer(x, y, st);
			case "DaisyCluster":
				return new DaisyCluster(x, y, st);
			case "Fish":
				return new Fish(x, y, st);
			case "Stopper":
				return new Stopper(x, y, st);
			case "WirePoint":
				return new WirePoint(x, y, st);
			case "BarbedWire":
				return new BarbedWire(x, y, st);
			case "EdgeDoor":
				return new EdgeDoor(x, y, st);
			case "Cauliflower":
				return new Cauliflower(x, y, st);
			case "StickySlime":
				return new StickySlime(x, y, st);
			case "Bouncer":
				return new Bouncer(x, y, st);
			case "Button":
				return new Button(x, y, st);
			case "ShockFloat":
				return new ShockFloat(x, y, st);
			case "Mole":
				return new Mole(x, y, st);
			case "MoleTile":
				return new MoleTile(x, y, st);
			case "ShoreSpore":
				return new ShoreSpore(x, y, st);
			case "RevolveSpore":
				return new RevolveSpore(x, y, st);
			case "Broadcaster":
				return new Broadcaster(x, y, st);
			case "TriggeredLaser":
				return new TriggeredLaser(x, y, st);
			case "ClimbSpore":
				return new ClimbSpore(x, y, st);
			case "WallBouncer":
				return new WallBouncer(x, y, st);
			case "SquishyChaser":
				return new SquishyChaser(x, y, st);
			case "AimSpore":
				return new AimSpore(x, y, st);
			case "SquishBounce":
				return new SquishBounce(x, y, st);
			case "PlantBlock":
				return new PlantBlock(x, y, st);
			case "PlantBlockAccepter":
				return new PlantBlockAccepter(x, y, st);
			case "BallDropper":
				return new BallDropper(x, y, st);
			case "Hopper":
				return new Hopper(x, y, st);
			case "MoveBlock":
				return new MoveBlock(x, y, st);
			case "FlameBlower":
				return new FlameBlower(x, y, st);
			case "Inverter":
				return new Inverter(x, y, st);
			case "MiniMoveBlock":
				return new MiniMoveBlock(x, y, st);
			case "SmashHand":
				return new SmashHand(x, y, st);
			case "Pendulum":
				return new Pendulum(x, y, st);
			case "MirrorLaser":
				return new MirrorLaser(x, y, st);
			case "SpikeExtend":
				return new SpikeExtend(x, y, st);
			case "WaterCharger":
				return new WaterCharger(x, y, st);
			case "Floater":
				return new Floater(x, y, st);
			case "BatThing":
				return new BatThing(x, y, st);
			case "SetPiece":
				return new SetPiece(x, y, st);
			case "OuchOutlet":
				return new OuchOutlet(x, y, st);
			case "ArmLocker":
				return new ArmLocker(x, y, st);
			case "MovePod":
				return new MovePod(x, y, st);
			case "LaserBlock":
				return new LaserBlock(x, y, st);
			case "LightBox":
				return new LightBox(x, y, st);
			case "GhostLight":
				return new GhostLight(x, y, st);
			case "WalkPod":
				return new WalkPod(x, y, st);
			case "WalkBlock":
				return new WalkBlock(x, y, st);
			case "Elevator":
				return new Elevator(x, y, st);
			case "FlameOn":
				return new FlameOn(x, y, st);
			case "FloatWall":
				return new FloatWall(x, y, st);
			case "NewCamTrig":
				return new NewCamTrig(x, y, st);
			case "LineCollider":
				return new LineCollider(x, y, st);
			case "SoundZone":
				return new SoundZone(x, y, st);
			case "ToneFader":
				return new ToneFader(x, y, st);
			case "WMScaleSprite":
				return new WMScaleSprite(x, y, st);
			case "FloatPod":
				return new FloatPod(x, y, st);
		}
		Log.trace("name " + name+" not found");
		return null;
	}
	
}