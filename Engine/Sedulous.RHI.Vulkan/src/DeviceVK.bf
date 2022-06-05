using Sedulous.Foundation.Logging.Abstractions;
using System;
namespace Sedulous.RHI.Vulkan;

class DeviceVK : Device
{
	public this(ILogger logger) : base(logger)
	{
	}

	public override Result<void> CreateFence(out Fence fence)
	{
		fence = ?;
		return default;
	}

	private Adapter mAdapter;
	public override Adapter Adapter => mAdapter;

	public override CommandQueue GetCommandQueue(CommandQueueType commandQueueType)
	{
		return default;
	}

	public override void DestroyCommandQueue(in CommandQueue commandQueue)
	{

	}

	public override void DestroyFence(in Fence fence)
	{

	}

	public override Result<void> CreateSemaphore(out Semaphore semaphore)
	{
		semaphore = ?;
		return default;
	}

	public override void DestroySemaphore(in Semaphore semaphore)
	{

	}

	public override Result<void> CreateRootSignaturePool(in RootSignaturePool.Description description, out RootSignaturePool rootSignaturePool)
	{
		rootSignaturePool  = ?;
		return default;
	}

	public override void DestroyRootSignaturePool(in RootSignaturePool rootSignaturePool)
	{

	}

	public override Result<void> CreateRootSignature(in RootSignature.Description description, out RootSignature rootSignature)
	{
		rootSignature  = ?;
		return default;
	}

	public override void DestroyRootSignature(in RootSignature rootSignature)
	{

	}

	public override Result<void> CreateDescriptorSet(in DescriptorSet.Description description, out DescriptorSet descriptorSet)
	{
		descriptorSet = ?;
		return default;
	}

	public override void DestroyDescriptorSet(in DescriptorSet descriptorSet)
	{

	}

	public override Result<void> CreateComputePipeline(in ComputePipeline.Description description, out ComputePipeline computePipeline)
	{
		computePipeline = ?;
		return default;
	}

	public override void DestroyComputePipeline(in ComputePipeline computePipeline)
	{

	}

	public override Result<void> CreateGraphicsPipeline(in GraphicsPipeline.Description description, out GraphicsPipeline graphicsPipeline)
	{
		graphicsPipeline = ?;
		return default;
	}

	public override void DestroyGraphicsPipeline(in GraphicsPipeline graphicsPipeline)
	{

	}

	public override Result<void> CreateMemoryPool(in MemoryPool.Description description, out MemoryPool memoryPool)
	{
		memoryPool = ?;
		return default;
	}

	public override void DestroyMemoryPool(in MemoryPool memoryPool)
	{

	}

	public override Result<void> CreateQueryPool(in QueryPool.Description description, out QueryPool queryPool)
	{
		queryPool = ?;
		return default;
	}

	public override void DestroyQueryPool(in QueryPool queryPool)
	{

	}

	public override Result<void> CreateShaderLibrary(in ShaderLibrary.Description description, out ShaderLibrary shaderLibrary)
	{
		shaderLibrary = ?;
		return default;
	}

	public override void DestroyShaderLibrary(in ShaderLibrary shaderLibrary)
	{

	}

	public override Result<void> CreateBuffer(in Buffer.Description description, out Buffer buffer)
	{
		buffer = ?;
		return default;
	}

	public override Result<void> CreateMappedConstantBuffer(uint64 size, char8* name, bool deviceLocalPreferred)
	{
		return default;
	}

	public override Result<void> CreateMappedUploadBuffer(uint64 size, char8* name)
	{
		return default;
	}

	public override void DestroyBuffer(in Buffer buffer)
	{

	}

	public override Result<void> CreateSampler(in Sampler.Description description, out Sampler sampler)
	{
		sampler = ?;
		return default;
	}

	public override void DestroySampler(in Sampler sampler)
	{

	}

	public override Result<void> CreateTexture(in Texture.Description description, out Texture texture)
	{
		texture = ?;
		return default;
	}

	public override void DestroyTexture(in Texture texture)
	{

	}

	public override Result<void> CreateTextureView(in TextureView.Description description, out TextureView textureView)
	{
		textureView = ?;
		return default;
	}

	public override void DestroyTextureView(in TextureView textureView)
	{

	}

	public override bool TryBindAliasingTexture(in Texture.AliasingBindDescription description)
	{
		return default;
	}

	public override Result<void> CreateSwapChain(in SwapChain.Description description, out SwapChain swapChain)
	{
		swapChain = ?;
		return default;
	}

	public override void DestroySwapChain(in SwapChain swapChain)
	{

	}

	public override Result<void> CreateSurface(in Surface.Description description, out Surface surface)
	{
		surface = ?;
		return default;
	}

	public override void DestroySurface(in Surface surface)
	{

	}
}