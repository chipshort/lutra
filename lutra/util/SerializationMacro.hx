package lutra.util;

#if macro
import haxe.io.Path;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.Unserializer;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import haxe.macro.ExprTools;
#end
//import lutra.util.SerializationHelper.JScene;

/**
 * ...
 * @author Christoph Otter
 */
class SerializationMacro
{
	static var components = new Array<String> ();
	static var systems = new Array<String> ();
	
	macro public static function loadScene (file : ExprOf<String>) : ExprOf<Scene>
	{
		var f = Context.resolvePath ("../" + ExprTools.getValue (file));
		
		Context.registerModuleDependency (Context.getLocalModule (), f);
		var code = unserializeScene (File.getContent (f));
		
		return Context.parseInlineString (code, Context.currentPos ());
	}
	
	macro public static function includeFiles () : Expr
	{
		var folders = new Array<String> ();
		
		for (path in Context.getClassPath ()) {
			if (FileSystem.exists (path) && FileSystem.isDirectory (path)) {
				includeDir (path);
			}
			else if (FileSystem.exists (path)) {
				includeFile (path);
			}
		}
		
		var comps = "components: " + toArrayString (components) + ",";
		var sys = "systems: " + toArrayString (systems);
		
		Compiler.keep ("Reflect");
		
		return Context.parseInlineString ("{" + comps + sys + "}", Context.currentPos ());
	}
	
	#if macro
	static function unserialize (data : String) : String
	{
		try {
			var res = Unserializer.run (data);
			
			if (Math.isNaN (res)) return "Math.NaN";
			else if (res == Math.NEGATIVE_INFINITY) return "Math.NEGATIVE_INFINITY";
			else if (res == Math.POSITIVE_INFINITY) return "Math.POSITIVE_INFINITY";
			else if (Std.is (res, Bool)) return Std.string (res);
			else if (Std.is (res, Int)) return Std.string (res);
			else if (Std.is (res, String)) return '"' + res + '"';
			else if (Std.is (res, Float)) return Std.string (res);
		} catch (e : Dynamic) {
		}
		
		return 'haxe.Unserializer.run ("' + data + '")';
	}
	
	static function unserializeScene (s : String) : String
	{
		var s : JScene = Json.parse (s);
		var result = "{ var scene = new lutra.Scene ();";
		
		
		for (e in s.entities) {
			result += "scene.addEntity (" + unserializeEntity (e) + ");";
		}
		for (sys in s.systems) {
			result += "scene.addSystem (" + unserializeSystem (sys) + ");";
		}
		
		if (s.scaleMode != null)
			result += 'scene.scaleMode = haxe.Unserializer.run ("' + s.scaleMode + '");';
		
		return result + " scene; }";
	}
	
	static inline function unserializeSystem (s : String) : String
	{
		return 'new $s (scene)';
	}
	
	static function unserializeEntity (e : JEntity, reuse = false) : String
	{
		var result = "{ var entity = ";
		if (reuse)
			result += 'scene.entities.get ("' + e.name + '");';
		else
			result += 'scene.newEntity ("' + e.name + '");';
		
		for (c in e.components) {
			var comp = unserializeComponent (c);
			result += "entity.addComponent (" + comp + ");";
		}
		
		return result + " entity; }";
	}
	
	static function unserializeComponent (c : Dynamic) : String
	{
		var cls = c.___clazz;
		var result = '{ var component = if (entity.hasComponent ( $cls ))';
		result += ' entity.getComponent ( $cls );';
		result += ' else new $cls (scene);';
		
		for (name in Reflect.fields (c)) {
			if (name != "___clazz") {
				var data = unserialize (Reflect.field (c, name));
				
				result += 'component.$name = $data ;';
			}
		}
		
		return result + " component; }";
    }
	
	static function includeDir (dir : String) : Void
	{
		for (f in FileSystem.readDirectory (dir)) {
			var newF = FileSystem.fullPath (dir + f);
			if (FileSystem.exists (newF) && FileSystem.isDirectory (newF)) {
				includeDir (Path.addTrailingSlash (newF));
			}
			else if (FileSystem.exists (newF)) {
				includeFile (newF);
			}
		}
	}
	
	static function includeFile (file : String) : Void
	{
		//TODO: find a better solution to check if it is a Component than using indexOf
		//maybe HaxeLanguageServices?
		
		if (!StringTools.endsWith (file, ".hx")) return;
		
		var content = File.getContent (file);
		
		var extendsComp = content.indexOf ("extends Component") != -1 ||
			content.indexOf ("extends lutra.components.Component") != -1;
		
		if (content.indexOf ("@component") != -1 && extendsComp) { //TODO: use @:component instead
			var comp = getPackage (file, content);
			
			if (comp != null && comp != "lutra.util.SerializationMacro") {
				//Compiler.keep (comp);
				components.push (comp);
			}
		}
		else if (content.indexOf ("@system") != -1) {
			var sys = getPackage (file, content);
			
			if (sys != null && sys != "lutra.util.SerializationMacro") {
				//Compiler.keep (sys);
				systems.push (sys);
			}
		}
	}
	
	static function getPackage (file : String, source : String) : String
	{
		var split = source.split ("\n");
		for (line in split) {
			var l = StringTools.trim (line);
			
			if (StringTools.startsWith (l, "package ")) {
				var pack = StringTools.trim (l.substring (8, l.indexOf (";"))); //TODO: trim
				var name = Path.withoutExtension (Path.withoutDirectory (file));
				
				return pack + "." + name;
			}
		}
		return null;
	}
	
	static function toArrayString<T> (array : Array<T>) : String
	{
		var a = "[";
		for (x in array) {
			a += /*"\"" +*/ x + ", "/*"\", "*/;
		}
		a = a.substring (0, a.length - 2);
		a += "]";
		
		return a;
	}
	#end
}


//Helper definitions
typedef JScene = {
	entities : Array<JEntity>,
	systems : Array<String>,
	?scaleMode : String
}

typedef JEntity = {
	components : Array<Dynamic>,
	name : String
}