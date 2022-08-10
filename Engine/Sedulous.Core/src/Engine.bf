using Sedulous.Foundation.Logging.Abstractions;
using System.Collections;
using System.Threading;
using Sedulous.Foundation.Utilities;
using System;
using Sedulous.Core.Jobs;
using Sedulous.Core.Resources;
using System.IO;
using Sedulous.Core.Scenes;
namespace Sedulous.Core;

class EngineConfig
{
	public readonly List<Plugin> Plugins = new List<Plugin>() ~ delete _;

	public String ResourceDirectory { get; private set; } = new .() ~ delete _;

	public void SetResourceDirectory(StringView resourceDirectory)
	{
		ResourceDirectory.Set(resourceDirectory);
	}
}

class Engine
{
	private readonly Clock mEngineClock = new .() ~ delete _;
	private readonly Monitor mScenesMonitor = new .() ~ delete _;
	private readonly List<Scene> mScenes = new .() ~ delete _;
	private readonly List<Plugin> mPlugins = new List<Plugin>() ~ delete _;
	private readonly JobSystem mJobSystem = null;
	private readonly ResourceSystem mResourceSystem = null;
	private readonly String mResourcesDirectory = new .() ~ delete _;

	public JobSystem JobSytem => mJobSystem;
	public ResourceSystem ResourceSytem => mResourceSystem;

	public ILogger Logger { get; private set; }

	public this(ILogger logger)
	{
		Logger = logger;
		mJobSystem = new .(this, 16);
		mResourceSystem = new .(this);
	}

	public ~this()
	{
		delete mResourceSystem;
		delete mJobSystem;
	}

	private void Configure(EngineConfig config)
	{
		mPlugins.AddRange(config.Plugins);
		mResourcesDirectory.Set(config.ResourceDirectory);
	}

	private void Startup()
	{
		mJobSystem.Startup();
		mResourceSystem.Startup();

		for (var plugin in mPlugins)
		{
			plugin.OnStartup(this);
		}
	}

	private void Shutdown()
	{
		for (int i = mPlugins.Count - 1; i >= 0; i--)
		{
			mPlugins[i].OnShutdown();
		}

		mResourceSystem.Shutdown();
		mJobSystem.Shutdown();
	}

	private void Tick()
	{
		mJobSystem?.Update();
		mResourceSystem?.Update();

		for (Scene scene in mScenes)
		{
			//mJobSystem.RunJob(new => scene.Update, "Scene Update");
			scene.Update();
		}
	}

	public Scene CreateScene()
	{
		using (mScenesMonitor.Enter())
		{
			Scene scene = new Scene();

			mScenes.Add(scene);

			return scene;
		}
	}

	public void DestroyScene(Scene scene)
	{
		mScenes.Remove(scene);
		delete scene;
	}
}