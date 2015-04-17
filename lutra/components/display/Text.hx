package lutra.components.display;

import retto.graphics.Color;
import lutra.components.Component;
import lutra.Scene;

/**
 * ...
 * @author Christoph Otter
 */
class Text extends Component
{
	@export public var text : String = "";
	@export public var color : Color = 0;
	@export public var size : Float = 16.0;
	@export public var style : Int = 0; //see retto.Graphics class for meaning
	@export public var font : String = "";
}