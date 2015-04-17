package lutra.util;

/**
 * This represents a map of the type [Class<T> => T]
 */
abstract ClassMap<T> (OrderedClassMap<Dynamic>) //have to use Dynamic because of Java?
{
	public inline function new ()
	{
		this = new OrderedClassMap<T> ();
	}

	/**
	 * Checks if there is a T of this type
	 * @return true if there is such a Component, false if not
	 */
	public inline function has (type : Class<T>) : Bool
	{
		return this.exists (type);
	}

	/**
	 * @return the T if it exists, null otherwise
	 */
	@:arrayAccess public inline function get<S : T> (type : Class<S>) : Null<S>
	{
		return cast this.get (cast type);
	}

	/**
	 * Removes the T from this map
	 */
	public inline function remove (type : Class<T>) : Void
	{
		this.remove (type);
	}

	/**
	 * Uses the T's type as key to set it
	 */
	public inline function setByValue (v : T) : Void
	{
		this.set (Type.getClass (v), v);
	}

	public inline function iterator () : Iterator<T>
	{
		return this.iterator ();
	}
}

/**
 * A map that uses the type of an object as it's key and keeps the order they were added
 * @author Christoph Otter
 */
class OrderedClassMap<T> implements Map.IMap<Class<T>, T>
{
	var map : Map<String, T>;
	var keyList : List<String>;

	public function new ()
	{
		map = new Map<String, T> ();
		keyList = new List<String> ();
	}
	
	public function get (k : Class<T>) : Null<T>
	{
		return map.get (Type.getClassName (k));
	}
	public function set (k : Class<T>, v : T) : Void
	{
		var key = Type.getClassName (k);
		
		if (!map.exists (key)) keyList.add (key);
		map.set (key, v);
	}
	public function exists (k : Class<T>) : Bool
	{
		return map.exists (Type.getClassName (k));
	}
	public function remove (k : Class<T>) : Bool
	{
		var key = Type.getClassName (k);
		
		keyList.remove (key);
		return map.remove (key);
	}
	public function keys () : Iterator<Class<T>>
	{
		var keys = keyList.iterator ();
		return {
			hasNext: keys.hasNext,
			next: function () : Dynamic {
				return cast Type.resolveClass (keys.next ());
			}
		};
	}
	public function iterator () : Iterator<T>
	{
		var keys = keyList.iterator ();
		var _map = map;
		return {
			next: function () {
				return _map.get (keys.next ());
			},
			hasNext: function () {
				return keys.hasNext (); //does not work without surrounding function, for some reason?
			}
		}
	}
	public function toString () : String
	{
		return map.toString (); //actually, this should be done differently to ensure the order, but atm, I do not care.
	}
}