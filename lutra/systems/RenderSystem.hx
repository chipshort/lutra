package lutra.systems;

import lutra.components.Component;
import lutra.Entity;
import lutra.Scene;
import retto.graphics.Graphics;

/**
 * Extend RenderSystem to maintain correct rendering order of entities.
 * RenderSystem extends IteratingSystem, but makes sure renderEntity is called in the correct order.
 * @author Christoph Otter
 */
class RenderSystem extends IteratingSystem
{

	public function new (pScene : Scene, pType : String, requiredComps : Array<Class<Component>>)
	{
		super (pScene, pType, requiredComps);
		
		scene.registerMessageHandler (this, "rendering");
	}
	
	override public function render (g : Graphics) : Void
	{
	}
	
	override public function onMessage (type : String, msg : String, data : Dynamic) : Void 
	{
		if (type == "rendering" && msg == "renderEntity") {
			var entity : Entity = data.e;
			
			if (checkEntity (entity))
				renderEntity (entity, data.g);
		}
	}
	
}