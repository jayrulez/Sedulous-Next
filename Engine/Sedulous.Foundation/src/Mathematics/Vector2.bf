namespace Sedulous.Foundation.Mathematics;

struct Vector2<T>
{
	public T X;
	public T Y;

	public this()
	{
		X = default;
		Y = default;
	}

	public this(T value)
	{
		this.X = value;
		this.Y = value;
	}

	public this(T x, T y)
	{
		X = x;
		Y = y;
	}
}

typealias Vector2ui = Vector2<uint32>;
