using Sedulous.Foundation.Logging.Abstractions;
using System;
using System.Collections;
namespace Sedulous.RHI;

abstract class Device
{
	private readonly ILogger m_Logger;
	private readonly DeviceAllocator m_Allocator;

	public this(ILogger logger, DeviceAllocator allocator)
	{
		m_Logger = logger;
		m_Allocator = allocator;
	}

	public ILogger GetLogger() => m_Logger;

	public DeviceAllocator GetDeviceAllocator() => m_Allocator;

	public abstract void SetDebugName(StringView name);
	public abstract readonly ref DeviceDesc GetDesc();
	public abstract Result GetCommandQueue(CommandQueueType commandQueueType, out CommandQueue commandQueue);

	public abstract Result CreateCommandAllocator(CommandQueue commandQueue, uint32 physicalDeviceMask, out CommandAllocator commandAllocator);
	public abstract Result CreateDescriptorPool(DescriptorPoolDesc descriptorPoolDesc, out DescriptorPool descriptorPool);
	public abstract Result CreateBuffer(BufferDesc bufferDesc, out Buffer buffer);
	public abstract Result CreateTexture(TextureDesc textureDesc, out Texture texture);
	public abstract Result CreateBufferView(BufferViewDesc bufferViewDesc, out Descriptor bufferView);
	public abstract Result CreateTexture1DView(Texture1DViewDesc textureViewDesc, out Descriptor textureView);
	public abstract Result CreateTexture2DView(Texture2DViewDesc textureViewDesc, out Descriptor textureView);
	public abstract Result CreateTexture3DView(Texture3DViewDesc textureViewDesc, out Descriptor textureView);
	public abstract Result CreateSampler(SamplerDesc samplerDesc, out Descriptor sampler);
	public abstract Result CreatePipelineLayout(PipelineLayoutDesc pipelineLayoutDesc, out PipelineLayout pipelineLayout);
	public abstract Result CreateGraphicsPipeline(GraphicsPipelineDesc graphicsPipelineDesc, out Pipeline pipeline);
	public abstract Result CreateComputePipeline(ComputePipelineDesc computePipelineDesc, out Pipeline pipeline);
	public abstract Result CreateFrameBuffer(FrameBufferDesc frameBufferDesc, out FrameBuffer frameBuffer);
	public abstract Result CreateQueryPool(QueryPoolDesc queryPoolDesc, out QueryPool queryPool);
	public abstract Result CreateQueueSemaphore(out QueueSemaphore queueSemaphore);
	public abstract Result CreateDeviceSemaphore(bool signaled, out DeviceSemaphore deviceSemaphore);
	public abstract Result CreateSwapChain(SwapChainDesc swapChainDesc, out SwapChain swapChain);
	public abstract Result CreateRayTracingPipeline(RayTracingPipelineDesc rayTracingPipelineDesc, out Pipeline pipeline);
	public abstract Result CreateAccelerationStructure(AccelerationStructureDesc accelerationStructureDesc, out AccelerationStructure accelerationStructure);

	public abstract void DestroyCommandAllocator(ref CommandAllocator commandAllocator);
	public abstract void DestroyDescriptorPool(ref DescriptorPool descriptorPool);
	public abstract void DestroyBuffer(ref Buffer buffer);
	public abstract void DestroyTexture(ref Texture texture);
	public abstract void DestroyDescriptor(ref Descriptor descriptor);
	public abstract void DestroyPipelineLayout(ref PipelineLayout pipelineLayout);
	public abstract void DestroyPipeline(ref Pipeline pipeline);
	public abstract void DestroyFrameBuffer(ref FrameBuffer frameBuffer);
	public abstract void DestroyQueryPool(ref QueryPool queryPool);
	public abstract void DestroyQueueSemaphore(ref QueueSemaphore queueSemaphore);
	public abstract void DestroyDeviceSemaphore(ref DeviceSemaphore deviceSemaphore);
	public abstract void DestroySwapChain(ref SwapChain swapChain);
	public abstract void DestroyAccelerationStructure(ref AccelerationStructure accelerationStructure);
	public abstract void DestroyCommandBuffer(ref CommandBuffer commandBuffer);

	public abstract Result GetDisplays(Display** displays, ref uint32 displayNum);
	public abstract Result GetDisplaySize(ref Display display, ref uint16 width, ref uint16 height);

	public abstract Result AllocateMemory(uint32 physicalDeviceMask, MemoryType memoryType, uint64 size, out Memory memory);
	public abstract Result BindBufferMemory(BufferMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum);
	public abstract Result BindTextureMemory(TextureMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum);
	public abstract Result BindAccelerationStructureMemory(AccelerationStructureMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum);
	public abstract void FreeMemory(ref Memory memory);

	public abstract FormatSupportBits GetFormatSupport(Format format);

	public abstract uint32 CalculateAllocationNumber(ResourceGroupDesc resourceGroupDesc);
	public abstract Result AllocateAndBindMemory(ResourceGroupDesc resourceGroupDesc, Memory* allocations);

	public abstract void SetSPIRVBindingOffsets(SPIRVBindingOffsets spirvBindingOffsets);
}