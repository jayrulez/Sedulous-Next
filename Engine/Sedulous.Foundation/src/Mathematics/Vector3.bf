using System;
namespace Sedulous.Foundation.Mathematics;

[CRepr]
struct TVector3<T>
	where T : operator - T
	where T : operator T + T
	where T : operator T - T
	where T : operator T * T
	where T : operator T / T
	where T : operator explicit int
	where T : operator implicit float
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

	public this(TVector2<T> vector, T z)
	{
		X = vector.X;
		Y = vector.Y;
		Z = z;
	}
}

typealias Vector3 = TVector3<float>;

typealias Float3 = TVector3<float>;
