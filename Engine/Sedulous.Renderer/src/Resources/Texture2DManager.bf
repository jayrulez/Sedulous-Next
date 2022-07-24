using Sedulous.Core.Assets;
using System;
namespace Sedulous.Renderer.Resources;

class Texture2DManager : AssetManager<Texture2DResource>
{
	public override Texture2DResource Load(StringView path)
	{
		return default;
	}

	public this(AssetSystem resourceSystem) : base(resourceSystem)
	{

	}
}