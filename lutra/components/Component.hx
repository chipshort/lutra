package lutra.components;

import haxe.Serializer;
import haxe.Unserializer;
import lutra.Scene;

/**
 * The base class for all Components.
 * @author Christoph Otter
 */
@:keepSub
class Component
{
	var scene : Scene;
	
	/**
	 * Every subclass of Component needs to have exactly this constructor.
	 * Otherwise they will not work with the editor or when loading them from file.
	 */
	public function new (s : Scene) 
	{
		scene = s;
	}
	
}
