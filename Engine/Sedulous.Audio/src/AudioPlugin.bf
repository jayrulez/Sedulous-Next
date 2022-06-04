using Sedulous.Core;
namespace Sedulous.Audio;

class AudioPlugin : Plugin
{
	public this(Engine engine) : base(engine)
	{

	}

	public override void OnStartup()
	{
		Engine.Logger.LogInformation("AudioPlugin:OnStartup");
	}

	public override void OnInitialize()
	{
		Engine.Logger.LogInformation("AudioPlugin:OnInitialize");
	}

	public override void OnShutdown()
	{
		Engine.Logger.LogInformation("AudioPlugin:OnShutdown");
	}
}