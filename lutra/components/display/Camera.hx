package lutra.components.display;
import lutra.components.Component;

/**
 * ...
 * @author Christoph Otter
 */
@component class Camera extends Component
{
	@export public var active : Bool = true;
	@export public var offsetX : Int = 0;
	@export public var offsetY : Int = 0;
}