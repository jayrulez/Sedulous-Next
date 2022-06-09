using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// An enum.
	/// </summary>
	//[Flags]
	public enum CompilationMode : uint8
	{
		/// <summary>
		/// Shaders are compiled without special parameters.
		/// </summary>
		None = 0x0,
		/// <summary>
		/// Shaders are compiled with debug information.
		/// </summary>
		Debug = 0x1,
		/// <summary>
		/// Shaders are compiled with optimizations.
		/// </summary>
		Release = 0x2
	}
}
