using Sedulous.Foundation.Logging.Abstractions;
using System.Collections;
using System;
using System.IO;
namespace Sedulous.Core.Assets;

class AssetSystem
{
	private readonly Engine mEngine = null;

	private readonly Dictionary<Type, AssetManager> mAssetManagers = new .() ~ delete _;

	private bool mIsRunning = false;

	public ILogger Logger => mEngine.Logger;

	public this(Engine engine)
	{
		mEngine = engine;
	}

	public ~this()
	{
		for ((Type resourceType, AssetManager assetManager) entry in mAssetManagers)
		{
			entry.assetManager.ReleaseRef();
		}
	}

	public void Startup()
	{
		if (mIsRunning)
		{
			Logger.LogError("Startup called on AssetSystem that is already running.");
			return;
		}

		mIsRunning = true;
	}

	public void Shutdown()
	{
		if (!mIsRunning)
		{
			Logger.LogError("Shutdown called on AssetSystem that is not running.");
			return;
		}

		for ((Type resourceType, AssetManager assetManager) entry in mAssetManagers)
		{
			entry.assetManager.UnloadAllAssets();
		}

		mIsRunning = false;
	}

	public void Update()
	{
		for ((Type resourceType, AssetManager assetManager) entry in mAssetManagers)
		{
			entry.assetManager.Update();
		}
	}

	public void AddAssetManager<TAsset, TAssetManager>(TAssetManager assetManager)
		where TAsset : Asset
		where TAssetManager : AssetManager<TAsset>
	{
		if (mAssetManagers.ContainsKey(typeof(TAsset)))
		{
			Logger.LogError("AssetManager already registered for resource type '{}'.", typeof(TAsset).GetName(.. scope .()));
			return;
		}
		mAssetManagers[typeof(TAsset)] = assetManager;
		assetManager.AddRef();
	}

	public void AddAssetManager<TAsset, TAssetManager>()
		where TAsset : Asset
		where TAssetManager : AssetManager<TAsset>
	{
		if (mAssetManagers.ContainsKey(typeof(TAsset)))
		{
			Logger.LogError("AssetManager already registered for resource type '{}'.", typeof(TAsset).GetName(.. scope .()));
			return;
		}
		mAssetManagers[typeof(TAsset)] = new TAssetManager(this);
	}

	public AssetManager<T> GetResourceManager<T>()
		where T : Asset
	{
		if (mAssetManagers.ContainsKey(typeof(T)))
		{
			return (AssetManager<T>)mAssetManagers[typeof(T)];
		}

		return null;
	}
}