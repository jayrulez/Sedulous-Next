using System;
using Bulkan;
using Sedulous.Graphics;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics;

	using static Sedulous.Graphics.Vulkan.VKExtensionsMethods;
	using static Sedulous.Graphics.Vulkan.VKHelpers;

	/// <summary>
	/// The Vulkan implementation of a ResourceLayout Object.
	/// </summary>
	public class VKResourceLayout : ResourceLayout
	{
		/// <summary>
		/// The Vulkan desriptorset layout struct.
		/// </summary>
		public readonly VkDescriptorSetLayout DescriptorSetLayout;

		internal readonly VKResourceCounts ResourceCounts;

		private readonly VKGraphicsContext vkContext;

		private String name;

		private bool disposed;

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
				vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT, DescriptorSetLayout.Handle, name);
			}
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKResourceLayout" /> class.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="description">The layout description.</param>
		public  this(VKGraphicsContext context, ref ResourceLayoutDescription description)
			: base(ref description)
		{
			vkContext = context;
			VkDescriptorSetLayoutCreateInfo vkDescriptorSetLayoutCreateInfo = VkDescriptorSetLayoutCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO
			};
			VkDescriptorSetLayoutBinding* ptr = scope VkDescriptorSetLayoutBinding[description.Elements.Count]*;
			uint32 num = 0u;
			uint32 num2 = 0u;
			uint32 num3 = 0u;
			uint32 num4 = 0u;
			uint32 num5 = 0u;
			uint32 num6 = 0u;
			for (uint32 num7 = 0u; num7 < description.Elements.Count; num7++)
			{
				LayoutElementDescription element = description.Elements[num7];
				uint32 num8 = (ptr[num7].binding = VKHelpers.GetBinding(element));
				ptr[num7].descriptorCount = 1u;
				ptr[num7].descriptorType = element.Type.ToVulkan(element.AllowDynamicOffset);
				ptr[num7].stageFlags = element.Stages.ToVulkan();
				switch (element.Type.ToVulkan())
				{
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER:
					num++;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE:
					num2++;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER:
					num3++;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER:
					num4++;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE:
					num5++;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR:
					num6++;
					break;

				default:break;
				}
			}
			ResourceCounts = VKResourceCounts(num, num2, num3, num4, num5, num6);
			vkDescriptorSetLayoutCreateInfo.bindingCount = (uint32)description.Elements.Count;
			vkDescriptorSetLayoutCreateInfo.pBindings = ptr;
			VkDescriptorSetLayout descriptorSetLayout = default(VkDescriptorSetLayout);
			VulkanNative.vkCreateDescriptorSetLayout(vkContext.VkDevice, &vkDescriptorSetLayoutCreateInfo, null, &descriptorSetLayout);
			DescriptorSetLayout = descriptorSetLayout;
		}

		/// <inheritdoc />
		public override void Dispose()
		{
			/*Dispose(disposing: true);
			GC.SuppressFinalize(this);*/
		}

		/// <summary>
		/// Releases unmanaged and - optionally - managed resources.
		/// </summary>
		/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
		private  void Dispose(bool disposing)
		{
			if (!disposed)
			{
				if (disposing)
				{
					VulkanNative.vkDestroyDescriptorSetLayout(vkContext.VkDevice, DescriptorSetLayout, null);
				}
				disposed = true;
			}
		}
	}
}
