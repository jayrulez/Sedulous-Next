using Sedulous.Core;
using Sedulous.RHI;
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
	}
	public override void OnShutdown()
	{
		Engine.Logger.LogInformation("RendererPlugin:OnShutdown");
	}
}