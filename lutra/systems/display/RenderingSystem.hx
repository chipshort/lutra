package lutra.systems.display;
import lutra.components.display.Camera;
import lutra.components.Position;
import retto.graphics.Graphics;

/**
 * ...
 * @author Christoph Otter
 */
@system class RenderingSystem extends IteratingSystem
{
	var camEntity : Entity;
	
	//var tempEvent : 
	
	public function new (scene : Scene)
	{
		super (scene, "rendering", [Position]);
	}
	
	override public function render (graphics : Graphics) : Void
	{
		if (camEntity != null) {
			var pos = camEntity.getComponent (Position);
			var cam = camEntity.getComponent (Camera);
			graphics.pushTranslation (centerX (pos.x) + cam.offsetX, centerY (pos.y) + cam.offsetY);
		}
		else {
			graphics.pushTranslation (0, 0);
		}
		
		super.render (graphics);
		
		graphics.popTranslation ();
	}
	
	override function renderEntity (entity : Entity, graphics : Graphics) : Void
	{
		sendMessage ("renderEntity", {
			e: entity, //TODO: investigate performance of structures
			g: graphics
		});
	}
	
	override public function onMessage (type : String, msg : String, data : Dynamic) : Void 
	{
		if (msg == "setCamera") {
			setCamera (cast data);
		}
	}
	
	inline function setCamera (camera : Entity) : Void
	{
		camEntity = camera;
		#if debug
		if (camera != null && !camera.hasComponent (Position))
			trace ("ERROR: Your Camera has no Position");
		#end
	}
	
	/**
	 * Gets the amount to translate to get this x coordinate to the center
	 */
	inline function centerX (x : Float) : Float
	{
		return scene.stage.stageWidth / 2 - x;
	}
	
	/**
	 * Gets the amount to translate to get this y coordinate to the center
	 */
	inline function centerY (y : Float) : Float
	{
		return scene.stage.stageHeight / 2 - y;
	}
	
}