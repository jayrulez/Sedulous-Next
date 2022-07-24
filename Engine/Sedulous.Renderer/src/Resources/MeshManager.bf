using Sedulous.Core.Assets;
using System;
namespace Sedulous.Renderer.Resources;

class MeshManager : AssetManager<MeshResource>
{
	public override MeshResource Load(StringView path)
	{
		return default;
	}

	public this(AssetSystem resourceSystem) : base(resourceSystem)
	{

	}
}