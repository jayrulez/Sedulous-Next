using System;
using Bulkan;
using Sedulous.Graphics;

namespace Sedulous.Graphics.Vulkan
{
	using internal Sedulous.Graphics;

	using static Sedulous.Graphics.Vulkan.VKExtensionsMethods;
	using static Sedulous.Graphics.Vulkan.VKHelpers;

	/// <summary>
	/// This class represents a native shader Object on Metal.
	/// </summary>
	public class VKShader : Shader
	{
		/// <summary>
		/// The native vulkan shader Object.
		/// </summary>
		public readonly VkShaderModule ShaderModule;

		private VkPipelineShaderStageCreateInfo? shaderStateInfo;

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
				vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_SHADER_MODULE, ShaderModule.Handle, name);
			}
		}

		/// <summary>
		/// Gets the ShaderStateInfo using in the pipelinestate.
		/// </summary>
		public  VkPipelineShaderStageCreateInfo ShaderStateInfo
		{
			get
			{
				if (!shaderStateInfo.HasValue)
				{
					shaderStateInfo = VkPipelineShaderStageCreateInfo
					{
						sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
						stage = Description.Stage.ToVulkan(),
						module = ShaderModule,
						pName = Description.EntryPoint,
						pSpecializationInfo = null
					};
				}
				return shaderStateInfo.Value;
			}
		}

		/// <inheritdoc />
		public override void* NativePointer => (void*)(int)ShaderModule.Handle;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKShader" /> class.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="description">The shader description.</param>
		public  this(GraphicsContext context, ref ShaderDescription description)
			: base(context, ref description)
		{
			vkContext = Context as VKGraphicsContext;
			VkDevice vkDevice = vkContext.VkDevice;
			VkShaderModuleCreateInfo vkShaderModuleCreateInfo = VkShaderModuleCreateInfo
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
			};
			uint8* pCode = description.ShaderBytes.Ptr;
			{
				vkShaderModuleCreateInfo.codeSize = (uint)description.ShaderBytes.Count;
				vkShaderModuleCreateInfo.pCode = (uint32*)pCode;
				VkShaderModule shaderModule = default(VkShaderModule);
				VulkanNative.vkCreateShaderModule(vkDevice, &vkShaderModuleCreateInfo, null, &shaderModule);
				ShaderModule = shaderModule;
			}
		}

		public ~this()
		{
			OnDestroy();

			VulkanNative.vkDestroyShaderModule(vkContext.VkDevice, ShaderModule, null);
		}
	}
}
