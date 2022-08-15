using Sedulous.Foundation.Logging.Abstractions;
using System;
using System.Collections;
using System.Threading;
namespace Sedulous.RHI.Validation
{
	class DeviceValidator : Device
	{
		private Device mDevice;
		bool m_IsSwapChainSupported = false;
		bool m_IsWrapperD3D11Supported = false;
		bool m_IsWrapperD3D12Supported = false;
		bool m_IsWrapperVKSupported = false;
		bool m_IsRayTracingSupported = false;
		bool m_IsMeshShaderExtSupported = false;
		bool m_IsWrapperSPIRVOffsetsSupported = false;
		uint32 m_PhysicalDeviceNum = 0;
		uint32 m_PhysicalDeviceMask = 0;
		CommandQueueValidator[COMMAND_QUEUE_TYPE_NUM] m_CommandQueues = .();
		Dictionary<MemoryType, MemoryLocation> m_MemoryTypeMap = new .() ~ delete _;
		Monitor m_Monitor;

		public this(Device device, ILogger logger, DeviceAllocator allocator) : base(logger, allocator)
		{
			mDevice = device;
		}

		public override void SetDebugName(StringView name)
		{
			mDevice.SetDebugName(name);
		}

		public override ref DeviceDesc GetDesc()
		{
			return ref mDevice.GetDesc();
		}

		public override Result GetCommandQueue(CommandQueueType commandQueueType, out CommandQueue commandQueue)
		{
			commandQueue = ?;
			RETURN_ON_FAILURE!(mDevice.GetLogger(), commandQueueType < CommandQueueType.MAX_NUM, Result.INVALID_ARGUMENT,
			    "Can't get CommandQueue: 'commandQueueType' is invalid.");

			CommandQueue commandQueueImpl;
			readonly Result result = mDevice.GetCommandQueue(commandQueueType, out commandQueueImpl);

			if (result == Result.SUCCESS)
			{
			    readonly uint32 index = (uint32)commandQueueType;
			    if (m_CommandQueues[index] == null)
			        m_CommandQueues[index] = Allocate!<CommandQueueValidator>(mDevice.GetDeviceAllocator(), this, commandQueueImpl);

			    commandQueue = (CommandQueue)m_CommandQueues[index];
			}

			return result;
		}

		public override Result CreateCommandAllocator(CommandQueue commandQueue, uint32 physicalDeviceMask, out CommandAllocator commandAllocator)
		{
			commandAllocator = ?;

			return default;
		}

		public override Result CreateDescriptorPool(DescriptorPoolDesc descriptorPoolDesc, out DescriptorPool descriptorPool)
		{
			descriptorPool = ?;

			return default;
		}

		public override Result CreateBuffer(BufferDesc bufferDesc, out Buffer buffer)
		{
			buffer = ?;
			return default;
		}

		public override Result CreateTexture(TextureDesc textureDesc, out Texture texture)
		{
			texture = ?;

			return default;
		}

		public override Result CreateBufferView(BufferViewDesc bufferViewDesc, out Descriptor bufferView)
		{
			bufferView = ?;

			return default;
		}

		public override Result CreateTexture1DView(Texture1DViewDesc textureViewDesc, out Descriptor textureView)
		{
			textureView = ?;

			return default;
		}

		public override Result CreateTexture2DView(Texture2DViewDesc textureViewDesc, out Descriptor textureView)
		{
			textureView = ?;

			return default;
		}

		public override Result CreateTexture3DView(Texture3DViewDesc textureViewDesc, out Descriptor textureView)
		{
			textureView = ?;

			return default;
		}

		public override Result CreateSampler(SamplerDesc samplerDesc, out Descriptor sampler)
		{
			sampler = ?;

			return default;
		}

		public override Result CreatePipelineLayout(PipelineLayoutDesc pipelineLayoutDesc, out PipelineLayout pipelineLayout)
		{
			pipelineLayout = ?;

			return default;
		}

		public override Result CreateGraphicsPipeline(GraphicsPipelineDesc graphicsPipelineDesc, out Pipeline pipeline)
		{
			pipeline = ?;

			return default;
		}

		public override Result CreateComputePipeline(ComputePipelineDesc computePipelineDesc, out Pipeline pipeline)
		{
			pipeline = ?;

			return default;
		}

		public override Result CreateFrameBuffer(FrameBufferDesc frameBufferDesc, out FrameBuffer frameBuffer)
		{
			frameBuffer = ?;

			return default;
		}

		public override Result CreateQueryPool(QueryPoolDesc queryPoolDesc, out QueryPool queryPool)
		{
			queryPool = ?;

			return default;
		}

		public override Result CreateQueueSemaphore(out QueueSemaphore queueSemaphore)
		{
			queueSemaphore = ?;

			return default;
		}

		public override Result CreateDeviceSemaphore(bool signaled, out DeviceSemaphore deviceSemaphore)
		{
			deviceSemaphore = ?;

			return default;
		}

		public override Result CreateSwapChain(SwapChainDesc swapChainDesc, out SwapChain swapChain)
		{
			swapChain= ?;

			return default;
		}

		public override Result CreateRayTracingPipeline(RayTracingPipelineDesc rayTracingPipelineDesc, out Pipeline pipeline)
		{
			pipeline = ?;

			return default;
		}

		public override Result CreateAccelerationStructure(AccelerationStructureDesc accelerationStructureDesc, out AccelerationStructure accelerationStructure)
		{
			accelerationStructure = ?;
			return default;
		}

		public override void DestroyCommandAllocator(ref CommandAllocator commandAllocator)
		{

		}

		public override void DestroyDescriptorPool(ref DescriptorPool descriptorPool)
		{

		}

		public override void DestroyBuffer(ref Buffer buffer)
		{

		}

		public override void DestroyTexture(ref Texture texture)
		{

		}

		public override void DestroyDescriptor(ref Descriptor descriptor)
		{

		}

		public override void DestroyPipelineLayout(ref PipelineLayout pipelineLayout)
		{

		}

		public override void DestroyPipeline(ref Pipeline pipeline)
		{

		}

		public override void DestroyFrameBuffer(ref FrameBuffer frameBuffer)
		{

		}

		public override void DestroyQueryPool(ref QueryPool queryPool)
		{

		}

		public override void DestroyQueueSemaphore(ref QueueSemaphore queueSemaphore)
		{

		}

		public override void DestroyDeviceSemaphore(ref DeviceSemaphore deviceSemaphore)
		{

		}

		public override void DestroySwapChain(ref SwapChain swapChain)
		{

		}

		public override void DestroyAccelerationStructure(ref AccelerationStructure accelerationStructure)
		{

		}

		public override void DestroyCommandBuffer(ref CommandBuffer commandBuffer)
		{

		}

		public override Result GetDisplays(Display** displays, ref uint32 displayNum)
		{
			return default;
		}

		public override Result GetDisplaySize(ref Display display, ref uint16 width, ref uint16 height)
		{
			return default;
		}

		public override Result AllocateMemory(uint32 physicalDeviceMask, uint32 memoryType, uint64 size, out Memory memory)
		{
			memory = ?;
			return default;
		}

		public override Result BindBufferMemory(BufferMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum)
		{
			return default;
		}

		public override Result BindTextureMemory(TextureMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum)
		{
			return default;
		}

		public override Result BindAccelerationStructureMemory(AccelerationStructureMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum)
		{
			return default;
		}

		public override void FreeMemory(ref Memory memory)
		{

		}

		public override FormatSupportBits GetFormatSupport(Format format)
		{
			return default;
		}

		public override uint32 CalculateAllocationNumber(ResourceGroupDesc resourceGroupDesc)
		{
			return default;
		}

		public override Result AllocateAndBindMemory(ResourceGroupDesc resourceGroupDesc, Memory* allocations)
		{
			return default;
		}

		public override void SetSPIRVBindingOffsets(SPIRVBindingOffsets spirvBindingOffsets)
		{

		}

		public uint32 GetPhysicalDeviceNum() => m_PhysicalDeviceNum;

		public bool IsPhysicalDeviceMaskValid(uint32 physicalDeviceMask) => m_PhysicalDeviceMask & physicalDeviceMask == physicalDeviceMask;

		public Monitor GetLock() => m_Monitor;
	}
}