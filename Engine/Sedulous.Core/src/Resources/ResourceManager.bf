using System;
namespace Sedulous.Core.Resources;

abstract class ResourceManager : RefCounted
{
	public this()
	{
	}

	public virtual void Update() => void();
	public virtual void UnloadAllResources() => void();
}

abstract class ResourceManager<T> : ResourceManager where T : Resource
{
	public abstract T Load(StringView path);
}