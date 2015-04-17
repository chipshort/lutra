package lutra.components;

/**
 * The coordinates of the Entity's center
 * @author Christoph Otter
 */
@component @networked class Position extends Component
{
	@export public var x : Float = 0;
	@export public var y : Float = 0;
}