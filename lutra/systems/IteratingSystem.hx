package lutra.systems;
import lutra.components.Component;
import lutra.Entity;
import lutra.Scene;
import lutra.systems.System;
import retto.graphics.Graphics;

/**
 * A special type of system that iterates over all Entities and chooses those that have all required Components
 * @author Christoph Otter
 */
class IteratingSystem extends System
{
	var entities = new Array<Entity> ();
	var entitiesToRemove = new Array<Entity> ();
	var requiredComps : Array<Class<Component>>;

	/**
	 * This system will call updateEntity and renderEntity for every Entity that has all the (requiredComps)
	 */
	public function new (pScene : Scene, pType : String, requiredComps : Array<Class<Component>>)
	{
		super(pScene, pType);
		this.requiredComps = requiredComps;
	}

	override public function unload () : Void
	{
		entities = null;
		entitiesToRemove = null;
		requiredComps = null;
	}

	override public function update (dt : Float) : Void
	{
		for (i in 0 ... entities.length) {
			updateEntity (entities[i], dt);
		}
		
		for (i in 0 ... entitiesToRemove.length) {
			var e = entitiesToRemove.pop ();
			entities.remove (e);
		}
	}
	
	override public function render (g : Graphics) : Void
	{
		for (i in 0 ... entities.length) {
			renderEntity (entities[i], g);
		}
	}

	override public function entityAdded (entity : Entity) : Void
	{
		if (checkEntity (entity)) {
			entities.push (entity);
		}
	}

	override public function entityRemoved (entity : Entity) : Void
	{
		entities.remove (entity);
	}

	override public function entityChanged (entity : Entity):Void
	{
		if (!checkEntity (entity)) {
			entitiesToRemove.push (entity);
		}
	}

	inline function checkEntity (entity : Entity) : Bool
	{
		if (requiredComps == null) return true;
		
		var hasAllComps = true;
		//go through all required Components
		for (i in 0 ... requiredComps.length) {
			var c = requiredComps[i];
			if (!entity.components.has (c)) { //Entity misses necessary Component
				hasAllComps = false;
				break;
			}
		}
		
		return hasAllComps;
	}

	function updateEntity (entity : Entity, dt : Float) : Void
	{
	}
	
	function renderEntity (entity : Entity, graphics : Graphics) : Void
	{
	}

}