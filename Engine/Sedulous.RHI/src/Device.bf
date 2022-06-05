using Sedulous.Foundation.Logging.Abstractions;
using System;
namespace Sedulous.RHI;

abstract class Device
{
	public struct Description
	{
	}

	public abstract Adapter Adapter { get; }

	public this(ILogger logger)
	{
	}

	public abstract CommandQueue GetCommandQueue(CommandQueueType commandQueueType);
	public abstract void DestroyCommandQueue(in CommandQueue commandQueue);

	public abstract Result<void> CreateFence(out Fence fence);
	public abstract void DestroyFence(in Fence fence);

	public abstract Result<void> CreateSemaphore(out Semaphore semaphore);
	public abstract void DestroySemaphore(in Semaphore semaphore);

	public abstract Result<void> CreateRootSignaturePool(in RootSignaturePool.Description description, out RootSignaturePool rootSignaturePool);
	public abstract void DestroyRootSignaturePool(in RootSignaturePool rootSignaturePool);

	public abstract Result<void> CreateRootSignature(in RootSignature.Description description, out RootSignature rootSignature);
	public abstract void DestroyRootSignature(in RootSignature rootSignature);

	public abstract Result<void> CreateDescriptorSet(in DescriptorSet.Description description, out DescriptorSet descriptorSet);
	public abstract void DestroyDescriptorSet(in DescriptorSet descriptorSet);

	public abstract Result<void> CreateComputePipeline(in ComputePipeline.Description description, out ComputePipeline computePipeline);
	public abstract void DestroyComputePipeline(in ComputePipeline computePipeline);

	public abstract Result<void> CreateGraphicsPipeline(in GraphicsPipeline.Description description, out GraphicsPipeline graphicsPipeline);
	public abstract void DestroyGraphicsPipeline(in GraphicsPipeline graphicsPipeline);

	public abstract Result<void> CreateMemoryPool(in MemoryPool.Description description, out MemoryPool memoryPool);
	public abstract void DestroyMemoryPool(in MemoryPool memoryPool);

	public abstract Result<void> CreateQueryPool(in QueryPool.Description description, out QueryPool queryPool);
	public abstract void DestroyQueryPool(in QueryPool queryPool);

	public abstract Result<void> CreateShaderLibrary(in ShaderLibrary.Description description, out ShaderLibrary shaderLibrary);
	public abstract void DestroyShaderLibrary(in ShaderLibrary shaderLibrary);

	public abstract Result<void> CreateBuffer(in Buffer.Description description, out Buffer buffer);
	public abstract Result<void> CreateMappedConstantBuffer(uint64 size, char8* name, bool deviceLocalPreferred);
	public abstract Result<void> CreateMappedUploadBuffer(uint64 size, char8* name);
	public abstract void DestroyBuffer(in Buffer buffer);

	public abstract Result<void> CreateSampler(in Sampler.Description description, out Sampler sampler);
	public abstract void DestroySampler(in Sampler sampler);

	public abstract Result<void> CreateTexture(in Texture.Description description, out Texture texture);
	public abstract void DestroyTexture(in Texture texture);

	public abstract Result<void> CreateTextureView(in TextureView.Description description, out TextureView textureView);
	public abstract void DestroyTextureView(in TextureView textureView);

	public abstract bool TryBindAliasingTexture(in Texture.AliasingBindDescription description);

	public abstract Result<void> CreateSwapChain(in SwapChain.Description description, out SwapChain swapChain);
	public abstract void DestroySwapChain(in SwapChain swapChain);

	public abstract Result<void> CreateSurface(in Surface.Description description, out Surface surface);
	public abstract void DestroySurface(in Surface surface);
}