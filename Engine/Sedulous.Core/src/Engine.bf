using Sedulous.Foundation.Logging.Abstractions;
using System.Collections;
using System.Threading;
namespace Sedulous.Core
{
	class Engine
	{
		private readonly Monitor mWorldsMonitor = new .() ~ delete _;
		private List<World> mWorlds = new .() ~ delete _;

		public readonly ILogger Logger = null;

		public this(ILogger logger)
		{
			Logger = logger;
		}

		public void Startup() { }

		public void Initialize() { }

		public void Shutdown() { }

		public void Tick() { }
	}
}