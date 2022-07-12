namespace Sedulous.Core.Resources;

abstract class ResourceManager
{
	public this()
	{
	}
}

class ResourceManager<T> : ResourceManager where T : Resource
{
}