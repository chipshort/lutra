package lutra.systems.display;
import lutra.components.display.Camera;
import lutra.components.Position;
import lutra.Entity;
import lutra.Scene;

/**
 * This System handles the Camera component.
 * It communicates with the imaging System to set the Camera.
 * @author Christoph Otter
 */
@system class CameraSystem extends IteratingSystem
{

	public function new (scene : Scene)
	{
		super (scene, "camera", [Position, Camera]);
	}
	
	override public function update (dt : Float) : Void
	{
		setCamera (null);
		
		super.update (dt);
	}

	override function updateEntity (entity : Entity, dt : Float) : Void
	{
		if (entity.getComponent (Camera).active)
			setCamera (entity);
	}
	
	inline function setCamera (entity : Entity) : Void
	{
		sendMessageTo ("rendering", "setCamera", entity);
	}

}