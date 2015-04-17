package lutra.components.sound;

import openfl.media.Sound;
import retto.Loader;

/**
 * A basic component for sound emitting
 * @author Christoph Otter
 */
@component class SoundEmitter extends Component
{
	@export public var file (default, set) : String;
	
	public var sound : Sound;
	
	inline function set_file (f : String) : String
	{
		sound = scene.loader.getSound (f);
		return file = f;
	}
	
	public inline function play () : Void
	{
		sound.play ();
	}
}