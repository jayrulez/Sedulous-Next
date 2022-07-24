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

		mEngine.ResourceSytem.AddAssetManager<Texture2DResource, Texture2DManager>();
		mEngine.ResourceSytem.AddAssetManager<MaterialResource, MaterialManager>();
	}

	public override void OnShutdown()
	{
		mEngine.Logger.LogInformation("RendererPlugin:OnShutdown");
	}
}