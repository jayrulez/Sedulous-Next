using Sedulous.Foundation.Logging.Abstractions;
using System.Collections;
using System.Threading;
using Sedulous.Foundation.Utilities;
namespace Sedulous.Core;

class EngineSettings
{
	public ILogger Logger { get; set; }
	public readonly List<Plugin> Plugins = new List<Plugin>() ~ delete _;
}

class Engine
{
	private readonly Clock mEngineClock = new .() ~ delete _;
	private readonly Monitor mWorldsMonitor = new .() ~ delete _;
	private List<World> mWorlds = new .() ~ delete _;
	private List<Plugin> mPlugins = new List<Plugin>() ~ delete _;
	private readonly EngineSettings mSettings = null;

	public ILogger Logger => mSettings.Logger;

	public this(EngineSettings settings)
	{
		mSettings = settings;
	}

	public void Startup()
	{
		mPlugins.AddRange(mSettings.Plugins);

		for (var plugin in mPlugins)
		{
			plugin.OnStartup();
		}
	}

	public void Initialize()
	{
		for (var plugin in mPlugins)
		{
			plugin.OnInitialize();
		}
	}

	public void Shutdown()
	{
		for (int i = mPlugins.Count - 1; i >= 0; i--)
		{
			mPlugins[i].OnShutdown();
		}
	}

	public void Tick() { }
}