using System;

namespace Sedulous.Graphics.Raytracing
{
	/// <summary>
	/// Raytracing instance flags.
	/// </summary>
	//[Flags]
	public enum AccelerationStructureInstanceFlags
	{
		/// <summary>
		/// No options specified.
		/// </summary>
		None = 0x0,
		/// <summary>
		/// Disables front/back face culling for this instance.
		/// </summary>
		TriangleCullDisable = 0x1,
		/// <summary>
		/// This flag reverses front and back facings.
		/// </summary>
		TriangleFrontCounterclockwise = 0x2,
		/// <summary>
		/// Applied to all the geometries in the bottom-level acceleration structure referenced by the instance
		/// </summary>
		ForceOpaque = 0x3,
		/// <summary>
		/// Applied to any of the geometries in the bottom-level acceleration structure referenced by the instance
		/// </summary>
		ForceNonOpaque = 0x4
	}
}
