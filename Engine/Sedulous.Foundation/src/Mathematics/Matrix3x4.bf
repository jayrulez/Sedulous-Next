using System;
namespace Sedulous.Foundation.Mathematics;


[CRepr]
struct Matrix3x4<T>
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

	public this(
		T M11, T M12, T M13, T M14,
		T M21, T M22, T M23, T M24,
		T M31, T M32, T M33, T M34)
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
	}
}
