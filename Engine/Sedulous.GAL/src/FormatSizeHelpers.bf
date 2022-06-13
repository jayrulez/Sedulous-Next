using System.Diagnostics;
using System;

namespace Sedulous.GAL
{
    public static class FormatSizeHelpers
    {
        /// <summary>
        /// Given a pixel format, returns the number of bytes required to store
        /// a single pixel.
        /// Compressed formats may not be used with this method as the number of
        /// bytes per pixel is variable.
        /// </summary>
        /// <param name="format">An uncompressed pixel format</param>
        /// <returns>The number of bytes required to store a single pixel in the given format</returns>
        public static uint32 GetSizeInBytes(PixelFormat format)
        {
            switch (format)
            {
                case PixelFormat.R8_UNorm: fallthrough;
                case PixelFormat.R8_SNorm: fallthrough;
                case PixelFormat.R8_UInt: fallthrough;
                case PixelFormat.R8_SInt:
                    return 1;

                case PixelFormat.R16_UNorm: fallthrough;
                case PixelFormat.R16_SNorm: fallthrough;
                case PixelFormat.R16_UInt: fallthrough;
                case PixelFormat.R16_SInt: fallthrough;
                case PixelFormat.R16_Float: fallthrough;
                case PixelFormat.R8_G8_UNorm: fallthrough;
                case PixelFormat.R8_G8_SNorm: fallthrough;
                case PixelFormat.R8_G8_UInt: fallthrough;
                case PixelFormat.R8_G8_SInt:
                    return 2;

                case PixelFormat.R32_UInt: fallthrough;
                case PixelFormat.R32_SInt: fallthrough;
                case PixelFormat.R32_Float: fallthrough;
                case PixelFormat.R16_G16_UNorm: fallthrough;
                case PixelFormat.R16_G16_SNorm: fallthrough;
                case PixelFormat.R16_G16_UInt: fallthrough;
                case PixelFormat.R16_G16_SInt: fallthrough;
                case PixelFormat.R16_G16_Float: fallthrough;
                case PixelFormat.R8_G8_B8_A8_UNorm: fallthrough;
                case PixelFormat.R8_G8_B8_A8_UNorm_SRgb: fallthrough;
                case PixelFormat.R8_G8_B8_A8_SNorm: fallthrough;
                case PixelFormat.R8_G8_B8_A8_UInt: fallthrough;
                case PixelFormat.R8_G8_B8_A8_SInt: fallthrough;
                case PixelFormat.B8_G8_R8_A8_UNorm: fallthrough;
                case PixelFormat.B8_G8_R8_A8_UNorm_SRgb: fallthrough;
                case PixelFormat.R10_G10_B10_A2_UNorm: fallthrough;
                case PixelFormat.R10_G10_B10_A2_UInt: fallthrough;
                case PixelFormat.R11_G11_B10_Float: fallthrough;
                case PixelFormat.D24_UNorm_S8_UInt:
                    return 4;

                case PixelFormat.D32_Float_S8_UInt:
                    return 5;

                case PixelFormat.R16_G16_B16_A16_UNorm: fallthrough;
                case PixelFormat.R16_G16_B16_A16_SNorm: fallthrough;
                case PixelFormat.R16_G16_B16_A16_UInt: fallthrough;
                case PixelFormat.R16_G16_B16_A16_SInt: fallthrough;
                case PixelFormat.R16_G16_B16_A16_Float: fallthrough;
                case PixelFormat.R32_G32_UInt: fallthrough;
                case PixelFormat.R32_G32_SInt: fallthrough;
                case PixelFormat.R32_G32_Float:
                    return 8;

                case PixelFormat.R32_G32_B32_A32_Float: fallthrough;
                case PixelFormat.R32_G32_B32_A32_UInt: fallthrough;
                case PixelFormat.R32_G32_B32_A32_SInt:
                    return 16;

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
                    Debug.WriteLine("GetSizeInBytes should not be used on a compressed format.");
				Runtime.FatalError(scope $"Illegal {typeof(PixelFormat).GetName(.. scope .())}");
                default: 
				Runtime.FatalError(scope $"Illegal {typeof(PixelFormat).GetName(.. scope .())}");
            }
        }

        /// <summary>
        /// Given a vertex element format, returns the number of bytes required
        /// to store an element in that format.
        /// </summary>
        /// <param name="format">A vertex element format</param>
        /// <returns>The number of bytes required to store an element in the given format</returns>
        public static uint32 GetSizeInBytes(VertexElementFormat format)
        {
            switch (format)
            {
                case VertexElementFormat.Byte2_Norm: fallthrough;
                case VertexElementFormat.Byte2: fallthrough;
                case VertexElementFormat.SByte2_Norm: fallthrough;
                case VertexElementFormat.SByte2: fallthrough;
                case VertexElementFormat.Half1:
                    return 2;
                case VertexElementFormat.Float1: fallthrough;
                case VertexElementFormat.UInt1: fallthrough;
                case VertexElementFormat.Int1: fallthrough;
                case VertexElementFormat.Byte4_Norm: fallthrough;
                case VertexElementFormat.Byte4: fallthrough;
                case VertexElementFormat.SByte4_Norm: fallthrough;
                case VertexElementFormat.SByte4: fallthrough;
                case VertexElementFormat.UShort2_Norm: fallthrough;
                case VertexElementFormat.UShort2: fallthrough;
                case VertexElementFormat.Short2_Norm: fallthrough;
                case VertexElementFormat.Short2: fallthrough;
                case VertexElementFormat.Half2:
                    return 4;
                case VertexElementFormat.Float2: fallthrough;
                case VertexElementFormat.UInt2: fallthrough;
                case VertexElementFormat.Int2: fallthrough;
                case VertexElementFormat.UShort4_Norm: fallthrough;
                case VertexElementFormat.UShort4: fallthrough;
                case VertexElementFormat.Short4_Norm: fallthrough;
                case VertexElementFormat.Short4: fallthrough;
                case VertexElementFormat.Half4:
                    return 8;
                case VertexElementFormat.Float3: fallthrough;
                case VertexElementFormat.UInt3: fallthrough;
                case VertexElementFormat.Int3:
                    return 12;
                case VertexElementFormat.Float4: fallthrough;
                case VertexElementFormat.UInt4: fallthrough;
                case VertexElementFormat.Int4:
                    return 16;
                default:
				Runtime.FatalError(scope $"Illegal {typeof(VertexElementFormat).GetName(.. scope .())}");
            }
        }
    }
}
