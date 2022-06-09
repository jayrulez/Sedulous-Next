using System;
using System.Collections.Generic;
using Bulkan;
using Sedulous.Graphics;
using Sedulous.Graphics.Raytracing;
using System.Collections;

namespace Sedulous.Graphics.Vulkan
{
	/// <summary>
	/// Vulkan Raytracing pipeline state.
	/// </summary>
	public class VKRaytracingPipelineState : RaytracingPipelineState
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

		/// <summary>
		/// Generated shader binding table.
		/// </summary>
		public VKShaderTable shaderBindingTable;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKRaytracingPipelineState" /> class.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="description">The raytracing pipeline state description.</param>
		public  this(VKGraphicsContext context, ref RaytracingPipelineDescription description)
			: base(ref description)
		{
			vkContext = context;
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
			VkPipelineLayout vkPipelineLayout = default(VkPipelineLayout);
			VulkanNative.vkCreatePipelineLayout(context.VkDevice, &vkPipelineLayoutCreateInfo, null, &vkPipelineLayout);
			NativePipelineLayout = vkPipelineLayout;
			List<VkPipelineShaderStageCreateInfo> list = new List<VkPipelineShaderStageCreateInfo>();
			List<String> list2 = new List<String>();
			if (description.Shaders.RayGenerationShader != null)
			{
				VKShader vKShader = description.Shaders.RayGenerationShader as VKShader;
				list.Add(vKShader.ShaderStateInfo);
				list2.Add(vKShader.Description.EntryPoint);
			}
			if (description.Shaders.MissShader != null)
			{
				for (int32 j = 0; j < description.Shaders.MissShader.Count; j++)
				{
					VKShader vKShader2 = description.Shaders.MissShader[j] as VKShader;
					list.Add(vKShader2.ShaderStateInfo);
					list2.Add(vKShader2.Description.EntryPoint);
				}
			}
			if (description.Shaders.ClosestHitShader != null)
			{
				for (int32 k = 0; k < description.Shaders.ClosestHitShader.Count; k++)
				{
					VKShader vKShader3 = description.Shaders.ClosestHitShader[k] as VKShader;
					list.Add(vKShader3.ShaderStateInfo);
					list2.Add(vKShader3.Description.EntryPoint);
				}
			}
			if (description.Shaders.AnyHitShader != null)
			{
				for (int32 l = 0; l < description.Shaders.AnyHitShader.Count; l++)
				{
					VKShader vKShader4 = description.Shaders.AnyHitShader[l] as VKShader;
					list.Add(vKShader4.ShaderStateInfo);
					list2.Add(vKShader4.Description.EntryPoint);
				}
			}
			if (description.Shaders.IntersectionShader != null)
			{
				for (int32 m = 0; m < description.Shaders.IntersectionShader.Count; m++)
				{
					VKShader vKShader5 = description.Shaders.IntersectionShader[m] as VKShader;
					list.Add(vKShader5.ShaderStateInfo);
					list2.Add(vKShader5.Description.EntryPoint);
				}
			}
			VkPipelineShaderStageCreateInfo* ptr2 = scope VkPipelineShaderStageCreateInfo[list.Count]*;
			for (int32 n = 0; n < list.Count; n++)
			{
				ptr2[n] = list[n];
			}
			VkRayTracingShaderGroupCreateInfoKHR* ptr3 = scope VkRayTracingShaderGroupCreateInfoKHR[description.HitGroups.Count]*;
			for (int32 num = 0; num < description.HitGroups.Count; num++)
			{
				HitGroupDescription hitGroupDescription = description.HitGroups[num];
				VkRayTracingShaderGroupCreateInfoKHR vkRayTracingShaderGroupCreateInfoKHR = VkRayTracingShaderGroupCreateInfoKHR
				{
					sType = VkStructureType.VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_KHR
				};
				switch (hitGroupDescription.Type)
				{
				case HitGroupDescription.HitGroupType.Triangles:
					vkRayTracingShaderGroupCreateInfoKHR.type = VkRayTracingShaderGroupTypeKHR.VK_RAY_TRACING_SHADER_GROUP_TYPE_TRIANGLES_HIT_GROUP_KHR;
					break;
				case HitGroupDescription.HitGroupType.Procedural:
					vkRayTracingShaderGroupCreateInfoKHR.type = VkRayTracingShaderGroupTypeKHR.VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR;
					break;
				default:
					vkRayTracingShaderGroupCreateInfoKHR.type = VkRayTracingShaderGroupTypeKHR.VK_RAY_TRACING_SHADER_GROUP_TYPE_GENERAL_KHR;
					break;
				}
				vkRayTracingShaderGroupCreateInfoKHR.generalShader = ((hitGroupDescription.GeneralEntryPoint != null) ? ((uint32)list2.IndexOf(hitGroupDescription.GeneralEntryPoint)) : uint32.MaxValue);
				vkRayTracingShaderGroupCreateInfoKHR.closestHitShader = ((hitGroupDescription.ClosestHitEntryPoint != null) ? ((uint32)list2.IndexOf(hitGroupDescription.ClosestHitEntryPoint)) : uint32.MaxValue);
				vkRayTracingShaderGroupCreateInfoKHR.anyHitShader = ((hitGroupDescription.AnyHitEntryPoint != null) ? ((uint32)list2.IndexOf(hitGroupDescription.AnyHitEntryPoint)) : uint32.MaxValue);
				vkRayTracingShaderGroupCreateInfoKHR.intersectionShader = ((hitGroupDescription.IntersectionEntryPoint != null) ? ((uint32)list2.IndexOf(hitGroupDescription.IntersectionEntryPoint)) : uint32.MaxValue);
				ptr3[num] = vkRayTracingShaderGroupCreateInfoKHR;
			}
			VkRayTracingPipelineCreateInfoKHR vkRayTracingPipelineCreateInfoKHR = VkRayTracingPipelineCreateInfoKHR
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_CREATE_INFO_KHR,
				stageCount = (uint32)list.Count,
				pStages = ptr2,
				groupCount = (uint32)description.HitGroups.Count,
				pGroups = ptr3,
				maxPipelineRayRecursionDepth = description.MaxTraceRecursionDepth,
				layout = vkPipelineLayout
			};
			VkPipeline nativePipeline = default(VkPipeline);
			VulkanNative.vkCreateRayTracingPipelinesKHR(context.VkDevice, VkDeferredOperationKHR.Null, VkPipelineCache.Null, 1u, &vkRayTracingPipelineCreateInfoKHR, null, &nativePipeline);
			NativePipeline = nativePipeline;
			CreateShaderBindingTable(context, ref description);
		}

		private void CreateShaderBindingTable(VKGraphicsContext context, ref RaytracingPipelineDescription description)
		{
			shaderBindingTable = new VKShaderTable(context);
			RaytracingShaderStateDescription shaders = description.Shaders;
			String shaderIdentifier = shaders.GetEntryPointByStage(ShaderStages.RayGeneration)[0];
			shaderBindingTable.AddRayGenProgram(shaderIdentifier);
			String[] entryPointByStage = shaders.GetEntryPointByStage(ShaderStages.Miss);
			for (int32 i = 0; i < entryPointByStage.Count; i++)
			{
				shaderBindingTable.AddMissProgram(entryPointByStage[i]);
			}
			HitGroupDescription[] hitGroups = description.HitGroups;
			for (int32 j = 0; j < hitGroups.Count; j++)
			{
				if (hitGroups[j].Type != 0)
				{
					String name = hitGroups[j].Name;
					shaderBindingTable.AddHitGroupProgram(name);
				}
			}
			shaderBindingTable.Generate(NativePipeline);
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
					VulkanNative.vkDestroyPipelineLayout(vkContext.VkDevice, NativePipelineLayout, null);
					VulkanNative.vkDestroyPipeline(vkContext.VkDevice, NativePipeline, null);
				}
				disposed = true;
			}
		}
	}
}
