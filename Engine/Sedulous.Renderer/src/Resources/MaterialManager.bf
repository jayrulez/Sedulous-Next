using Sedulous.Core.Resources;
using System;
namespace Sedulous.Renderer.Resources;

class MaterialManager : ResourceManager<MaterialResource>
{
	public override MaterialResource Load(StringView path)
	{
		return default;
	}

	public this(ResourceSystem resourceSystem) : base(resourceSystem)
	{

	}
}