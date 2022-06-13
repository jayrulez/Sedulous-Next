using System.Diagnostics;
using System;

namespace Sedulous.GAL
{
	using internal Sedulous.GAL;

    internal static class ValidationHelpers
    {
#if !VALIDATE_USAGE
		[SkipCall]
#endif
        internal static void ValidateResourceSet(GraphicsDevice gd, ResourceSetDescription description)
        {
#if VALIDATE_USAGE
            ResourceLayoutElementDescription[] elements = description.Layout.Description.Elements;
            BindableResource[] resources = description.BoundResources;

            if (elements.Count != resources.Count)
            {
                Runtime.FatalError(
                    scope $"The number of resources specified ({resources.Count}) must be equal to the number of resources in the {typeof(ResourceLayout).GetName(.. scope .())}} ({elements.Count}).");
            }

            for (uint32 i = 0; i < elements.Count; i++)
            {
                ValidateResourceKind(elements[i].Kind, resources[i], i);
            }

            for (int i = 0; i < description.Layout.Description.Elements.Count; i++)
            {
                ResourceLayoutElementDescription element = description.Layout.Description.Elements[i];
                if (element.Kind == ResourceKind.UniformBuffer
                    || element.Kind == ResourceKind.StructuredBufferReadOnly
                    || element.Kind == ResourceKind.StructuredBufferReadWrite)
                {
                    DeviceBufferRange range = Util.GetBufferRange(description.BoundResources[i], 0);

                    if (!gd.Features.BufferRangeBinding && (range.Offset != 0 || range.SizeInBytes != range.Buffer.SizeInBytes))
                    {
						//Runtime.FatalError(scope $"The {typeof(DeviceBufferRange).GetFullName( .. scope .())} in slot {i} uses a non-zero offset or less-than-full size, which requires {typeof(GraphicsDeviceFeatures).GetName(.. scope .())}}.{nameof(GraphicsDeviceFeatures.BufferRangeBinding)}.");
                        Runtime.FatalError(scope $"The {typeof(DeviceBufferRange).GetFullName( .. scope .())} in slot {i} uses a non-zero offset or less-than-full size, which requires {typeof(GraphicsDeviceFeatures).GetName(.. scope .())}}..BufferRangeBinding.");
                    }

                    uint32 alignment = element.Kind == ResourceKind.UniformBuffer
                       ? gd.UniformBufferMinOffsetAlignment
                       : gd.StructuredBufferMinOffsetAlignment;

                    if ((range.Offset % alignment) != 0)
                    {
                       Runtime.FatalError(scope $"The {typeof(DeviceBufferRange).GetFullName( .. scope .())} in slot {i} has an invalid offset: {range.Offset}. The offset for this buffer must be a multiple of {alignment}.");
                    }
                }
            }
#endif
        }

#if !VALIDATE_USAGE
		[SkipCall]
#endif
        private static void ValidateResourceKind(ResourceKind kind, BindableResource resource, uint32 slot)
        {
            switch (kind)
            {
                case ResourceKind.UniformBuffer:
                {
                    if (!Util.GetDeviceBuffer(resource, var b)
                        || (b.Usage & BufferUsage.UniformBuffer) == 0)
                    {
						//Runtime.FatalError(scope $"Resource in slot {slot} does not match {typeof(ResourceKind).GetFullName( .. scope .())}.{kind} specified in the {typeof(ResourceLayout).GetName(.. scope .())}}. It must be a {typeof(DeviceBuffer).GetName(.. scope .())}} or {typeof(DeviceBufferRange).GetName(.. scope .())}} with {typeof(BufferUsage).GetName(.. scope .())}}.{nameof(BufferUsage.UniformBuffer)}.");
                        Runtime.FatalError(scope $"Resource in slot {slot} does not match {typeof(ResourceKind).GetFullName( .. scope .())}.{kind} specified in the {typeof(ResourceLayout).GetName(.. scope .())}}. It must be a {typeof(DeviceBuffer).GetName(.. scope .())}} or {typeof(DeviceBufferRange).GetName(.. scope .())}} with {typeof(BufferUsage).GetName(.. scope .())}}..UniformBuffer.");
                    }
                    break;
                }
                case ResourceKind.StructuredBufferReadOnly:
                {
                    if (!Util.GetDeviceBuffer(resource, var b)
                        || (b.Usage & (BufferUsage.StructuredBufferReadOnly | BufferUsage.StructuredBufferReadWrite)) == 0)
                    {
						//Runtime.FatalError(scope $"Resource in slot {slot} does not match {typeof(ResourceKind).GetName(.. scope .())}}.{kind} specified in the {typeof(ResourceLayout).GetName(.. scope .())}}. It must be a {typeof(DeviceBuffer).GetName(.. scope .())}} with {typeof(BufferUsage).GetName(.. scope .())}}.{nameof(BufferUsage.StructuredBufferReadOnly)}.");
                        Runtime.FatalError(scope $"Resource in slot {slot} does not match {typeof(ResourceKind).GetName(.. scope .())}}.{kind} specified in the {typeof(ResourceLayout).GetName(.. scope .())}}. It must be a {typeof(DeviceBuffer).GetName(.. scope .())}} with {typeof(BufferUsage).GetName(.. scope .())}}..StructuredBufferReadOnly.");
                    }
                    break;
                }
                case ResourceKind.StructuredBufferReadWrite:
                {
                    if (!Util.GetDeviceBuffer(resource, var b)
                        || (b.Usage & BufferUsage.StructuredBufferReadWrite) == 0)
                    {
						//Runtime.FatalError(scope $"Resource in slot {slot} does not match {typeof(ResourceKind).GetName(.. scope .())}} specified in the {typeof(ResourceLayout).GetName(.. scope .())}}. It must be a {typeof(DeviceBuffer).GetName(.. scope .())}} with {typeof(BufferUsage).GetName(.. scope .())}}.{nameof(BufferUsage.StructuredBufferReadWrite)}.");
                        Runtime.FatalError(scope $"Resource in slot {slot} does not match {typeof(ResourceKind).GetName(.. scope .())}} specified in the {typeof(ResourceLayout).GetName(.. scope .())}}. It must be a {typeof(DeviceBuffer).GetName(.. scope .())}} with {typeof(BufferUsage).GetName(.. scope .())}}.StructuredBufferReadWrite.");
                    }
                    break;
                }
                case ResourceKind.TextureReadOnly:
                {
                    if (!(var tv = resource as TextureView  && (tv.Target.Usage & TextureUsage.Sampled) != 0)
                        && !(var t = resource as Texture && (t.Usage & TextureUsage.Sampled) != 0))
                    {
						//Runtime.FatalError(scope $"Resource in slot {slot} does not match {typeof(ResourceKind).GetName(.. scope .())}.{kind} specified in the {typeof(ResourceLayout).GetName(.. scope .())}. It must be a {typeof(Texture).GetName(.. scope .())} or {typeof(TextureView).GetName(.. scope .())} whose target has {nameof(TextureUsage)}.{nameof(TextureUsage.Sampled)}.");
                        Runtime.FatalError(scope $"Resource in slot {slot} does not match {typeof(ResourceKind).GetName(.. scope .())}.{kind} specified in the {typeof(ResourceLayout).GetName(.. scope .())}. It must be a {typeof(Texture).GetName(.. scope .())} or {typeof(TextureView).GetName(.. scope .())} whose target has TextureUsage.Sampled.");
                    }
                    break;
                }
                case ResourceKind.TextureReadWrite:
                {
                    if (!(var tv = resource as TextureView && (tv.Target.Usage & TextureUsage.Storage) != 0)
                        && !(var t = resource as Texture && (t.Usage & TextureUsage.Storage) != 0))
                    {
						//Runtime.FatalError(scope $"Resource in slot {slot} does not match {typeof(ResourceKind).GetName(.. scope .())}}.{kind} specified in the {typeof(ResourceLayout).GetName(.. scope .())}}. It must be a {typeof(Texture).GetName(.. scope .())}} or {typeof(TextureView).GetName(.. scope .())}} whose target has {typeof(TextureUsage).GetName(.. scope .())}}.{nameof(TextureUsage.Storage)}.");
                        Runtime.FatalError(scope $"Resource in slot {slot} does not match {typeof(ResourceKind).GetName(.. scope .())}}.{kind} specified in the {typeof(ResourceLayout).GetName(.. scope .())}}. It must be a {typeof(Texture).GetName(.. scope .())}} or {typeof(TextureView).GetName(.. scope .())}} whose target has TextureUsage.Storage.");
                    }
                    break;
                }
                case ResourceKind.Sampler:
                {
                    if ((resource as Sampler) == null)
                    {
                        Runtime.FatalError(
                            scope $"Resource in slot {slot} does not match {typeof(ResourceKind).GetName(.. scope .())}.{kind} specified in the {typeof(ResourceLayout).GetName(.. scope .())}. It must be a {typeof(Sampler).GetName(.. scope .())}.");
                    }
                    break;
                }
                default:
					Runtime.FatalError(scope $"Invalid {typeof(ResourceKind).GetName(.. scope .())}");
            }
        }
    }
}
