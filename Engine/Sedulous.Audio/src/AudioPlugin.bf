using Sedulous.Core;
namespace Sedulous.Audio;

class AudioPlugin : Plugin
{
	private Engine mEngine = null;

	public override void OnStartup(Engine engine)
	{
		mEngine = engine;

		mEngine.Logger.LogInformation("AudioPlugin:OnStartup");
	}

	public override void OnShutdown()
	{
		mEngine.Logger.LogInformation("AudioPlugin:OnShutdown");
	}
}