package lutra.components.display;
import retto.graphics.ImageData;

/**
 * Represents an Entity using an Image
 * @author Christoph Otter
 */
@component class Image extends Component
{	
	@export public var file (default, set) : String;
	
	public var image : ImageData;
	
	//TODO: size and color
	
	inline function set_file (f : String) : String
	{
		image = scene.loader.getImage (f);
		return file = f;
	}

}