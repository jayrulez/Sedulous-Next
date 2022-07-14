using System;
namespace Sedulous.Foundation.Mathematics;

[CRepr]
struct TVector2<T>
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

	public static Self operator +(Self lhs, Self rhs)
	{
		Self result = .(lhs.X + rhs.X, lhs.Y + rhs.Y);
		return result;
	}

	public static Self operator -(Self lhs, Self rhs)
	{
		Self result = .(lhs.X - rhs.X, lhs.Y - rhs.Y);
		return result;
	}

	public static Self operator *(Self lhs, Self rhs)
	{
		Self result = .(lhs.X * rhs.X, lhs.Y * rhs.Y);
		return result;
	}

	public static Self operator *(T lhs, Self rhs)
	{
		Self result = .(lhs * rhs.X, lhs * rhs.Y);
		return result;
	}

	public static Self operator *(Self lhs, T rhs)
	{
		Self result = .(lhs.X * rhs, lhs.Y * rhs);
		return result;
	}

	public static Self operator /(Self lhs, Self rhs)
	{
		Self result = .(lhs.X / rhs.X, lhs.Y / rhs.Y);
		return result;
	}

	public static Self operator /(Self lhs, T rhs)
	{
		Self result = .(lhs.X / rhs, lhs.Y / rhs);
		return result;
	}

	public static Self operator -(Self lhs)
	{
		Self result = .(-lhs.X, -lhs.Y);
		return result;
	}

	public static T Dot(Self vector1, Self vector2)
	{
		return vector1.X * vector2.X + vector1.Y * vector2.Y;
	}

	public static void Dot(Self vector1, Self vector2, out T result)
	{
		result = vector1.X * vector2.X + vector1.Y * vector2.Y;
	}

	public static Self Transform(Self vector, TQuaternion<T> quaternion)
	{
		var x2 = quaternion.X + quaternion.X;
		var y2 = quaternion.Y + quaternion.Y;
		var z2 = quaternion.Z + quaternion.Z;

		var wz2 = quaternion.W * z2;
		var xx2 = quaternion.X * x2;
		var xy2 = quaternion.X * y2;
		var yy2 = quaternion.Y * y2;
		var zz2 = quaternion.Z * z2;

		Self result;

		result.X = vector.X * ((T)1 - yy2 - zz2) + vector.Y * (xy2 - wz2);
		result.Y = vector.X * (xy2 + wz2) + vector.Y * ((T)1 - xx2 - zz2);

		return result;
	}

	public static Self Normalize(Self vector)
	{
		T magnitude = (T)Math.Sqrt(vector.X * vector.X + vector.Y * vector.Y);
		T inverseMagnitude = (T)1 / magnitude;

		Self result;

		result.X = vector.X * inverseMagnitude;
		result.Y = vector.Y * inverseMagnitude;

		return result;
	}
}

typealias Vector2ui = TVector2<uint32>;

typealias Vector2 = TVector2<float>;
