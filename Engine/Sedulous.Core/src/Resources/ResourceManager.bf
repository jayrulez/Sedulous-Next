using System;
namespace Sedulous.Core.Resources;

abstract class ResourceManager : RefCounted
{
	public this(ResourceSystem resourceSystem)
	{
		ResourceSystem = resourceSystem;
	}

	public readonly ResourceSystem ResourceSystem { get; private set; }
	public abstract Type ResourceType { get; }
	public virtual void Update() => void();
	public virtual void UnloadAllResources() => void();
}

abstract class ResourceManager<T> : ResourceManager where T : Resource
{
	public override Type ResourceType => typeof(T);

	public this(ResourceSystem resourceSystem) : base(resourceSystem)
	{
	}

	public abstract T Load(StringView path);
}