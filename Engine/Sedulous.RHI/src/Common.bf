using System;
namespace Sedulous.RHI;

public static
{
	public const uint32 MAX_MRT_COUNT = 8;
	public const uint32 MAX_VERTEX_ATTRIBS = 15;
	public const uint32 MAX_VERTEX_BINDINGS = 15;
	public const uint32 COLOR_MASK_RED = 0x1;
	public const uint32 COLOR_MASK_GREEN = 0x2;
	public const uint32 COLOR_MASK_BLUE = 0x4;
	public const uint32 COLOR_MASK_ALPHA = 0x8;
	public const uint32 COLOR_MASK_ALL = COLOR_MASK_RED | COLOR_MASK_GREEN | COLOR_MASK_BLUE | COLOR_MASK_ALPHA;
	public const uint32 COLOR_MASK_NONE = 0;
}

enum Backend
{
	BACKEND_VULKAN = 0,
	BACKEND_D3D12 = 1,
	BACKEND_METAL = 2,
	BACKEND_COUNT,
	BACKEND_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum CommandQueueType
{
	QUEUE_TYPE_GRAPHICS = 0,
	QUEUE_TYPE_COMPUTE = 1,
	QUEUE_TYPE_TRANSFER = 2,
	QUEUE_TYPE_COUNT,
	QUEUE_TYPE_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum Format
{
	FORMAT_UNDEFINED = 0,
	FORMAT_R1_UNORM = 1,
	FORMAT_R2_UNORM = 2,
	FORMAT_R4_UNORM = 3,
	FORMAT_R4G4_UNORM = 4,
	FORMAT_G4R4_UNORM = 5,
	FORMAT_A8_UNORM = 6,
	FORMAT_R8_UNORM = 7,
	FORMAT_R8_SNORM = 8,
	FORMAT_R8_UINT = 9,
	FORMAT_R8_SINT = 10,
	FORMAT_R8_SRGB = 11,
	FORMAT_B2G3R3_UNORM = 12,
	FORMAT_R4G4B4A4_UNORM = 13,
	FORMAT_R4G4B4X4_UNORM = 14,
	FORMAT_B4G4R4A4_UNORM = 15,
	FORMAT_B4G4R4X4_UNORM = 16,
	FORMAT_A4R4G4B4_UNORM = 17,
	FORMAT_X4R4G4B4_UNORM = 18,
	FORMAT_A4B4G4R4_UNORM = 19,
	FORMAT_X4B4G4R4_UNORM = 20,
	FORMAT_R5G6B5_UNORM = 21,
	FORMAT_B5G6R5_UNORM = 22,
	FORMAT_R5G5B5A1_UNORM = 23,
	FORMAT_B5G5R5A1_UNORM = 24,
	FORMAT_A1B5G5R5_UNORM = 25,
	FORMAT_A1R5G5B5_UNORM = 26,
	FORMAT_R5G5B5X1_UNORM = 27,
	FORMAT_B5G5R5X1_UNORM = 28,
	FORMAT_X1R5G5B5_UNORM = 29,
	FORMAT_X1B5G5R5_UNORM = 30,
	FORMAT_B2G3R3A8_UNORM = 31,
	FORMAT_R8G8_UNORM = 32,
	FORMAT_R8G8_SNORM = 33,
	FORMAT_G8R8_UNORM = 34,
	FORMAT_G8R8_SNORM = 35,
	FORMAT_R8G8_UINT = 36,
	FORMAT_R8G8_SINT = 37,
	FORMAT_R8G8_SRGB = 38,
	FORMAT_R16_UNORM = 39,
	FORMAT_R16_SNORM = 40,
	FORMAT_R16_UINT = 41,
	FORMAT_R16_SINT = 42,
	FORMAT_R16_SFLOAT = 43,
	FORMAT_R16_SBFLOAT = 44,
	FORMAT_R8G8B8_UNORM = 45,
	FORMAT_R8G8B8_SNORM = 46,
	FORMAT_R8G8B8_UINT = 47,
	FORMAT_R8G8B8_SINT = 48,
	FORMAT_R8G8B8_SRGB = 49,
	FORMAT_B8G8R8_UNORM = 50,
	FORMAT_B8G8R8_SNORM = 51,
	FORMAT_B8G8R8_UINT = 52,
	FORMAT_B8G8R8_SINT = 53,
	FORMAT_B8G8R8_SRGB = 54,
	FORMAT_R8G8B8A8_UNORM = 55,
	FORMAT_R8G8B8A8_SNORM = 56,
	FORMAT_R8G8B8A8_UINT = 57,
	FORMAT_R8G8B8A8_SINT = 58,
	FORMAT_R8G8B8A8_SRGB = 59,
	FORMAT_B8G8R8A8_UNORM = 60,
	FORMAT_B8G8R8A8_SNORM = 61,
	FORMAT_B8G8R8A8_UINT = 62,
	FORMAT_B8G8R8A8_SINT = 63,
	FORMAT_B8G8R8A8_SRGB = 64,
	FORMAT_R8G8B8X8_UNORM = 65,
	FORMAT_B8G8R8X8_UNORM = 66,
	FORMAT_R16G16_UNORM = 67,
	FORMAT_G16R16_UNORM = 68,
	FORMAT_R16G16_SNORM = 69,
	FORMAT_G16R16_SNORM = 70,
	FORMAT_R16G16_UINT = 71,
	FORMAT_R16G16_SINT = 72,
	FORMAT_R16G16_SFLOAT = 73,
	FORMAT_R16G16_SBFLOAT = 74,
	FORMAT_R32_UINT = 75,
	FORMAT_R32_SINT = 76,
	FORMAT_R32_SFLOAT = 77,
	FORMAT_A2R10G10B10_UNORM = 78,
	FORMAT_A2R10G10B10_UINT = 79,
	FORMAT_A2R10G10B10_SNORM = 80,
	FORMAT_A2R10G10B10_SINT = 81,
	FORMAT_A2B10G10R10_UNORM = 82,
	FORMAT_A2B10G10R10_UINT = 83,
	FORMAT_A2B10G10R10_SNORM = 84,
	FORMAT_A2B10G10R10_SINT = 85,
	FORMAT_R10G10B10A2_UNORM = 86,
	FORMAT_R10G10B10A2_UINT = 87,
	FORMAT_R10G10B10A2_SNORM = 88,
	FORMAT_R10G10B10A2_SINT = 89,
	FORMAT_B10G10R10A2_UNORM = 90,
	FORMAT_B10G10R10A2_UINT = 91,
	FORMAT_B10G10R10A2_SNORM = 92,
	FORMAT_B10G10R10A2_SINT = 93,
	FORMAT_B10G11R11_UFLOAT = 94,
	FORMAT_E5B9G9R9_UFLOAT = 95,
	FORMAT_R16G16B16_UNORM = 96,
	FORMAT_R16G16B16_SNORM = 97,
	FORMAT_R16G16B16_UINT = 98,
	FORMAT_R16G16B16_SINT = 99,
	FORMAT_R16G16B16_SFLOAT = 100,
	FORMAT_R16G16B16_SBFLOAT = 101,
	FORMAT_R16G16B16A16_UNORM = 102,
	FORMAT_R16G16B16A16_SNORM = 103,
	FORMAT_R16G16B16A16_UINT = 104,
	FORMAT_R16G16B16A16_SINT = 105,
	FORMAT_R16G16B16A16_SFLOAT = 106,
	FORMAT_R16G16B16A16_SBFLOAT = 107,
	FORMAT_R32G32_UINT = 108,
	FORMAT_R32G32_SINT = 109,
	FORMAT_R32G32_SFLOAT = 110,
	FORMAT_R32G32B32_UINT = 111,
	FORMAT_R32G32B32_SINT = 112,
	FORMAT_R32G32B32_SFLOAT = 113,
	FORMAT_R32G32B32A32_UINT = 114,
	FORMAT_R32G32B32A32_SINT = 115,
	FORMAT_R32G32B32A32_SFLOAT = 116,
	FORMAT_R64_UINT = 117,
	FORMAT_R64_SINT = 118,
	FORMAT_R64_SFLOAT = 119,
	FORMAT_R64G64_UINT = 120,
	FORMAT_R64G64_SINT = 121,
	FORMAT_R64G64_SFLOAT = 122,
	FORMAT_R64G64B64_UINT = 123,
	FORMAT_R64G64B64_SINT = 124,
	FORMAT_R64G64B64_SFLOAT = 125,
	FORMAT_R64G64B64A64_UINT = 126,
	FORMAT_R64G64B64A64_SINT = 127,
	FORMAT_R64G64B64A64_SFLOAT = 128,
	FORMAT_D16_UNORM = 129,
	FORMAT_X8_D24_UNORM = 130,
	FORMAT_D32_SFLOAT = 131,
	FORMAT_S8_UINT = 132,
	FORMAT_D16_UNORM_S8_UINT = 133,
	FORMAT_D24_UNORM_S8_UINT = 134,
	FORMAT_D32_SFLOAT_S8_UINT = 135,
	FORMAT_DXBC1_RGB_UNORM = 136,
	FORMAT_DXBC1_RGB_SRGB = 137,
	FORMAT_DXBC1_RGBA_UNORM = 138,
	FORMAT_DXBC1_RGBA_SRGB = 139,
	FORMAT_DXBC2_UNORM = 140,
	FORMAT_DXBC2_SRGB = 141,
	FORMAT_DXBC3_UNORM = 142,
	FORMAT_DXBC3_SRGB = 143,
	FORMAT_DXBC4_UNORM = 144,
	FORMAT_DXBC4_SNORM = 145,
	FORMAT_DXBC5_UNORM = 146,
	FORMAT_DXBC5_SNORM = 147,
	FORMAT_DXBC6H_UFLOAT = 148,
	FORMAT_DXBC6H_SFLOAT = 149,
	FORMAT_DXBC7_UNORM = 150,
	FORMAT_DXBC7_SRGB = 151,
	FORMAT_PVRTC1_2BPP_UNORM = 152,
	FORMAT_PVRTC1_4BPP_UNORM = 153,
	FORMAT_PVRTC2_2BPP_UNORM = 154,
	FORMAT_PVRTC2_4BPP_UNORM = 155,
	FORMAT_PVRTC1_2BPP_SRGB = 156,
	FORMAT_PVRTC1_4BPP_SRGB = 157,
	FORMAT_PVRTC2_2BPP_SRGB = 158,
	FORMAT_PVRTC2_4BPP_SRGB = 159,
	FORMAT_ETC2_R8G8B8_UNORM = 160,
	FORMAT_ETC2_R8G8B8_SRGB = 161,
	FORMAT_ETC2_R8G8B8A1_UNORM = 162,
	FORMAT_ETC2_R8G8B8A1_SRGB = 163,
	FORMAT_ETC2_R8G8B8A8_UNORM = 164,
	FORMAT_ETC2_R8G8B8A8_SRGB = 165,
	FORMAT_ETC2_EAC_R11_UNORM = 166,
	FORMAT_ETC2_EAC_R11_SNORM = 167,
	FORMAT_ETC2_EAC_R11G11_UNORM = 168,
	FORMAT_ETC2_EAC_R11G11_SNORM = 169,
	FORMAT_ASTC_4x4_UNORM = 170,
	FORMAT_ASTC_4x4_SRGB = 171,
	FORMAT_ASTC_5x4_UNORM = 172,
	FORMAT_ASTC_5x4_SRGB = 173,
	FORMAT_ASTC_5x5_UNORM = 174,
	FORMAT_ASTC_5x5_SRGB = 175,
	FORMAT_ASTC_6x5_UNORM = 176,
	FORMAT_ASTC_6x5_SRGB = 177,
	FORMAT_ASTC_6x6_UNORM = 178,
	FORMAT_ASTC_6x6_SRGB = 179,
	FORMAT_ASTC_8x5_UNORM = 180,
	FORMAT_ASTC_8x5_SRGB = 181,
	FORMAT_ASTC_8x6_UNORM = 182,
	FORMAT_ASTC_8x6_SRGB = 183,
	FORMAT_ASTC_8x8_UNORM = 184,
	FORMAT_ASTC_8x8_SRGB = 185,
	FORMAT_ASTC_10x5_UNORM = 186,
	FORMAT_ASTC_10x5_SRGB = 187,
	FORMAT_ASTC_10x6_UNORM = 188,
	FORMAT_ASTC_10x6_SRGB = 189,
	FORMAT_ASTC_10x8_UNORM = 190,
	FORMAT_ASTC_10x8_SRGB = 191,
	FORMAT_ASTC_10x10_UNORM = 192,
	FORMAT_ASTC_10x10_SRGB = 193,
	FORMAT_ASTC_12x10_UNORM = 194,
	FORMAT_ASTC_12x10_SRGB = 195,
	FORMAT_ASTC_12x12_UNORM = 196,
	FORMAT_ASTC_12x12_SRGB = 197,
	FORMAT_CLUT_P4 = 198,
	FORMAT_CLUT_P4A4 = 199,
	FORMAT_CLUT_P8 = 200,
	FORMAT_CLUT_P8A8 = 201,
	FORMAT_R4G4B4A4_UNORM_PACK16 = 202,
	FORMAT_B4G4R4A4_UNORM_PACK16 = 203,
	FORMAT_R5G6B5_UNORM_PACK16 = 204,
	FORMAT_B5G6R5_UNORM_PACK16 = 205,
	FORMAT_R5G5B5A1_UNORM_PACK16 = 206,
	FORMAT_B5G5R5A1_UNORM_PACK16 = 207,
	FORMAT_A1R5G5B5_UNORM_PACK16 = 208,
	FORMAT_G16B16G16R16_422_UNORM = 209,
	FORMAT_B16G16R16G16_422_UNORM = 210,
	FORMAT_R12X4G12X4B12X4A12X4_UNORM_4PACK16 = 211,
	FORMAT_G12X4B12X4G12X4R12X4_422_UNORM_4PACK16 = 212,
	FORMAT_B12X4G12X4R12X4G12X4_422_UNORM_4PACK16 = 213,
	FORMAT_R10X6G10X6B10X6A10X6_UNORM_4PACK16 = 214,
	FORMAT_G10X6B10X6G10X6R10X6_422_UNORM_4PACK16 = 215,
	FORMAT_B10X6G10X6R10X6G10X6_422_UNORM_4PACK16 = 216,
	FORMAT_G8B8G8R8_422_UNORM = 217,
	FORMAT_B8G8R8G8_422_UNORM = 218,
	FORMAT_G8_B8_R8_3PLANE_420_UNORM = 219,
	FORMAT_G8_B8R8_2PLANE_420_UNORM = 220,
	FORMAT_G8_B8_R8_3PLANE_422_UNORM = 221,
	FORMAT_G8_B8R8_2PLANE_422_UNORM = 222,
	FORMAT_G8_B8_R8_3PLANE_444_UNORM = 223,
	FORMAT_G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16 = 224,
	FORMAT_G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16 = 225,
	FORMAT_G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16 = 226,
	FORMAT_G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16 = 227,
	FORMAT_G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16 = 228,
	FORMAT_G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16 = 229,
	FORMAT_G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16 = 230,
	FORMAT_G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16 = 231,
	FORMAT_G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16 = 232,
	FORMAT_G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16 = 233,
	FORMAT_G16_B16_R16_3PLANE_420_UNORM = 234,
	FORMAT_G16_B16_R16_3PLANE_422_UNORM = 235,
	FORMAT_G16_B16_R16_3PLANE_444_UNORM = 236,
	FORMAT_G16_B16R16_2PLANE_420_UNORM = 237,
	FORMAT_G16_B16R16_2PLANE_422_UNORM = 238,
	FORMAT_COUNT = FORMAT_G16_B16R16_2PLANE_422_UNORM + 1,
	FORMAT_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum SlotMaskBit
{
	SLOT_0 = 0x1,
	SLOT_1 = 0x2,
	SLOT_2 = 0x4,
	SLOT_3 = 0x8,
	SLOT_4 = 0x10,
	SLOT_5 = 0x20,
	SLOT_6 = 0x40,
	SLOT_7 = 0x80
}

enum FilterType
{
	FILTER_TYPE_NEAREST = 0,
	FILTER_TYPE_LINEAR,
	FILTER_TYPE_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum AddressMode
{
	ADDRESS_MODE_MIRROR,
	ADDRESS_MODE_REPEAT,
	ADDRESS_MODE_CLAMP_TO_EDGE,
	ADDRESS_MODE_CLAMP_TO_BORDER,
	ADDRESS_MODE_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum MipMapMode
{
	MIPMAP_MODE_NEAREST = 0,
	MIPMAP_MODE_LINEAR,
	MIPMAP_MODE_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum LoadAction
{
	LOAD_ACTION_DONTCARE,
	LOAD_ACTION_LOAD,
	LOAD_ACTION_CLEAR,
	LOAD_ACTION_COUNT,
	LOAD_ACTION_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum StoreAction
{
	STORE_ACTION_STORE,
	STORE_ACTION_DISCARD,
	STORE_ACTION_COUNT,
	STORE_ACTION_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum PrimitiveTopology
{
	PRIM_TOPO_POINT_LIST = 0,
	PRIM_TOPO_LINE_LIST,
	PRIM_TOPO_LINE_STRIP,
	PRIM_TOPO_TRI_LIST,
	PRIM_TOPO_TRI_STRIP,
	PRIM_TOPO_PATCH_LIST,
	PRIM_TOPO_COUNT,
	PRIM_TOPO_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum BlendConstant
{
	BLEND_CONST_ZERO = 0,
	BLEND_CONST_ONE,
	BLEND_CONST_SRC_COLOR,
	BLEND_CONST_ONE_MINUS_SRC_COLOR,
	BLEND_CONST_DST_COLOR,
	BLEND_CONST_ONE_MINUS_DST_COLOR,
	BLEND_CONST_SRC_ALPHA,
	BLEND_CONST_ONE_MINUS_SRC_ALPHA,
	BLEND_CONST_DST_ALPHA,
	BLEND_CONST_ONE_MINUS_DST_ALPHA,
	BLEND_CONST_SRC_ALPHA_SATURATE,
	BLEND_CONST_BLEND_FACTOR,
	BLEND_CONST_ONE_MINUS_BLEND_FACTOR,
	BLEND_CONST_COUNT,
	BLEND_CONST_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum CullMode
{
	CULL_MODE_NONE = 0,
	CULL_MODE_BACK,
	CULL_MODE_FRONT,
	CULL_MODE_BOTH,
	CULL_MODE_COUNT,
	CULL_MODE_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum FrontFace
{
	FRONT_FACE_CCW = 0,
	FRONT_FACE_CW,
	FRONT_FACE_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum FillMode
{
	FILL_MODE_SOLID,
	FILL_MODE_WIREFRAME,
	FILL_MODE_COUNT,
	FILL_MODE_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum VertexInputRate
{
	INPUT_RATE_VERTEX = 0,
	INPUT_RATE_INSTANCE = 1,
	INPUT_RATE_COUNT,
	INPUT_RATE_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum CompareMode
{
	CMP_NEVER,
	CMP_LESS,
	CMP_EQUAL,
	CMP_LEQUAL,
	CMP_GREATER,
	CMP_NOTEQUAL,
	CMP_GEQUAL,
	CMP_ALWAYS,
	CMP_COUNT,
	CMP_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum StencilOp
{
	STENCIL_OP_KEEP,
	STENCIL_OP_SET_ZERO,
	STENCIL_OP_REPLACE,
	STENCIL_OP_INVERT,
	STENCIL_OP_INCR,
	STENCIL_OP_DECR,
	STENCIL_OP_INCR_SAT,
	STENCIL_OP_DECR_SAT,
	STENCIL_OP_COUNT,
	STENCIL_OP_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum BlendMode
{
	BLEND_MODE_ADD,
	BLEND_MODE_SUBTRACT,
	BLEND_MODE_REVERSE_SUBTRACT,
	BLEND_MODE_MIN,
	BLEND_MODE_MAX,
	BLEND_MODE_COUNT,
	BLEND_MODE_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum TextureDimension
{
	TEX_DIMENSION_1D,
	TEX_DIMENSION_2D,
	TEX_DIMENSION_2DMS,
	TEX_DIMENSION_3D,
	TEX_DIMENSION_CUBE,
	TEX_DIMENSION_1D_ARRAY,
	TEX_DIMENSION_2D_ARRAY,
	TEX_DIMENSION_2DMS_ARRAY,
	TEX_DIMENSION_CUBE_ARRAY,
	TEX_DIMENSION_COUNT,
	TEX_DIMENSION_UNDEFINED,
	TEX_DIMENSION_MAX_ENUM_BIT = 0x7FFFFFFF
}

[AllowDuplicates]
enum ShaderStage
{
	SHADER_STAGE_NONE = 0,

	SHADER_STAGE_VERT = 0X00000001,
	SHADER_STAGE_TESC = 0X00000002,
	SHADER_STAGE_TESE = 0X00000004,
	SHADER_STAGE_GEOM = 0X00000008,
	SHADER_STAGE_FRAG = 0X00000010,
	SHADER_STAGE_COMPUTE = 0X00000020,
	SHADER_STAGE_RAYTRACING = 0X00000040,

	SHADER_STAGE_ALL_GRAPHICS = SHADER_STAGE_VERT | SHADER_STAGE_TESC | SHADER_STAGE_TESE | SHADER_STAGE_GEOM | SHADER_STAGE_FRAG,
	SHADER_STAGE_HULL = SHADER_STAGE_TESC,
	SHADER_STAGE_DOMAIN = SHADER_STAGE_TESE,
	SHADER_STAGE_COUNT = 6,
	SHADER_STAGE_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum FenceStatus
{
	FENCE_STATUS_COMPLETE = 0,
	FENCE_STATUS_INCOMPLETE,
	FENCE_STATUS_NOTSUBMITTED,
	FENCE_STATUS_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum QueryType
{
	QUERY_TYPE_TIMESTAMP = 0,
	QUERY_TYPE_PIPELINE_STATISTICS,
	QUERY_TYPE_OCCLUSION,
	QUERY_TYPE_COUNT,
}

enum ResourceState
{
	RESOURCE_STATE_UNDEFINED = 0,
	RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER = 0x1,
	RESOURCE_STATE_INDEX_BUFFER = 0x2,
	RESOURCE_STATE_RENDER_TARGET = 0x4,
	RESOURCE_STATE_UNORDERED_ACCESS = 0x8,
	RESOURCE_STATE_DEPTH_WRITE = 0x10,
	RESOURCE_STATE_DEPTH_READ = 0x20,
	RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE = 0x40,
	RESOURCE_STATE_PIXEL_SHADER_RESOURCE = 0x80,
	RESOURCE_STATE_SHADER_RESOURCE = 0x40 | 0x80,
	RESOURCE_STATE_STREAM_OUT = 0x100,
	RESOURCE_STATE_INDIRECT_ARGUMENT = 0x200,
	RESOURCE_STATE_COPY_DEST = 0x400,
	RESOURCE_STATE_COPY_SOURCE = 0x800,
	RESOURCE_STATE_GENERIC_READ = (((((0x1 | 0x2) | 0x40) | 0x80) | 0x200) | 0x800),
	RESOURCE_STATE_PRESENT = 0x1000,
	RESOURCE_STATE_COMMON = 0x2000,
	RESOURCE_STATE_ACCELERATION_STRUCTURE = 0x4000,
	RESOURCE_STATE_SHADING_RATE_SOURCE = 0x8000,
	RESOURCE_STATE_RESOLVE_DEST = 0x10000,
	RESOURCE_STATE_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum MemoryUsage
{
	/// No intended memory usage specified.
	MEM_USAGE_UNKNOWN = 0,
	/// Memory will be used on device only, no need to be mapped on host.
	MEM_USAGE_GPU_ONLY = 1,
	/// Memory will be mapped on host. Could be used for transfer to device.
	MEM_USAGE_CPU_ONLY = 2,
	/// Memory will be used for frequent (dynamic) updates from host and reads on device.
	/// Memory location (heap) is unsure.
	MEM_USAGE_CPU_TO_GPU = 3,
	/// Memory will be used for writing on device and readback on host.
	/// Memory location (heap) is unsure.
	MEM_USAGE_GPU_TO_CPU = 4,
	MEM_USAGE_COUNT,
	MEM_USAGE_MAX_ENUM = 0x7FFFFFFF
}

enum BufferCreationFlag
{
	/// Default flag (Buffer will use aliased memory, buffer will not be cpu accessible until mapBuffer is called)
	BCF_NONE = 0,
	/// Buffer will allocate its own memory (COMMITTED resource)
	BCF_OWN_MEMORY_BIT = 0x02,
	/// Buffer will be persistently mapped
	BCF_PERSISTENT_MAP_BIT = 0x04,
	/// Use ESRAM to store this buffer
	BCF_ESRAM = 0x08,
	/// Flag to specify not to allocate descriptors for the resource
	BCF_NO_DESCRIPTOR_VIEW_CREATION = 0x10,
	/// Flag to specify to create GPUOnly buffer as Host visible
	BCF_HOST_VISIBLE = 0x20,
// Metal only
	/* ICB Flags */
	/// Inherit pipeline in ICB
	BCF_ICB_INHERIT_PIPELINE = 0x100,
	/// Inherit pipeline in ICB
	BCF_ICB_INHERIT_BUFFERS = 0x200,
// end Metal only
	BCF_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum TextureCreationFlag
{
	/// Default flag (Texture will use default allocation strategy decided by the api specific allocator)
	TCF_NONE = 0,
	/// Texture will allocate its own memory (COMMITTED resource)
	/// Note that this flag is not restricted Commited/Dedicated Allocation
	/// Actually VMA/D3D12MA allocate dedicated memories with ALLOW_ALIAS flag with specific loacl heaps
	/// If the texture needs to be restricted Committed/Dedicated(thus you want to keep its priority high)
	/// Toogle is_dedicated flag in TextureDescriptor
	TCF_OWN_MEMORY_BIT = 0x01,
	/// Texture will be allocated in memory which can be shared among multiple processes
	TCF_EXPORT_BIT = 0x02,
	/// Texture will be allocated in memory which can be shared among multiple gpus
	TCF_EXPORT_ADAPTER_BIT = 0x04,
	/// Texture will be imported from a handle created in another process
	TCF_IMPORT_BIT = 0x08,
	/// Use ESRAM to store this texture
	TCF_ESRAM = 0x10,
	/// Use on-tile memory to store this texture
	TCF_ON_TILE = 0x20,
	/// Prevent compression meta data from generating (XBox)
	TCF_NO_COMPRESSION = 0x40,
	/// Force 2D instead of automatically determining dimension based on width, height, depth
	TCF_FORCE_2D = 0x80,
	/// Force 3D instead of automatically determining dimension based on width, height, depth
	TCF_FORCE_3D = 0x100,
	/// Display target
	TCF_ALLOW_DISPLAY_TARGET = 0x200,
	/// Create a normal map texture
	TCF_NORMAL_MAP = 0x800,
	/// Fragment mask
	TCF_FRAG_MASK = 0x2000,
	TCF_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum SampleCount
{
	SAMPLE_COUNT_1 = 1,
	SAMPLE_COUNT_2 = 2,
	SAMPLE_COUNT_4 = 4,
	SAMPLE_COUNT_8 = 8,
	SAMPLE_COUNT_16 = 16,
	SAMPLE_COUNT_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum PipelineType
{
	PIPELINE_TYPE_NONE = 0,
	PIPELINE_TYPE_COMPUTE,
	PIPELINE_TYPE_GRAPHICS,
	PIPELINE_TYPE_RAYTRACING,
	PIPELINE_TYPE_COUNT,
	PIPELINE_TYPE_MAX_ENUM_BIT = 0x7FFFFFFF
}

[AllowDuplicates]
enum ResourceType
{
	RESOURCE_TYPE_NONE = 0,
	RESOURCE_TYPE_SAMPLER = 0x01,
	// SRV Read only texture
	RESOURCE_TYPE_TEXTURE = (RESOURCE_TYPE_SAMPLER << 1),
	/// RTV Texture
	RESOURCE_TYPE_RENDER_TARGET = (RESOURCE_TYPE_TEXTURE << 1),
	/// DSV Texture
	RESOURCE_TYPE_DEPTH_STENCIL = (RESOURCE_TYPE_RENDER_TARGET << 1),
	/// UAV Texture
	RESOURCE_TYPE_RW_TEXTURE = (RESOURCE_TYPE_DEPTH_STENCIL << 1),
	// SRV Read only buffer
	RESOURCE_TYPE_BUFFER = (RESOURCE_TYPE_RW_TEXTURE << 1),
	RESOURCE_TYPE_BUFFER_RAW = (RESOURCE_TYPE_BUFFER | (RESOURCE_TYPE_BUFFER << 1)),
	/// UAV Buffer
	RESOURCE_TYPE_RW_BUFFER = (RESOURCE_TYPE_BUFFER << 2),
	RESOURCE_TYPE_RW_BUFFER_RAW = (RESOURCE_TYPE_RW_BUFFER | (RESOURCE_TYPE_RW_BUFFER << 1)),
	/// CBV Uniform buffer
	RESOURCE_TYPE_UNIFORM_BUFFER = (RESOURCE_TYPE_RW_BUFFER << 2),
	/// Push constant / Root constant
	RESOURCE_TYPE_PUSH_CONSTANT = (RESOURCE_TYPE_UNIFORM_BUFFER << 1),
	/// IA
	RESOURCE_TYPE_VERTEX_BUFFER = (RESOURCE_TYPE_PUSH_CONSTANT << 1),
	RESOURCE_TYPE_INDEX_BUFFER = (RESOURCE_TYPE_VERTEX_BUFFER << 1),
	RESOURCE_TYPE_INDIRECT_BUFFER = (RESOURCE_TYPE_INDEX_BUFFER << 1),
	/// Cubemap SRV
	RESOURCE_TYPE_TEXTURE_CUBE = (RESOURCE_TYPE_TEXTURE | (RESOURCE_TYPE_INDIRECT_BUFFER << 1)),
	/// RTV / DSV per mip slice
	RESOURCE_TYPE_RENDER_TARGET_MIP_SLICES = (RESOURCE_TYPE_INDIRECT_BUFFER << 2),
	/// RTV / DSV per array slice
	RESOURCE_TYPE_RENDER_TARGET_ARRAY_SLICES = (RESOURCE_TYPE_RENDER_TARGET_MIP_SLICES << 1),
	/// RTV / DSV per depth slice
	RESOURCE_TYPE_RENDER_TARGET_DEPTH_SLICES = (RESOURCE_TYPE_RENDER_TARGET_ARRAY_SLICES << 1),
	RESOURCE_TYPE_RAY_TRACING = (RESOURCE_TYPE_RENDER_TARGET_DEPTH_SLICES << 1),
// Vulkan only
	/// Subpass input (descriptor type only available in Vulkan)
	RESOURCE_TYPE_INPUT_ATTACHMENT = (RESOURCE_TYPE_RAY_TRACING << 1),
	RESOURCE_TYPE_TEXEL_BUFFER = (RESOURCE_TYPE_INPUT_ATTACHMENT << 1),
	RESOURCE_TYPE_RW_TEXEL_BUFFER = (RESOURCE_TYPE_TEXEL_BUFFER << 1),
	RESOURCE_TYPE_COMBINED_IMAGE_SAMPLER = (RESOURCE_TYPE_RW_TEXEL_BUFFER << 1),
// End Vulkan only
// Metal only
	RESOURCE_TYPE_ARGUMENT_BUFFER = (RESOURCE_TYPE_RAY_TRACING << 1),
	RESOURCE_TYPE_INDIRECT_COMMAND_BUFFER = (RESOURCE_TYPE_ARGUMENT_BUFFER << 1),
	RESOURCE_TYPE_RENDER_PIPELINE_STATE = (RESOURCE_TYPE_INDIRECT_COMMAND_BUFFER << 1),
// End Metal only
	RESOURCE_TYPE_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum TexutreViewUsage
{
	TVU_SRV = 0x01,
	TVU_RTV_DSV = 0x02,
	TVU_UAV = 0x04,
	TVU_MAX_ENUM_BIT = 0x7FFFFFFF
}

enum TextureViewAspect
{
	TVA_COLOR = 0x01,
	TVA_DEPTH = 0x02,
	TVA_STENCIL = 0x04,
	TVA_MAX_ENUM_BIT = 0x7FFFFFFF
}

public static
{
	[Inline] public static bool IsDepthStencilFormat(in Format fmt)
	{
		switch (fmt) {
		case .FORMAT_D24_UNORM_S8_UINT: fallthrough;
		case .FORMAT_D32_SFLOAT_S8_UINT: fallthrough;
		case .FORMAT_D32_SFLOAT: fallthrough;
		case .FORMAT_X8_D24_UNORM: fallthrough;
		case .FORMAT_D16_UNORM: fallthrough;
		case .FORMAT_D16_UNORM_S8_UINT:
			return true;
		default: return false;
		}
	}

	[Inline] public static bool FormatUtil_IsDepthOnlyFormat(in Format fmt)
	{
		switch (fmt) {
		case .FORMAT_D32_SFLOAT:
		case .FORMAT_D16_UNORM:
			return true;
		default: return false;
		}
		return false;
	}

	[Inline] public static uint32 FormatUtil_BitSizeOfBlock(in Format fmt)
	{
		switch (fmt) {
		case .FORMAT_UNDEFINED: return 0;
		case .FORMAT_R1_UNORM: return 8;
		case .FORMAT_R2_UNORM: return 8;
		case .FORMAT_R4_UNORM: return 8;
		case .FORMAT_R4G4_UNORM: return 8;
		case .FORMAT_G4R4_UNORM: return 8;
		case .FORMAT_A8_UNORM: return 8;
		case .FORMAT_R8_UNORM: return 8;
		case .FORMAT_R8_SNORM: return 8;
		case .FORMAT_R8_UINT: return 8;
		case .FORMAT_R8_SINT: return 8;
		case .FORMAT_R8_SRGB: return 8;
		case .FORMAT_B2G3R3_UNORM: return 8;
		case .FORMAT_R4G4B4A4_UNORM: return 16;
		case .FORMAT_R4G4B4X4_UNORM: return 16;
		case .FORMAT_B4G4R4A4_UNORM: return 16;
		case .FORMAT_B4G4R4X4_UNORM: return 16;
		case .FORMAT_A4R4G4B4_UNORM: return 16;
		case .FORMAT_X4R4G4B4_UNORM: return 16;
		case .FORMAT_A4B4G4R4_UNORM: return 16;
		case .FORMAT_X4B4G4R4_UNORM: return 16;
		case .FORMAT_R5G6B5_UNORM: return 16;
		case .FORMAT_B5G6R5_UNORM: return 16;
		case .FORMAT_R5G5B5A1_UNORM: return 16;
		case .FORMAT_B5G5R5A1_UNORM: return 16;
		case .FORMAT_A1B5G5R5_UNORM: return 16;
		case .FORMAT_A1R5G5B5_UNORM: return 16;
		case .FORMAT_R5G5B5X1_UNORM: return 16;
		case .FORMAT_B5G5R5X1_UNORM: return 16;
		case .FORMAT_X1R5G5B5_UNORM: return 16;
		case .FORMAT_X1B5G5R5_UNORM: return 16;
		case .FORMAT_B2G3R3A8_UNORM: return 16;
		case .FORMAT_R8G8_UNORM: return 16;
		case .FORMAT_R8G8_SNORM: return 16;
		case .FORMAT_G8R8_UNORM: return 16;
		case .FORMAT_G8R8_SNORM: return 16;
		case .FORMAT_R8G8_UINT: return 16;
		case .FORMAT_R8G8_SINT: return 16;
		case .FORMAT_R8G8_SRGB: return 16;
		case .FORMAT_R16_UNORM: return 16;
		case .FORMAT_R16_SNORM: return 16;
		case .FORMAT_R16_UINT: return 16;
		case .FORMAT_R16_SINT: return 16;
		case .FORMAT_R16_SFLOAT: return 16;
		case .FORMAT_R16_SBFLOAT: return 16;
		case .FORMAT_R8G8B8_UNORM: return 24;
		case .FORMAT_R8G8B8_SNORM: return 24;
		case .FORMAT_R8G8B8_UINT: return 24;
		case .FORMAT_R8G8B8_SINT: return 24;
		case .FORMAT_R8G8B8_SRGB: return 24;
		case .FORMAT_B8G8R8_UNORM: return 24;
		case .FORMAT_B8G8R8_SNORM: return 24;
		case .FORMAT_B8G8R8_UINT: return 24;
		case .FORMAT_B8G8R8_SINT: return 24;
		case .FORMAT_B8G8R8_SRGB: return 24;
		case .FORMAT_R16G16B16_UNORM: return 48;
		case .FORMAT_R16G16B16_SNORM: return 48;
		case .FORMAT_R16G16B16_UINT: return 48;
		case .FORMAT_R16G16B16_SINT: return 48;
		case .FORMAT_R16G16B16_SFLOAT: return 48;
		case .FORMAT_R16G16B16_SBFLOAT: return 48;
		case .FORMAT_R16G16B16A16_UNORM: return 64;
		case .FORMAT_R16G16B16A16_SNORM: return 64;
		case .FORMAT_R16G16B16A16_UINT: return 64;
		case .FORMAT_R16G16B16A16_SINT: return 64;
		case .FORMAT_R16G16B16A16_SFLOAT: return 64;
		case .FORMAT_R16G16B16A16_SBFLOAT: return 64;
		case .FORMAT_R32G32_UINT: return 64;
		case .FORMAT_R32G32_SINT: return 64;
		case .FORMAT_R32G32_SFLOAT: return 64;
		case .FORMAT_R32G32B32_UINT: return 96;
		case .FORMAT_R32G32B32_SINT: return 96;
		case .FORMAT_R32G32B32_SFLOAT: return 96;
		case .FORMAT_R32G32B32A32_UINT: return 128;
		case .FORMAT_R32G32B32A32_SINT: return 128;
		case .FORMAT_R32G32B32A32_SFLOAT: return 128;
		case .FORMAT_R64_UINT: return 64;
		case .FORMAT_R64_SINT: return 64;
		case .FORMAT_R64_SFLOAT: return 64;
		case .FORMAT_R64G64_UINT: return 128;
		case .FORMAT_R64G64_SINT: return 128;
		case .FORMAT_R64G64_SFLOAT: return 128;
		case .FORMAT_R64G64B64_UINT: return 192;
		case .FORMAT_R64G64B64_SINT: return 192;
		case .FORMAT_R64G64B64_SFLOAT: return 192;
		case .FORMAT_R64G64B64A64_UINT: return 256;
		case .FORMAT_R64G64B64A64_SINT: return 256;
		case .FORMAT_R64G64B64A64_SFLOAT: return 256;
		case .FORMAT_D16_UNORM: return 16;
		case .FORMAT_S8_UINT: return 8;
		case .FORMAT_D32_SFLOAT_S8_UINT: return 64;
		case .FORMAT_DXBC1_RGB_UNORM: return 64;
		case .FORMAT_DXBC1_RGB_SRGB: return 64;
		case .FORMAT_DXBC1_RGBA_UNORM: return 64;
		case .FORMAT_DXBC1_RGBA_SRGB: return 64;
		case .FORMAT_DXBC2_UNORM: return 128;
		case .FORMAT_DXBC2_SRGB: return 128;
		case .FORMAT_DXBC3_UNORM: return 128;
		case .FORMAT_DXBC3_SRGB: return 128;
		case .FORMAT_DXBC4_UNORM: return 64;
		case .FORMAT_DXBC4_SNORM: return 64;
		case .FORMAT_DXBC5_UNORM: return 128;
		case .FORMAT_DXBC5_SNORM: return 128;
		case .FORMAT_DXBC6H_UFLOAT: return 128;
		case .FORMAT_DXBC6H_SFLOAT: return 128;
		case .FORMAT_DXBC7_UNORM: return 128;
		case .FORMAT_DXBC7_SRGB: return 128;
		case .FORMAT_PVRTC1_2BPP_UNORM: return 64;
		case .FORMAT_PVRTC1_4BPP_UNORM: return 64;
		case .FORMAT_PVRTC2_2BPP_UNORM: return 64;
		case .FORMAT_PVRTC2_4BPP_UNORM: return 64;
		case .FORMAT_PVRTC1_2BPP_SRGB: return 64;
		case .FORMAT_PVRTC1_4BPP_SRGB: return 64;
		case .FORMAT_PVRTC2_2BPP_SRGB: return 64;
		case .FORMAT_PVRTC2_4BPP_SRGB: return 64;
		case .FORMAT_ETC2_R8G8B8_UNORM: return 64;
		case .FORMAT_ETC2_R8G8B8_SRGB: return 64;
		case .FORMAT_ETC2_R8G8B8A1_UNORM: return 64;
		case .FORMAT_ETC2_R8G8B8A1_SRGB: return 64;
		case .FORMAT_ETC2_R8G8B8A8_UNORM: return 64;
		case .FORMAT_ETC2_R8G8B8A8_SRGB: return 64;
		case .FORMAT_ETC2_EAC_R11_UNORM: return 64;
		case .FORMAT_ETC2_EAC_R11_SNORM: return 64;
		case .FORMAT_ETC2_EAC_R11G11_UNORM: return 64;
		case .FORMAT_ETC2_EAC_R11G11_SNORM: return 64;
		case .FORMAT_ASTC_4x4_UNORM: return 128;
		case .FORMAT_ASTC_4x4_SRGB: return 128;
		case .FORMAT_ASTC_5x4_UNORM: return 128;
		case .FORMAT_ASTC_5x4_SRGB: return 128;
		case .FORMAT_ASTC_5x5_UNORM: return 128;
		case .FORMAT_ASTC_5x5_SRGB: return 128;
		case .FORMAT_ASTC_6x5_UNORM: return 128;
		case .FORMAT_ASTC_6x5_SRGB: return 128;
		case .FORMAT_ASTC_6x6_UNORM: return 128;
		case .FORMAT_ASTC_6x6_SRGB: return 128;
		case .FORMAT_ASTC_8x5_UNORM: return 128;
		case .FORMAT_ASTC_8x5_SRGB: return 128;
		case .FORMAT_ASTC_8x6_UNORM: return 128;
		case .FORMAT_ASTC_8x6_SRGB: return 128;
		case .FORMAT_ASTC_8x8_UNORM: return 128;
		case .FORMAT_ASTC_8x8_SRGB: return 128;
		case .FORMAT_ASTC_10x5_UNORM: return 128;
		case .FORMAT_ASTC_10x5_SRGB: return 128;
		case .FORMAT_ASTC_10x6_UNORM: return 128;
		case .FORMAT_ASTC_10x6_SRGB: return 128;
		case .FORMAT_ASTC_10x8_UNORM: return 128;
		case .FORMAT_ASTC_10x8_SRGB: return 128;
		case .FORMAT_ASTC_10x10_UNORM: return 128;
		case .FORMAT_ASTC_10x10_SRGB: return 128;
		case .FORMAT_ASTC_12x10_UNORM: return 128;
		case .FORMAT_ASTC_12x10_SRGB: return 128;
		case .FORMAT_ASTC_12x12_UNORM: return 128;
		case .FORMAT_ASTC_12x12_SRGB: return 128;
		case .FORMAT_CLUT_P4: return 8;
		case .FORMAT_CLUT_P4A4: return 8;
		case .FORMAT_CLUT_P8: return 8;
		case .FORMAT_CLUT_P8A8: return 16;
		case .FORMAT_G16B16G16R16_422_UNORM: return 8;
		case .FORMAT_B16G16R16G16_422_UNORM: return 8;
		case .FORMAT_R12X4G12X4B12X4A12X4_UNORM_4PACK16: return 8;
		case .FORMAT_G12X4B12X4G12X4R12X4_422_UNORM_4PACK16: return 8;
		case .FORMAT_B12X4G12X4R12X4G12X4_422_UNORM_4PACK16: return 8;
		case .FORMAT_R10X6G10X6B10X6A10X6_UNORM_4PACK16: return 8;
		case .FORMAT_G10X6B10X6G10X6R10X6_422_UNORM_4PACK16: return 8;
		case .FORMAT_B10X6G10X6R10X6G10X6_422_UNORM_4PACK16: return 8;
		case .FORMAT_G8B8G8R8_422_UNORM: return 4;
		case .FORMAT_B8G8R8G8_422_UNORM: return 4;
		default: return 32;
		}
	}

	[Inline] public static uint32 FormatUtil_WidthOfBlock(in Format fmt)
	{
		switch (fmt) {
		case .FORMAT_UNDEFINED: return 1;
		case .FORMAT_R1_UNORM: return 8;
		case .FORMAT_R2_UNORM: return 4;
		case .FORMAT_R4_UNORM: return 2;
		case .FORMAT_DXBC1_RGB_UNORM: return 4;
		case .FORMAT_DXBC1_RGB_SRGB: return 4;
		case .FORMAT_DXBC1_RGBA_UNORM: return 4;
		case .FORMAT_DXBC1_RGBA_SRGB: return 4;
		case .FORMAT_DXBC2_UNORM: return 4;
		case .FORMAT_DXBC2_SRGB: return 4;
		case .FORMAT_DXBC3_UNORM: return 4;
		case .FORMAT_DXBC3_SRGB: return 4;
		case .FORMAT_DXBC4_UNORM: return 4;
		case .FORMAT_DXBC4_SNORM: return 4;
		case .FORMAT_DXBC5_UNORM: return 4;
		case .FORMAT_DXBC5_SNORM: return 4;
		case .FORMAT_DXBC6H_UFLOAT: return 4;
		case .FORMAT_DXBC6H_SFLOAT: return 4;
		case .FORMAT_DXBC7_UNORM: return 4;
		case .FORMAT_DXBC7_SRGB: return 4;
		case .FORMAT_PVRTC1_2BPP_UNORM: return 8;
		case .FORMAT_PVRTC1_4BPP_UNORM: return 4;
		case .FORMAT_PVRTC2_2BPP_UNORM: return 8;
		case .FORMAT_PVRTC2_4BPP_UNORM: return 4;
		case .FORMAT_PVRTC1_2BPP_SRGB: return 8;
		case .FORMAT_PVRTC1_4BPP_SRGB: return 4;
		case .FORMAT_PVRTC2_2BPP_SRGB: return 8;
		case .FORMAT_PVRTC2_4BPP_SRGB: return 4;
		case .FORMAT_ETC2_R8G8B8_UNORM: return 4;
		case .FORMAT_ETC2_R8G8B8_SRGB: return 4;
		case .FORMAT_ETC2_R8G8B8A1_UNORM: return 4;
		case .FORMAT_ETC2_R8G8B8A1_SRGB: return 4;
		case .FORMAT_ETC2_R8G8B8A8_UNORM: return 4;
		case .FORMAT_ETC2_R8G8B8A8_SRGB: return 4;
		case .FORMAT_ETC2_EAC_R11_UNORM: return 4;
		case .FORMAT_ETC2_EAC_R11_SNORM: return 4;
		case .FORMAT_ETC2_EAC_R11G11_UNORM: return 4;
		case .FORMAT_ETC2_EAC_R11G11_SNORM: return 4;
		case .FORMAT_ASTC_4x4_UNORM: return 4;
		case .FORMAT_ASTC_4x4_SRGB: return 4;
		case .FORMAT_ASTC_5x4_UNORM: return 5;
		case .FORMAT_ASTC_5x4_SRGB: return 5;
		case .FORMAT_ASTC_5x5_UNORM: return 5;
		case .FORMAT_ASTC_5x5_SRGB: return 5;
		case .FORMAT_ASTC_6x5_UNORM: return 6;
		case .FORMAT_ASTC_6x5_SRGB: return 6;
		case .FORMAT_ASTC_6x6_UNORM: return 6;
		case .FORMAT_ASTC_6x6_SRGB: return 6;
		case .FORMAT_ASTC_8x5_UNORM: return 8;
		case .FORMAT_ASTC_8x5_SRGB: return 8;
		case .FORMAT_ASTC_8x6_UNORM: return 8;
		case .FORMAT_ASTC_8x6_SRGB: return 8;
		case .FORMAT_ASTC_8x8_UNORM: return 8;
		case .FORMAT_ASTC_8x8_SRGB: return 8;
		case .FORMAT_ASTC_10x5_UNORM: return 10;
		case .FORMAT_ASTC_10x5_SRGB: return 10;
		case .FORMAT_ASTC_10x6_UNORM: return 10;
		case .FORMAT_ASTC_10x6_SRGB: return 10;
		case .FORMAT_ASTC_10x8_UNORM: return 10;
		case .FORMAT_ASTC_10x8_SRGB: return 10;
		case .FORMAT_ASTC_10x10_UNORM: return 10;
		case .FORMAT_ASTC_10x10_SRGB: return 10;
		case .FORMAT_ASTC_12x10_UNORM: return 12;
		case .FORMAT_ASTC_12x10_SRGB: return 12;
		case .FORMAT_ASTC_12x12_UNORM: return 12;
		case .FORMAT_ASTC_12x12_SRGB: return 12;
		case .FORMAT_CLUT_P4: return 2;
		default: return 1;
		}
	}

	[Inline] public static uint32 FormatUtil_HeightOfBlock(in Format fmt)
	{
		switch (fmt) {
		case .FORMAT_UNDEFINED: return 1;
		case .FORMAT_DXBC1_RGB_UNORM: return 4;
		case .FORMAT_DXBC1_RGB_SRGB: return 4;
		case .FORMAT_DXBC1_RGBA_UNORM: return 4;
		case .FORMAT_DXBC1_RGBA_SRGB: return 4;
		case .FORMAT_DXBC2_UNORM: return 4;
		case .FORMAT_DXBC2_SRGB: return 4;
		case .FORMAT_DXBC3_UNORM: return 4;
		case .FORMAT_DXBC3_SRGB: return 4;
		case .FORMAT_DXBC4_UNORM: return 4;
		case .FORMAT_DXBC4_SNORM: return 4;
		case .FORMAT_DXBC5_UNORM: return 4;
		case .FORMAT_DXBC5_SNORM: return 4;
		case .FORMAT_DXBC6H_UFLOAT: return 4;
		case .FORMAT_DXBC6H_SFLOAT: return 4;
		case .FORMAT_DXBC7_UNORM: return 4;
		case .FORMAT_DXBC7_SRGB: return 4;
		case .FORMAT_PVRTC1_2BPP_UNORM: return 4;
		case .FORMAT_PVRTC1_4BPP_UNORM: return 4;
		case .FORMAT_PVRTC2_2BPP_UNORM: return 4;
		case .FORMAT_PVRTC2_4BPP_UNORM: return 4;
		case .FORMAT_PVRTC1_2BPP_SRGB: return 4;
		case .FORMAT_PVRTC1_4BPP_SRGB: return 4;
		case .FORMAT_PVRTC2_2BPP_SRGB: return 4;
		case .FORMAT_PVRTC2_4BPP_SRGB: return 4;
		case .FORMAT_ETC2_R8G8B8_UNORM: return 4;
		case .FORMAT_ETC2_R8G8B8_SRGB: return 4;
		case .FORMAT_ETC2_R8G8B8A1_UNORM: return 4;
		case .FORMAT_ETC2_R8G8B8A1_SRGB: return 4;
		case .FORMAT_ETC2_R8G8B8A8_UNORM: return 4;
		case .FORMAT_ETC2_R8G8B8A8_SRGB: return 4;
		case .FORMAT_ETC2_EAC_R11_UNORM: return 4;
		case .FORMAT_ETC2_EAC_R11_SNORM: return 4;
		case .FORMAT_ETC2_EAC_R11G11_UNORM: return 4;
		case .FORMAT_ETC2_EAC_R11G11_SNORM: return 4;
		case .FORMAT_ASTC_4x4_UNORM: return 4;
		case .FORMAT_ASTC_4x4_SRGB: return 4;
		case .FORMAT_ASTC_5x4_UNORM: return 4;
		case .FORMAT_ASTC_5x4_SRGB: return 4;
		case .FORMAT_ASTC_5x5_UNORM: return 5;
		case .FORMAT_ASTC_5x5_SRGB: return 5;
		case .FORMAT_ASTC_6x5_UNORM: return 5;
		case .FORMAT_ASTC_6x5_SRGB: return 5;
		case .FORMAT_ASTC_6x6_UNORM: return 6;
		case .FORMAT_ASTC_6x6_SRGB: return 6;
		case .FORMAT_ASTC_8x5_UNORM: return 5;
		case .FORMAT_ASTC_8x5_SRGB: return 5;
		case .FORMAT_ASTC_8x6_UNORM: return 6;
		case .FORMAT_ASTC_8x6_SRGB: return 6;
		case .FORMAT_ASTC_8x8_UNORM: return 8;
		case .FORMAT_ASTC_8x8_SRGB: return 8;
		case .FORMAT_ASTC_10x5_UNORM: return 5;
		case .FORMAT_ASTC_10x5_SRGB: return 5;
		case .FORMAT_ASTC_10x6_UNORM: return 6;
		case .FORMAT_ASTC_10x6_SRGB: return 6;
		case .FORMAT_ASTC_10x8_UNORM: return 8;
		case .FORMAT_ASTC_10x8_SRGB: return 8;
		case .FORMAT_ASTC_10x10_UNORM: return 10;
		case .FORMAT_ASTC_10x10_SRGB: return 10;
		case .FORMAT_ASTC_12x10_UNORM: return 10;
		case .FORMAT_ASTC_12x10_SRGB: return 10;
		case .FORMAT_ASTC_12x12_UNORM: return 12;
		case .FORMAT_ASTC_12x12_SRGB: return 12;
		default: return 1;
		}
	}
}

struct VendorPreset
{
	public uint32 DeviceId;
	public uint32 VendorId;
	public uint32 DriverVersion;
	public char8[64] GpuName; // If GPU Name is missing then value will be empty string
}

struct FormatSupport
{
	public uint8 ShaderRead;
	public uint8 ShaderWrite;
	public uint8 RenderTargetWrite;
}

struct ConstantSpecialization
{
	public uint32 ConstantID;
	private Value mValue;

	public uint32 UInt32 { get => mValue.UInt32; set mut => mValue.UInt32 = value; }
	public int32 Int32 { get => mValue.Int32; set mut => mValue.Int32 = value; }
	public float Float { get => mValue.Float; set mut => mValue.Float = value; }

	[Union] public struct Value
	{
		public uint32 UInt32;
		public int32 Int32;
		public float Float;
	}
}

struct ShaderResource
{
	public char8* Name;
	public uint NameHash;
	public ResourceType ResourceType;
	public uint32 Set;
	public uint32 Binding;
	public uint32 Size;
	public uint32 Offset;
	public ShaderStage Stages;
}

struct VertexInput
{
	public char8* Name;
	public char8* Semantics;
	public Format Format;
}

struct ShaderReflection
{
	public char8* EntryName;
	public ShaderStage stage;
	public Span<VertexInput> VertexInputs;
	public Span<ShaderResource> ShaderResources;
	public uint32[3] ThreadGroupSizes;
}

struct PipelineReflection
{
	public ShaderReflection*[(.)ShaderStage.SHADER_STAGE_COUNT] Stages;
	// descriptor sets / root tables
	public Span<ShaderResource> ShaderResources;
}

struct PipelineShaderDescription
{
}

struct DescriptorData
{
	// Update Via Shader Reflection.
	public char8* Name;
	// Update Via Binding Slot.
	public uint32 Binding;
	public ResourceType BindingType;
	[Union] struct Params
	{
		public struct BufferParams
		{
			/// Offset to bind the buffer descriptor
			public uint64* Offsets;
			public uint64* Sizes;
		}
		// Descriptor set buffer extraction options
		public struct ExtractionParams
		{
			public PipelineShaderDescription* Shader;
			public uint32 BufferIndex;
			public ShaderStage ShaderStage;
		}
		public struct UavParams
		{
			public uint32 UavMipSlice;
			public bool blendMipChain;
		}
		public BufferParams mBufferParams;
		public ExtractionParams mExtractionParams;
		public UavParams mUavParams;
		public bool EnableStencilResource;
	};
	private Params mParams;


	public ref Params.BufferParams BufferParams mut => ref mParams.mBufferParams;
	public ref Params.ExtractionParams ExtractionParams mut => ref mParams.mExtractionParams;
	public ref Params.UavParams UavParams mut => ref mParams.mUavParams;
	public ref bool EnableStencilResource mut => ref mParams.EnableStencilResource;

	[Union] struct Resources
	{
		public Span<TextureView> Textures;
		public Span<Sampler> Samplers;
		public Span<Buffer> Buffers;
		public Span<GraphicsPipeline> RenderPipelines;
		public Span<ComputePipeline> ComputePipelines;
		public Span<DescriptorSet> DescriptorSets;
	};
	private Resources mResources;
	/// Array of texture descriptors (srv and uav textures)
	public ref Span<TextureView> Textures mut => ref mResources.Textures;
	/// Array of sampler descriptors
	public ref Span<Sampler> Samplers mut => ref mResources.Samplers;
	/// Array of buffer descriptors (srv, uav and cbv buffers)
	public ref Span<Buffer> Buffers mut => ref mResources.Buffers;
	/// Array of pipeline descriptors
	public ref Span<GraphicsPipeline> RenderPipelines mut => ref mResources.RenderPipelines;
	/// Array of pipeline descriptors
	public ref Span<ComputePipeline> ComputePipelines mut => ref mResources.ComputePipelines;
	/// DescriptorSet buffer extraction
	public ref Span<DescriptorSet> DescriptorSets mut => ref mResources.DescriptorSets;
	/// Custom binding (raytracing acceleration structure ...)
	// public Span<AccelerationStructure> AccelerationStructures;

	public uint32 Count;
}

[Union]
struct ClearValue
{
	struct Color
	{
		public float R;
		public float G;
		public float B;
		public float A;
	}
	struct DepthStencil
	{
		public float Depth;
		public uint32 Stencil;
	}
	private Color mColor;
	private DepthStencil mDepthStencil;


	public ref float R mut => ref mColor.R;
	public ref float G mut => ref mColor.G;
	public ref float B mut => ref mColor.B;
	public ref float A mut => ref mColor.A;
	public ref float Depth mut => ref mDepthStencil.Depth;
	public ref uint32 Stencil mut => ref mDepthStencil.Stencil;
}