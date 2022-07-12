using Sedulous.Foundation.Logging.Abstractions;
using System.Collections;
namespace Sedulous.Core.Resources;

class ResourceSystem
{
	private readonly Engine mEngine = null;

	private readonly List<ResourceManager> mResourceManagers = new .() ~ delete _;

	private bool mIsRunning = false;

	public ILogger Logger => mEngine.Logger;

	public this(Engine engine)
	{
		mEngine = engine;
	}

	public ~this()
	{
	}

	public void Startup()
	{
		if (mIsRunning)
		{
			Logger.LogError("Startup called on ResourceSystem that is already running.");
			return;
		}

		mIsRunning = true;
	}

	public void Shutdown()
	{
		if (!mIsRunning)
		{
			Logger.LogError("Shutdown called on ResourceSystem that is not running.");
			return;
		}

		mIsRunning = false;
	}

	public void Update()
	{
	}
}