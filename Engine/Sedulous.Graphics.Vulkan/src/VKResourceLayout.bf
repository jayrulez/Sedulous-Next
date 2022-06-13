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
			VkDescriptorSetLayoutBinding* bindings = scope VkDescriptorSetLayoutBinding[description.Elements.Count]*;
			uint32 uniformBufferCount  = 0u;
			uint32 sampledImageCount  = 0u;
			uint32 samplerCount  = 0u;
			uint32 storageBufferCount  = 0u;
			uint32 storageImageCount  = 0u;
			uint32 accelerationStructureCount = 0u;
			for (uint32 i = 0u; i < description.Elements.Count; i++)
			{
				ref LayoutElementDescription element = ref description.Elements[i];
				bindings[i].binding = VKHelpers.GetBinding(element);
				bindings[i].descriptorCount = 1u;
				bindings[i].descriptorType = element.Type.ToVulkan(element.AllowDynamicOffset);
				bindings[i].stageFlags = element.Stages.ToVulkan();
				switch (element.Type.ToVulkan())
				{
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER:
					uniformBufferCount ++;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE:
					sampledImageCount ++;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER:
					samplerCount ++;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER:
					storageBufferCount ++;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE:
					storageImageCount ++;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR:
					accelerationStructureCount++;
					break;

				default:break;
				}
			}
			ResourceCounts = VKResourceCounts(uniformBufferCount , sampledImageCount , samplerCount , storageBufferCount , storageImageCount , accelerationStructureCount);
			vkDescriptorSetLayoutCreateInfo.bindingCount = (uint32)description.Elements.Count;
			vkDescriptorSetLayoutCreateInfo.pBindings = bindings;
			VkDescriptorSetLayout descriptorSetLayout = default(VkDescriptorSetLayout);
			VulkanNative.vkCreateDescriptorSetLayout(vkContext.VkDevice, &vkDescriptorSetLayoutCreateInfo, null, &descriptorSetLayout);
			DescriptorSetLayout = descriptorSetLayout;
		}

		/// <inheritdoc />
		public override void Dispose()
		{
			Dispose(/*disposing:*/ true);
			/*GC.SuppressFinalize(this);*/
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
