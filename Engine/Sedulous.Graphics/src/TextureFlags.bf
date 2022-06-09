using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Identifies how to bing a texture.
	/// </summary>
	//[Flags]
	public enum TextureFlags : uint8
	{
		/// <summary>
		/// No option.
		/// </summary>
		None = 0x0,
		/// <summary>
		/// A texture usable as a ShaderResourceView.
		/// </summary>
		ShaderResource = 0x1,
		/// <summary>
		/// A texture usable as render target.
		/// </summary>
		RenderTarget = 0x2,
		/// <summary>
		/// A texture usable as an unordered access buffer.
		/// </summary>
		UnorderedAccess = 0x4,
		/// <summary>
		/// A texture usable as a depth stencil buffer.
		/// </summary>
		DepthStencil = 0x8,
		/// <summary>
		/// Enables MIP map generation by GPU
		/// </summary>
		GenerateMipmaps = 0x10
	}
}
