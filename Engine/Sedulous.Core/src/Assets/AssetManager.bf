using System;
namespace Sedulous.Core.Assets;

abstract class AssetManager : RefCounted
{
	public this(AssetSystem assetSystem)
	{
		AssetSystem = assetSystem;
	}

	public readonly AssetSystem AssetSystem { get; private set; }
	public abstract Type AssetType { get; }
	public virtual void Update() => void();
	public virtual void UnloadAllAssets() => void();
}

abstract class AssetManager<T> : AssetManager where T : Asset
{
	public override Type AssetType => typeof(T);

	public this(AssetSystem assetSystem) : base(assetSystem)
	{
	}

	public abstract T Load(StringView path);
}