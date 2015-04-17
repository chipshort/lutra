package lutra;
import lutra.systems.System;
import openfl.Lib;
import retto.Game;
import retto.graphics.Graphics;
import retto.net.Connection;
import retto.util.OrderedStringMap;

private enum Action
{
	AddEntity (entity : Entity);
	RemoveEntity (entity : Entity);
	ChangedEntity (entity : Entity);
	AddSystem (system : System);
	RemoveSystem (system : String);
}

/**
 * A Scene is like a screen containing all the Entities.
 * It also manages the Systems.
 * @author Christoph Otter
 */
class Scene extends Game
{
	public static var current (default, null) : Scene;
	static var entityPool = new Array<Entity> ();
	
	public var entities = new OrderedStringMap<Entity> ();
	public var systems = new OrderedStringMap<System> ();
	
	var actionQueue = new Array<Action> (); //event queue
	
	var messageHandlers = new Map<String, Array<String>> ();
	
	/**
	 * @return an Entity from entityPool or a new one if entityPool is empty
	 */
	@:access(lutra.Entity)
	public function newEntity (name : String) : Entity
	{
		if (entityPool.length > 0) {
			var e = entityPool.pop ();
			e.name = name;
			
			return e;
		}
		
		return new Entity (name);
	}
	
	#if !server
	/**
	 * This sets this Scene as the currently active Scene
	 * It automatically hides the currently active Scene
	 */
	override public function show () : Void
	{
		if (!inited) finishLoading ();
		
		var stage = Lib.current.stage;
		
		//remove current scene if there is one
		if (current != null) {
			current.hide ();
			//stage.removeChild (current);
			//current.dispose (); //dispose here?
		}
		
		current = this;
		
		stage.addChild (this);
	}
	
	public inline function hide () : Void
	{
		stage.removeChild (this);
		current = null;
	}
	#end
	
	override public function dispose () : Void
	{
		inited = false;
		
		for (entity in entities)
			entity.dispose ();
		
		for (system in systems.keys ())
			removeSystem (system);
		
		super.dispose ();
	}
	
	/**
	 * Adds an Entity to this Scene
	 */
	public inline function addEntity (entity : Entity) : Void
	{
		if (inited)
			actionQueue.push (AddEntity (entity));
		else
			_addEntity (entity);
	}

	/**
	 * Removes an Entity from this Scene
	 */
	public inline function removeEntity (entity : Entity) : Void
	{
		if (inited)
			actionQueue.push (RemoveEntity (entity));
		else
			_removeEntity (entity);
	}

	/**
	 * Adds a System to this Scene
	 */
	public inline function addSystem (system : System) : Void
	{
		if (inited)
			actionQueue.push (AddSystem (system));
		else
			_addSystem (system);
	}

	/**
	 * Removes the System of type (system) from this Scene
	 */
	public inline function removeSystem (system : String) : Void
	{
		if (inited)
			actionQueue.push (RemoveSystem (system));
		else
			_removeSystem (system);
	}

	/**
	 * Checks if there is a systen of type (system) in this Scene
	 */
	public inline function hasSystem (system : String) : Bool
	{
		return systems.exists (system);
	}
	
	/**
	 * Returns the System of the type (type), null if this Scene has no such System
	 */
	public inline function getSystem (type : String) : System
	{
		return systems.get (type);
	}
	
	/**
	 * Registers (system) to get notified about messages from (type) System.
	 */
	public function registerMessageHandler (system : System, type : String) : Void
	{
		var list = messageHandlers[type];
		
		if (list == null)
			messageHandlers[type] = list = new Array<String> ();
		else if (list.indexOf (system.type) != -1) //already registered
			return;
		
		list.push (system.type);
	}
	
	function fireMessage (sysType : String, msg : String, data : Dynamic) : Void
	{
		var list = messageHandlers[sysType];
		
		if (list == null) return;
		
		var toBeRemoved = new Array<String> ();
		
		for (sys in list) {
			var system = getSystem (sys);
			if (system == null) {
				toBeRemoved.push (sys);
				continue;
			}
			system.onMessage (sysType, msg, data);
		}
		
		for (removeMe in toBeRemoved) {
			list.remove (removeMe);
		}
	}
	
	override function onInit () : Void
	{
		for (system in systems)
			system.init ();
		
		onInitScene ();
	}
	
	override public function onDraw (g : Graphics) : Void
	{
		g.clear ();
		
		for (system in systems)
			system.render (g);
		
		onDrawScene (g);
	}
	
	override function onUpdate (dt : Float) : Void
	{
		for (system in systems)
			system.update (dt);
		
		for (action in actionQueue) {
			switch (action) {
				case AddEntity (e):
					_addEntity (e);
				case RemoveEntity (e):
					_removeEntity (e);
				case ChangedEntity (e):
					_entityChanged (e);
				case AddSystem (s):
					_addSystem (s);
				case RemoveSystem (s):
					_removeSystem (s);
			}
		}
		
		if (actionQueue.length > 0)
			actionQueue = [];
		
		onUpdateScene (dt);
	}
	
	//These can be used without any System.
	public dynamic function onInitScene () : Void
	{
	}
	public dynamic function onDrawScene (g : Graphics) : Void
	{
	}
	public dynamic function onUpdateScene (dt : Float) : Void
	{
	}
	
	
	function entityChanged (entity : Entity) : Void
	{
		if (inited)
			actionQueue.push (ChangedEntity (entity));
		else
			_entityChanged (entity);
	}
	
	function _entityChanged (entity : Entity) : Void
	{
		for (system in systems) {
			system.entityChanged (entity);
		}
	}
	
	//actual actions
	function _addSystem (system : System) : Void
	{
		//systems.setByValue (system);
		var type = system.type;
		
		if (systems.exists (type))
			systems.remove (type);
		
		systems.set (type, system);
		
		//add all entities
		for (entity in entities)
			system.entityAdded (entity);
		
		if (inited)
			system.init ();
	}
	function _removeSystem (system : String) : Void
	{
		systems.remove (system);
		//unload System
		var sys = systems.get (system);
		if (sys != null)
			sys.unload ();
	}
	function _addEntity (entity : Entity) : Void
	{
		if (entity == null || entity.name == null) {
			#if debug
			trace ("ERROR: Cannot add an entity that is null or whose name is null");
			#end
			return;
		}
		
		#if debug
		if (entities.exists (entity.name))
			trace ("WARNING: There already is an entity with the same name");
		#end
		entities.set (entity.name, entity);
		entity.scene = this;
		for (system in systems)
			system.entityAdded (entity);
	}
	function _removeEntity (entity : Entity) : Void
	{
		if (entity == null || entity.name == null) {
			#if debug
			trace ("ERROR: Cannot remove and entity that is null or whose name is null");
			#end
			return;
		}
		
		entities.remove (entity.name);
		entity.scene = null;
		for (system in systems)
			system.entityRemoved (entity);
	}
}