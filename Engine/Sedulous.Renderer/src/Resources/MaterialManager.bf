using Sedulous.Core.Assets;
using System;
namespace Sedulous.Renderer.Resources;

class MaterialManager : AssetManager<MaterialResource>
{
	public override MaterialResource Load(StringView path)
	{
		return default;
	}

	public this(AssetSystem resourceSystem) : base(resourceSystem)
	{

	}
}