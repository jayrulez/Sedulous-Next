using Sedulous.Core.Resources;
using System;
namespace Sedulous.Renderer.Resources;

class MaterialResourceManager : ResourceManager<MaterialResource>
{
	public override MaterialResource Load(StringView path)
	{
		return default;
	}
}