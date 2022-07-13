using Sedulous.Foundation.Logging.Abstractions;
using System.Collections;
using System;
using System.IO;
namespace Sedulous.Core.Resources;

class ResourceSystem
{
	private readonly Engine mEngine = null;

	private readonly Dictionary<Type, ResourceManager> mResourceManagers = new .() ~ delete _;

	private readonly String mResourceDir = new .() ~ delete _;

	private bool mIsRunning = false;

	public ILogger Logger => mEngine.Logger;

	public this(Engine engine, StringView resourceDir)
	{
		mResourceDir.Set(Path.GetFullPath(scope String(resourceDir), .. scope .()));

		mEngine = engine;
	}

	public ~this()
	{
		for ((Type resourceType, ResourceManager resourceManager) entry in mResourceManagers)
		{
			entry.resourceManager.ReleaseRef();
		}
	}

	public void Startup()
	{
		if (mIsRunning)
		{
			Logger.LogError("Startup called on ResourceSystem that is already running.");
			return;
		}

		mIsRunning = true;
	}

	public void Shutdown()
	{
		if (!mIsRunning)
		{
			Logger.LogError("Shutdown called on ResourceSystem that is not running.");
			return;
		}

		for ((Type resourceType, ResourceManager resourceManager) entry in mResourceManagers)
		{
			entry.resourceManager.UnloadAllResources();
		}

		mIsRunning = false;
	}

	public void Update()
	{
		for ((Type resourceType, ResourceManager resourceManager) entry in mResourceManagers)
		{
			entry.resourceManager.Update();
		}
	}

	public void AddResourceManager<TResource, TResourceManager>(TResourceManager resourceManager)
		where TResource : Resource
		where TResourceManager : ResourceManager<TResource>
	{
		if (mResourceManagers.ContainsKey(typeof(TResource)))
		{
			Logger.LogError("ResourceManager already registered for resource type '{}'.", typeof(TResource).GetName(.. scope .()));
			return;
		}
		mResourceManagers[typeof(TResource)] = resourceManager;
		resourceManager.AddRef();
	}

	public ResourceManager<T> GetResourceManager<T>()
		where T : Resource
	{
		if (mResourceManagers.ContainsKey(typeof(T)))
		{
			return (ResourceManager<T>)mResourceManagers[typeof(T)];
		}

		return null;
	}
}