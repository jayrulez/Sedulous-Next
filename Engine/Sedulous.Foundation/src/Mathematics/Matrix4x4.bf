namespace Sedulous.Foundation.Mathematics;

struct Matrix4x4<T>
	where T : operator - T
	where T : operator implicit int
{
	public T M11;
	public T M12;
	public T M13;
	public T M14;

	public T M21;
	public T M22;
	public T M23;
	public T M24;

	public T M31;
	public T M32;
	public T M33;
	public T M34;

	public T M41;
	public T M42;
	public T M43;
	public T M44;

	public this(
		T M11, T M12, T M13, T M14,
		T M21, T M22, T M23, T M24,
		T M31, T M32, T M33, T M34,
		T M41, T M42, T M43, T M44)
	{
		this.M11 = M11;
		this.M12 = M12;
		this.M13 = M13;
		this.M14 = M14;

		this.M21 = M21;
		this.M22 = M22;
		this.M23 = M23;
		this.M24 = M24;

		this.M31 = M31;
		this.M32 = M32;
		this.M33 = M33;
		this.M34 = M34;

		this.M41 = M41;
		this.M42 = M42;
		this.M43 = M43;
		this.M44 = M44;
	}

	public static Matrix4x4<T> Identity { get; } = .(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);

	public Vector3<T> Right
	{
		get { return .(M11, M12, M13); }
		set mut
		{
			M11 = value.X;
			M12 = value.Y;
			M13 = value.Z;
		}
	}

	public Vector3<T> Left
	{
		get { return .(-M11, -M12, -M13); }
		set mut
		{
			M11 = -value.X;
			M12 = -value.Y;
			M13 = -value.Z;
		}
	}

	public Vector3<T> Up
	{
		get { return .(M21, M22, M23); }
		set mut
		{
			M21 = value.X;
			M22 = value.Y;
			M23 = value.Z;
		}
	}

	public Vector3<T> Down
	{
		get { return .(-M21, -M22, -M23); }
		set mut
		{
			M21 = -value.X;
			M22 = -value.Y;
			M23 = -value.Z;
		}
	}

	public Vector3<T> Backward
	{
		get { return .(M31, M32, M33); }
		set mut
		{
			M31 = value.X;
			M32 = value.Y;
			M33 = value.Z;
		}
	}

	public Vector3<T> Forward
	{
		get { return .(-M31, -M32, -M33); }
		set mut
		{
			M31 = -value.X;
			M32 = -value.Y;
			M33 = -value.Z;
		}
	}

	public Vector3<T> Translation
	{
		get { return .(M41, M42, M43); }
		set mut
		{
			M41 = value.X;
			M42 = value.Y;
			M43 = value.Z;
		}
	}
}

typealias Matrix4x4f = Matrix4x4<float>;
