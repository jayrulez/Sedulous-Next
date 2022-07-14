using Sedulous.Core.Resources;
using System;
namespace Sedulous.Renderer.Resources;

class MeshManager : ResourceManager<MeshResource>
{
	public override MeshResource Load(StringView path)
	{
		return default;
	}
}