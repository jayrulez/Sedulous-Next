using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Specifies the types of CPU access allowed for a resource.
	/// </summary>
	//[Flags]
	public enum ResourceCpuAccess : uint8
	{
		/// <summary>
		/// None (default value).
		/// </summary>
		None = 0x0,
		/// <summary>
		/// The CPU can be write this resource.
		/// </summary>
		Write = 0x1,
		/// <summary>
		/// the CPU can be read this resources.
		/// </summary>
		Read = 0x2
	}
}
