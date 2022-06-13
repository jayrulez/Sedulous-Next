using Bulkan;

namespace Sedulous.GAL.Vulkan
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.Vulkan;

    internal class VKResourceFactory : ResourceFactory
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VkDevice _device;

        public this(VKGraphicsDevice vkGraphicsDevice)
            : base (vkGraphicsDevice.Features)
        {
            _gd = vkGraphicsDevice;
            _device = vkGraphicsDevice.Device;
        }

        public override GraphicsBackend BackendType => GraphicsBackend.Vulkan;

        public override CommandList CreateCommandList(CommandListDescription description)
        {
            return new VKCommandList(_gd, description);
        }

        public override Framebuffer CreateFramebuffer(FramebufferDescription description)
        {
            return new VKFramebuffer(_gd, description, false);
        }

        protected override Pipeline CreateGraphicsPipelineCore(GraphicsPipelineDescription description)
        {
            return new VKPipeline(_gd, description);
        }

        public override Pipeline CreateComputePipeline(ComputePipelineDescription description)
        {
            return new VKPipeline(_gd, description);
        }

        public override ResourceLayout CreateResourceLayout(ResourceLayoutDescription description)
        {
            return new VKResourceLayout(_gd, description);
        }

        public override ResourceSet CreateResourceSet(ResourceSetDescription description)
        {
            ValidationHelpers.ValidateResourceSet(_gd, description);
            return new VKResourceSet(_gd, description);
        }

        protected override Sampler CreateSamplerCore(SamplerDescription description)
        {
            return new VKSampler(_gd, description);
        }

        protected override Shader CreateShaderCore(ShaderDescription description)
        {
            return new VKShader(_gd, description);
        }

        protected override Texture CreateTextureCore(TextureDescription description)
        {
            return new VKTexture(_gd, description);
        }

        protected override Texture CreateTextureCore(uint64 nativeTexture, TextureDescription description)
        {
            return new VKTexture(
                _gd,
                description.Width, description.Height,
                description.MipLevels, description.ArrayLayers,
                VKFormats.VdToVkPixelFormat(description.Format, (description.Usage & TextureUsage.DepthStencil) != 0),
                description.Usage,
                description.SampleCount,
                nativeTexture);
        }

        protected override TextureView CreateTextureViewCore(TextureViewDescription description)
        {
            return new VKTextureView(_gd, description);
        }

        protected override DeviceBuffer CreateBufferCore(BufferDescription description)
        {
            return new VKBuffer(_gd, description.SizeInBytes, description.Usage);
        }

        public override Fence CreateFence(bool signaled)
        {
            return new VKFence(_gd, signaled);
        }

        public override Swapchain CreateSwapchain(ref SwapchainDescription description)
        {
            return new VKSwapchain(_gd, ref description);
        }
    }
}
