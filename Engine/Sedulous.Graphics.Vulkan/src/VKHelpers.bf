using System;
using System.Diagnostics;
using System.Text;
using Bulkan;
using Sedulous.Graphics;
using Sedulous.Foundation.Mathematics;

namespace Sedulous.Graphics.Vulkan
{
	/// <summary>
	/// Set of Vulkan helpers.
	/// </summary>
	public static class VKHelpers
	{
		/// <summary>
		/// Operating system enum.
		/// </summary>
		public enum OS
		{
			/// <summary>
			/// Windows platform.
			/// </summary>
			Windows,
			/// <summary>
			/// OSX platform.
			/// </summary>
			Linux,
			/// <summary>
			/// Android platform.
			/// </summary>
			Android,
			/// <summary>
			/// MacOS platform.
			/// </summary>
			MacOS,
			/// <summary>
			/// iOS platform.
			/// </summary>
			iOS
		}

		/// <summary>
		/// Get the current Platform.
		/// </summary>
		/// <returns>The platform.</returns>
		public static OS GetCurrentPlatfom()
		{
			if(Environment.OSVersion.Platform == PlatformID.Win32Windows){
				return OS.Windows;
			}
			/*if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
			{
				return OS.Windows;
			}
			if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
			{
				if (RuntimeInformation.OSDescription.Contains("Unix"))
				{
					return OS.Android;
				}
				return OS.Linux;
			}
			if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
			{
				if (RuntimeInformation.OSDescription.Contains("Darwin"))
				{
					return OS.iOS;
				}
				return OS.MacOS;
			}*/
			return OS.Windows;
		}

		/// <summary>
		/// Create a valide Api version uint32.
		/// </summary>
		/// <param name="major">The major.</param>
		/// <param name="minor">The minor.</param>
		/// <param name="patch">The patch.</param>
		/// <returns>Vulkan api version.</returns>
		public static uint32 Version(uint32 major, uint32 minor, uint32 patch)
		{
			return (major << 22) | (minor << 12) | patch;
		}

		/// <summary>
		/// Check errors.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="result">The result of last operation.</param>
		//[Conditional("DEBUG")]
		public static void CheckErrors(GraphicsContext context, VkResult result)
		{
			if (result != 0)
			{
				context.ValidationLayer?.Notify("Vulkan", result.ToString(.. scope .()));
			}
		}

		/// <summary>
		/// Gets the memory type.
		/// </summary>
		/// <param name="memoryProperties">The device memory properties.</param>
		/// <param name="index">The memory index.</param>
		/// <returns>The result memory type.</returns>
		public  static VkMemoryType GetMemoryType(this VkPhysicalDeviceMemoryProperties memoryProperties, uint32 index)
		{
			//return (&memoryProperties.memoryTypes_0)[index];
			return memoryProperties.memoryTypes[index];
		}

		/// <summary>
		/// Find a memory type.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <param name="typeFilter">The filter type.</param>
		/// <param name="properties">The memory properties.</param>
		/// <returns>A value &gt; 0 if everything was ok.</returns>
		public static int32 FindMemoryType(VKGraphicsContext context, uint32 typeFilter, VkMemoryPropertyFlags properties)
		{
			VkPhysicalDeviceMemoryProperties vkPhysicalDeviceMemoryProperties = context.VkPhysicalDeviceMemoryProperties;
			for (int i = 0; i < vkPhysicalDeviceMemoryProperties.memoryTypeCount; i++)
			{
				if ((typeFilter & (1 << i)) != 0L && (vkPhysicalDeviceMemoryProperties.GetMemoryType((uint32)i).propertyFlags & properties) == properties)
				{
					return (.)i;
				}
			}
			context.ValidationLayer?.Notify("Vulkan", "No suitable memory type.");
			return -1;
		}

		/// <summary>
		/// Returns up to requested number of global layer properties.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <returns>The String array of supported layers.</returns>
		public  static void EnumerateInstanceLayers(GraphicsContext context, out String[] layers)
		{
			uint32 layerCount = 0u;
			VulkanNative.vkEnumerateInstanceLayerProperties(&layerCount, null);
			if (layerCount == 0)
			{
				layers = new String[0];
				return;
			}
			layers = new String[layerCount];
			VkLayerProperties* ptr = scope VkLayerProperties[(int32)layerCount]*;
			VulkanNative.vkEnumerateInstanceLayerProperties(&layerCount, ptr);
			for (int i = 0; i < layerCount; i++)
			{
				layers[i] = new String(&ptr[i].layerName);
			}
		}

		/// <summary>
		///  Returns up to requested number of global extension properties.
		/// </summary>
		/// <param name="context">The graphics context.</param>
		/// <returns>A String array of supported extensions.</returns>
		public  static void EnumerateInstanceExtensions(GraphicsContext context, out String[] extensions)
		{
			uint32 extensionCount = 0u;
			VulkanNative.vkEnumerateInstanceExtensionProperties(null, &extensionCount, null);
			if (extensionCount == 0)
			{
				extensions = new String[0];
				return;
			}
			VkExtensionProperties* ptr = scope VkExtensionProperties[(int32)extensionCount]*;
			VulkanNative.vkEnumerateInstanceExtensionProperties(null, &extensionCount, ptr);
			extensions = new String[extensionCount];
			for (int i = 0; i < extensionCount; i++)
			{
				extensions[i] = new String(&ptr[i].extensionName);
			}
		}

		/// <summary>
		/// Gets the bindings offset to avoid overlap.
		/// </summary>
		/// <param name="element">The layout element description.</param>
		/// <returns>The first slop available.</returns>
		public static uint32 GetBinding(LayoutElementDescription element)
		{
			switch (element.Type)
			{
			case ResourceType.ConstantBuffer:
				return element.Slot;
			case ResourceType.StructuredBufferReadWrite: fallthrough;
			case ResourceType.TextureReadWrite:
				return element.Slot + 20;
			case ResourceType.Sampler:
				return element.Slot + 40;
			case ResourceType.StructuredBuffer: fallthrough;
			case ResourceType.Texture: fallthrough;
			case ResourceType.AccelerationStructure:
				return element.Slot + 60;
			default:
				return 0;
			}
		}

		/// <summary>
		/// Convert a Matrix4x4 in a Vulkan transform matrix 3x4.
		/// </summary>
		/// <param name="m">The matrix to convert.</param>
		/// <returns>The Vulkan transform matrix.</returns>
		public static VkTransformMatrixKHR ToTransformMatrix(this Matrix4x4 m)
		{
			VkTransformMatrixKHR result = default(VkTransformMatrixKHR);
			result.matrix[0] = m.M11;
			result.matrix[1] = m.M12;
			result.matrix[2] = m.M13;
			result.matrix[3] = m.M14;
			result.matrix[4] = m.M21;
			result.matrix[5] = m.M22;
			result.matrix[6] = m.M23;
			result.matrix[7] = m.M24;
			result.matrix[8] = m.M31;
			result.matrix[9] = m.M32;
			result.matrix[10] = m.M33;
			result.matrix[11] = m.M34;
			return result;
		}
	}
}
