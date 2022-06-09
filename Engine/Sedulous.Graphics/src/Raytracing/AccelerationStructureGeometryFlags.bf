using System;

namespace Sedulous.Graphics.Raytracing
{
	/// <summary>
	/// Flags specifying additional parameters for acceleration structure builds.
	/// </summary>
	//[Flags]
	public enum AccelerationStructureGeometryFlags
	{
		/// <summary>
		/// No options specified.
		/// </summary>
		None = 0x0,
		/// <summary>
		/// When rays encounter this geometry, the geometry acts as if no any hit shader is present.
		/// It is recommended to use this flag liberally, as it can enable important ray processing optimizations.
		/// </summary>
		Opaque = 0x1,
		/// <summary>
		/// By default, the system is free to trigger an any hit shader more than once for a given ray-primitive intersection.
		/// This flexibility helps improve the traversal efficiency of acceleration structures in certain cases
		/// </summary>
		NoDuplicateAnyhitInverseOcation = 0x2
	}
}
