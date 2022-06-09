using System;
using Bulkan;
using Sedulous.Graphics;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics;

	using static Sedulous.Graphics.Vulkan.VKExtensionsMethods;
	using static Sedulous.Graphics.Vulkan.VKHelpers;

	/// <summary>
	/// This class represents the a Vulkan samplerState Object.
	/// </summary>
	public class VKSamplerState : SamplerState
	{
		/// <summary>
		/// The native sampler state.
		/// </summary>
		public readonly VkSampler NativeSampler;

		private VKGraphicsContext vkContext;

		private String name;

		/// <inheritdoc />
		public override String Name
		{
			get
			{
				return name;
			}
			set
			{
				name = value;
				vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_SAMPLER, NativeSampler.Handle, name);
			}
		}

		/// <inheritdoc />
		public override void* NativePointer
		{
			get
			{
				if (!(NativeSampler != VkSampler.Null))
				{
					return null;
				}
				return (void*)(int)NativeSampler.Handle;
			}
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKSamplerState" /> class.
		/// </summary>
		/// <param name="context">The graphics context. <see cref="T:Sedulous.Graphics.GraphicsContext" />.</param>
		/// <param name="description">The sampler state description. <see cref="T:Sedulous.Graphics.SamplerStateDescription" />.</param>
		public  this(GraphicsContext context, ref SamplerStateDescription description)
			: base(context, ref description)
		{
			description.Filter.ToVulkan(var minFilter, var magFilter, var mipmapMode);
			VkSamplerCreateInfo vkSamplerCreateInfo = VkSamplerCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
				addressModeU = description.AddressU.ToVulkan(),
				addressModeV = description.AddressU.ToVulkan(),
				addressModeW = description.AddressU.ToVulkan(),
				minFilter = minFilter,
				magFilter = magFilter,
				mipmapMode = mipmapMode,
				compareEnable = (description.ComparisonFunc != ComparisonFunction.Never),
				compareOp = description.ComparisonFunc.ToVulkan(),
				anisotropyEnable = (description.Filter == TextureFilter.Anisotropic),
				maxAnisotropy = description.MaxAnisotropy,
				minLod = description.MinLOD,
				maxLod = description.MaxLOD,
				mipLodBias = description.MipLODBias,
				borderColor = description.BorderColor.ToVulkan()
			};
			vkContext = Context as VKGraphicsContext;
			VkSampler nativeSampler = default(VkSampler);
			VulkanNative.vkCreateSampler(vkContext.VkDevice, &vkSamplerCreateInfo, null, &nativeSampler);
			NativeSampler = nativeSampler;
		}

		public ~this(){
			OnDestroy();
			VulkanNative.vkDestroySampler(vkContext.VkDevice, NativeSampler, null);
		}
	}
}
