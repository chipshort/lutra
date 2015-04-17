package lutra.systems.display;
import lutra.systems.RenderSystem;
import retto.graphics.Graphics;

import lutra.components.display.Text;
import lutra.components.Position;
import lutra.Entity;
import lutra.systems.IteratingSystem;

/**
 * Renders Entities with a Text Component at their Position Component.
 * Note: This requires RenderingSystem.
 * @author Christoph Otter
 */
@system class TextSystem extends RenderSystem
{

	public function new (scene : Scene)
	{
		super (scene, "text", [Position, Text]);
	}
	
	override function renderEntity (entity : Entity, graphics : Graphics) : Void 
	{
		var pos = entity.getComponent (Position);
		var txt = entity.getComponent (Text);
		var font = txt.font == "" ? null : txt.font;
		
		graphics.pushColor (0xFFFFFFFF);
		graphics.drawText (txt.text, pos.x, pos.y, txt.size, font);
		graphics.popColor ();
	}
	
}