using System;
namespace Sedulous.Foundation.Mathematics;


[CRepr]
struct TQuaternion<T>
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

	public this(TVector3<T> vector, T scalar)
	{
		X = vector.X;
		Y = vector.Y;
		Z = vector.Z;
		W = scalar;
	}
}

typealias Quaternion = TQuaternion<float>;