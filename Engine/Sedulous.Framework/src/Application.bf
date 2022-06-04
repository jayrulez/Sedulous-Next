using Sedulous.Core;
using Sedulous.Foundation.Logging.Abstractions;
using System;
using System.Collections;
namespace Sedulous.Framework;

class ApplicationSettings : EngineSettings
{
}

abstract class Application
{
	private bool mIsRunning = false;
	protected readonly Engine mEngine = null ~ delete _;
	protected readonly ApplicationSettings mSettings;

	public ILogger Logger => mEngine.Logger;

	public this(ApplicationSettings settings)
	{
		mSettings = settings;
		mEngine = new Engine(mSettings);
	}

	protected virtual Result<void> OnStartup() => .Ok;

	protected virtual Result<void> OnInitialize() => .Ok;

	protected virtual void OnShutdown() => void();

	protected virtual void OnFrameBegin() => void();

	protected virtual void OnFrameEnd() => void();

	private Result<void> Startup()
	{
		if (OnStartup() case .Err)
			return .Err;

		mEngine.Startup();

		return .Ok;
	}

	private Result<void> Initialize()
	{
		if (OnInitialize() case .Err)
			return .Err;

		mEngine.Initialize();

		return .Ok;
	}

	private void Shutdown()
	{
		mEngine.Shutdown();
		OnShutdown();
	}

	private void RunFrame()
	{
		OnFrameBegin();
		mEngine.Tick();
		OnFrameEnd();
	}

	public void Run()
	{
		if (mIsRunning)
		{
			return;
		}

		if (Startup() case .Err)
			return;

		if (Initialize() case .Err)
			return;

		mIsRunning = true;

		while (mIsRunning)
		{
			RunFrame();
		}

		Shutdown();
	}

	public void Stop()
	{
		mIsRunning = false;
	}
}