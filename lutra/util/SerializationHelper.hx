package lutra.util;
import haxe.Json;
import haxe.rtti.Meta;
import haxe.Serializer;
import haxe.Unserializer;
import lutra.components.Component;
import lutra.Entity;
import lutra.Scene;
import lutra.systems.System;
import lutra.util.SerializationMacro;
import openfl.Assets;

/**
 * ...
 * @author Christoph Otter
 */
class SerializationHelper
{
	public static inline function loadScene (asset : String) : Scene
	{
		var keep : {
			components: Array<Class<Component>>,
			systems : Array<Class<System>>
		} = SerializationMacro.includeFiles ();
		
		var ret = null;
		//try {
			ret = unserializeScene (Assets.getText (asset));
		/*}
		catch (e : Dynamic) {
			#if debug
			trace ("ERROR: Map file is corrupt: " + asset);
			#end
		}*/
		return ret;
	}
	
	public static function serializeScene (scene : Scene) : String
	{
		var s : JScene = {
			entities: [],
			systems: []
		};
		
		for (entity in scene.entities) {
			s.entities.push (serializeEntity (entity));
		}
		
		for (sys in scene.systems) {
			s.systems.push (serializeSystem (sys));
		}
		
		s.scaleMode = Serializer.run (scene.scaleMode);
		
		return Json.stringify (s);
	}
	
	public static function unserializeScene (s : String) : Scene
	{
		var s : JScene = Json.parse (s);
		
		var scene = new Scene ();
		
		for (e in s.entities) {
			scene.addEntity (unserializeEntity (scene, e));
		}
		for (sys in s.systems) {
			scene.addSystem (unserializeSystem (scene, sys));
		}
		
		if (s.scaleMode != null)
			scene.scaleMode = Unserializer.run (s.scaleMode);
		
		return scene;
	}
	
	//TODO: maybe allow System properties
	public static inline function serializeSystem (system : System) : String
	{
		var cls = Type.getClassName (Type.getClass (system));
		
		return cls;
	}
	
	public static inline function unserializeSystem (scene : Scene, s : String) : System
	{
		var cls = Type.resolveClass (s);
		
		return Type.createInstance (cls, [scene]);
	}
	
	public static function serializeEntity (entity : Entity, networked = false) : JEntity
	{
		var e = {
			components: [],
			name: entity.name
		}
		
		for (comp in entity.components) {
			var include = true;
			
			if (networked) {
				var meta = Meta.getType (Type.getClass (comp));
				include = Reflect.hasField (meta, "networked");
			}
			
			if (include)
				e.components.push (serializeComponent (comp));
		}
		return e;
	}
	
	/**
	 * Creates an Entity from the given string (s).
	 * If (reuse) is true and (scene) contains an Entity of the same name, the Entity is reused.
	 */
	public static function unserializeEntity (scene : Scene, e : JEntity, reuse = false) : Entity
	{
		var entity = if (reuse)
			scene.entities.get (e.name);
		else
			scene.newEntity (e.name);
		
		for (c in e.components) {
			var comp = unserializeComponent (scene, c, entity);
			entity.addComponent (comp);
		}
		
		return entity;
	}
	
	public static function serializeComponent (comp : Component) : Dynamic
	{
		var c : Dynamic = { };
		
		var cls = Type.getClass (comp);
		var metaFields = haxe.rtti.Meta.getFields (cls);
		var fields = Reflect.fields (metaFields);
		
		c.___clazz = Type.getClassName (cls);
		
		for (name in fields) {
			var hasExportMeta = Reflect.hasField (Reflect.field (metaFields, name), "export");
			if (hasExportMeta) {
				var value = Reflect.getProperty (comp, name);
				
				Reflect.setField (c, name, Serializer.run (value));
			}
		}
		
		return c;
	}
	
    public static function unserializeComponent (scene : Scene, c : Dynamic, ?entity : Entity) : Component
	{
		var cls = Type.resolveClass (c.___clazz);
		var clsFields = Type.getInstanceFields (cls);
		
		var comp = if (entity == null || !entity.hasComponent (cast cls))
			Type.createInstance (cls, [scene]);
		else
			entity.getComponent (cls);
		
		for (name in Reflect.fields (c)) {
			if (name != "___clazz") {
				if (clsFields.indexOf (name) != -1)
					Reflect.setProperty (comp, name, Unserializer.run (Reflect.field (c, name)));
			}
		}
		
		return comp;
    }
}
