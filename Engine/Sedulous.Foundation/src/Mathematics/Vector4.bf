namespace Sedulous.Foundation.Mathematics;

struct Vector4<T>
{
	public T X;
	public T Y;
	public T Z;
	public T W;

	public this()
	{
		X = default;
		Y = default;
		Z = default;
		W = default;
	}

	public this(T x, T y, T z, T w)
	{
		X = x;
		Y = y;
		Z = z;
		W = w;
	}

	public this(Vector3<T> vector, T scalar)
	{
		X = vector.X;
		Y = vector.Y;
		Z = vector.Z;
		W = scalar;
	}
}

typealias Vector4ui = Vector4<uint32>;