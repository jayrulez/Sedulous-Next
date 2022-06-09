using System;
using Bulkan;
using Sedulous.Graphics;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics;

	/// <summary>
	/// This class represents a native pipelineState on Vulkan.
	/// </summary>
	public class VKComputePipelineState : ComputePipelineState
	{
		/// <summary>
		/// The Vulkan native pipeline struct.
		/// </summary>
		public VkPipeline NativePipeline;

		/// <summary>
		/// The Vulkan native pipeline layout struct.
		/// </summary>
		public VkPipelineLayout NativePipelineLayout;

		private VKGraphicsContext vkContext;

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
				vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_PIPELINE, NativePipeline.Handle, name);
			}
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKComputePipelineState" /> class.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="description">The compute pipeline state description.</param>
		public  this(VKGraphicsContext context, ref ComputePipelineDescription description)
			: base(ref description)
		{
			vkContext = context;
			VkComputePipelineCreateInfo vkComputePipelineCreateInfo = VkComputePipelineCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO
			};
			VkPipelineLayoutCreateInfo vkPipelineLayoutCreateInfo = VkPipelineLayoutCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO
			};
			if (description.ResourceLayouts != null)
			{
				VkDescriptorSetLayout* ptr = scope VkDescriptorSetLayout[description.ResourceLayouts.Count]*;
				for (int32 i = 0; i < description.ResourceLayouts.Count; i++)
				{
					VKResourceLayout vKResourceLayout = description.ResourceLayouts[i] as VKResourceLayout;
					ptr[i] = vKResourceLayout.DescriptorSetLayout;
				}
				vkPipelineLayoutCreateInfo.setLayoutCount = (uint32)description.ResourceLayouts.Count;
				vkPipelineLayoutCreateInfo.pSetLayouts = ptr;
			}
			VkPipelineLayout nativePipelineLayout = default(VkPipelineLayout);
			VulkanNative.vkCreatePipelineLayout(context.VkDevice, &vkPipelineLayoutCreateInfo, null, &nativePipelineLayout);
			NativePipelineLayout = nativePipelineLayout;
			vkComputePipelineCreateInfo.layout = NativePipelineLayout;
			vkComputePipelineCreateInfo.stage = (description.shaderDescription.ComputeShader as VKShader).ShaderStateInfo;
			VkPipeline nativePipeline = default(VkPipeline);
			VulkanNative.vkCreateComputePipelines(context.VkDevice, VkPipelineCache.Null, 1u, &vkComputePipelineCreateInfo, null, &nativePipeline);
			NativePipeline = nativePipeline;
		}

		/// <inheritdoc />
		public override void Dispose()
		{
			//Dispose(disposing: true);
			//GC.SuppressFinalize(this);
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
					VulkanNative.vkDestroyPipelineLayout(vkContext.VkDevice, NativePipelineLayout, null);
					VulkanNative.vkDestroyPipeline(vkContext.VkDevice, NativePipeline, null);
				}
				disposed = true;
			}
		}
	}
}
