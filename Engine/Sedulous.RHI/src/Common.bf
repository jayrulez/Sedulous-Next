using System;
using Sedulous.Foundation.Logging.Abstractions;
namespace Sedulous.RHI;

// NRI Commit: dcd4f638da4b49e2678e04c440d040cf0b954e08
// NRI_VERSION_MAJOR 1
// NRI_VERSION_MINOR 84
// NRI_VERSION_DATE "14 August 2022"

public static
{
	public static uint32 SetBit(uint32 index)
	{
		return 1 << index;
	}

	public const uint16 REMAINING_ARRAY_LAYERS = 0;
	public const uint16 REMAINING_MIP_LEVELS = 0;
	public const uint16 WHOLE_SIZE = 0;
	public const uint32 WHOLE_DEVICE_GROUP = 0;
	public const bool VARIABLE_DESCRIPTOR_NUM = true;
	public const bool DESCRIPTOR_ARRAY = true;

	public const uint32 PHYSICAL_DEVICE_GROUP_MAX_SIZE = 4;
	public const uint32 COMMAND_QUEUE_TYPE_NUM = (uint32)CommandQueueType.MAX_NUM;
}

enum Result
{
	SUCCESS,
	FAILURE,
	INVALID_ARGUMENT,
	OUT_OF_MEMORY,
	UNSUPPORTED,
	DEVICE_LOST,
	SWAPCHAIN_RESIZE,

	MAX_NUM
}

enum Vendor : uint8
{
	UNKNOWN,
	NVIDIA,
	AMD,
	INTEL,

	MAX_NUM
}

enum GraphicsAPI
{
	D3D11,
	D3D12,
	VULKAN,

	MAX_NUM
}

enum CommandQueueType
{
	GRAPHICS,
	COMPUTE,
	COPY,

	MAX_NUM
}

enum MemoryLocation : uint8
{
	DEVICE,
	HOST_UPLOAD,
	HOST_READBACK,

	MAX_NUM
}

enum TextureType : uint16
{
	TEXTURE_1D,
	TEXTURE_2D,
	TEXTURE_3D,

	MAX_NUM
}

enum Texture1DViewType : uint16
{
	SHADER_RESOURCE_1D,
	SHADER_RESOURCE_1D_ARRAY,
	SHADER_RESOURCE_STORAGE_1D,
	SHADER_RESOURCE_STORAGE_1D_ARRAY,
	COLOR_ATTACHMENT,
	DEPTH_STENCIL_ATTACHMENT,

	MAX_NUM
}

enum Texture2DViewType : uint16
{
	SHADER_RESOURCE_2D,
	SHADER_RESOURCE_2D_ARRAY,
	SHADER_RESOURCE_CUBE,
	SHADER_RESOURCE_CUBE_ARRAY,
	SHADER_RESOURCE_STORAGE_2D,
	SHADER_RESOURCE_STORAGE_2D_ARRAY,
	COLOR_ATTACHMENT,
	DEPTH_STENCIL_ATTACHMENT,

	MAX_NUM
}

enum Texture3DViewType : uint16
{
	SHADER_RESOURCE_3D,
	SHADER_RESOURCE_STORAGE_3D,
	COLOR_ATTACHMENT,

	MAX_NUM
}

enum BufferViewType : uint16
{
	SHADER_RESOURCE,
	SHADER_RESOURCE_STORAGE,
	CONSTANT,

	MAX_NUM
}

enum DescriptorType : uint16
{
	SAMPLER,
	CONSTANT_BUFFER,
	TEXTURE,
	STORAGE_TEXTURE,
	BUFFER,
	STORAGE_BUFFER,
	STRUCTURED_BUFFER,
	STORAGE_STRUCTURED_BUFFER,
	ACCELERATION_STRUCTURE,

	MAX_NUM
}

enum VertexStreamStepRate : uint16
{
	PER_VERTEX,
	PER_INSTANCE,

	MAX_NUM
}

enum TextureUsageBits : uint16
{
	NONE = 0,
	SHADER_RESOURCE = SetBit(0),
	SHADER_RESOURCE_STORAGE = SetBit(1),
	COLOR_ATTACHMENT = SetBit(2),
	DEPTH_STENCIL_ATTACHMENT = SetBit(3)
}

enum BufferUsageBits : uint16
{
	NONE = 0,
	SHADER_RESOURCE = SetBit(0),
	SHADER_RESOURCE_STORAGE = SetBit(1),
	VERTEX_BUFFER = SetBit(2),
	INDEX_BUFFER = SetBit(3),
	CONSTANT_BUFFER = SetBit(4),
	ARGUMENT_BUFFER = SetBit(5),
	RAY_TRACING_BUFFER = SetBit(6),
	ACCELERATION_STRUCTURE_BUILD_READ = SetBit(7)
}

enum AccessBits : uint16
{
	UNKNOWN = 0,
	VERTEX_BUFFER = SetBit(0),
	INDEX_BUFFER = SetBit(1),
	CONSTANT_BUFFER = SetBit(2),
	ARGUMENT_BUFFER = SetBit(3),
	SHADER_RESOURCE = SetBit(4),
	SHADER_RESOURCE_STORAGE = SetBit(5),
	COLOR_ATTACHMENT = SetBit(6),
	DEPTH_STENCIL_WRITE = SetBit(7),
	DEPTH_STENCIL_READ = SetBit(8),
	COPY_SOURCE = SetBit(9),
	COPY_DESTINATION = SetBit(10),
	ACCELERATION_STRUCTURE_READ = SetBit(11),
	ACCELERATION_STRUCTURE_WRITE = SetBit(12)
}

enum TextureLayout : uint16
{
	GENERAL,
	COLOR_ATTACHMENT,
	DEPTH_STENCIL,
	DEPTH_STENCIL_READONLY,
	DEPTH_READONLY,
	STENCIL_READONLY,
	SHADER_RESOURCE,
	PRESENT,
	UNKNOWN,

	MAX_NUM
}

enum ShaderStage : uint16
{
	ALL,
	VERTEX,
	TESS_CONTROL,
	TESS_EVALUATION,
	GEOMETRY,
	FRAGMENT,
	COMPUTE,
	RAYGEN,
	MISS,
	INTERSECTION,
	CLOSEST_HIT,
	ANY_HIT,
	CALLABLE,
	MESH_CONTROL,
	MESH_EVALUATION,

	MAX_NUM
}

enum PipelineLayoutShaderStageBits : uint16
{
	NONE = 0,
	VERTEX = SetBit(1),
	TESS_CONTROL = SetBit(2),
	TESS_EVALUATION = SetBit(3),
	GEOMETRY = SetBit(4),
	FRAGMENT = SetBit(5),
	COMPUTE = SetBit(6),
	RAYGEN = SetBit(7),
	MISS = SetBit(8),
	INTERSECTION = SetBit(9),
	CLOSEST_HIT = SetBit(10),
	ANY_HIT = SetBit(11),
	CALLABLE = SetBit(12),
	MESH_CONTROL = SetBit(13),
	MESH_EVALUATION = SetBit(14),
	ALL_GRAPHICS = VERTEX | TESS_CONTROL | TESS_EVALUATION | GEOMETRY | FRAGMENT | MESH_CONTROL | MESH_EVALUATION,
	ALL_RAY_TRACING = RAYGEN | MISS | INTERSECTION | CLOSEST_HIT | ANY_HIT | CALLABLE
}

enum BarrierDependency
{
	ALL_STAGES,
	GRAPHICS_STAGE,
	COMPUTE_STAGE,
	COPY_STAGE,
	RAYTRACING_STAGE,

	MAX_NUM
}

enum ColorWriteBits : uint8
{
	R = SetBit(0),
	G = SetBit(1),
	B = SetBit(2),
	A = SetBit(3),
	RGBA = R | G | B | A
}

enum Topology : uint8
{
	POINT_LIST,
	LINE_LIST,
	LINE_STRIP,
	TRIANGLE_LIST,
	TRIANGLE_STRIP,
	LINE_LIST_WITH_ADJACENCY,
	LINE_STRIP_WITH_ADJACENCY,
	TRIANGLE_LIST_WITH_ADJACENCY,
	TRIANGLE_STRIP_WITH_ADJACENCY,
	PATCH_LIST,

	MAX_NUM
}

enum FillMode
{
	SOLID,
	WIREFRAME,

	MAX_NUM
}

enum CullMode
{
	NONE,
	FRONT,
	BACK,

	MAX_NUM
}

enum LogicFunc
{
	NONE,
	CLEAR,
	AND,
	AND_REVERSE,
	COPY,
	AND_INVERTED,
	XOR,
	OR,
	NOR,
	EQUIVALENT,
	INVERT,
	OR_REVERSE,
	COPY_INVERTED,
	OR_INVERTED,
	NAND,
	SET,

	MAX_NUM
}

enum CompareFunc : uint16
{
	NONE,
	ALWAYS,
	NEVER,
	LESS,
	LESS_EQUAL,
	EQUAL,
	GREATER_EQUAL,
	GREATER,
	NOT_EQUAL,

	MAX_NUM
}

enum StencilFunc : uint16
{
	KEEP,
	ZERO,
	REPLACE,
	INCREMENT_AND_CLAMP,
	DECREMENT_AND_CLAMP,
	INVERT,
	INCREMENT_AND_WRAP,
	DECREMENT_AND_WRAP,

	MAX_NUM
}

enum BlendFactor
{
	ZERO,
	ONE,
	SRC_COLOR,
	ONE_MINUS_SRC_COLOR,
	DST_COLOR,
	ONE_MINUS_DST_COLOR,
	SRC_ALPHA,
	ONE_MINUS_SRC_ALPHA,
	DST_ALPHA,
	ONE_MINUS_DST_ALPHA,
	CONSTANT_COLOR,
	ONE_MINUS_CONSTANT_COLOR,
	CONSTANT_ALPHA,
	ONE_MINUS_CONSTANT_ALPHA,
	SRC_ALPHA_SATURATE,
	SRC1_COLOR,
	ONE_MINUS_SRC1_COLOR,
	SRC1_ALPHA,
	ONE_MINUS_SRC1_ALPHA,

	MAX_NUM
}

enum BlendFunc
{
	ADD,
	SUBTRACT,
	REVERSE_SUBTRACT,
	MIN,
	MAX,

	MAX_NUM
}

enum IndexType
{
	UINT16,
	UINT32,

	MAX_NUM
}

enum QueryType
{
	TIMESTAMP,
	OCCLUSION,
	PIPELINE_STATISTICS,
	ACCELERATION_STRUCTURE_COMPACTED_SIZE,

	MAX_NUM
}

enum PipelineStatsBits : uint32
{
	INPUT_ASSEMBLY_VERTICES = SetBit(0),
	INPUT_ASSEMBLY_PRIMITIVES = SetBit(1),
	VERTEX_SHADER_INVOCATIONS = SetBit(2),
	GEOMETRY_SHADER_INVOCATIONS = SetBit(3),
	GEOMETRY_SHADER_PRIMITIVES = SetBit(4),
	CLIPPING_INVOCATIONS = SetBit(5),
	CLIPPING_PRIMITIVES = SetBit(6),
	FRAGMENT_SHADER_INVOCATIONS = SetBit(7),
	TESS_CONTROL_SHADER_PATCHES = SetBit(8),
	TESS_EVALUATION_SHADER_INVOCATIONS = SetBit(9),
	COMPUTE_SHADER_INVOCATIONS = SetBit(10)
}

enum ResourceViewBits : uint32
{
	READONLY_DEPTH = SetBit(0),
	READONLY_STENCIL = SetBit(1)
}

enum Filter : uint8
{
	NEAREST,
	LINEAR,

	MAX_NUM
}

enum FilterExt : uint8
{
	NONE,
	MIN,
	MAX,

	MAX_NUM
}

enum AddressMode : uint16
{
	REPEAT,
	MIRRORED_REPEAT,
	CLAMP_TO_EDGE,
	CLAMP_TO_BORDER,

	MAX_NUM
}

enum BorderColor : uint16
{
	FLOAT_TRANSPARENT_BLACK,
	FLOAT_OPAQUE_BLACK,
	FLOAT_OPAQUE_WHITE,
	INT_TRANSPARENT_BLACK,
	INT_OPAQUE_BLACK,
	INT_OPAQUE_WHITE,

	MAX_NUM
}

enum Format : uint16
{
	UNKNOWN,

	R8_UNORM,
	R8_SNORM,
	R8_UINT,
	R8_SINT,

	RG8_UNORM,
	RG8_SNORM,
	RG8_UINT,
	RG8_SINT,

	BGRA8_UNORM,
	BGRA8_SRGB,

	RGBA8_UNORM,
	RGBA8_SNORM,
	RGBA8_UINT,
	RGBA8_SINT,
	RGBA8_SRGB,

	R16_UNORM,
	R16_SNORM,
	R16_UINT,
	R16_SINT,
	R16_SFLOAT,

	RG16_UNORM,
	RG16_SNORM,
	RG16_UINT,
	RG16_SINT,
	RG16_SFLOAT,

	RGBA16_UNORM,
	RGBA16_SNORM,
	RGBA16_UINT,
	RGBA16_SINT,
	RGBA16_SFLOAT,

	R32_UINT,
	R32_SINT,
	R32_SFLOAT,

	RG32_UINT,
	RG32_SINT,
	RG32_SFLOAT,

	RGB32_UINT,
	RGB32_SINT,
	RGB32_SFLOAT,

	RGBA32_UINT,
	RGBA32_SINT,
	RGBA32_SFLOAT,

	R10_G10_B10_A2_UNORM,
	R10_G10_B10_A2_UINT,
	R11_G11_B10_UFLOAT,
	R9_G9_B9_E5_UFLOAT,

	BC1_RGBA_UNORM,
	BC1_RGBA_SRGB,
	BC2_RGBA_UNORM,
	BC2_RGBA_SRGB,
	BC3_RGBA_UNORM,
	BC3_RGBA_SRGB,
	BC4_R_UNORM,
	BC4_R_SNORM,
	BC5_RG_UNORM,
	BC5_RG_SNORM,
	BC6H_RGB_UFLOAT,
	BC6H_RGB_SFLOAT,
	BC7_RGBA_UNORM,
	BC7_RGBA_SRGB,

	// DEPTH_STENCIL_ATTACHMENT views
	D16_UNORM,
	D24_UNORM_S8_UINT,
	D32_SFLOAT,
	D32_SFLOAT_S8_UINT_X24,

	// Depth-stencil specific SHADER_RESOURCE views
	R24_UNORM_X8,
	X24_R8_UINT,
	X32_R8_UINT_X24,
	R32_SFLOAT_X8_X24,

	MAX_NUM
}

typealias MemoryType = uint32;

enum AttachmentContentType
{
	COLOR,
	DEPTH,
	STENCIL,
	DEPTH_STENCIL,

	MAX_NUM
}

enum RenderPassBeginFlag : uint8
{
	NONE,
	SKIP_FRAME_BUFFER_CLEAR,

	MAX_NUM
}

enum PrimitiveRestart : uint8
{
	DISABLED,
	INDICES_UINT16,
	INDICES_UINT32,

	MAX_NUM
}

enum FormatSupportBits : uint16
{
	UNSUPPORTED = 0,
	TEXTURE = SetBit(0),
	STORAGE_TEXTURE = SetBit(1),
	BUFFER = SetBit(2),
	STORAGE_BUFFER = SetBit(3),
	COLOR_ATTACHMENT = SetBit(4),
	DEPTH_STENCIL_ATTACHMENT = SetBit(5),
	VERTEX_BUFFER = SetBit(6)
}

[CRepr]
struct Rect
{
	public int32 left;
	public int32 top;
	public uint32 width;
	public uint32 height;
}

[CRepr]
struct Viewport
{
	public float[2] offset;
	public float[2] size;
	public float depthRangeMin;
	public float depthRangeMax;
}

[CRepr]
struct Color<T>
{
	public T r;
	public T g;
	public T b;
	public T a;
}

[CRepr]
struct DepthStencilClearValue
{
	public float depth;
	public uint8 stencil;
}

[CRepr]
[Union] struct ClearValueDesc
{
	public DepthStencilClearValue depthStencil;
	public Color<float> rgba32f;
	public Color<uint32> rgba32ui;
	public Color<int32> rgba32i;
}

[CRepr]
struct ClearDesc
{
	public ClearValueDesc value;
	public AttachmentContentType attachmentContentType;
	public uint32 colorAttachmentIndex;
}

struct ClearStorageBufferDesc
{
	public Descriptor storageBuffer;
	public uint32 value;
	public uint32 setIndex;
	public uint32 rangeIndex;
	public uint32 offsetInRange;
}

struct ClearStorageTextureDesc
{
	public Descriptor storageTexture;
	public ClearValueDesc value;
	public uint32 setIndex;
	public uint32 rangeIndex;
	public uint32 offsetInRange;
}

[CRepr]
struct TextureRegionDesc
{
	public uint16[3] offset;
	public uint16[3] size;
	public uint16 mipOffset;
	public uint16 arrayOffset;
}

[CRepr]
struct TextureDataLayoutDesc
{
	public uint64 offset;
	public uint32 rowPitch;
	public uint32 slicePitch;
}

struct WorkSubmissionDesc
{
	public CommandBuffer* commandBuffers;
	public QueueSemaphore* wait;
	public QueueSemaphore* signal;
	public uint32 commandBufferNum;
	public uint32 waitNum;
	public uint32 signalNum;
	public uint32 physicalDeviceIndex;
}

struct BufferMemoryBindingDesc
{
	public Memory memory;
	public Buffer buffer;
	public uint64 offset;
	public uint32 physicalDeviceMask;
}

struct TextureMemoryBindingDesc
{
	public Memory memory;
	public Texture texture;
	public uint64 offset;
	public uint32 physicalDeviceMask;
}

struct MemoryDesc
{
	public uint64 size;
	public uint32 alignment;
	public MemoryType type;
	public bool mustBeDedicated;
}

[CRepr]
struct AddressModes
{
	public AddressMode u;
	public AddressMode v;
	public AddressMode w;
}

struct SamplerDesc
{
	public Filter magnification;
	public Filter minification;
	public Filter mip;
	public FilterExt filterExt;
	public uint32 anisotropy;
	public float mipBias;
	public float mipMin;
	public float mipMax;
	public AddressModes addressModes;
	public CompareFunc compareFunc;
	public BorderColor borderColor;
	public bool unnormalizedCoordinates;
}

struct TextureDesc
{
	public TextureType type;
	public TextureUsageBits usageMask;
	public Format format;
	public uint16[3] size;
	public uint16 mipNum;
	public uint16 arraySize;
	public uint8 sampleNum;
	public uint32 physicalDeviceMask;

	public const TextureUsageBits DEFAULT_USAGE_MASK = TextureUsageBits.SHADER_RESOURCE;

	public static TextureDesc Texture1D(Format format, uint16 width, uint16 mipNum = 1, uint16 arraySize = 1, TextureUsageBits usageMask = DEFAULT_USAGE_MASK)
	{
		TextureDesc textureDesc = .();
		textureDesc.type = TextureType.TEXTURE_1D;
		textureDesc.format = format;
		textureDesc.usageMask = usageMask;
		textureDesc.size[0] = width;
		textureDesc.size[1] = 1;
		textureDesc.size[2] = 1;
		textureDesc.mipNum = mipNum;
		textureDesc.arraySize = arraySize;
		textureDesc.sampleNum = 1;

		return textureDesc;
	}

	public static TextureDesc Texture2D(Format format, uint16 width, uint16 height, uint16 mipNum = 1, uint16 arraySize = 1, TextureUsageBits usageMask = DEFAULT_USAGE_MASK, uint8 sampleNum = 1)
	{
		TextureDesc textureDesc = .();
		textureDesc.type = TextureType.TEXTURE_2D;
		textureDesc.format = format;
		textureDesc.usageMask = usageMask;
		textureDesc.size[0] = width;
		textureDesc.size[1] = height;
		textureDesc.size[2] = 1;
		textureDesc.mipNum = mipNum;
		textureDesc.arraySize = arraySize;
		textureDesc.sampleNum = sampleNum;

		return textureDesc;
	}

	public static TextureDesc Texture3D(Format format, uint16 width, uint16 height, uint16 depth, uint16 mipNum = 1, TextureUsageBits usageMask = DEFAULT_USAGE_MASK)
	{
		TextureDesc textureDesc = .();
		textureDesc.type = TextureType.TEXTURE_3D;
		textureDesc.format = format;
		textureDesc.usageMask = usageMask;
		textureDesc.size[0] = width;
		textureDesc.size[1] = height;
		textureDesc.size[2] = depth;
		textureDesc.mipNum = mipNum;
		textureDesc.arraySize = 1;
		textureDesc.sampleNum = 1;

		return textureDesc;
	}
}

struct BufferDesc
{
	public uint64 size;
	public uint32 structureStride;
	public BufferUsageBits usageMask;
	public uint32 physicalDeviceMask;
}

struct Texture1DViewDesc
{
	public Texture texture;
	public Texture1DViewType viewType;
	public Format format;
	public uint16 mipOffset;
	public uint16 mipNum;
	public uint16 arrayOffset;
	public uint16 arraySize;
	public uint32 physicalDeviceMask;
	public ResourceViewBits flags;
}

struct Texture2DViewDesc
{
	public Texture texture;
	public Texture2DViewType viewType;
	public Format format;
	public uint16 mipOffset;
	public uint16 mipNum;
	public uint16 arrayOffset;
	public uint16 arraySize;
	public uint32 physicalDeviceMask;
	public ResourceViewBits flags;
}

struct Texture3DViewDesc
{
	public Texture texture;
	public Texture3DViewType viewType;
	public Format format;
	public uint16 mipOffset;
	public uint16 mipNum;
	public uint16 sliceOffset;
	public uint16 sliceNum;
	public uint32 physicalDeviceMask;
	public ResourceViewBits flags;
}

struct BufferViewDesc
{
	public Buffer buffer;
	public BufferViewType viewType;
	public Format format;
	public uint64 offset;
	public uint64 size;
	public uint32 physicalDeviceMask;
}

struct DescriptorPoolDesc
{
	public uint32 physicalDeviceMask;
	public uint32 descriptorSetMaxNum;
	public uint32 samplerMaxNum;
	public uint32 staticSamplerMaxNum;
	public uint32 constantBufferMaxNum;
	public uint32 dynamicConstantBufferMaxNum;
	public uint32 textureMaxNum;
	public uint32 storageTextureMaxNum;
	public uint32 bufferMaxNum;
	public uint32 storageBufferMaxNum;
	public uint32 structuredBufferMaxNum;
	public uint32 storageStructuredBufferMaxNum;
	public uint32 accelerationStructureMaxNum;
}

struct TextureTransitionBarrierDesc
{
	public Texture texture;
	public uint16 mipOffset;
	public uint16 mipNum;
	public uint16 arrayOffset;
	public uint16 arraySize;
	public AccessBits prevAccess;
	public AccessBits nextAccess;
	public TextureLayout prevLayout;
	public TextureLayout nextLayout;
}

struct BufferTransitionBarrierDesc
{
	public Buffer buffer;
	public AccessBits prevAccess;
	public AccessBits nextAccess;
}

struct BufferAliasingBarrierDesc
{
	public Buffer before;
	public Buffer after;
	public AccessBits nextAccess;
}

struct TextureAliasingBarrierDesc
{
	public Texture before;
	public Texture after;
	public AccessBits nextAccess;
	public TextureLayout nextLayout;
}

struct TransitionBarrierDesc
{
	public BufferTransitionBarrierDesc* buffers;
	public TextureTransitionBarrierDesc* textures;
	public uint32 bufferNum;
	public uint32 textureNum;
}

struct AliasingBarrierDesc
{
	public BufferAliasingBarrierDesc* buffers;
	public TextureAliasingBarrierDesc* textures;
	public uint32 bufferNum;
	public uint32 textureNum;
}

struct DescriptorRangeDesc
{
	public uint32 baseRegisterIndex;
	public uint32 descriptorNum;
	public DescriptorType descriptorType;
	public ShaderStage visibility;
	public bool isDescriptorNumVariable;
	public bool isArray;
}

struct DynamicConstantBufferDesc
{
	public uint32 registerIndex;
	public ShaderStage visibility;
}

struct StaticSamplerDesc
{
	public SamplerDesc samplerDesc;
	public uint32 registerIndex;
	public ShaderStage visibility;
}

struct DescriptorSetDesc
{
	public DescriptorRangeDesc* ranges;
	public uint32 rangeNum;
	public StaticSamplerDesc* staticSamplers;
	public uint32 staticSamplerNum;
	public DynamicConstantBufferDesc* dynamicConstantBuffers;
	public uint32 dynamicConstantBufferNum;
}

struct DescriptorRangeUpdateDesc
{
	public Descriptor* descriptors;
	public uint32 descriptorNum;
	public uint32 offsetInRange;
}

struct DescriptorSetCopyDesc
{
	public DescriptorSet srcDescriptorSet;
	public uint32 baseSrcRange;
	public uint32 baseDstRange;
	public uint32 rangeNum;
	public uint32 baseSrcDynamicConstantBuffer;
	public uint32 baseDstDynamicConstantBuffer;
	public uint32 dynamicConstantBufferNum;
	public uint32 physicalDeviceMask;
}

struct PushConstantDesc
{
	public uint32 registerIndex;
	public uint32 size;
	public ShaderStage visibility;
}

struct SPIRVBindingOffsets
{
	public uint32 samplerOffset;
	public uint32 textureOffset;
	public uint32 constantBufferOffset;
	public uint32 storageTextureAndBufferOffset;
}

struct ShaderDesc
{
	public ShaderStage stage;
	public void* bytecode;
	public uint64 size;
	public char8* entryPointName;
}

struct VertexAttributeD3D
{
	public char8* semanticName = null;
	public uint32 semanticIndex;
}

struct VertexAttributeVK
{
	public uint32 location;
}

struct VertexAttributeDesc
{
	public VertexAttributeD3D d3d = .();
	public VertexAttributeVK vk = .();
	public uint32 offset;
	public Format format;
	public uint16 streamIndex;
}

struct VertexStreamDesc
{
	public uint32 stride;
	public uint16 bindingSlot;
	public VertexStreamStepRate stepRate;
}

struct InputAssemblyDesc
{
	public VertexAttributeDesc* attributes;
	public VertexStreamDesc* streams;
	public uint8 attributeNum;
	public uint8 streamNum;
	public Topology topology;
	public uint8 tessControlPointNum;
	public PrimitiveRestart primitiveRestart;
}

struct SamplePosition
{
	public int8 x;
	public int8 y;
}

struct RasterizationDesc
{
	public uint32 viewportNum;
	public int32 depthBiasConstantFactor;
	public float depthBiasClamp;
	public float depthBiasSlopeFactor;
	public FillMode fillMode;
	public CullMode cullMode;
	public uint16 sampleMask;
	public uint8 sampleNum;
	public bool alphaToCoverage;
	public bool frontCounterClockwise;
	public bool depthClamp;
	public bool antialiasedLines;
	public bool rasterizerDiscard;
	public bool conservativeRasterization;
}

struct StencilDesc
{
	public CompareFunc compareFunc;
	public StencilFunc fail;
	public StencilFunc pass;
	public StencilFunc depthFail;
}

struct BlendingDesc
{
	public BlendFactor srcFactor;
	public BlendFactor dstFactor;
	public BlendFunc func;
}

struct ColorAttachmentDesc
{
	public Format format;
	public BlendingDesc colorBlend;
	public BlendingDesc alphaBlend;
	public ColorWriteBits colorWriteMask;
	public bool blendEnabled;
}

// CompareFunc::NONE = depth/stencil test disabled

struct DepthAttachmentDesc
{
	public CompareFunc compareFunc;
	public bool write;
}

struct StencilAttachmentDesc
{
	public StencilDesc front;
	public StencilDesc back;
	public uint8 reference;
	public uint8 compareMask;
	public uint8 writeMask;
}

struct OutputMergerDesc
{
	public ColorAttachmentDesc* color;
	public DepthAttachmentDesc depth;
	public StencilAttachmentDesc stencil;
	public Format depthStencilFormat;
	public LogicFunc colorLogicFunc;
	public uint32 colorNum;
	public Color<float> blendConsts;
}

struct PipelineLayoutDesc
{
	public DescriptorSetDesc* descriptorSets;
	public PushConstantDesc* pushConstants;
	public uint32 descriptorSetNum;
	public uint32 pushConstantNum;
	public PipelineLayoutShaderStageBits stageMask;
	public bool ignoreGlobalSPIRVOffsets;
}

struct GraphicsPipelineDesc
{
	public PipelineLayout pipelineLayout;
	public InputAssemblyDesc* inputAssembly;
	public RasterizationDesc* rasterization;
	public OutputMergerDesc* outputMerger;
	public ShaderDesc* shaderStages;
	public uint32 shaderStageNum;
}

struct ComputePipelineDesc
{
	public PipelineLayout pipelineLayout;
	public ShaderDesc computeShader;
}

struct FrameBufferDesc
{
	public Descriptor* colorAttachments;
	public Descriptor depthStencilAttachment;
	public readonly ClearValueDesc* colorClearValues;
	public readonly ClearValueDesc* depthStencilClearValue;
	public uint32 colorAttachmentNum;
	public uint32 physicalDeviceMask;
}

struct QueryPoolDesc
{
	public QueryType queryType;
	public uint32 capacity;
	public PipelineStatsBits pipelineStatsMask;
	public uint32 physicalDeviceMask;
}

struct PipelineStatisticsDesc
{
	public uint64 inputVertices;
	public uint64 inputPrimitives;
	public uint64 vertexShaderInvocations;
	public uint64 geometryShaderInvocations;
	public uint64 geometryShaderPrimitives;
	public uint64 rasterizerInPrimitives;
	public uint64 rasterizerOutPrimitives;
	public uint64 fragmentShaderInvocations;
	public uint64 tessControlInvocations;
	public uint64 tessEvaluationInvocations;
	public uint64 computeShaderInvocations;
}

struct DeviceDesc
{
	// Common
	public GraphicsAPI graphicsAPI;
	public Vendor vendor;
	public uint16 nriVersionMajor;
	public uint16 nriVersionMinor;

	// Viewports
	public uint32 viewportMaxNum;
	public uint32 viewportSubPixelBits;
	public int32[2] viewportBoundsRange;

	// Framebuffer
	public uint32 frameBufferMaxDim;
	public uint32 frameBufferLayerMaxNum;
	public uint32 framebufferColorAttachmentMaxNum;

	// Multi-sampling
	public uint8 frameBufferColorSampleMaxNum;
	public uint8 frameBufferDepthSampleMaxNum;
	public uint8 frameBufferStencilSampleMaxNum;
	public uint8 frameBufferNoAttachmentsSampleMaxNum;
	public uint8 textureColorSampleMaxNum;
	public uint8 textureIntegerSampleMaxNum;
	public uint8 textureDepthSampleMaxNum;
	public uint8 textureStencilSampleMaxNum;
	public uint8 storageTextureSampleMaxNum;

	// Resource dimensions
	public uint32 texture1DMaxDim;
	public uint32 texture2DMaxDim;
	public uint32 texture3DMaxDim;
	public uint32 textureArrayMaxDim;
	public uint32 texelBufferMaxDim;

	// Memory
	public uint32 memoryAllocationMaxNum;
	public uint32 samplerAllocationMaxNum;
	public uint32 uploadBufferTextureRowAlignment;
	public uint32 uploadBufferTextureSliceAlignment;
	public uint32 typedBufferOffsetAlignment;
	public uint32 constantBufferOffsetAlignment;
	public uint32 constantBufferMaxRange;
	public uint32 storageBufferOffsetAlignment;
	public uint32 storageBufferMaxRange;
	public uint32 bufferTextureGranularity;
	public uint64 bufferMaxSize;
	public uint32 pushConstantsMaxSize;

	// Shader resources
	public uint32 boundDescriptorSetMaxNum;
	public uint32 perStageDescriptorSamplerMaxNum;
	public uint32 perStageDescriptorConstantBufferMaxNum;
	public uint32 perStageDescriptorStorageBufferMaxNum;
	public uint32 perStageDescriptorTextureMaxNum;
	public uint32 perStageDescriptorStorageTextureMaxNum;
	public uint32 perStageResourceMaxNum;

	// Descriptor set
	public uint32 descriptorSetSamplerMaxNum;
	public uint32 descriptorSetConstantBufferMaxNum;
	public uint32 descriptorSetStorageBufferMaxNum;
	public uint32 descriptorSetTextureMaxNum;
	public uint32 descriptorSetStorageTextureMaxNum;

	// Vertex shader
	public uint32 vertexShaderAttributeMaxNum;
	public uint32 vertexShaderStreamMaxNum;
	public uint32 vertexShaderOutputComponentMaxNum;

	// Tessellation control shader
	public float tessControlShaderGenerationMaxLevel;
	public uint32 tessControlShaderPatchPointMaxNum;
	public uint32 tessControlShaderPerVertexInputComponentMaxNum;
	public uint32 tessControlShaderPerVertexOutputComponentMaxNum;
	public uint32 tessControlShaderPerPatchOutputComponentMaxNum;
	public uint32 tessControlShaderTotalOutputComponentMaxNum;

	// Tessellation evaluation shader
	public uint32 tessEvaluationShaderInputComponentMaxNum;
	public uint32 tessEvaluationShaderOutputComponentMaxNum;

	// Geometry shader
	public uint32 geometryShaderInvocationMaxNum;
	public uint32 geometryShaderInputComponentMaxNum;
	public uint32 geometryShaderOutputComponentMaxNum;
	public uint32 geometryShaderOutputVertexMaxNum;
	public uint32 geometryShaderTotalOutputComponentMaxNum;

	// Fragment shader
	public uint32 fragmentShaderInputComponentMaxNum;
	public uint32 fragmentShaderOutputAttachmentMaxNum;
	public uint32 fragmentShaderDualSourceAttachmentMaxNum;
	public uint32 fragmentShaderCombinedOutputResourceMaxNum;

	// Compute shader
	public uint32 computeShaderSharedMemoryMaxSize;
	public uint32[3] computeShaderWorkGroupMaxNum;
	public uint32 computeShaderWorkGroupInvocationMaxNum;
	public uint32[3] computeShaderWorkGroupMaxDim;

	// Ray tracing
	public uint64 rayTracingShaderGroupIdentifierSize;
	public uint64 rayTracingShaderTableAligment;
	public uint64 rayTracingShaderTableMaxStride;
	public uint32 rayTracingShaderRecursionMaxDepth;
	public uint32 rayTracingGeometryObjectMaxNum;

	// Mesh shader
	public uint32 meshTaskMaxNum;
	public uint32 meshTaskWorkGroupInvocationMaxNum;
	public uint32[3] meshTaskWorkGroupMaxDim;
	public uint32 meshTaskTotalMemoryMaxSize;
	public uint32 meshTaskOutputMaxNum;
	public uint32 meshWorkGroupInvocationMaxNum;
	public uint32[3] meshWorkGroupMaxDim;
	public uint32 meshTotalMemoryMaxSize;
	public uint32 meshOutputVertexMaxNum;
	public uint32 meshOutputPrimitiveMaxNum;
	public uint32 meshMultiviewViewMaxNum;
	public uint32 meshOutputPerVertexGranularity;
	public uint32 meshOutputPerPrimitiveGranularity;

	// Other
	public uint32 subPixelPrecisionBits;
	public uint32 subTexelPrecisionBits;
	public uint32 mipmapPrecisionBits;
	public uint32 drawIndexedIndex16ValueMax;
	public uint32 drawIndexedIndex32ValueMax;
	public uint32 drawIndirectMaxNum;
	public float samplerLodBiasMin;
	public float samplerLodBiasMax;
	public float samplerAnisotropyMax;
	public int32 texelOffsetMin;
	public uint32 texelOffsetMax;
	public int32 texelGatherOffsetMin;
	public uint32 texelGatherOffsetMax;
	public uint32 clipDistanceMaxNum;
	public uint32 cullDistanceMaxNum;
	public uint32 combinedClipAndCullDistanceMaxNum;
	public uint8 conservativeRasterTier;
	public uint32 phyiscalDeviceGroupSize;
	public uint64 timestampFrequencyHz;

	// Features support
	public bool isAPIValidationEnabled;
	public bool isTextureFilterMinMaxSupported;
	public bool isLogicOpSupported;
	public bool isDepthBoundsTestSupported;
	public bool isProgrammableSampleLocationsSupported;
	public bool isComputeQueueSupported;
	public bool isCopyQueueSupported;
	public bool isCopyQueueTimestampSupported;
	public bool isRegisterAliasingSupported;
	public bool isSubsetAllocationSupported;
	public bool isFloat16Supported;
}

#region Helper
struct TextureSubresourceUploadDesc
{
	public void* slices;
	public uint32 sliceNum;
	public uint32 rowPitch;
	public uint32 slicePitch;
}

struct TextureUploadDesc
{
	public TextureSubresourceUploadDesc* subresources;
	public Texture texture;
	public AccessBits nextAccess;
	public TextureLayout nextLayout;
	public uint16 mipNum;
	public uint16 arraySize;
}

struct BufferUploadDesc
{
	public void* data;
	public uint64 dataSize;
	public Buffer buffer;
	public uint64 bufferOffset;
	public AccessBits prevAccess;
	public AccessBits nextAccess;
}

struct ResourceGroupDesc
{
	public MemoryLocation memoryLocation;
	public Texture* textures;
	public uint32 textureNum;
	public Buffer* buffers;
	public uint32 bufferNum;
}
#endregion

#region SwapChain
struct Display
{
}

enum SwapChainFormat : uint16
{
	// BT.709 - LDR, https://en.wikipedia.org/wiki/Rec._709
	// BT.2020 - HDR, https://en.wikipedia.org/wiki/Rec._2020
	// G10 - linear (gamma 1.0)
	// G22 - sRGB (gamma ~2.2)
	// G2084 - SMPTE ST.2084 (Perceptual Quantization)

	BT709_G10_8BIT,
	BT709_G10_16BIT,
	BT709_G22_8BIT,
	BT709_G22_10BIT,
	BT2020_G2084_10BIT,
	MAX_NUM
}

enum WindowSystemType : uint8
{
	WINDOWS,
	X11,
	WAYLAND,
	METAL,
	MAX_NUM
}

struct WindowsWindow
{
	public void* hwnd; // HWND
}

struct X11Window
{
	public void* dpy; // Display*
	public uint64 window; // Window
}

struct WaylandWindow
{
	public void* display; // wl_display*
	public void* surface; // wl_surface*
}

struct MetalWindow
{
	public void* caMetalLayer;
}

[Union] struct Window
{
	public WindowsWindow windows;
	public X11Window x11;
	public WaylandWindow wayland;
	public MetalWindow metal;
}

// SwapChain buffers will be created as "color attachment" resources
struct SwapChainDesc
{
	public WindowSystemType windowSystemType;
	public Window window;
	public CommandQueue commandQueue;
	public uint16 width;
	public uint16 height;
	public uint16 textureNum;
	public SwapChainFormat format;
	public uint32 verticalSyncInterval;
	public uint32 physicalDeviceIndex;
	public Display* display;
}

struct HdrMetadata
{
	public float[2] displayPrimaryRed;
	public float[2] displayPrimaryGreen;
	public float[2] displayPrimaryBlue;
	public float[2] whitePoint;
	public float luminanceMax;
	public float luminanceMin;
	public float contentLightLevelMax;
	public float frameAverageLightLevelMax;
}
#endregion

#region RayTracing
enum GeometryType
{
	TRIANGLES,
	AABBS,
	MAX_NUM
}

enum AccelerationStructureType
{
	TOP_LEVEL,
	BOTTOM_LEVEL,
	MAX_NUM
}

enum CopyMode
{
	CLONE = 0,
	COMPACT = 1,
	MAX_NUM
}

enum BottomLevelGeometryBits : uint32
{
	NONE = 0,
	OPAQUE_GEOMETRY = SetBit(0),
	NO_DUPLICATE_ANY_HIT_INVOCATION = SetBit(1)
}

enum TopLevelInstanceBits : uint32
{
	NONE = 0,
	TRIANGLE_CULL_DISABLE = SetBit(0),
	TRIANGLE_FRONT_COUNTERCLOCKWISE = SetBit(1),
	FORCE_OPAQUE = SetBit(2),
	FORCE_NON_OPAQUE = SetBit(3)
}

enum AccelerationStructureBuildBits : uint32
{
	NONE = 0,
	ALLOW_UPDATE = SetBit(0),
	ALLOW_COMPACTION = SetBit(1),
	PREFER_FAST_TRACE = SetBit(2),
	PREFER_FAST_BUILD = SetBit(3),
	MINIMIZE_MEMORY = SetBit(4)
}

struct ShaderLibrary
{
	public readonly ShaderDesc* shaderDescs;
	public uint32 shaderNum;
}

struct ShaderGroupDesc
{
	public uint32[3] shaderIndices;
}

struct RayTracingPipelineDesc
{
	public PipelineLayout pipelineLayout;
	public readonly ShaderLibrary* shaderLibrary;
	public readonly ShaderGroupDesc* shaderGroupDescs; // TODO: move to ShaderLibrary
	public uint32 shaderGroupDescNum;
	public uint32 recursionDepthMax;
	public uint32 payloadAttributeSizeMax;
	public uint32 intersectionAttributeSizeMax;
}

struct Triangles
{
	public Buffer vertexBuffer;
	public uint64 vertexOffset;
	public uint32 vertexNum;
	public uint64 vertexStride;
	public Format vertexFormat;
	public Buffer indexBuffer;
	public uint64 indexOffset;
	public uint32 indexNum;
	public IndexType indexType;
	public Buffer transformBuffer;
	public uint64 transformOffset;
}

struct AABBs
{
	public Buffer buffer;
	public uint32 boxNum;
	public uint32 stride;
	public uint64 offset;
}

struct GeometryObject
{
	public GeometryType type;
	public BottomLevelGeometryBits flags;
	[Union] struct GeometryShapes
	{
		public Triangles triangles;
		public AABBs boxes;
	}
	public using GeometryShapes shapes;

	/*public Triangles triangles { get => shapes.triangles; set mut { shapes.triangles = value; } }
	public AABBs boxes { get => shapes.boxes; set mut { shapes.boxes = value; } }*/
}

struct GeometryObjectInstance
{
	public float[3][4] transform;
	public uint32 instanceId; // : 24;
	public uint32 mask; // : 8;
	public uint32 shaderBindingTableLocalOffset; // : 24;
	public TopLevelInstanceBits flags; // : 8;
	public uint64 accelerationStructureHandle;
}

struct AccelerationStructureDesc
{
	public AccelerationStructureType type;
	public AccelerationStructureBuildBits flags;
	public uint32 physicalDeviceMask;
	public uint32 instanceOrGeometryObjectNum;
	public GeometryObject* geometryObjects;
}

struct AccelerationStructureMemoryBindingDesc
{
	public Memory memory;
	public AccelerationStructure accelerationStructure;
	public uint64 offset;
	public uint32 physicalDeviceMask;
}

struct StridedBufferRegion
{
	public Buffer buffer;
	public uint64 offset;
	public uint64 size;
	public uint64 stride;
}

struct DispatchRaysDesc
{
	public StridedBufferRegion raygenShader;
	public StridedBufferRegion missShaders;
	public StridedBufferRegion hitShaderGroups;
	public StridedBufferRegion callableShaders;
	public uint32 width;
	public uint32 height;
	public uint32 depth;
}
#endregion

#region DeviceCreation
enum Message
{
	TYPE_INFO,
	TYPE_WARNING,
	TYPE_ERROR,

	MAX_NUM,
}

enum PhysicalDeviceType
{
	UNKNOWN,
	INTEGRATED,
	DISCRETE,

	MAX_NUM
}

struct MemoryAllocatorInterface
{
	public function void*(void* userArg, int size, int alignment) Allocate;
	public function void*(void* userArg, void* memory, int size, int alignment) Reallocate;
	public function void(void* userArg, void* memory) Free;
	public void* userArg;
}

struct CallbackInterface
{
	public function void(void* userArg, char8* message, Message messageType) MessageCallback;
	public function void(void* userArg) AbortExecution;
	public void* userArg;
}

struct DisplayDesc
{
	public int32 originLeft;
	public int32 originTop;
	public uint32 width;
	public uint32 height;
}

struct PhysicalDeviceGroup
{
	public char8[128] description;
	public uint64 luid;
	public uint64 dedicatedVideoMemoryMB;
	public PhysicalDeviceType type;
	public Vendor vendor;
	public uint32 deviceID;
	public uint32 physicalDeviceGroupSize;
	public readonly DisplayDesc* displays;
	public uint32 displayNum;
}

struct VulkanExtensions
{
	public readonly char8** instanceExtensions;
	public uint32 instanceExtensionNum;
	public readonly char8** deviceExtensions;
	public uint32 deviceExtensionNum;
}

struct DeviceCreationDesc
{
	public readonly PhysicalDeviceGroup* physicalDeviceGroup;
	public CallbackInterface callbackInterface;
	public MemoryAllocatorInterface memoryAllocatorInterface;
	public GraphicsAPI graphicsAPI;
	public SPIRVBindingOffsets spirvBindingOffsets;
	public VulkanExtensions vulkanExtensions;
	public bool enableNRIValidation; // : 1;
	public bool enableAPIValidation; // : 1;
	public bool enableMGPU; // : 1;
	public bool D3D11CommandBufferEmulation; // : 1;
}
#endregion

#region Utils
public static
{
	public static Vendor GetVendorFromID(uint32 vendorID)
	{
		switch (vendorID)
		{
		case 0x10DE: return Vendor.NVIDIA;
		case 0x1002: return Vendor.AMD;
		case 0x8086: return Vendor.INTEL;
		}

		return Vendor.UNKNOWN;
	}

	public static mixin RETURN_ON_FAILURE<T>(ILogger logger, bool condition, T returnCode, StringView format, Object args)
	{
		if (condition == false)
		{
			logger.LogError(format, args);

			return returnCode;
		}
	}

	public static mixin RETURN_ON_FAILURE<T>(ILogger logger, bool condition, T returnCode, StringView format, Object arg1, Object arg2)
	{
		if (condition == false)
		{
			logger.LogError(format, arg1, arg2);

			return returnCode;
		}
	}

	public static mixin RETURN_ON_FAILURE<T>(ILogger logger, bool condition, T returnCode, StringView format, Object arg1, Object arg2, Object arg3)
	{
		if (condition == false)
		{
			logger.LogError(format, arg1, arg2, arg3);

			return returnCode;
		}
	}

	public static mixin RETURN_ON_FAILURE<T>(ILogger logger, bool condition, T returnCode, StringView format, Object arg1, Object arg2, Object arg3, Object arg4)
	{
		if (condition == false)
		{
			logger.LogError(format, arg1, arg2, arg3, arg4);

			return returnCode;
		}
	}

	public static mixin RETURN_ON_FAILURE<T>(ILogger logger, bool condition, T returnCode, StringView format, Object arg1, Object arg2, Object arg3, Object arg4, Object arg5)
	{
		if (condition == false)
		{
			logger.LogError(format, arg1, arg2, arg3, arg4, arg5);

			return returnCode;
		}
	}

	public static mixin RETURN_ON_FAILURE<T>(ILogger logger, bool condition, T returnCode, StringView format, Object arg1, Object arg2, Object arg3, Object arg4, Object arg5, Object arg6)
	{
		if (condition == false)
		{
			logger.LogError(format, arg1, arg2, arg3, arg4, arg5, arg6);

			return returnCode;
		}
	}

	public static mixin RETURN_ON_FAILURE<T>(ILogger logger, bool condition, T returnCode, StringView format)
	{
		if (condition == false)
		{
			logger.LogError(format);

			return returnCode;
		}
	}

	public static void REPORT_INFO(ILogger logger, StringView format, params Object[] args)
	{
		logger.LogInformation(format, params args);
	}

	public static void REPORT_WARNING(ILogger logger, StringView format, params Object[] args)
	{
		logger.LogWarning(format, params args);
	}

	public static void REPORT_ERROR(ILogger logger, StringView format, params Object[] args)
	{
		logger.LogError(format, params args);
	}

	public static void REPORT_ERROR(ILogger logger, StringView format)
	{
		logger.LogError(format);
	}

	public static mixin CHECK(ILogger logger, bool condition, StringView format, Object args)
	{
#if DEBUG
		if (!condition)
		{
			logger.LogError(format, args);
		}
#endif
	}

	public static mixin CHECK(ILogger logger, bool condition, StringView format)
	{
#if DEBUG
		if (!condition)
		{
			logger.LogError(format);
		}
#endif
	}
}
#endregion

#region AllocationUtils
public static
{
	public static mixin Allocate<T>(DeviceAllocator allocator) where T : var
	{
#if USE_CUSTOM_ALLOCATOR
		alloctype(T) data = new:allocator T();
#else
		alloctype(T) data = new T();
#endif
		data
	}

	public static mixin Allocate<T>(DeviceAllocator allocator, var p1) where T : var
	{
#if USE_CUSTOM_ALLOCATOR
		alloctype(T) data = new:allocator T(p1);
#else
		alloctype(T) data = new T(p1);
#endif
		data
	}

	public static mixin Allocate<T>(DeviceAllocator allocator, var p1, var p2) where T : var
	{
#if USE_CUSTOM_ALLOCATOR
		alloctype(T) data = new:allocator T(p1, p2);
#else
		alloctype(T) data = new T(p1, p2);
#endif
		data
	}

	public static mixin Allocate<T>(DeviceAllocator allocator, var p1, var p2, var p3) where T : var
	{
#if USE_CUSTOM_ALLOCATOR
		alloctype(T) data = new:allocator T(p1, p2, p3);
#else
		alloctype(T) data = new T(p1, p2, p3);
#endif
		data
	}

	public static mixin Allocate<T>(DeviceAllocator allocator, var p1, var p2, var p3, var p4) where T : var
	{
#if USE_CUSTOM_ALLOCATOR
		alloctype(T) data = new:allocator T(p1, p2, p3, p4);
#else
		alloctype(T) data = new T(p1, p2, p3, p4);
#endif
		data
	}

	public static mixin Allocate<T>(DeviceAllocator allocator, var p1, var p2, var p3, var p4, var p5) where T : var
	{
#if USE_CUSTOM_ALLOCATOR
		alloctype(T) data = new:allocator T(p1, p2, p3, p4, p5);
#else
		alloctype(T) data = new T(p1, p2, p3, p4, p5);
#endif
		data
	}

	public static mixin Deallocate<T>(DeviceAllocator allocator, T instance) where T : delete
	{
		if (instance != null)
		{
#if USE_CUSTOM_ALLOCATOR
			delete: allocator instance;
#else
			delete instance;
#endif
		}
	}
}
#endregion

#region Shared

[CRepr]
struct MemoryTypeInfo
{
	public uint16 memoryTypeIndex;
	public uint8 location;
	[Bitfield<bool>(.Public, .Bits(1), "isDedicated")]
	[Bitfield<bool>(.Public, .Bits(1), "isHostCoherent")]
	private uint8 bits;
}


[Union] struct MemoryTypeUnpack
{
	public MemoryType type;
	public MemoryTypeInfo info;
}

public static
{
	[Comptime(ConstEval = true)]
	public static void Asserts()
	{
		Compiler.Assert(sizeof(MemoryTypeInfo) <= sizeof(MemoryType), "Unexpected structure size");
	}

	public static bool IsHostVisibleMemory(MemoryLocation location)
	{
		return location > MemoryLocation.DEVICE;
	}

	public static uint32 GetPhysicalDeviceGroupMask(uint32 mask)
	{
		return mask == WHOLE_DEVICE_GROUP ? 0xff : mask;
	}

	public const uint32[(int)Format.MAX_NUM] TEXEL_BLOCK_WIDTH = .(
		0, // UNKNOWN

		1, // R8_UNORM
		1, // R8_SNORM
		1, // R8_UINT
		1, // R8_SINT

		1, // RG8_UNORM
		1, // RG8_SNORM
		1, // RG8_UINT
		1, // RG8_SINT

		1, // BGRA8_UNORM
		1, // BGRA8_SRGB

		1, // RGBA8_UNORM
		1, // RGBA8_SNORM
		1, // RGBA8_UINT
		1, // RGBA8_SINT
		1, // RGBA8_SRGB

		1, // R16_UNORM
		1, // R16_SNORM
		1, // R16_UINT
		1, // R16_SINT
		1, // R16_SFLOAT

		1, // RG16_UNORM
		1, // RG16_SNORM
		1, // RG16_UINT
		1, // RG16_SINT
		1, // RG16_SFLOAT

		1, // RGBA16_UNORM
		1, // RGBA16_SNORM
		1, // RGBA16_UINT
		1, // RGBA16_SINT
		1, // RGBA16_SFLOAT

		1, // R32_UINT
		1, // R32_SINT
		1, // R32_SFLOAT

		1, // RG32_UINT
		1, // RG32_SINT
		1, // RG32_SFLOAT

		1, // RGB32_UINT
		1, // RGB32_SINT
		1, // RGB32_SFLOAT

		1, // RGBA32_UINT
		1, // RGBA32_SINT
		1, // RGBA32_SFLOAT

		1, // R10_G10_B10_A2_UNORM
		1, // R10_G10_B10_A2_UINT
		1, // R11_G11_B10_UFLOAT
		1, // R9_G9_B9_E5_UFLOAT

		4, // BC1_RGBA_UNORM
		4, // BC1_RGBA_SRGB
		4, // BC2_RGBA_UNORM
		4, // BC2_RGBA_SRGB
		4, // BC3_RGBA_UNORM
		4, // BC3_RGBA_SRGB
		4, // BC4_R_UNORM
		4, // BC4_R_SNORM
		4, // BC5_RG_UNORM
		4, // BC5_RG_SNORM
		4, // BC6H_RGB_UFLOAT
		4, // BC6H_RGB_SFLOAT
		4, // BC7_RGBA_UNORM
		4, // BC7_RGBA_SRGB

		// DEPTH_STENCIL_ATTACHMENT views
		1, // D16_UNORM
		1, // D24_UNORM_S8_UINT
		1, // D32_SFLOAT
		1, // D32_SFLOAT_S8_UINT_X24

		// Depth-stencil specific SHADER_RESOURCE views
		0, // R24_UNORM_X8
		0, // X24_R8_UINT
		0, // X32_R8_UINT_X24
		0 // R32_SFLOAT_X8_X24
		);

	public static uint32 GetTexelBlockWidth(Format format)
	{
		return TEXEL_BLOCK_WIDTH[(int)format];
	}

	public const uint32[(int)Format.MAX_NUM] TEXEL_BLOCK_SIZE = .(
		1, // UNKNOWN

		1, // R8_UNORM
		1, // R8_SNORM
		1, // R8_UINT
		1, // R8_SINT

		2, // RG8_UNORM
		2, // RG8_SNORM
		2, // RG8_UINT
		2, // RG8_SINT

		4, // BGRA8_UNORM
		4, // BGRA8_SRGB

		4, // RGBA8_UNORM
		4, // RGBA8_SNORM
		4, // RGBA8_UINT
		4, // RGBA8_SINT
		4, // RGBA8_SRGB

		2, // R16_UNORM
		2, // R16_SNORM
		2, // R16_UINT
		2, // R16_SINT
		2, // R16_SFLOAT

		4, // RG16_UNORM
		4, // RG16_SNORM
		4, // RG16_UINT
		4, // RG16_SINT
		4, // RG16_SFLOAT

		8, // RGBA16_UNORM
		8, // RGBA16_SNORM
		8, // RGBA16_UINT
		8, // RGBA16_SINT
		8, // RGBA16_SFLOAT

		4, // R32_UINT
		4, // R32_SINT
		4, // R32_SFLOAT

		8, // RG32_UINT
		8, // RG32_SINT
		8, // RG32_SFLOAT

		12, // RGB32_UINT
		12, // RGB32_SINT
		12, // RGB32_SFLOAT

		16, // RGBA32_UINT
		16, // RGBA32_SINT
		16, // RGBA32_SFLOAT

		4, // R10_G10_B10_A2_UNORM
		4, // R10_G10_B10_A2_UINT
		4, // R11_G11_B10_UFLOAT
		4, // R9_G9_B9_E5_UFLOAT

		8, // BC1_RGBA_UNORM
		8, // BC1_RGBA_SRGB
		16, // BC2_RGBA_UNORM
		16, // BC2_RGBA_SRGB
		16, // BC3_RGBA_UNORM
		16, // BC3_RGBA_SRGB
		8, // BC4_R_UNORM
		8, // BC4_R_SNORM
		16, // BC5_RG_UNORM
		16, // BC5_RG_SNORM
		16, // BC6H_RGB_UFLOAT
		16, // BC6H_RGB_SFLOAT
		16, // BC7_RGBA_UNORM
		16, // BC7_RGBA_SRGB

		// DEPTH_STENCIL_ATTACHMENT views
		2, // D16_UNORM
		4, // D24_UNORM_S8_UINT
		4, // D32_SFLOAT
		8, // D32_SFLOAT_S8_UINT_X24

		// Depth-stencil specific SHADER_RESOURCE views
		0, // R24_UNORM_X8
		0, // X24_R8_UINT
		0, // X32_R8_UINT_X24
		0 // R32_SFLOAT_X8_X24
		);

	public static uint32 GetTexelBlockSize(Format format)
	{
		return TEXEL_BLOCK_SIZE[(int)format];
	}
}

#endregion

#region StdAllocator

public static
{
	[Inline] public static T Align<T>(T x, int alignment) //where T : operator implicit int
		//where int : operator implicit T
		where T : var
	{
		//return ((x) + (alignment - 1)) & ~(alignment - 1);

		return (T)(((int)x + alignment - 1) & ~(alignment - 1));
	}

	[Inline] public static uint8* Align(uint8* x, int alignment)
	{
		return (uint8*)(void*)(((int)(void*)x + alignment - 1) & ~(alignment - 1));
	}

	public static mixin STACK_ALLOC<T>(int size) where T : struct
	{
		T* data = null;
		if (size > 0)
		{
			data = scope:: [Align(alignof(T))] T[size]*;
			//data = Align(data, alignof(T));
		}
		data
	}

	public static mixin ALLOCATE_SCRATCH<T>(Device device, uint64 size)
	{
		T* data = scope:: [Align(alignof(T))] T[size]*;
		data
	}

	public static mixin FREE_SCRATCH<T>(Device device, T* memory, uint64 size) where T : struct
	{
	}

	public static mixin FREE_SCRATCH<T>(Device device, T* memory, uint64 size) where T : IDisposable
	{
		(*memory).Dispose();
	}

	public static mixin FREE_SCRATCH<T>(Device device, T* memory, uint64 size) where T : delete
	{
		delete:null memory;
	}
}
#endregion