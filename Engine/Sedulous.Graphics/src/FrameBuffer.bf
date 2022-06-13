using System;

namespace Sedulous.Graphics
{
	/// <summary>
	/// This class represent which color texture and depth texture are rendered to present.
	/// </summary>
	public abstract class FrameBuffer : IDisposable
	{
		/// <summary>
		/// Holds if the instance has been disposed.
		/// </summary>
		protected bool disposed;

		/// <summary>
		/// A value indicating whether we need to dispose attachment textures when this framebuffer is disposed.
		/// </summary>
		protected bool disposeAttachments;


		/// <summary>
		/// Gets or sets a String identifying this instance. Can be used in graphics debuggers tools.
		/// </summary>
		public abstract String Name { get; set; }

		/// <summary>
		/// Gets or sets the width in pixels of the <see cref="T:Sedulous.Graphics.FrameBuffer" />.
		/// </summary>
		public uint32 Width { get; protected set; }

		/// <summary>
		/// Gets or sets the height in pixels of the <see cref="T:Sedulous.Graphics.FrameBuffer" />.
		/// </summary>
		public uint32 Height { get; protected set; }

		/// <summary>
		/// Gets or sets the array size of the <see cref="T:Sedulous.Graphics.FrameBuffer" />.
		/// </summary>
		public uint32 ArraySize { get; protected set; } = 1u;


		/// <summary>
		/// Gets or sets the sample count of the <see cref="T:Sedulous.Graphics.FrameBuffer" />.
		/// </summary>
		public TextureSampleCount SampleCount { get; protected set; }

		/// <summary>
		/// Gets a value indicating whether this FrameBuffer requires the projection matrix to be flipped.
		/// </summary>
		public abstract bool RequireFlipProjection { get; }

		/// <summary>
		/// Gets or sets the collection of colors targets textures associated with this <see cref="T:Sedulous.Graphics.FrameBuffer" />.
		/// </summary>
		public virtual FrameBufferAttachment[] ColorTargets { get; protected set; }

		/// <summary>
		/// Gets or sets the depth targets texture associated with this <see cref="T:Sedulous.Graphics.FrameBuffer" />.
		/// </summary>
		public virtual FrameBufferAttachment? DepthStencilTarget { get; protected set; }

		/// <summary>
		/// Gets or sets an <see cref="P:Sedulous.Graphics.FrameBuffer.OutputDescription" /> which describes the number and formats of the depth and colors targets.
		/// </summary>
		public OutputDescription OutputDescription { get; protected set; }

		/// <summary>
		/// Gets or sets a value indicating whether the framebuffer is associates to a swapchain.
		/// </summary>
		public bool IntermediateBufferAssociated { get; set; }

		private OutputAttachmentDescription[] mReferencesDescriptions = null;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.FrameBuffer" /> class.
		/// </summary>
		/// <param name="depthTarget">The depth texture which must have been created with <see cref="F:Sedulous.Graphics.TextureFlags.DepthStencil" /> flag.</param>
		/// <param name="colorTargets">The array of color textures, all of which must have been created with <see cref="F:Sedulous.Graphics.TextureFlags.RenderTarget" /> flags.</param>
		/// <param name="disposeAttachments">When this framebuffer is disposed, dispose the attachment textures too.</param>
		public this(FrameBufferAttachment? depthTarget, FrameBufferAttachment[] colorTargets, bool disposeAttachments)
		{
			DepthStencilTarget = depthTarget;
			ColorTargets = colorTargets;
			this.disposeAttachments = disposeAttachments;
			FrameBufferAttachment[] colorTargets2 = ColorTargets;
			if (colorTargets2 != null && colorTargets2.Count != 0)
			{
				FrameBufferAttachment frameBufferAttachment = ColorTargets[0];
				Width = frameBufferAttachment.AttachmentTexture.Description.Width;
				Height = frameBufferAttachment.AttachmentTexture.Description.Height;
				ArraySize = frameBufferAttachment.AttachmentTexture.Description.ArraySize;
				SampleCount = frameBufferAttachment.AttachmentTexture.Description.SampleCount;
			}
			else if (DepthStencilTarget.HasValue)
			{
				TextureDescription? textureDescription = DepthStencilTarget?.AttachmentTexture.Description;
				if (textureDescription.HasValue)
				{
					Width = textureDescription.Value.Width;
					Height = textureDescription.Value.Height;
					ArraySize = textureDescription.Value.ArraySize;
					SampleCount = textureDescription.Value.SampleCount;
				}
			}
			OutputDescription = /*OutputDescription*/ .CreateFromFrameBuffer(this, out mReferencesDescriptions);
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.FrameBuffer" /> class.
		/// </summary>
		public this()
		{
		}

		/// <summary>
		/// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
		/// </summary>
		public void Dispose()
		{
			Dispose( /*disposing:*/true);
			//GC.SuppressFinalize(this);
		}

		/// <summary>
		/// Releases unmanaged and - optionally - managed resources.
		/// </summary>
		/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
		protected virtual void Dispose(bool disposing)
		{
			if (disposed)
			{
				return;
			}
			if (disposing)
			{
				if (disposeAttachments)
				{
					if (ColorTargets != null)
					{
						FrameBufferAttachment[] colorTargets = ColorTargets;
						for (int32 i = 0; i < colorTargets.Count; i++)
						{
							FrameBufferAttachment frameBufferAttachment = colorTargets[i];

							frameBufferAttachment.AttachmentTexture.Dispose();
							if (frameBufferAttachment.AttachmentTexture != null)
								delete frameBufferAttachment.AttachmentTexture;

							frameBufferAttachment.ResolvedTexture?.Dispose();
							if (frameBufferAttachment.ResolvedTexture != null)
								delete frameBufferAttachment.ResolvedTexture;
						}
					}

					if (DepthStencilTarget.HasValue)
					{
						/*ref FrameBufferAttachment depthStencilTarget = ref DepthStencilTarget.ValueRef;

						depthStencilTarget.AttachmentTexture?.Dispose();
						depthStencilTarget.ResolvedTexture?.Dispose();

						if (depthStencilTarget.AttachmentTexture != null)
						{
							if (depthStencilTarget.AttachmentTexture == depthStencilTarget.ResolvedTexture)
							{
								delete depthStencilTarget.AttachmentTexture;
							} else
							{
								delete depthStencilTarget.AttachmentTexture;
								if (depthStencilTarget.ResolvedTexture != null)
									delete depthStencilTarget.ResolvedTexture;
							}
						}

						depthStencilTarget.AttachmentTexture = null;
						depthStencilTarget.ResolvedTexture = null;*/

						/*DepthStencilTarget?.AttachmentTexture?.Dispose();
						if (DepthStencilTarget?.AttachmentTexture != null)
						{
							delete DepthStencilTarget.Value.AttachmentTexture;
							DepthStencilTarget?.AttachmentTexture = null;
						}

						DepthStencilTarget?.ResolvedTexture?.Dispose();
						if (DepthStencilTarget?.ResolvedTexture != null)
							delete DepthStencilTarget.Value.ResolvedTexture;*/
					}

					defer:: delete ColorTargets;
				}

				if (mReferencesDescriptions != null)
					delete mReferencesDescriptions;
			}
			disposed = true;
		}
	}
}
