using System;
using Bulkan;
using Sedulous.Graphics;
using System.Collections;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics;

	using static Sedulous.Graphics.Vulkan.VKExtensionsMethods;

	/// <summary>
	/// This class represents a native pipelineState on Vulkan.
	/// </summary>
	public class VKGraphicsPipelineState : GraphicsPipelineState
	{
		/// <summary>
		/// The Vulkan native pipeline struct.
		/// </summary>
		public VkPipeline NativePipeline;

		/// <summary>
		/// The Vulkan native pipeline layout struct.
		/// </summary>
		public VkPipelineLayout NativePipelineLayout;

		internal bool ScissorEnabled;

		private VkRenderPass renderPass;

		private VKGraphicsContext vkContext;

		private String name;

		private bool disposed;

		private VkSampleCountFlags sampleCount;

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
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKGraphicsPipelineState" /> class.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="description">The graphics pipeline state description.</param>
		public  this(VKGraphicsContext context, ref GraphicsPipelineDescription description)
			: base(ref description)
		{
			vkContext = context;
			VkGraphicsPipelineCreateInfo vkGraphicsPipelineCreateInfo =  VkGraphicsPipelineCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO
			};
			VkPipelineRasterizationStateCreateInfo vkPipelineRasterizationStateCreateInfo =  VkPipelineRasterizationStateCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO
			};
			bool flag = description.RenderStates.RasterizerState.FrontCounterClockwise ^ !context.ClipSpaceYInvertedSupported;
			vkPipelineRasterizationStateCreateInfo.cullMode = description.RenderStates.RasterizerState.CullMode.ToVulkan();
			vkPipelineRasterizationStateCreateInfo.polygonMode = description.RenderStates.RasterizerState.FillMode.ToVulkan();
			vkPipelineRasterizationStateCreateInfo.frontFace = ((!flag) ? VkFrontFace.VK_FRONT_FACE_CLOCKWISE : VkFrontFace.VK_FRONT_FACE_COUNTER_CLOCKWISE);
			vkPipelineRasterizationStateCreateInfo.lineWidth = 1f;
			vkPipelineRasterizationStateCreateInfo.depthBiasEnable = true;
			vkPipelineRasterizationStateCreateInfo.depthBiasConstantFactor = description.RenderStates.RasterizerState.DepthBias;
			vkPipelineRasterizationStateCreateInfo.depthBiasSlopeFactor = description.RenderStates.RasterizerState.SlopeScaledDepthBias;
			vkPipelineRasterizationStateCreateInfo.depthBiasClamp = description.RenderStates.RasterizerState.DepthBiasClamp;
			vkPipelineRasterizationStateCreateInfo.depthClampEnable = !description.RenderStates.RasterizerState.DepthClipEnable;
			vkPipelineRasterizationStateCreateInfo.rasterizerDiscardEnable = false;
			ScissorEnabled = description.RenderStates.RasterizerState.ScissorEnable;
			vkGraphicsPipelineCreateInfo.pRasterizationState = &vkPipelineRasterizationStateCreateInfo;
			int num = description.Outputs.ColorAttachments.Count;
			VkPipelineColorBlendAttachmentState* ptr = scope VkPipelineColorBlendAttachmentState[num]*;
			BlendStateRenderTargetDescription renderTarget = description.RenderStates.BlendState.RenderTarget0;
			BlendStateRenderTargetDescription* ptr2 = &renderTarget;
			for (int i = 0; i < num; i++)
			{
				ptr[i] = VkPipelineColorBlendAttachmentState
				{
					blendEnable = ptr2.BlendEnable,
					alphaBlendOp = ptr2.BlendOperationAlpha.ToVulkan(),
					colorBlendOp = ptr2.BlendOperationColor.ToVulkan(),
					srcColorBlendFactor = ptr2.SourceBlendColor.ToVulkan(),
					dstColorBlendFactor = ptr2.DestinationBlendColor.ToVulkan(),
					srcAlphaBlendFactor = ptr2.SourceBlendAlpha.ToVulkan(),
					dstAlphaBlendFactor = ptr2.DestinationBlendAlpha.ToVulkan(),
					colorWriteMask = ptr2.ColorWriteChannels.ToVulkan()
				};
				if (description.RenderStates.BlendState.IndependentBlendEnable)
				{
					ptr2++;
				}
			}
			VkPipelineColorBlendStateCreateInfo vkPipelineColorBlendStateCreateInfo = VkPipelineColorBlendStateCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
				attachmentCount = (uint32)num,
				pAttachments = ptr
			};
			if (description.RenderStates.BlendFactor.HasValue)
			{
				vkPipelineColorBlendStateCreateInfo.blendConstants[0] = description.RenderStates.BlendFactor.Value.X;
				vkPipelineColorBlendStateCreateInfo.blendConstants[1] = description.RenderStates.BlendFactor.Value.Y;
				vkPipelineColorBlendStateCreateInfo.blendConstants[2] = description.RenderStates.BlendFactor.Value.Z;
				vkPipelineColorBlendStateCreateInfo.blendConstants[3] = description.RenderStates.BlendFactor.Value.W;
			}
			vkGraphicsPipelineCreateInfo.pColorBlendState = &vkPipelineColorBlendStateCreateInfo;
			VkPipelineDepthStencilStateCreateInfo vkPipelineDepthStencilStateCreateInfo = VkPipelineDepthStencilStateCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO,
				depthTestEnable = description.RenderStates.DepthStencilState.DepthEnable,
				depthWriteEnable = description.RenderStates.DepthStencilState.DepthWriteMask,
				depthCompareOp = description.RenderStates.DepthStencilState.DepthFunction.ToVulkan(),
				stencilTestEnable = description.RenderStates.DepthStencilState.StencilEnable,
				minDepthBounds = 0f,
				maxDepthBounds = 1f,
				front = .()
				{
					compareOp = description.RenderStates.DepthStencilState.FrontFace.StencilFunction.ToVulkan(),
					depthFailOp = description.RenderStates.DepthStencilState.FrontFace.StencilDepthFailOperation.ToVulkan(),
					failOp = description.RenderStates.DepthStencilState.FrontFace.StencilFailOperation.ToVulkan(),
					passOp = description.RenderStates.DepthStencilState.FrontFace.StencilPassOperation.ToVulkan(),
					compareMask = description.RenderStates.DepthStencilState.StencilReadMask,
					writeMask = description.RenderStates.DepthStencilState.StencilWriteMask,
					reference = (uint32)description.RenderStates.StencilReference
				},
				back = .()
				{
					compareOp = description.RenderStates.DepthStencilState.BackFace.StencilFunction.ToVulkan(),
					depthFailOp = description.RenderStates.DepthStencilState.BackFace.StencilDepthFailOperation.ToVulkan(),
					failOp = description.RenderStates.DepthStencilState.BackFace.StencilFailOperation.ToVulkan(),
					passOp = description.RenderStates.DepthStencilState.BackFace.StencilPassOperation.ToVulkan(),
					compareMask = description.RenderStates.DepthStencilState.StencilReadMask,
					writeMask = description.RenderStates.DepthStencilState.StencilWriteMask,
					reference = (uint32)description.RenderStates.StencilReference
				}
			};
			vkGraphicsPipelineCreateInfo.pDepthStencilState = &vkPipelineDepthStencilStateCreateInfo;
			VkPipelineDynamicStateCreateInfo vkPipelineDynamicStateCreateInfo = VkPipelineDynamicStateCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO
			};
			VkDynamicState* ptr3 = scope VkDynamicState[2]*;
			*ptr3 = VkDynamicState.VK_DYNAMIC_STATE_VIEWPORT;
			ptr3[1] = VkDynamicState.VK_DYNAMIC_STATE_SCISSOR;
			vkPipelineDynamicStateCreateInfo.dynamicStateCount = 2u;
			vkPipelineDynamicStateCreateInfo.pDynamicStates = ptr3;
			vkGraphicsPipelineCreateInfo.pDynamicState = &vkPipelineDynamicStateCreateInfo;
			VkPipelineMultisampleStateCreateInfo vkPipelineMultisampleStateCreateInfo = VkPipelineMultisampleStateCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO
			};
			sampleCount = description.Outputs.SampleCount.ToVulkan();
			vkPipelineMultisampleStateCreateInfo.rasterizationSamples = sampleCount;
			vkGraphicsPipelineCreateInfo.pMultisampleState = &vkPipelineMultisampleStateCreateInfo;
			VkPipelineInputAssemblyStateCreateInfo vkPipelineInputAssemblyStateCreateInfo = VkPipelineInputAssemblyStateCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO
			};
			if (description.PrimitiveTopology >= PrimitiveTopology.Patch_List)
			{
				uint32 patchControlPoints = (uint32)(description.PrimitiveTopology - 33 + 1);
				VkPipelineTessellationStateCreateInfo vkPipelineTessellationStateCreateInfo = VkPipelineTessellationStateCreateInfo
				{
					sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_STATE_CREATE_INFO,
					patchControlPoints = patchControlPoints
				};
				vkPipelineInputAssemblyStateCreateInfo.topology = VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_PATCH_LIST;
				vkGraphicsPipelineCreateInfo.pTessellationState = &vkPipelineTessellationStateCreateInfo;
			}
			else
			{
				vkPipelineInputAssemblyStateCreateInfo.topology = description.PrimitiveTopology.ToVulkan();
			}
			vkGraphicsPipelineCreateInfo.pInputAssemblyState = &vkPipelineInputAssemblyStateCreateInfo;
			List<VkPipelineShaderStageCreateInfo> list = new List<VkPipelineShaderStageCreateInfo>();
			if (description.Shaders.VertexShader != null)
			{
				VKShader vKShader = description.Shaders.VertexShader as VKShader;
				list.Add(vKShader.ShaderStateInfo);
			}
			if (description.Shaders.HullShader != null)
			{
				VKShader vKShader2 = description.Shaders.HullShader as VKShader;
				list.Add(vKShader2.ShaderStateInfo);
			}
			if (description.Shaders.DomainShader != null)
			{
				VKShader vKShader3 = description.Shaders.DomainShader as VKShader;
				list.Add(vKShader3.ShaderStateInfo);
			}
			if (description.Shaders.GeometryShader != null)
			{
				VKShader vKShader4 = description.Shaders.GeometryShader as VKShader;
				list.Add(vKShader4.ShaderStateInfo);
			}
			if (description.Shaders.PixelShader != null)
			{
				VKShader vKShader5 = description.Shaders.PixelShader as VKShader;
				list.Add(vKShader5.ShaderStateInfo);
			}
			VkPipelineShaderStageCreateInfo* ptr4 = scope VkPipelineShaderStageCreateInfo[list.Count]*;
			for (int32 j = 0; j < list.Count; j++)
			{
				ptr4[j] = list[j];
			}
			vkGraphicsPipelineCreateInfo.stageCount = (uint32)list.Count;
			vkGraphicsPipelineCreateInfo.pStages = ptr4;
			InputLayouts shaderInputLayout = description.Shaders.ShaderInputLayout;
			int32 num2 = ((description.InputLayouts != null) ? (.)description.InputLayouts.LayoutElements.Count : 0);
			int32 num3 = 0;
			if (shaderInputLayout != null && shaderInputLayout.LayoutElements.Count > 0)
			{
				num3 = (.)shaderInputLayout.LayoutElements[0].Elements.Count;
			}
			else if (description.InputLayouts != null)
			{
				List<LayoutDescription> layoutElements = description.InputLayouts.LayoutElements;
				for (int32 k = 0; k < layoutElements.Count; k++)
				{
					num3 += (.)layoutElements[k].Elements.Count;
				}
			}
			VkVertexInputBindingDescription* ptr5 = scope VkVertexInputBindingDescription[num2]*;
			VkVertexInputAttributeDescription* ptr6 = scope VkVertexInputAttributeDescription[num3]*;
			int32 num4 = 0;
			int32 num5 = 0;
			for (uint32 num6 = 0u; num6 < description.InputLayouts?.LayoutElements.Count; num6++)
			{
				LayoutDescription layoutDescription = description.InputLayouts.LayoutElements[(int32)num6];
				ptr5[num6] = VkVertexInputBindingDescription
				{
					binding = num6,
					inputRate = ((layoutDescription.StepRate != 0) ? VkVertexInputRate.VK_VERTEX_INPUT_RATE_INSTANCE : VkVertexInputRate.VK_VERTEX_INPUT_RATE_VERTEX),
					stride = layoutDescription.Stride
				};
				for (int32 l = 0; l < layoutDescription.Elements.Count; l++)
				{
					ElementDescription elementDescription = layoutDescription.Elements[l];
					VkVertexInputAttributeDescription vkVertexInputAttributeDescription;
					if (shaderInputLayout != null)
					{
						if (shaderInputLayout.TryGetSlot(elementDescription.Semantic, elementDescription.SemanticIndex, var slot))
						{
							VkVertexInputAttributeDescription* intPtr = ptr6 + num4++;
							vkVertexInputAttributeDescription = VkVertexInputAttributeDescription
							{
								format = elementDescription.Format.ToVulkan(),
								binding = num6,
								location = slot,
								offset = (uint32)elementDescription.Offset
							};
							*intPtr = vkVertexInputAttributeDescription;
						}
					}
					else
					{
						VkVertexInputAttributeDescription* intPtr2 = ptr6 + num4++;
						vkVertexInputAttributeDescription = VkVertexInputAttributeDescription
						{
							format = elementDescription.Format.ToVulkan(),
							binding = num6,
							location = (uint32)(num5 + l),
							offset = (uint32)elementDescription.Offset
						};
						*intPtr2 = vkVertexInputAttributeDescription;
					}
				}
				num5 += (.)layoutDescription.Elements.Count;
			}
			VkPipelineVertexInputStateCreateInfo vkPipelineVertexInputStateCreateInfo = VkPipelineVertexInputStateCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
				vertexBindingDescriptionCount = (uint32)num2,
				pVertexBindingDescriptions = ptr5,
				vertexAttributeDescriptionCount = (uint32)num3,
				pVertexAttributeDescriptions = ptr6
			};
			vkGraphicsPipelineCreateInfo.pVertexInputState = &vkPipelineVertexInputStateCreateInfo;
			VkPipelineViewportStateCreateInfo vkPipelineViewportStateCreateInfo = VkPipelineViewportStateCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO,
				viewportCount = 1u,
				scissorCount = 1u
			};
			vkGraphicsPipelineCreateInfo.pViewportState = &vkPipelineViewportStateCreateInfo;
			VkPipelineLayoutCreateInfo vkPipelineLayoutCreateInfo = VkPipelineLayoutCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO
			};
			if (description.ResourceLayouts != null)
			{
				VkDescriptorSetLayout* ptr7 = scope VkDescriptorSetLayout[description.ResourceLayouts.Count]*;
				for (int32 m = 0; m < description.ResourceLayouts.Count; m++)
				{
					VKResourceLayout vKResourceLayout = description.ResourceLayouts[m] as VKResourceLayout;
					ptr7[m] = vKResourceLayout.DescriptorSetLayout;
				}
				vkPipelineLayoutCreateInfo.setLayoutCount = (uint32)description.ResourceLayouts.Count;
				vkPipelineLayoutCreateInfo.pSetLayouts = ptr7;
			}
			VkPipelineLayout nativePipelineLayout = default(VkPipelineLayout);
			VulkanNative.vkCreatePipelineLayout(context.VkDevice, &vkPipelineLayoutCreateInfo, null, &nativePipelineLayout);
			NativePipelineLayout = nativePipelineLayout;
			vkGraphicsPipelineCreateInfo.layout = NativePipelineLayout;
			renderPass = CreateCompatibilityRenderPass(description.Outputs);
			vkGraphicsPipelineCreateInfo.renderPass = renderPass;
			VkPipeline nativePipeline = default(VkPipeline);
			VulkanNative.vkCreateGraphicsPipelines(context.VkDevice, VkPipelineCache.Null, 1u, &vkGraphicsPipelineCreateInfo, null, &nativePipeline);
			NativePipeline = nativePipeline;
		}

		private  VkRenderPass CreateCompatibilityRenderPass(OutputDescription outputs)
		{
			VkAttachmentLoadOp loadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE;
			int num = (outputs.DepthAttachment.HasValue ? (outputs.ColorAttachments.Count + 1) : outputs.ColorAttachments.Count) * 2;
			VkAttachmentDescription* ptr = scope VkAttachmentDescription[num]*;
			VkAttachmentReference* ptr2 = scope VkAttachmentReference[outputs.ColorAttachments.Count]*;
			VkAttachmentReference* ptr3 = scope VkAttachmentReference[outputs.ColorAttachments.Count]*;
			uint32 num2 = 0u;
			uint32 num3 = 0u;
			uint32 num4 = 0u;
			for (int32 i = 0; i < outputs.ColorAttachments.Count; i++)
			{
				ref OutputAttachmentDescription reference = ref outputs.ColorAttachments[i];
				VkFormat format = reference.Format.ToVulkan(/*depthFormat:*/ false);
				var (vkAttachmentDescription, vkAttachmentReference) = CreateAttachment(format, sampleCount, num2, loadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
				ptr[num2++] = vkAttachmentDescription;
				ptr2[num3++] = vkAttachmentReference;
				if (reference.ResolveMSAA)
				{
					var (vkAttachmentDescription2, vkAttachmentReference2) = CreateAttachment(format, sampleCount, num2, loadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
					ptr[num2++] = vkAttachmentDescription2;
					ptr3[num4++] = vkAttachmentReference2;
				}
			}
			bool flag = false;
			VkAttachmentReference vkAttachmentReference4 = default(VkAttachmentReference);
			if (outputs.DepthAttachment.HasValue)
			{
				OutputAttachmentDescription value = outputs.DepthAttachment.Value;
				VkFormat format2 = value.Format.ToVulkan(/*depthFormat:*/ true);
				if (value.Format == PixelFormat.D24_UNorm_S8_UInt || value.Format == PixelFormat.D32_Float_S8X24_UInt)
				{
					flag = true;
				}
				VkAttachmentDescription item = CreateAttachment(format2, sampleCount, num2, loadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, (!flag) ? VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE : VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, isDepth: true).Item1;
				VkAttachmentReference vkAttachmentReference3 = default(VkAttachmentReference);
				vkAttachmentReference3.attachment = num2;
				vkAttachmentReference3.layout = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
				vkAttachmentReference4 = vkAttachmentReference3;
				ptr[num2++] = item;
				if (value.ResolveMSAA)
				{
					VkAttachmentDescription item2 = CreateAttachment(format2, sampleCount, num2, loadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, (!flag) ? VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE : VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, isDepth: true).Item1;
					vkAttachmentReference3 = default(VkAttachmentReference);
					vkAttachmentReference3.attachment = num2;
					vkAttachmentReference3.layout = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
					ptr[num2++] = item2;
				}
			}
			VkSubpassDescription vkSubpassDescription = default(VkSubpassDescription);
			vkSubpassDescription.pipelineBindPoint = VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS;
			VkSubpassDescription vkSubpassDescription2 = vkSubpassDescription;
			if (num3 != 0)
			{
				vkSubpassDescription2.colorAttachmentCount = num3;
				vkSubpassDescription2.pColorAttachments = ptr2;
			}
			uint32 num5 = 1u;
			if (num4 != 0)
			{
				vkSubpassDescription2.pResolveAttachments = ptr3;
				num5++;
			}
			if (outputs.DepthAttachment.HasValue)
			{
				vkSubpassDescription2.pDepthStencilAttachment = &vkAttachmentReference4;
			}
			VkSubpassDependency* ptr4 = scope VkSubpassDependency[(int32)num5]*;
			VkSubpassDependency vkSubpassDependency;
			if (num4 == 0)
			{
				vkSubpassDependency = VkSubpassDependency
				{
					srcSubpass = uint32.MaxValue,
					dstSubpass = 0u,
					srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
					dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
					srcAccessMask = VkAccessFlags.VK_ACCESS_NONE,
					dstAccessMask = (VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT)
				};
				*ptr4 = vkSubpassDependency;
			}
			else
			{
				vkSubpassDependency = VkSubpassDependency
				{
					srcSubpass = uint32.MaxValue,
					dstSubpass = 0u,
					srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
					dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
					srcAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT,
					dstAccessMask = (VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
					dependencyFlags = VkDependencyFlags.VK_DEPENDENCY_BY_REGION_BIT
				};
				*ptr4 = vkSubpassDependency;
				VkSubpassDependency* intPtr = ptr4 + 1;
				vkSubpassDependency = VkSubpassDependency
				{
					srcSubpass = 0u,
					dstSubpass = uint32.MaxValue,
					srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
					dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
					srcAccessMask = (VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
					dstAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT,
					dependencyFlags = VkDependencyFlags.VK_DEPENDENCY_BY_REGION_BIT
				};
				*intPtr = vkSubpassDependency;
			}
			VkRenderPassCreateInfo vkRenderPassCreateInfo = default(VkRenderPassCreateInfo);
			vkRenderPassCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
			vkRenderPassCreateInfo.attachmentCount = num2;
			vkRenderPassCreateInfo.pAttachments = ptr;
			vkRenderPassCreateInfo.subpassCount = 1u;
			vkRenderPassCreateInfo.pSubpasses = &vkSubpassDescription2;
			vkRenderPassCreateInfo.dependencyCount = num5;
			vkRenderPassCreateInfo.pDependencies = ptr4;
			VkRenderPassCreateInfo vkRenderPassCreateInfo2 = vkRenderPassCreateInfo;
			VkRenderPassMultiviewCreateInfo vkRenderPassMultiviewCreateInfo = default(VkRenderPassMultiviewCreateInfo);
			if (outputs.ArraySliceCount > 1)
			{
				uint32 num6 = (uint32)((1 << (int32)outputs.ArraySliceCount) - 1);
				vkRenderPassMultiviewCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_RENDER_PASS_MULTIVIEW_CREATE_INFO;
				vkRenderPassMultiviewCreateInfo.subpassCount = 1u;
				vkRenderPassMultiviewCreateInfo.pViewMasks = &num6;
				vkRenderPassMultiviewCreateInfo.correlationMaskCount = 1u;
				vkRenderPassMultiviewCreateInfo.pCorrelationMasks = &num6;
				vkRenderPassCreateInfo2.pNext = &vkRenderPassMultiviewCreateInfo;
			}
			VkRenderPass result = default(VkRenderPass);
			VulkanNative.vkCreateRenderPass(vkContext.VkDevice, &vkRenderPassCreateInfo2, null, &result);
			return result;
		}

		private (VkAttachmentDescription, VkAttachmentReference) CreateAttachment(VkFormat format, VkSampleCountFlags samples, uint32 index, VkAttachmentLoadOp loadOp, VkAttachmentStoreOp storeOp, VkAttachmentStoreOp stencilStoreOp, VkImageLayout finalLayout, bool isDepth = false)
		{
			VkAttachmentDescription vkAttachmentDescription = default(VkAttachmentDescription);
			vkAttachmentDescription.format = format;
			vkAttachmentDescription.samples = samples;
			vkAttachmentDescription.loadOp = loadOp;
			vkAttachmentDescription.storeOp = storeOp;
			vkAttachmentDescription.stencilLoadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE;
			vkAttachmentDescription.stencilStoreOp = stencilStoreOp;
			vkAttachmentDescription.initialLayout = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED;
			vkAttachmentDescription.finalLayout = finalLayout;
			VkAttachmentDescription item = vkAttachmentDescription;
			VkAttachmentReference item2 = VkAttachmentReference
			{
				attachment = index,
				layout = finalLayout
			};
			return (item, item2);
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
					VulkanNative.vkDestroyRenderPass(vkContext.VkDevice, renderPass, null);
				}
				disposed = true;
			}
		}
	}
}
