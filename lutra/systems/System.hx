package lutra.systems;
import lutra.Entity;
import lutra.Scene;
import retto.graphics.Graphics;

/**
 * Systems are used to update and render everything. They do the actual work.
 * Extend to this or IteratingSystem to create your own Systems.
 * Systems are required to have a constructor with the Scene object as the only argument!
 * @author Christoph Otter
 */
@:keepSub
class System
{
	//using type String to make Systems interchangable
	public var type (default, null) : String;
	var scene : Scene;
	
	/**
	 * The constructor of every subclass of System or IteratingSystem needs to have the Scene object as the only argument.
	 * Otherwise they will not work with the editor or when loading them from file.
	 */
	public function new (pScene : Scene, pType : String)
	{
		scene = pScene;
		type = pType;
	}
	
	/**
	 * Called when you should initiate
	 */
	public function init () : Void
	{
	}

	/**
	 * Called when this System is removed from a Scene
	 */
	public function unload () : Void
	{
	}

	/**
	 * Use this function to update your game logic
	 */
	public function update (dt : Float) : Void
	{
	}
	
	/**
	 * Use this function to render your visuals
	 */
	public function render (g : Graphics) : Void
	{
	}

	/**
	 * Called when an Entity was added to the Scene
	 */
	public function entityAdded (entity : Entity) : Void
	{
	}

	/**
	 * Called when an Entity was removed from the Scene
	 */
	public function entityRemoved (entity : Entity) : Void
	{
	}

	/**
	 * Called when an Entity was changed (Components removed / added)
	 */
	public function entityChanged (entity : Entity) : Void
	{
	}
	
	/**
	 * Called when a message from another System is recieved
	 */
	public function onMessage (type : String, msg : String, data : Dynamic) : Void
	{
	}
	
	/**
	 * Sends a message to all Systems registered as listeners for this System's messages
	 */
	@:access(lutra.Scene)
	inline function sendMessage (msg : String, data : Dynamic) : Void
	{
		scene.fireMessage (type, msg, data);
	}
	
	/**
	 * Sends a message to the System of type (receiver).
	 * If no such System exists, nothing happens.
	 */
	inline function sendMessageTo (receiver : String, msg : String, data : Dynamic) : Void
	{
		var sys = scene.getSystem (receiver);
		
		if (sys != null)
			sys.onMessage (type, msg, data);
	}
}