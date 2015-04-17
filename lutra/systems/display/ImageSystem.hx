package lutra.systems.display;
import lutra.components.display.Camera;
import lutra.components.display.Image;
import lutra.components.Position;
import lutra.components.Rotation;
import lutra.Entity;
import lutra.Scene;
import lutra.systems.IteratingSystem;
import lutra.systems.RenderSystem;
import lutra.systems.System;
import retto.graphics.Graphics;

/**
 * Renders Entities with an Image Component at the position of their Position Component.
 * Note: This requires RenderingSystem.
 * @author Christoph Otter
 */
@system class ImageSystem extends RenderSystem
{
	public function new (scene : Scene)
	{
		super (scene, "imaging", [Position, Image]);
		
		//scene.registerMessageHandler (this, "rendering");
	}
	
	override function renderEntity (entity : Entity, graphics : Graphics) : Void
	{
		var position = entity.getComponent (Position);
		var image = entity.getComponent (Image).image;
		var rotation = entity.getComponent (Rotation);
		if (image == null) return;
		
		var x = position.x - image.width / 2;
		var y = position.y - image.height / 2;
		
		//this should not be needed as white is standard
		graphics.pushColor (0xFFFFFFFF);
		if (rotation != null && rotation.angle != 0) {
			var originX = image.width / 2;
			var originY = image.height / 2;
			
			if (!Math.isNaN (rotation.originX))
				originX = rotation.originX;
			
			if (!Math.isNaN(rotation.originY))
				originY = rotation.originY;
			
			graphics.drawImage (image, x, y, rotation.angle, originX, originY);
		} else {
			graphics.drawImage (image, x, y);
		}
		graphics.popColor ();
	}
	
}