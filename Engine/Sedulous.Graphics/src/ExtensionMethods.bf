using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Extension Methods.
	/// </summary>
	public static class ExtensionMethods
	{
		/// <summary>
		/// Indicates if this format is in Gamma Color Scapce.
		/// </summary>
		/// <param name="format">Pixel format.</param>
		/// <returns>Is in gamma space.</returns>
		public static bool IsGammaColorSpaceFormat(this PixelFormat format)
		{
			switch (format)
			{
			case PixelFormat.R32G32B32A32_Float: fallthrough;
			case PixelFormat.R32G32B32_Float: fallthrough;
			case PixelFormat.R16G16B16A16_Float: fallthrough;
			case PixelFormat.R32G32_Float: fallthrough;
			case PixelFormat.R11G11B10_Float: fallthrough;
			case PixelFormat.R8G8B8A8_UNorm_SRgb: fallthrough;
			case PixelFormat.R16G16_Float: fallthrough;
			case PixelFormat.D32_Float: fallthrough;
			case PixelFormat.R32_Float: fallthrough;
			case PixelFormat.R16_Float: fallthrough;
			case PixelFormat.BC1_UNorm_SRgb: fallthrough;
			case PixelFormat.BC2_UNorm_SRgb: fallthrough;
			case PixelFormat.BC3_UNorm_SRgb: fallthrough;
			case PixelFormat.B8G8R8A8_UNorm_SRgb: fallthrough;
			case PixelFormat.B8G8R8X8_UNorm_SRgb: fallthrough;
			case PixelFormat.BC7_UNorm_SRgb: fallthrough;
			case PixelFormat.PVRTC_2BPP_RGB_SRGB: fallthrough;
			case PixelFormat.PVRTC_4BPP_RGB_SRGB: fallthrough;
			case PixelFormat.PVRTC_2BPP_RGBA_SRGBA: fallthrough;
			case PixelFormat.PVRTC_4BPP_RGBA_SRGBA: fallthrough;
			case PixelFormat.ETC2_RGBA_SRGB:
				return false;
			default:
				return true;
			}
		}

		/// <summary>
		/// Get Format size in bits (8 bits = uint8).
		/// </summary>
		/// <param name="format">Pixel format.</param>
		/// <returns>Size in bits.</returns>
		public static uint32 GetSizeInBits(this PixelFormat format)
		{
			switch (format)
			{
			case PixelFormat.R32G32B32A32_Typeless: fallthrough;
			case PixelFormat.R32G32B32A32_Float: fallthrough;
			case PixelFormat.R32G32B32A32_UInt: fallthrough;
			case PixelFormat.R32G32B32A32_SInt:
				return 128u;
			case PixelFormat.R32G32B32_Typeless: fallthrough;
			case PixelFormat.R32G32B32_Float: fallthrough;
			case PixelFormat.R32G32B32_UInt: fallthrough;
			case PixelFormat.R32G32B32_SInt:
				return 96u;
			case PixelFormat.R16G16B16A16_Typeless: fallthrough;
			case PixelFormat.R16G16B16A16_Float: fallthrough;
			case PixelFormat.R16G16B16A16_UNorm: fallthrough;
			case PixelFormat.R16G16B16A16_UInt: fallthrough;
			case PixelFormat.R16G16B16A16_SNorm: fallthrough;
			case PixelFormat.R16G16B16A16_SInt: fallthrough;
			case PixelFormat.R32G32_Typeless: fallthrough;
			case PixelFormat.R32G32_Float: fallthrough;
			case PixelFormat.R32G32_UInt: fallthrough;
			case PixelFormat.R32G32_SInt: fallthrough;
			case PixelFormat.R32G8X24_Typeless: fallthrough;
			case PixelFormat.D32_Float_S8X24_UInt: fallthrough;
			case PixelFormat.R32_Float_X8X24_Typeless: fallthrough;
			case PixelFormat.X32_Typeless_G8X24_UInt:
				return 64u;
			case PixelFormat.R10G10B10A2_Typeless: fallthrough;
			case PixelFormat.R10G10B10A2_UNorm: fallthrough;
			case PixelFormat.R10G10B10A2_UInt: fallthrough;
			case PixelFormat.R11G11B10_Float: fallthrough;
			case PixelFormat.R8G8B8A8_Typeless: fallthrough;
			case PixelFormat.R8G8B8A8_UNorm: fallthrough;
			case PixelFormat.R8G8B8A8_UNorm_SRgb: fallthrough;
			case PixelFormat.R8G8B8A8_UInt: fallthrough;
			case PixelFormat.R8G8B8A8_SNorm: fallthrough;
			case PixelFormat.R8G8B8A8_SInt: fallthrough;
			case PixelFormat.R16G16_Typeless: fallthrough;
			case PixelFormat.R16G16_Float: fallthrough;
			case PixelFormat.R16G16_UNorm: fallthrough;
			case PixelFormat.R16G16_UInt: fallthrough;
			case PixelFormat.R16G16_SNorm: fallthrough;
			case PixelFormat.R16G16_SInt: fallthrough;
			case PixelFormat.R32_Typeless: fallthrough;
			case PixelFormat.D32_Float: fallthrough;
			case PixelFormat.R32_Float: fallthrough;
			case PixelFormat.R32_UInt: fallthrough;
			case PixelFormat.R32_SInt: fallthrough;
			case PixelFormat.R24G8_Typeless: fallthrough;
			case PixelFormat.D24_UNorm_S8_UInt: fallthrough;
			case PixelFormat.R24_UNorm_X8_Typeless: fallthrough;
			case PixelFormat.X24_Typeless_G8_UInt: fallthrough;
			case PixelFormat.R9G9B9E5_Sharedexp: fallthrough;
			case PixelFormat.R8G8_B8G8_UNorm: fallthrough;
			case PixelFormat.G8R8_G8B8_UNorm: fallthrough;
			case PixelFormat.BC1_UNorm: fallthrough;
			case PixelFormat.BC2_UNorm: fallthrough;
			case PixelFormat.BC3_UNorm: fallthrough;
			case PixelFormat.B8G8R8A8_UNorm: fallthrough;
			case PixelFormat.B8G8R8X8_UNorm: fallthrough;
			case PixelFormat.R10G10B10_Xr_Bias_A2_UNorm: fallthrough;
			case PixelFormat.B8G8R8A8_Typeless: fallthrough;
			case PixelFormat.B8G8R8A8_UNorm_SRgb: fallthrough;
			case PixelFormat.B8G8R8X8_Typeless: fallthrough;
			case PixelFormat.B8G8R8X8_UNorm_SRgb: fallthrough;
			case PixelFormat.PVRTC_4BPP_RGB: fallthrough;
			case PixelFormat.PVRTC_4BPP_RGBA: fallthrough;
			case PixelFormat.PVRTC_4BPP_RGB_SRGB: fallthrough;
			case PixelFormat.PVRTC_4BPP_RGBA_SRGBA:
				return 32u;
			case PixelFormat.R8G8_Typeless: fallthrough;
			case PixelFormat.R8G8_UNorm: fallthrough;
			case PixelFormat.R8G8_UInt: fallthrough;
			case PixelFormat.R8G8_SNorm: fallthrough;
			case PixelFormat.R8G8_SInt: fallthrough;
			case PixelFormat.R16_Typeless: fallthrough;
			case PixelFormat.R16_Float: fallthrough;
			case PixelFormat.D16_UNorm: fallthrough;
			case PixelFormat.R16_UNorm: fallthrough;
			case PixelFormat.R16_UInt: fallthrough;
			case PixelFormat.R16_SNorm: fallthrough;
			case PixelFormat.R16_SInt: fallthrough;
			case PixelFormat.B5G6R5_UNorm: fallthrough;
			case PixelFormat.B5G5R5A1_UNorm: fallthrough;
			case PixelFormat.PVRTC_2BPP_RGB: fallthrough;
			case PixelFormat.PVRTC_2BPP_RGBA: fallthrough;
			case PixelFormat.PVRTC_2BPP_RGB_SRGB: fallthrough;
			case PixelFormat.PVRTC_2BPP_RGBA_SRGBA: fallthrough;
			case PixelFormat.ETC1_RGB8: fallthrough;
			case PixelFormat.ETC2_RGBA: fallthrough;
			case PixelFormat.ETC2_RGBA_SRGB:
				return 16u;
			case PixelFormat.R8_Typeless: fallthrough;
			case PixelFormat.R8_UNorm: fallthrough;
			case PixelFormat.R8_UInt: fallthrough;
			case PixelFormat.R8_SNorm: fallthrough;
			case PixelFormat.R8_SInt: fallthrough;
			case PixelFormat.A8_UNorm:
				return 8u;
			case PixelFormat.Unknown: fallthrough;
			case PixelFormat.R1_UNorm: fallthrough;
			case PixelFormat.BC1_Typeless: fallthrough;
			case PixelFormat.BC1_UNorm_SRgb: fallthrough;
			case PixelFormat.BC2_Typeless: fallthrough;
			case PixelFormat.BC2_UNorm_SRgb: fallthrough;
			case PixelFormat.BC3_Typeless: fallthrough;
			case PixelFormat.BC3_UNorm_SRgb: fallthrough;
			case PixelFormat.BC4_Typeless: fallthrough;
			case PixelFormat.BC4_UNorm: fallthrough;
			case PixelFormat.BC4_SNorm: fallthrough;
			case PixelFormat.BC5_Typeless: fallthrough;
			case PixelFormat.BC5_UNorm: fallthrough;
			case PixelFormat.BC5_SNorm: fallthrough;
			case PixelFormat.BC6H_Typeless: fallthrough;
			case PixelFormat.BC6H_Uf16: fallthrough;
			case PixelFormat.BC6H_Sf16: fallthrough;
			case PixelFormat.BC7_Typeless: fallthrough;
			case PixelFormat.BC7_UNorm: fallthrough;
			case PixelFormat.BC7_UNorm_SRgb: fallthrough;
			case PixelFormat.AYUV: fallthrough;
			case PixelFormat.Y410: fallthrough;
			case PixelFormat.Y416: fallthrough;
			case PixelFormat.NV12: fallthrough;
			case PixelFormat.P010: fallthrough;
			case PixelFormat.P016: fallthrough;
			case PixelFormat.Opaque420: fallthrough;
			case PixelFormat.YUY2: fallthrough;
			case PixelFormat.Y210: fallthrough;
			case PixelFormat.Y216: fallthrough;
			case PixelFormat.NV11: fallthrough;
			case PixelFormat.AI44: fallthrough;
			case PixelFormat.IA44: fallthrough;
			case PixelFormat.P8: fallthrough;
			case PixelFormat.A8P8: fallthrough;
			case PixelFormat.B4G4R4A4_UNorm: fallthrough;
			case PixelFormat.P208: fallthrough;
			case PixelFormat.V208: fallthrough;
			case PixelFormat.V408: fallthrough;
			case PixelFormat.R4G4B4A4:
				Runtime.FatalError("Invalid PixelFormat");
			default:
				return 4;
			}
		}
	}
}
