using System;
using Sedulous.Foundation.Mathematics;

namespace Sedulous.Graphics
{
	/// <summary>
	/// Miscellaneous helpers for graphic operations.
	/// </summary>
	public static class Helpers
	{
		/// <summary>
		/// Align the size in bytes to nearest multiple of 256.
		/// </summary>
		/// <param name="sizeInBytes">The size in bytes.</param>
		/// <returns>The aligned size.</returns>
		[Inline]
		public static uint32 AlignUp(uint32 sizeInBytes)
		{
			uint32 num = 255u;
			return (sizeInBytes + num) & ~num;
		}

		/// <summary>
		/// Align the size in bytes to nearest multiple of alignment value specified by parameter.
		/// </summary>
		/// <param name="alignment">The alignment size.</param>
		/// <param name="sizeInBytes">The size in bytes.</param>
		/// <returns>The aligned size.</returns>
		[Inline]
		public static uint32 AlignUp(uint32 alignment, uint32 sizeInBytes)
		{
			uint32 num = alignment - 1;
			return (sizeInBytes + num) & ~num;
		}

		/// <summary>
		/// Align the size in bytes to nearest multiple of alignment value specified by parameter.
		/// </summary>
		/// <param name="alignment">The alignment size.</param>
		/// <param name="sizeInBytes">The size in bytes.</param>
		/// <returns>The aligned size.</returns>
		[Inline]
		public static uint64 AlignUp(uint32 alignment, uint64 sizeInBytes)
		{
			uint64 num = alignment - 1;
			return (sizeInBytes + num) & ~num;
		}

		/// <summary>
		/// Ensures the size of the array.
		/// </summary>
		/// <typeparam name="T">The type of the array items.</typeparam>
		/// <param name="array">The array.</param>
		/// <param name="size">The size.</param>
		public static void EnsureArraySize<T>(ref T[] array, int32 size)
		{
			if (array == null)
			{
				array = new T[size];
			}
			else if (array.Count != size)
			{
				Array.Resize(ref array, size);
			}
		}

		/// <summary>
		/// Ensures the size of the array.
		/// </summary>
		/// <typeparam name="T">The type of the array items.</typeparam>
		/// <param name="array">The array.</param>
		/// <param name="size">The size.</param>
		public static void CheckArrayCapacity<T>(ref T[] array, int32 size)
		{
			if (array == null)
			{
				array = new T[size];
			}
			else if (array.Count < size)
			{
				Array.Resize(ref array, size);
			}
		}

		/// <summary>
		/// Gets the size in uint8 of a PixelFormat.
		/// </summary>
		/// <param name="format">The PixelFormat.</param>
		/// <returns>The size in bytes of the format.</returns>
		public static uint32 GetSizeInBytes(PixelFormat format)
		{
			switch (format)
			{
			case PixelFormat.R8_Typeless: fallthrough;
			case PixelFormat.R8_UNorm: fallthrough;
			case PixelFormat.R8_UInt: fallthrough;
			case PixelFormat.R8_SNorm: fallthrough;
			case PixelFormat.R8_SInt: fallthrough;
			case PixelFormat.A8_UNorm:
				return 1u;
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
			case PixelFormat.R4G4B4A4:
				return 2u;
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
			case PixelFormat.B8G8R8A8_UNorm: fallthrough;
			case PixelFormat.B8G8R8X8_UNorm: fallthrough;
			case PixelFormat.R10G10B10_Xr_Bias_A2_UNorm: fallthrough;
			case PixelFormat.B8G8R8A8_Typeless: fallthrough;
			case PixelFormat.B8G8R8A8_UNorm_SRgb: fallthrough;
			case PixelFormat.B8G8R8X8_Typeless: fallthrough;
			case PixelFormat.B8G8R8X8_UNorm_SRgb:
				return 4u;
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
				return 8u;
			case PixelFormat.R32G32B32_Typeless: fallthrough;
			case PixelFormat.R32G32B32_Float: fallthrough;
			case PixelFormat.R32G32B32_UInt: fallthrough;
			case PixelFormat.R32G32B32_SInt:
				return 12u;
			case PixelFormat.R32G32B32A32_Typeless: fallthrough;
			case PixelFormat.R32G32B32A32_Float: fallthrough;
			case PixelFormat.R32G32B32A32_UInt: fallthrough;
			case PixelFormat.R32G32B32A32_SInt:
				return 16u;
			default:
				Runtime.FatalError("Invalid pixel format.");
			}
		}

		/// <summary>
		/// Gets the size in bytes of a block.
		/// </summary>
		/// <param name="format">The pixel format.</param>
		/// <returns>The size in bytes.</returns>
		public static uint32 GetBlockSizeInBytes(PixelFormat format)
		{
			switch (format)
			{
			case PixelFormat.BC1_UNorm: fallthrough;
			case PixelFormat.BC1_UNorm_SRgb: fallthrough;
			case PixelFormat.BC4_UNorm: fallthrough;
			case PixelFormat.BC4_SNorm: fallthrough;
			case PixelFormat.PVRTC_2BPP_RGB: fallthrough;
			case PixelFormat.PVRTC_2BPP_RGBA: fallthrough;
			case PixelFormat.PVRTC_2BPP_RGB_SRGB: fallthrough;
			case PixelFormat.PVRTC_2BPP_RGBA_SRGBA: fallthrough;
			case PixelFormat.ETC1_RGB8:
				return 8;
			case PixelFormat.BC2_UNorm: fallthrough;
			case PixelFormat.BC2_UNorm_SRgb: fallthrough;
			case PixelFormat.BC3_UNorm: fallthrough;
			case PixelFormat.BC3_UNorm_SRgb: fallthrough;
			case PixelFormat.BC5_UNorm: fallthrough;
			case PixelFormat.BC5_SNorm: fallthrough;
			case PixelFormat.BC6H_Uf16: fallthrough;
			case PixelFormat.BC6H_Sf16: fallthrough;
			case PixelFormat.BC7_UNorm: fallthrough;
			case PixelFormat.BC7_UNorm_SRgb: fallthrough;
			case PixelFormat.PVRTC_4BPP_RGB: fallthrough;
			case PixelFormat.PVRTC_4BPP_RGBA: fallthrough;
			case PixelFormat.PVRTC_4BPP_RGB_SRGB: fallthrough;
			case PixelFormat.PVRTC_4BPP_RGBA_SRGBA: fallthrough;
			case PixelFormat.ETC2_RGBA: fallthrough;
			case PixelFormat.ETC2_RGBA_SRGB:
				return 16;
			default:
				Runtime.FatalError("Invalid pixel format.");
			}
		}

		/// <summary>
		/// Returns a value indicating if the PixelFormat is a compressed one.
		/// </summary>
		/// <param name="format">The pixel format.</param>
		/// <returns>True if the pixel format represents a compressed one. False otherwise.</returns>
		public static bool IsCompressedFormat(PixelFormat format)
		{
			if (format != PixelFormat.BC1_UNorm && format != PixelFormat.BC1_UNorm_SRgb && format != PixelFormat.BC4_UNorm && format != PixelFormat.BC4_SNorm && format != PixelFormat.ETC1_RGB8 && format != PixelFormat.BC2_UNorm && format != PixelFormat.BC2_UNorm_SRgb && format != PixelFormat.BC3_UNorm && format != PixelFormat.BC3_UNorm_SRgb && format != PixelFormat.BC5_UNorm && format != PixelFormat.BC5_SNorm && format != PixelFormat.BC6H_Uf16 && format != PixelFormat.BC6H_Sf16 && format != PixelFormat.BC7_UNorm && format != PixelFormat.BC7_UNorm_SRgb && format != PixelFormat.ETC1_RGB8 && format != PixelFormat.ETC2_RGBA && format != PixelFormat.ETC2_RGBA_SRGB && format != PixelFormat.PVRTC_2BPP_RGB && format != PixelFormat.PVRTC_2BPP_RGBA && format != PixelFormat.PVRTC_2BPP_RGB_SRGB && format != PixelFormat.PVRTC_2BPP_RGBA_SRGBA && format != PixelFormat.PVRTC_4BPP_RGB && format != PixelFormat.PVRTC_4BPP_RGBA && format != PixelFormat.PVRTC_4BPP_RGB_SRGB)
			{
				return format == PixelFormat.PVRTC_4BPP_RGBA_SRGBA;
			}
			return true;
		}

		/// <summary>
		/// Gets a value indicating if the PixelFormat can be used as stencil pixel format.
		/// </summary>
		/// <param name="format">The pixel format.</param>
		/// <returns>True if the format can be used as stencil. False otherwise.</returns>
		public static bool IsStencilFormat(PixelFormat format)
		{
			if ((uint32)(format - 19) <= 1u || (uint32)(format - 44) <= 1u)
			{
				return true;
			}
			return false;
		}

		/// <summary>
		/// Gets the size of a row with a specified size and format.
		/// </summary>
		/// <param name="width">The row size.</param>
		/// <param name="format">The row PixelFormat.</param>
		/// <returns>The row pitch.</returns>
		public static uint32 GetRowPitch(uint32 width, PixelFormat format)
		{
			if (IsCompressedFormat(format))
			{
				uint32 num = (width + 3) / 4u;
				uint32 blockSizeInBytes = GetBlockSizeInBytes(format);
				return num * blockSizeInBytes;
			}
			return width * GetSizeInBytes(format);
		}

		/// <summary>
		/// Gets the number of rows, depending of the height and the pixel format.
		/// </summary>
		/// <param name="height">The height.</param>
		/// <param name="format">The pixel format.</param>
		/// <returns>The number of rows.</returns>
		public static uint32 GetNumRows(uint32 height, PixelFormat format)
		{
			if (IsCompressedFormat(format))
			{
				return (height + 3) / 4u;
			}
			return height;
		}

		/// <summary>
		/// Gets the slice pitch.
		/// </summary>
		/// <param name="rowPitch">The row pitch.</param>
		/// <param name="height">The height.</param>
		/// <param name="format">The pixel format.</param>
		/// <returns>The slice pitch.</returns>
		public static uint32 GetSlicePitch(uint32 rowPitch, uint32 height, PixelFormat format)
		{
			return rowPitch * GetNumRows(height, format);
		}

		/// <summary>
		/// Gets the dimension size of a specified mip level.
		/// </summary>
		/// <param name="largestLevelDimension">The largest level dimension.</param>
		/// <param name="mipLevel">The mip level.</param>
		/// <returns>The dimension of the current mip level.</returns>
		public static uint32 GetDimension(uint32 largestLevelDimension, uint32 mipLevel)
		{
			uint32 val = (uint32)((int32)largestLevelDimension >> (int32)mipLevel);
			return Math.Max(1, val);
		}

		/// <summary>
		/// Gets the sub resource info of a Texture.
		/// </summary>
		/// <param name="description">The texture info.</param>
		/// <param name="subResource">The subResource id.</param>
		/// <returns>The SubResource Info.</returns>
		public static SubResourceInfo GetSubResourceInfo(TextureDescription description, uint32 subResource)
		{
			GetMipLevelAndArrayLayer(description, subResource, var mipLevel, var arrayLayer);
			GetMipDimensions(description, mipLevel, var width, var height, var depth);
			uint32 rowPitch = GetRowPitch(width, description.Format);
			uint32 slicePitch = GetSlicePitch(rowPitch, height, description.Format);
			SubResourceInfo result = default(SubResourceInfo);
			result.MipWidth = width;
			result.MipHeight = height;
			result.MipDepth = depth;
			result.RowPitch = rowPitch;
			result.SlicePitch = slicePitch;
			result.MipLevel = mipLevel;
			result.ArrayLayer = arrayLayer;
			result.Offset = ComputeSubResourceOffset(description, subResource);
			result.SizeInBytes = slicePitch * depth;
			return result;
		}

		/// <summary>
		/// Calculates the SubResource offset of a Texture.
		/// </summary>
		/// <param name="description">The Texture description.</param>
		/// <param name="subResource">The SubResource index.</param>
		/// <returns>The SubResource offset.</returns>
		public static uint64 ComputeSubResourceOffset(TextureDescription description, uint32 subResource)
		{
			GetMipLevelAndArrayLayer(description, subResource, var mipLevel, var arrayLayer);
			uint32 num = ComputeMipOffset(description, mipLevel);
			return ComputeLayerOffset(description, arrayLayer) + num;
		}

		/// <summary>
		/// Computes the MipMap offset.
		/// </summary>
		/// <param name="description">The TextureDescription.</param>
		/// <param name="mipLevel">The MipMap Level.</param>
		/// <returns>The mip offset.</returns>
		public static uint32 ComputeMipOffset(TextureDescription description, uint32 mipLevel)
		{
			uint32 val = ((!IsCompressedFormat(description.Format)) ? 1u : 4u);
			uint32 num = 0u;
			for (uint32 num2 = 0u; num2 < mipLevel; num2++)
			{
				GetMipDimensions(description, num2, var width, var height, var depth);
				uint32 width2 = Math.Max(width, val);
				uint32 height2 = Math.Max(height, val);
				num += GetRegionSize(width2, height2, depth, description.Format);
			}
			return num;
		}

		/// <summary>
		/// Computes the Layer offset.
		/// </summary>
		/// <param name="description">The TextureDescription.</param>
		/// <param name="arrayLayer">The array layer.</param>
		/// <returns>The Layer offset.</returns>
		public static uint32 ComputeLayerOffset(TextureDescription description, uint32 arrayLayer)
		{
			uint32 num = 0u;
			if (arrayLayer != 0)
			{
				uint32 val = ((!IsCompressedFormat(description.Format)) ? 1u : 4u);
				for (uint32 num2 = 0u; num2 < description.MipLevels; num2++)
				{
					GetMipDimensions(description, num2, var width, var height, var depth);
					uint32 width2 = Math.Max(width, val);
					uint32 height2 = Math.Max(height, val);
					num += GetRegionSize(width2, height2, depth, description.Format);
				}
			}
			return num;
		}

		/// <summary>
		/// Computes the Texture Size in bytes of a Texture Description.
		/// </summary>
		/// <param name="description">The Texture Description.</param>
		/// <returns>The size in bytes of the texture.</returns>
		public static uint32 ComputeTextureSize(TextureDescription description)
		{
			uint32 num = 0u;
			for (uint32 num2 = 0u; num2 < description.MipLevels; num2++)
			{
				GetMipDimensions(description, num2, var width, var height, var depth);
				uint32 slicePitch = GetSlicePitch(GetRowPitch(width, description.Format), height, description.Format);
				num += slicePitch * depth;
			}
			return num * description.ArraySize * description.Faces;
		}

		/// <summary>
		/// Gets the block size in bytes of a texture.
		/// </summary>
		/// <param name="width">The texture width.</param>
		/// <param name="height">The texture height.</param>
		/// <param name="depth">The texture depth.</param>
		/// <param name="format">The texture pixel format.</param>
		/// <returns>The size in bytes of the block region.</returns>
		public static uint32 GetRegionSize(uint32 width, uint32 height, uint32 depth, PixelFormat format)
		{
			var width;
			var height;

			uint32 num;
			if (IsCompressedFormat(format))
			{
				num = GetBlockSizeInBytes(format);
				width /= 4u;
				height /= 4u;
			}
			else
			{
				num = GetSizeInBytes(format);
			}
			return width * height * depth * num;
		}

		/// <summary>
		/// Calculates the sub resource index.
		/// </summary>
		/// <param name="description">The texture description.</param>
		/// <param name="mipLevel">The mipmap level.</param>
		/// <param name="arrayLayer">The array layer index.</param>
		/// <returns>The id of the sub resource.</returns>
		public static uint32 CalculateSubResource(TextureDescription description, uint32 mipLevel, uint32 arrayLayer)
		{
			return arrayLayer * description.MipLevels + mipLevel;
		}

		/// <summary>
		/// Gets the Mip Level and the Array Layer of a texture sub resource.
		/// </summary>
		/// <param name="description">The Texture Description.</param>
		/// <param name="subResource">The sub resource of the texture.</param>
		/// <param name="mipLevel">The Mip Level.</param>
		/// <param name="arrayLayer">The Array Layer.</param>
		public static void GetMipLevelAndArrayLayer(TextureDescription description, uint32 subResource, out uint32 mipLevel, out uint32 arrayLayer)
		{
			arrayLayer = subResource / description.MipLevels;
			mipLevel = subResource - arrayLayer * description.MipLevels;
		}

		/// <summary>
		/// Gets the mip level dimensions.
		/// </summary>
		/// <param name="description">The texture description.</param>
		/// <param name="mipLevel">The texture mip Level.</param>
		/// <param name="width">The texture width.</param>
		/// <param name="height">The texture height.</param>
		/// <param name="depth">The texture depth.</param>
		public static void GetMipDimensions(TextureDescription description, uint32 mipLevel, out uint32 width, out uint32 height, out uint32 depth)
		{
			if (mipLevel == 0)
			{
				width = description.Width;
				height = description.Height;
				depth = description.Depth;
			}
			else
			{
				width = GetDimension(description.Width, mipLevel);
				height = GetDimension(description.Height, mipLevel);
				depth = GetDimension(description.Depth, mipLevel);
			}
		}

		/// <summary>
		/// Gets the mip level dimensions.
		/// </summary>
		/// <param name="width">Texture Width.</param>
		/// <param name="height">Texture Height.</param>
		/// <returns>Mip levels.</returns>
		public static uint32 GetMipLevels(uint32 width, uint32 height)
		{
			uint32 num = width;
			uint32 num2 = height;
			uint32 num3 = 0u;
			while (num != 0 && num2 != 0)
			{
				num /= 2u;
				num2 /= 2u;
				num3++;
			}
			return num3;
		}

		/// <summary>
		/// Transform the given value to conform to an specified <see cref="T:Sedulous.Graphics.TextureAddressMode" />.
		/// </summary>
		/// <param name="value">The value to transform.</param>
		/// <param name="addressMode">The address mode.</param>
		public static void ApplyAddressMode(ref float value, TextureAddressMode addressMode)
		{
			switch (addressMode)
			{
			case TextureAddressMode.Wrap:
				value %= 1f;
				if (value < 0f)
				{
					value += 1f;
				}
				break;
			case TextureAddressMode.Mirror:
				if ((int32)value % 2 != 0)
				{
					value = 1f - value % 1f;
				}
				break;
			case TextureAddressMode.Mirror_One:
				value = Math.Clamp(value, -1f, 1f);
				break;
			default:
				value = Math.Clamp(value, 0f, 1f);
				break;
			}
		}
	}
}
