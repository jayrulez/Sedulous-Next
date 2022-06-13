using System;
using System.Diagnostics;

namespace Sedulous.GAL
{
    internal static class FormatHelpers
    {
        public static int32 GetElementCount(VertexElementFormat format)
        {
            switch (format)
            {
                case VertexElementFormat.Float1: fallthrough;
                case VertexElementFormat.UInt1: fallthrough;
                case VertexElementFormat.Int1: fallthrough;
                case VertexElementFormat.Half1:
                    return 1;
                case VertexElementFormat.Float2: fallthrough;
                case VertexElementFormat.Byte2_Norm: fallthrough;
                case VertexElementFormat.Byte2: fallthrough;
                case VertexElementFormat.SByte2_Norm: fallthrough;
                case VertexElementFormat.SByte2: fallthrough;
                case VertexElementFormat.UShort2_Norm: fallthrough;
                case VertexElementFormat.UShort2: fallthrough;
                case VertexElementFormat.Short2_Norm: fallthrough;
                case VertexElementFormat.Short2: fallthrough;
                case VertexElementFormat.UInt2: fallthrough;
                case VertexElementFormat.Int2: fallthrough;
                case VertexElementFormat.Half2:
                    return 2;
                case VertexElementFormat.Float3: fallthrough;
                case VertexElementFormat.UInt3: fallthrough;
                case VertexElementFormat.Int3:
                    return 3;
                case VertexElementFormat.Float4: fallthrough;
                case VertexElementFormat.Byte4_Norm: fallthrough;
                case VertexElementFormat.Byte4: fallthrough;
                case VertexElementFormat.SByte4_Norm: fallthrough;
                case VertexElementFormat.SByte4: fallthrough;
                case VertexElementFormat.UShort4_Norm: fallthrough;
                case VertexElementFormat.UShort4: fallthrough;
                case VertexElementFormat.Short4_Norm: fallthrough;
                case VertexElementFormat.Short4: fallthrough;
                case VertexElementFormat.UInt4: fallthrough;
                case VertexElementFormat.Int4: fallthrough;
                case VertexElementFormat.Half4:
                    return 4;
                default:
                    Runtime.FatalError(scope $"Illegal {typeof(VertexElementFormat).GetName(.. scope .())}");
            }
        }

        internal static uint32 GetSampleCountUInt32(TextureSampleCount sampleCount)
        {
            switch (sampleCount)
            {
                case TextureSampleCount.Count1:
                    return 1;
                case TextureSampleCount.Count2:
                    return 2;
                case TextureSampleCount.Count4:
                    return 4;
                case TextureSampleCount.Count8:
                    return 8;
                case TextureSampleCount.Count16:
                    return 16;
                case TextureSampleCount.Count32:
                    return 32;
                default:
                    Runtime.FatalError(scope $"Illegal {typeof(TextureSampleCount).GetName(.. scope .())}");
            }
        }

        internal static bool IsStencilFormat(PixelFormat format)
        {
            return format == PixelFormat.D24_UNorm_S8_UInt || format == PixelFormat.D32_Float_S8_UInt;
        }

        internal static bool IsDepthStencilFormat(PixelFormat format)
        {
            return format == PixelFormat.D32_Float_S8_UInt
                || format == PixelFormat.D24_UNorm_S8_UInt
                || format == PixelFormat.R16_UNorm
                || format == PixelFormat.R32_Float;
        }

        internal static bool IsCompressedFormat(PixelFormat format)
        {
            return format == PixelFormat.BC1_Rgb_UNorm
                || format == PixelFormat.BC1_Rgb_UNorm_SRgb
                || format == PixelFormat.BC1_Rgba_UNorm
                || format == PixelFormat.BC1_Rgba_UNorm_SRgb
                || format == PixelFormat.BC2_UNorm
                || format == PixelFormat.BC2_UNorm_SRgb
                || format == PixelFormat.BC3_UNorm
                || format == PixelFormat.BC3_UNorm_SRgb
                || format == PixelFormat.BC4_UNorm
                || format == PixelFormat.BC4_SNorm
                || format == PixelFormat.BC5_UNorm
                || format == PixelFormat.BC5_SNorm
                || format == PixelFormat.BC7_UNorm
                || format == PixelFormat.BC7_UNorm_SRgb
                || format == PixelFormat.ETC2_R8_G8_B8_UNorm
                || format == PixelFormat.ETC2_R8_G8_B8_A1_UNorm
                || format == PixelFormat.ETC2_R8_G8_B8_A8_UNorm;
        }

        internal static uint32 GetRowPitch(uint32 width, PixelFormat format)
        {
            switch (format)
            {
                case PixelFormat.BC1_Rgb_UNorm: fallthrough;
                case PixelFormat.BC1_Rgb_UNorm_SRgb: fallthrough;
                case PixelFormat.BC1_Rgba_UNorm: fallthrough;
                case PixelFormat.BC1_Rgba_UNorm_SRgb: fallthrough;
                case PixelFormat.BC2_UNorm: fallthrough;
                case PixelFormat.BC2_UNorm_SRgb: fallthrough;
                case PixelFormat.BC3_UNorm: fallthrough;
                case PixelFormat.BC3_UNorm_SRgb: fallthrough;
                case PixelFormat.BC4_UNorm: fallthrough;
                case PixelFormat.BC4_SNorm: fallthrough;
                case PixelFormat.BC5_UNorm: fallthrough;
                case PixelFormat.BC5_SNorm: fallthrough;
                case PixelFormat.BC7_UNorm: fallthrough;
                case PixelFormat.BC7_UNorm_SRgb: fallthrough;
                case PixelFormat.ETC2_R8_G8_B8_UNorm: fallthrough;
                case PixelFormat.ETC2_R8_G8_B8_A1_UNorm: fallthrough;
                case PixelFormat.ETC2_R8_G8_B8_A8_UNorm:
                    var blocksPerRow = (width + 3) / 4;
                    var blockSizeInBytes = GetBlockSizeInBytes(format);
                    return blocksPerRow * blockSizeInBytes;

                default:
                    return width * FormatSizeHelpers.GetSizeInBytes(format);
            }
        }

        public static uint32 GetBlockSizeInBytes(PixelFormat format)
        {
            switch (format)
            {
                case PixelFormat.BC1_Rgb_UNorm: fallthrough;
                case PixelFormat.BC1_Rgb_UNorm_SRgb: fallthrough;
                case PixelFormat.BC1_Rgba_UNorm: fallthrough;
                case PixelFormat.BC1_Rgba_UNorm_SRgb: fallthrough;
                case PixelFormat.BC4_UNorm: fallthrough;
                case PixelFormat.BC4_SNorm: fallthrough;
                case PixelFormat.ETC2_R8_G8_B8_UNorm: fallthrough;
                case PixelFormat.ETC2_R8_G8_B8_A1_UNorm:
                    return 8;
                case PixelFormat.BC2_UNorm: fallthrough;
                case PixelFormat.BC2_UNorm_SRgb: fallthrough;
                case PixelFormat.BC3_UNorm: fallthrough;
                case PixelFormat.BC3_UNorm_SRgb: fallthrough;
                case PixelFormat.BC5_UNorm: fallthrough;
                case PixelFormat.BC5_SNorm: fallthrough;
                case PixelFormat.BC7_UNorm: fallthrough;
                case PixelFormat.BC7_UNorm_SRgb: fallthrough;
                case PixelFormat.ETC2_R8_G8_B8_A8_UNorm:
                    return 16;
                default:
                    Runtime.FatalError(scope $"Illegal {typeof(PixelFormat).GetName(.. scope .())}");
            }
        }

        internal static bool IsFormatViewCompatible(PixelFormat viewFormat, PixelFormat realFormat)
        {
            if (IsCompressedFormat(realFormat))
            {
                return IsSrgbCounterpart(viewFormat, realFormat);
            }
            else
            {
                return GetViewFamilyFormat(viewFormat) == GetViewFamilyFormat(realFormat);
            }
        }

        private static bool IsSrgbCounterpart(PixelFormat viewFormat, PixelFormat realFormat)
        {
            Runtime.FatalError();
        }

        internal static uint32 GetNumRows(uint32 height, PixelFormat format)
        {
            switch (format)
            {
                case PixelFormat.BC1_Rgb_UNorm: fallthrough;
                case PixelFormat.BC1_Rgb_UNorm_SRgb: fallthrough;
                case PixelFormat.BC1_Rgba_UNorm: fallthrough;
                case PixelFormat.BC1_Rgba_UNorm_SRgb: fallthrough;
                case PixelFormat.BC2_UNorm: fallthrough;
                case PixelFormat.BC2_UNorm_SRgb: fallthrough;
                case PixelFormat.BC3_UNorm: fallthrough;
                case PixelFormat.BC3_UNorm_SRgb: fallthrough;
                case PixelFormat.BC4_UNorm: fallthrough;
                case PixelFormat.BC4_SNorm: fallthrough;
                case PixelFormat.BC5_UNorm: fallthrough;
                case PixelFormat.BC5_SNorm: fallthrough;
                case PixelFormat.BC7_UNorm: fallthrough;
                case PixelFormat.BC7_UNorm_SRgb: fallthrough;
                case PixelFormat.ETC2_R8_G8_B8_UNorm: fallthrough;
                case PixelFormat.ETC2_R8_G8_B8_A1_UNorm: fallthrough;
                case PixelFormat.ETC2_R8_G8_B8_A8_UNorm:
                    return (height + 3) / 4;

                default:
                    return height;
            }
        }

        internal static uint32 GetDepthPitch(uint32 rowPitch, uint32 height, PixelFormat format)
        {
            return rowPitch * GetNumRows(height, format);
        }

        internal static uint32 GetRegionSize(uint32 width, uint32 height, uint32 depth, PixelFormat format)
        {
			var width;
			var height;

            uint32 blockSizeInBytes;
            if (IsCompressedFormat(format))
            {
                Debug.Assert((width % 4 == 0 || width < 4) && (height % 4 == 0 || height < 4));
                blockSizeInBytes = GetBlockSizeInBytes(format);
                width /= 4;
                height /= 4;
            }
            else
            {
                blockSizeInBytes = FormatSizeHelpers.GetSizeInBytes(format);
            }

            return width * height * depth * blockSizeInBytes;
        }

        internal static TextureSampleCount GetSampleCount(uint32 samples)
        {
            switch (samples)
            {
                case 1: return TextureSampleCount.Count1;
                case 2: return TextureSampleCount.Count2;
                case 4: return TextureSampleCount.Count4;
                case 8: return TextureSampleCount.Count8;
                case 16: return TextureSampleCount.Count16;
                case 32: return TextureSampleCount.Count32;
                default: Runtime.FatalError(scope $"Unsupported multisample count: {samples}");
            }
        }

        internal static PixelFormat GetViewFamilyFormat(PixelFormat format)
        {
            switch (format)
            {
                case PixelFormat.R32_G32_B32_A32_Float: fallthrough;
                case PixelFormat.R32_G32_B32_A32_UInt: fallthrough;
                case PixelFormat.R32_G32_B32_A32_SInt:
                    return PixelFormat.R32_G32_B32_A32_Float;
                case PixelFormat.R16_G16_B16_A16_Float: fallthrough;
                case PixelFormat.R16_G16_B16_A16_UNorm: fallthrough;
                case PixelFormat.R16_G16_B16_A16_UInt: fallthrough;
                case PixelFormat.R16_G16_B16_A16_SNorm: fallthrough;
                case PixelFormat.R16_G16_B16_A16_SInt:
                    return PixelFormat.R16_G16_B16_A16_Float;
                case PixelFormat.R32_G32_Float: fallthrough;
                case PixelFormat.R32_G32_UInt: fallthrough;
                case PixelFormat.R32_G32_SInt:
                    return PixelFormat.R32_G32_Float;
                case PixelFormat.R10_G10_B10_A2_UNorm: fallthrough;
                case PixelFormat.R10_G10_B10_A2_UInt:
                    return PixelFormat.R10_G10_B10_A2_UNorm;
                case PixelFormat.R8_G8_B8_A8_UNorm: fallthrough;
                case PixelFormat.R8_G8_B8_A8_UNorm_SRgb: fallthrough;
                case PixelFormat.R8_G8_B8_A8_UInt: fallthrough;
                case PixelFormat.R8_G8_B8_A8_SNorm: fallthrough;
                case PixelFormat.R8_G8_B8_A8_SInt:
                    return PixelFormat.R8_G8_B8_A8_UNorm;
                case PixelFormat.R16_G16_Float: fallthrough;
                case PixelFormat.R16_G16_UNorm: fallthrough;
                case PixelFormat.R16_G16_UInt: fallthrough;
                case PixelFormat.R16_G16_SNorm: fallthrough;
                case PixelFormat.R16_G16_SInt:
                    return PixelFormat.R16_G16_Float;
                case PixelFormat.R32_Float: fallthrough;
                case PixelFormat.R32_UInt: fallthrough;
                case PixelFormat.R32_SInt:
                    return PixelFormat.R32_Float;
                case PixelFormat.R8_G8_UNorm: fallthrough;
                case PixelFormat.R8_G8_UInt: fallthrough;
                case PixelFormat.R8_G8_SNorm: fallthrough;
                case PixelFormat.R8_G8_SInt:
                    return PixelFormat.R8_G8_UNorm;
                case PixelFormat.R16_Float: fallthrough;
                case PixelFormat.R16_UNorm: fallthrough;
                case PixelFormat.R16_UInt: fallthrough;
                case PixelFormat.R16_SNorm: fallthrough;
                case PixelFormat.R16_SInt:
                    return PixelFormat.R16_Float;
                case PixelFormat.R8_UNorm: fallthrough;
                case PixelFormat.R8_UInt: fallthrough;
                case PixelFormat.R8_SNorm: fallthrough;
                case PixelFormat.R8_SInt:
                    return PixelFormat.R8_UNorm;
                case PixelFormat.BC1_Rgba_UNorm: fallthrough;
                case PixelFormat.BC1_Rgba_UNorm_SRgb: fallthrough;
                case PixelFormat.BC1_Rgb_UNorm: fallthrough;
                case PixelFormat.BC1_Rgb_UNorm_SRgb:
                    return PixelFormat.BC1_Rgba_UNorm;
                case PixelFormat.BC2_UNorm: fallthrough;
                case PixelFormat.BC2_UNorm_SRgb:
                    return PixelFormat.BC2_UNorm;
                case PixelFormat.BC3_UNorm: fallthrough;
                case PixelFormat.BC3_UNorm_SRgb:
                    return PixelFormat.BC3_UNorm;
                case PixelFormat.BC4_UNorm: fallthrough;
                case PixelFormat.BC4_SNorm:
                    return PixelFormat.BC4_UNorm;
                case PixelFormat.BC5_UNorm: fallthrough;
                case PixelFormat.BC5_SNorm:
                    return PixelFormat.BC5_UNorm;
                case PixelFormat.B8_G8_R8_A8_UNorm: fallthrough;
                case PixelFormat.B8_G8_R8_A8_UNorm_SRgb:
                    return PixelFormat.B8_G8_R8_A8_UNorm;
                case PixelFormat.BC7_UNorm: fallthrough;
                case PixelFormat.BC7_UNorm_SRgb:
                    return PixelFormat.BC7_UNorm;
                default:
                    return format;
            }
        }
    }
}
