package lutra;
import lutra.components.Component;
import lutra.util.ClassMap;
import lutra.util.SerializationHelper;


/**
 * Entities are containers for Components, their behaviour is determined by their Components.
 * You can override this class, but you should not do that (and you should not have to do this)
 * @author Christoph Otter
 */
@:access(lutra.Scene)
class Entity
{
	public var components = new ClassMap<Component> ();
	public var scene (null, default) : Scene;
	
	//TODO: allow entity trees?
	//change Rotation, Position to have a function to get global value (incorporating parent entity)
	
	public var name (default, null) : String;
	
	public function new (n : String)
	{
		name = n;
	}
	
	public function dispose () : Void
	{
		if (scene != null)
			scene.removeEntity (this);
		
		components = new ClassMap<Component> ();
		
		Scene.entityPool.push (this);
	}
	
	/**
	 * Adds (comp) as a Component to this Entity. If there already is a Component of that type, it's lost
	 */
	public inline function addComponent (comp : Component)
	{
		components.setByValue (comp);
		entityChanged ();
	}
	
	/**
	 * Removes a Component of the type (comp) from this Entity (e.g.: Position)
	 */
	public inline function removeComponent (comp : Class<Component>)
	{
		components.remove (comp);
		entityChanged ();
	}
	
	/**
	 * Checks if this Entity has a Component of the type (comp) attached to it
	 */
	public inline function hasComponent (comp : Class<Component>) : Bool
	{
		return components.has (comp);
	}
	
	/**
	 * @return The Component if it exists, null otherwise
	 */
	public inline function getComponent<T : Component> (type : Class<T>) : Null<T>
	{
		return components[type];
	}
	
	/**
	 * Creates a copy of this Entity using (name) as the copy's name.
	 */
	public inline function copy (name : String, ?s : Scene) : Entity
	{
		if (s == null) s = scene;
		
		var e = SerializationHelper.unserializeEntity (s, SerializationHelper.serializeEntity (this));
		e.name = name;
		
		return e;
	}
	
	/**
	 * @return Whether this Entity equals with (entity)
	 * This checks all Components and the name for actual equality (not just by reference)
	 */
	public inline function equals (entity : Entity) : Bool
	{
		return SerializationHelper.serializeEntity (this) == SerializationHelper.serializeEntity (entity);
	}
	
	inline function entityChanged () : Void
	{
		if (scene == null) return;
		
		scene.entityChanged (this);
	}
	
}