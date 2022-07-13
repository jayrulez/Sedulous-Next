using Sedulous.Core.Resources;
using System;
namespace Sedulous.Renderer.Resources;

class Texture2DResourceManager : ResourceManager<Texture2DResource>
{
	public override Texture2DResource Load(StringView path)
	{
		return default;
	}
}