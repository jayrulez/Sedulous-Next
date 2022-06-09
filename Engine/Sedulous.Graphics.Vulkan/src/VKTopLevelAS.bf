using System;
using Bulkan;
using Sedulous.Graphics.Raytracing;

namespace Sedulous.Graphics.Vulkan
{
	using static Sedulous.Graphics.Vulkan.VKHelpers;
	using static Sedulous.Graphics.Vulkan.VKExtensionsMethods;

	/// <summary>
	/// Vulkan Top Level Acceleration Structure implementation.
	/// </summary>
	public class VKTopLevelAS : TopLevelAS
	{
		/// <summary>
		/// The top level acceleration structure instance.
		/// </summary>
		public VkAccelerationStructureKHR TopLevelAS;

		private uint64 topLevelASHandle;

		private VKRaytracingHelpers.BufferData instanceBuffer;

		private VkBuffer scratchBuffer;

		private VKGraphicsContext vkContext;

		/// <inheritdoc />
		public override void* NativePointer => (void*)(int)topLevelASHandle;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKTopLevelAS" /> class.
		/// </summary>
		/// <param name="context">DirectX12 Context.</param>
		/// <param name="commandBuffer">Command buffer.</param>
		/// <param name="description">Top Level Description.</param>
		public  this(VKGraphicsContext context, VkCommandBuffer commandBuffer, ref TopLevelASDescription description)
			: base(context, ref description)
		{
			vkContext = context;
			VkAccelerationStructureInstanceKHR* ptr = scope VkAccelerationStructureInstanceKHR[description.Instances.Count]*;
			for (int32 i = 0; i < description.Instances.Count; i++)
			{
				AccelerationStructureInstance accelerationStructureInstance = description.Instances[i];
				ptr[i] = VkAccelerationStructureInstanceKHR
				{
					transform = accelerationStructureInstance.Transform4x4.ToTransformMatrix(),
					instanceCustomIndex = accelerationStructureInstance.InstanceID,
					mask = accelerationStructureInstance.InstanceMask,
					instanceShaderBindingTableRecordOffset = accelerationStructureInstance.InstanceContributionToHitGroupIndex,
					flags = accelerationStructureInstance.Flags.ToVulkan(),
					accelerationStructureReference = (uint64)(int64)(int)(accelerationStructureInstance.BottonLevel as VKBottomLevelAS).NativePointer
				};
			}
			instanceBuffer = VKRaytracingHelpers.CreateMappedBuffer(vkContext, (void*)ptr, (uint64)sizeof(VkAccelerationStructureInstanceKHR) * (uint64)description.Instances.Count, VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR);
			VkAccelerationStructureGeometryKHR vkAccelerationStructureGeometryKHR = VkAccelerationStructureGeometryKHR
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
				flags = VkGeometryFlagsKHR.VK_GEOMETRY_OPAQUE_BIT_KHR,
				geometryType = VkGeometryTypeKHR.VK_GEOMETRY_TYPE_INSTANCES_KHR,
				geometry = VkAccelerationStructureGeometryDataKHR
				{
					instances = VkAccelerationStructureGeometryInstancesDataKHR
					{
						sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR,
						arrayOfPointers = false,
						data = VkDeviceOrHostAddressConstKHR
						{
							deviceAddress = instanceBuffer.Buffer.GetBufferAddress(vkContext.VkDevice)
						}
					}
				}
			};
			VkAccelerationStructureBuildGeometryInfoKHR vkAccelerationStructureBuildGeometryInfoKHR =  VkAccelerationStructureBuildGeometryInfoKHR
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
				type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR,
				mode = VkBuildAccelerationStructureModeKHR.VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR,
				flags = description.Flags.ToVulkan(),
				geometryCount = 1u,
				pGeometries = &vkAccelerationStructureGeometryKHR
			};
			VkAccelerationStructureBuildGeometryInfoKHR vkAccelerationStructureBuildGeometryInfoKHR2 = vkAccelerationStructureBuildGeometryInfoKHR;
			VkAccelerationStructureBuildRangeInfoKHR* ptr2 = scope VkAccelerationStructureBuildRangeInfoKHR[1]*;
			ptr2.primitiveCount = (uint32)description.Instances.Count;
			ptr2.primitiveOffset = description.Offset;
			ptr2.firstVertex = 0u;
			ptr2.transformOffset = 0u;
			uint32 num = (uint32)description.Instances.Count;
			VkAccelerationStructureBuildSizesInfoKHR vkAccelerationStructureBuildSizesInfoKHR = default(VkAccelerationStructureBuildSizesInfoKHR);
			vkAccelerationStructureBuildSizesInfoKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR;
			VulkanNative.vkGetAccelerationStructureBuildSizesKHR(vkContext.VkDevice, VkAccelerationStructureBuildTypeKHR.VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR, &vkAccelerationStructureBuildGeometryInfoKHR2, &num, &vkAccelerationStructureBuildSizesInfoKHR);
			VkBuffer buffer = VKRaytracingHelpers.CreateBuffer(vkContext, vkAccelerationStructureBuildSizesInfoKHR.accelerationStructureSize, VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR).Buffer;
			VkAccelerationStructureCreateInfoKHR vkAccelerationStructureCreateInfoKHR = VkAccelerationStructureCreateInfoKHR
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_KHR,
				buffer = buffer,
				size = vkAccelerationStructureBuildSizesInfoKHR.accelerationStructureSize,
				type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR
			};
			VkAccelerationStructureKHR topLevelAS = default(VkAccelerationStructureKHR);
			VulkanNative.vkCreateAccelerationStructureKHR(vkContext.VkDevice, &vkAccelerationStructureCreateInfoKHR, null, &topLevelAS);
			TopLevelAS = topLevelAS;
			topLevelASHandle = TopLevelAS.GetAccelerationStructureAddress(vkContext.VkDevice);
			scratchBuffer = VKRaytracingHelpers.CreateBuffer(vkContext, vkAccelerationStructureBuildSizesInfoKHR.buildScratchSize, VkBufferUsageFlags.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT).Buffer;
			vkAccelerationStructureBuildGeometryInfoKHR = VkAccelerationStructureBuildGeometryInfoKHR
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
				type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR,
				flags = description.Flags.ToVulkan(),
				dstAccelerationStructure = TopLevelAS,
				geometryCount = 1u,
				pGeometries = &vkAccelerationStructureGeometryKHR,
				scratchData = VkDeviceOrHostAddressKHR
				{
					deviceAddress = scratchBuffer.GetBufferAddress(vkContext.VkDevice)
				}
			};
			VkAccelerationStructureBuildGeometryInfoKHR vkAccelerationStructureBuildGeometryInfoKHR3 = vkAccelerationStructureBuildGeometryInfoKHR;
			VulkanNative.vkCmdBuildAccelerationStructuresKHR(commandBuffer, vkAccelerationStructureBuildGeometryInfoKHR3.geometryCount, &vkAccelerationStructureBuildGeometryInfoKHR3, &ptr2);
			VkMemoryBarrier vkMemoryBarrier = VkMemoryBarrier
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_BARRIER,
				pNext = null,
				srcAccessMask = (VkAccessFlags.VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR | VkAccessFlags.VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR),
				dstAccessMask = (VkAccessFlags.VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR | VkAccessFlags.VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR)
			};
			VulkanNative.vkCmdPipelineBarrier(commandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR, VkPipelineStageFlags.VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR, VkDependencyFlags.None, 1u, &vkMemoryBarrier, 0u, null, 0u, null);
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.Vulkan.VKTopLevelAS" /> class.
		/// </summary>
		/// <param name="commandBuffer">Command Buffer instance.</param>
		/// <param name="description">New top level description.</param>
		public  void UpdateAccelerationStructure(VkCommandBuffer commandBuffer, ref TopLevelASDescription description)
		{
			Description = description;
			VkAccelerationStructureInstanceKHR[] array = scope VkAccelerationStructureInstanceKHR[description.Instances.Count];
			for (int32 i = 0; i < description.Instances.Count; i++)
			{
				AccelerationStructureInstance accelerationStructureInstance = description.Instances[i];
				VkAccelerationStructureInstanceKHR vkAccelerationStructureInstanceKHR = default(VkAccelerationStructureInstanceKHR);
				vkAccelerationStructureInstanceKHR.transform = accelerationStructureInstance.Transform4x4.ToTransformMatrix();
				vkAccelerationStructureInstanceKHR.instanceCustomIndex = accelerationStructureInstance.InstanceID;
				vkAccelerationStructureInstanceKHR.mask = accelerationStructureInstance.InstanceMask;
				vkAccelerationStructureInstanceKHR.instanceShaderBindingTableRecordOffset = accelerationStructureInstance.InstanceContributionToHitGroupIndex;
				vkAccelerationStructureInstanceKHR.flags = accelerationStructureInstance.Flags.ToVulkan();
				vkAccelerationStructureInstanceKHR.accelerationStructureReference = (uint64)(int)(accelerationStructureInstance.BottonLevel as VKBottomLevelAS).NativePointer;
				array[i] = vkAccelerationStructureInstanceKHR;
			}
			uint32 num = (uint32)(sizeof(VkAccelerationStructureInstanceKHR) * array.Count);
			void* destination = default(void*);
			VulkanNative.vkMapMemory(vkContext.VkDevice, instanceBuffer.Memory, 0uL, num, 0u, &destination);
			Internal.MemCpy(destination, (void*)array.Ptr, num);
			VulkanNative.vkUnmapMemory(vkContext.VkDevice, instanceBuffer.Memory);
			VkAccelerationStructureGeometryKHR vkAccelerationStructureGeometryKHR = default(VkAccelerationStructureGeometryKHR);
			vkAccelerationStructureGeometryKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR;
			vkAccelerationStructureGeometryKHR.flags = VkGeometryFlagsKHR.VK_GEOMETRY_OPAQUE_BIT_KHR;
			vkAccelerationStructureGeometryKHR.geometryType = VkGeometryTypeKHR.VK_GEOMETRY_TYPE_INSTANCES_KHR;
			vkAccelerationStructureGeometryKHR.geometry = VkAccelerationStructureGeometryDataKHR
			{
				instances = VkAccelerationStructureGeometryInstancesDataKHR
				{
					sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR,
					arrayOfPointers = false,
					data = VkDeviceOrHostAddressConstKHR
					{
						deviceAddress = instanceBuffer.Buffer.GetBufferAddress(vkContext.VkDevice)
					}
				}
			};
			VkAccelerationStructureGeometryKHR vkAccelerationStructureGeometryKHR2 = vkAccelerationStructureGeometryKHR;
			VkAccelerationStructureBuildGeometryInfoKHR vkAccelerationStructureBuildGeometryInfoKHR = default(VkAccelerationStructureBuildGeometryInfoKHR);
			vkAccelerationStructureBuildGeometryInfoKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR;
			vkAccelerationStructureBuildGeometryInfoKHR.type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR;
			vkAccelerationStructureBuildGeometryInfoKHR.flags = description.Flags.ToVulkan();
			vkAccelerationStructureBuildGeometryInfoKHR.mode = VkBuildAccelerationStructureModeKHR.VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR;
			vkAccelerationStructureBuildGeometryInfoKHR.dstAccelerationStructure = TopLevelAS;
			vkAccelerationStructureBuildGeometryInfoKHR.srcAccelerationStructure = TopLevelAS;
			vkAccelerationStructureBuildGeometryInfoKHR.geometryCount = 1u;
			vkAccelerationStructureBuildGeometryInfoKHR.pGeometries = &vkAccelerationStructureGeometryKHR2;
			vkAccelerationStructureBuildGeometryInfoKHR.scratchData = VkDeviceOrHostAddressKHR
			{
				deviceAddress = scratchBuffer.GetBufferAddress(vkContext.VkDevice)
			};
			VkAccelerationStructureBuildGeometryInfoKHR vkAccelerationStructureBuildGeometryInfoKHR2 = vkAccelerationStructureBuildGeometryInfoKHR;
			VkAccelerationStructureBuildRangeInfoKHR* ptr = scope VkAccelerationStructureBuildRangeInfoKHR[1]*;
			ptr.primitiveCount = (uint32)description.Instances.Count;
			ptr.primitiveOffset = description.Offset;
			ptr.firstVertex = 0u;
			ptr.transformOffset = 0u;
			VulkanNative.vkCmdBuildAccelerationStructuresKHR(commandBuffer, vkAccelerationStructureBuildGeometryInfoKHR2.geometryCount, &vkAccelerationStructureBuildGeometryInfoKHR2, &ptr);
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
					VulkanNative.vkDestroyAccelerationStructureKHR(vkContext.VkDevice, TopLevelAS, null);
				}
				disposed = true;
			}
		}
	}
}
