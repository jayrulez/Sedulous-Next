namespace Sedulous.Foundation.Mathematics;

struct Vector3<T>
{
	public T X;
	public T Y;
	public T Z;

	public this()
	{
		X = default;
		Y = default;
		Z = default;
	}

	public this(T value)
	{
		X = value;
		Y = value;
		Z = value;
	}

	public this(T x, T y, T z)
	{
		X = x;
		Y = y;
		Z = z;
	}

	public this(Vector2<T> vector, T z)
	{
		X = vector.X;
		Y = vector.Y;
		Z = z;
	}
}

typealias Vector3ui = Vector3<uint32>;
typealias Vector3f = Vector3<float>;
