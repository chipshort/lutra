package lutra.components;

/**
 * ...
 * @author Christoph Otter
 */
@component @networked class Rotation extends Component
{
	@export public var angle : Float;
	
	//Math.NaN means: automatically use center of Image
	@export public var originX : Float = Math.NaN;
	@export public var originY : Float = Math.NaN;
}