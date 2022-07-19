using System;
using Sedulous.Foundation.Utilities;
namespace Sedulous.Foundation.Mathematics;

[CRepr]
struct TVector4<T> : IHashable
	where int : operator explicit T
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

	public int GetHashCode()
	{
		int hash = 0;

		hash = HashHelper.CombineHash(hash, (.)X);
		hash = HashHelper.CombineHash(hash, (.)Y);
		hash = HashHelper.CombineHash(hash, (.)Z);
		hash = HashHelper.CombineHash(hash, (.)W);

		return hash;
	}
}

typealias Vector4 = TVector4<float>;