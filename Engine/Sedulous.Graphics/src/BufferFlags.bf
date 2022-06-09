using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Identifies how to bing a buffer.
	/// </summary>
	//[Flags]
	public enum BufferFlags
	{
		/// <summary>
		/// No option.
		/// </summary>
		None = 0x0,
		/// <summary>
		/// Bind a buffer as a vertex buffer to the input-assembler stage.
		/// </summary>
		VertexBuffer = 0x1,
		/// <summary>
		/// Bind a buffer as an index buffer to the input-assembler stage.
		/// </summary>
		IndexBuffer = 0x2,
		/// <summary>
		/// Bind a buffer as a constant buffer to a shader stage. This flag may NOT be combined with any other bind flag.
		/// </summary>
		ConstantBuffer = 0x4,
		/// <summary>
		/// Bind a buffer or texture to a shader stage.
		/// </summary>
		ShaderResource = 0x8,
		/// <summary>
		/// Bind a buffer to used in a raytracing stage.
		/// </summary>
		AccelerationStructure = 0x10,
		/// <summary>
		/// Bind a texture as a render target for the output-merger stage.
		/// </summary>
		RenderTarget = 0x20,
		/// <summary>
		/// Bind an unordered access resource.
		/// </summary>
		UnorderedAccess = 0x40,
		/// <summary>
		///  Enables a resource as a structured buffer.
		/// </summary>
		BufferStructured = 0x80,
		/// <summary>
		/// Indirect Buffer.
		/// </summary>
		IndirectBuffer = 0x100
	}
}
