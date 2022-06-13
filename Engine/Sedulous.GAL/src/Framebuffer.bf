using System;
using System.Diagnostics;
using System.Collections;

namespace Sedulous.GAL
{
	using internal Sedulous.GAL;

    /// <summary>
    /// A device resource used to control which color and depth textures are rendered to.
    /// See <see cref="FramebufferDescription"/>.
    /// </summary>
    public abstract class Framebuffer : DeviceResource, IDisposable
    {
        /// <summary>
        /// Gets the depth attachment associated with this instance. May be null if no depth texture is used.
        /// </summary>
        public virtual FramebufferAttachment? DepthTarget { get; protected set; }

        /// <summary>
        /// Gets the collection of color attachments associated with this instance. May be empty.
        /// </summary>
        public virtual Span<FramebufferAttachment> ColorTargets { get; protected set; }
		private readonly List<FramebufferAttachment> _colorTargets;

        /// <summary>
        /// Gets an <see cref="Sedulous.GAL.OutputDescription"/> which describes the number and formats of the depth and color targets
        /// in this instance.
        /// </summary>
        public virtual OutputDescription OutputDescription { get; protected set;}

        /// <summary>
        /// Gets the width of the <see cref="Framebuffer"/>.
        /// </summary>
        public virtual uint32 Width { get; protected set;}

        /// <summary>
        /// Gets the height of the <see cref="Framebuffer"/>.
        /// </summary>
        public virtual uint32 Height { get; protected set;}

        internal this() { }

		public ~this(){
			delete _colorTargets;
		}

        internal this(
            FramebufferAttachmentDescription? depthTargetDesc,
            Span<FramebufferAttachmentDescription> colorTargetDescs)
        {
            if (depthTargetDesc != null)
            {
                FramebufferAttachmentDescription depthAttachment = depthTargetDesc.Value;
                DepthTarget = FramebufferAttachment(
                    depthAttachment.Target,
                    depthAttachment.ArrayLayer,
                    depthAttachment.MipLevel);
            }
            _colorTargets = new List<FramebufferAttachment>() {Count = colorTargetDescs.Length};
            for (int i = 0; i < _colorTargets.Count; i++)
            {
                _colorTargets[i] = FramebufferAttachment(
                    colorTargetDescs[i].Target,
                    colorTargetDescs[i].ArrayLayer,
                    colorTargetDescs[i].MipLevel);
            }

            ColorTargets = _colorTargets;

            Texture dimTex;
            uint32 mipLevel;
            if (ColorTargets.Length > 0)
            {
                dimTex = ColorTargets[0].Target;
                mipLevel = ColorTargets[0].MipLevel;
            }
            else
            {
                Debug.Assert(DepthTarget != null);
                dimTex = DepthTarget.Value.Target;
                mipLevel = DepthTarget.Value.MipLevel;
            }

            Util.GetMipDimensions(dimTex, mipLevel, var mipWidth, var mipHeight, ?);
            Width = mipWidth;
            Height = mipHeight;


            OutputDescription = /*OutputDescription*/.CreateFromFramebuffer(this);
        }

        /// <summary>
        /// A String identifying this instance. Can be used to differentiate between objects in graphics debuggers and other
        /// tools.
        /// </summary>
        public abstract String Name { get; set; }

        /// <summary>
        /// A bool indicating whether this instance has been disposed.
        /// </summary>
        public abstract bool IsDisposed { get; }

        /// <summary>
        /// Frees unmanaged device resources controlled by this instance.
        /// </summary>
        public abstract void Dispose();
    }
}
