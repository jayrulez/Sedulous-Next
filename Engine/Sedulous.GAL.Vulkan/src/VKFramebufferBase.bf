using Bulkan;
using System.Collections;
using System;

namespace Sedulous.GAL.Vulkan
{
	using internal Sedulous.GAL;
    internal abstract class VKFramebufferBase : Framebuffer
    {
        public this(
            FramebufferAttachmentDescription? depthTexture,
            Span<FramebufferAttachmentDescription> colorTextures)
            : base(depthTexture, colorTextures)
        {
            RefCount = new ResourceRefCount(new => DisposeCore);
        }

        public this()
        {
            RefCount = new ResourceRefCount(new => DisposeCore);
        }

        public ResourceRefCount RefCount { get; } ~ delete _;

        public abstract uint32 RenderableWidth { get; }
        public abstract uint32 RenderableHeight { get; }

        public override void Dispose()
        {
            RefCount.Decrement();
        }

        protected abstract void DisposeCore();

        public abstract Bulkan.VkFramebuffer CurrentFramebuffer { get; }
        public abstract VkRenderPass RenderPassNoClear_Init { get; }
        public abstract VkRenderPass RenderPassNoClear_Load { get; }
        public abstract VkRenderPass RenderPassClear { get; }
        public abstract uint32 AttachmentCount { get; protected set;}
        public abstract void TransitionToIntermediateLayout(VkCommandBuffer cb);
        public abstract void TransitionToFinalLayout(VkCommandBuffer cb);
    }
}
