using Sedulous.Framework.SDL;
using Sedulous.Framework;
using Sedulous.Foundation.Logging.Abstractions;
using System;
using Sedulous.Foundation.Logging.Console;
using Sedulous.Foundation.Logging.Debug;

namespace Sandbox;

class SandboxApplication : SDLApplication
{
	private readonly ILogger mLogger = null ~ delete _;

	public this(in StringView windowTitle, uint32 windowWidth, uint32 windowHeight)
		: base(mLogger = new DebugLogger(), windowTitle, windowWidth, windowHeight)
	{
	}

	protected override Result<void> OnStartup()
	{
		if(base.OnStartup() case .Err)
			return .Err;

		//base.OnStartup();

		return .Ok;
	}
}