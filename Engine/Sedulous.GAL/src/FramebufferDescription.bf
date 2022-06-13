using System;

namespace Sedulous.GAL
{
	using internal Sedulous.GAL;

    /// <summary>
    /// Describes a <see cref="Framebuffer"/>, for creation using a <see cref="ResourceFactory"/>.
    /// </summary>
    public struct FramebufferDescription : IEquatable<FramebufferDescription>, IDisposable
    {
        /// <summary>
        /// The depth texture, which must have been created with <see cref="TextureUsage.DepthStencil"/> usage flags.
        /// May be null.
        /// </summary>
        public FramebufferAttachmentDescription? DepthTarget;

        /// <summary>
        /// An array of color textures, all of which must have been created with <see cref="TextureUsage.RenderTarget"/>
        /// usage flags. May be null or empty.
        /// </summary>
		public Span<FramebufferAttachmentDescription> ColorTargets;
        private FramebufferAttachmentDescription[] _colorTargets;

        /// <summary>
        /// Constructs a new <see cref="FramebufferDescription"/>.
        /// </summary>
        /// <param name="depthTarget">The depth texture, which must have been created with
        /// <see cref="TextureUsage.DepthStencil"/> usage flags. May be null.</param>
        /// <param name="colorTargets">An array of color textures, all of which must have been created with
        /// <see cref="TextureUsage.RenderTarget"/> usage flags. May be null or empty.</param>
        public this(Texture depthTarget, params Texture[] colorTargets)
        {
            if (depthTarget != null)
            {
                DepthTarget = FramebufferAttachmentDescription(depthTarget, 0);
            }
            else
            {
                DepthTarget = null;
            }
            _colorTargets = new FramebufferAttachmentDescription[colorTargets.Count];
            for (int i = 0; i < colorTargets.Count; i++)
            {
                _colorTargets[i] = FramebufferAttachmentDescription(colorTargets[i], 0);
            }

			ColorTargets = _colorTargets;
        }

        /// <summary>
        /// Constructs a new <see cref="FramebufferDescription"/>.
        /// </summary>
        /// <param name="depthTarget">A description of the depth attachment. May be null if no depth attachment will be used.</param>
        /// <param name="colorTargets">An array of descriptions of color attachments. May be empty if no color attachments will
        /// be used.</param>
        public this(
            FramebufferAttachmentDescription? depthTarget,
            FramebufferAttachmentDescription[] colorTargets)
        {
            DepthTarget = depthTarget;
            ColorTargets = colorTargets;
			_colorTargets = null;
        }

        /// <summary>
        /// Element-wise equality.
        /// </summary>
        /// <param name="other">The instance to compare to.</param>
        /// <returns>True if all elements and all array elements are equal; false otherswise.</returns>
        public bool Equals(FramebufferDescription other)
        {
			if(ColorTargets.Length != other.ColorTargets.Length)
				return false;

			for(int i = 0; i < other.ColorTargets.Length; i++){
				if(ColorTargets[i] != other.ColorTargets[i])
					return false;
			}
            return Util.NullableEquals(DepthTarget, other.DepthTarget);
        }

        /// <summary>
        /// Returns the hash code for this instance.
        /// </summary>
        /// <returns>A 32-bit signed integer that is the hash code for this instance.</returns>
        public int GetHashCode()
        {
            int hash = DepthTarget.GetHashCode();

			for(int i = 0; i < ColorTargets.Length; i++){
				hash = HashHelper.Combine(hash, ColorTargets[i].GetHashCode());
			}

			return hash;
        }

		public void Dispose()
		{
			if(_colorTargets != null)
				delete _colorTargets;
		}
    }
}
