using Sedulous.Framework.SDL;
using Sedulous.Framework;
using Sedulous.Foundation.Logging.Abstractions;
using System;
using Sedulous.Foundation.Logging.Console;

namespace Sandbox
{
	class SandboxApplication : SDLApplication
	{
		private readonly ILogger mLogger = null ~ delete _;

		public this(in StringView windowTitle, uint32 windowWidth, uint32 windowHeight)
			: base(mLogger = new ConsoleLogger(), windowTitle, windowWidth, windowHeight)
		{
		}
	}
}