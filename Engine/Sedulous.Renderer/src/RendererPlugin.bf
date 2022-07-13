using Sedulous.Core;
using Sedulous.RHI;
using Sedulous.Renderer.Resources;
namespace Sedulous.Renderer;

class RendererPlugin : Plugin
{
	private readonly Device mDevice = null;

	public this(Engine engine, Device device) : base(engine)
	{
		mDevice = device;
	}

	public override void OnStartup()
	{
		Engine.Logger.LogInformation("RendererPlugin:OnStartup");
	}

	public override void OnInitialize()
	{
		Engine.Logger.LogInformation("RendererPlugin:OnInitialize");

		Texture2DManager texture2DManager = new .();
		defer texture2DManager.ReleaseRef();
		
		MaterialManager materialManager = new .();
		defer materialManager.ReleaseRef();

		Engine.ResourceSytem.AddResourceManager<Texture2DResource...>(texture2DManager);
		Engine.ResourceSytem.AddResourceManager<MaterialResource...>(materialManager);
	}

	public override void OnShutdown()
	{
		Engine.Logger.LogInformation("RendererPlugin:OnShutdown");
	}
}