using Sedulous.Core;
using Sedulous.RHI;
using Sedulous.Renderer.Resources;
namespace Sedulous.Renderer;

class RendererPlugin : Plugin
{
	private Engine mEngine = null;
	private readonly Device mDevice = null;

	public this(Device device)
	{
		mDevice = device;
	}

	public override void OnStartup(Engine engine)
	{
		mEngine = engine;

		mEngine.Logger.LogInformation("RendererPlugin:OnInitialize");

		mEngine.ResourceSytem.AddResourceManager<Texture2DResource, Texture2DManager>();
		mEngine.ResourceSytem.AddResourceManager<MaterialResource, MaterialManager>();
	}

	public override void OnShutdown()
	{
		mEngine.Logger.LogInformation("RendererPlugin:OnShutdown");
	}
}