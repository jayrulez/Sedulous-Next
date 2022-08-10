using Sedulous.Foundation.Logging.Abstractions;
using System;
namespace Sedulous.Foundation.Logging.Debug;

class DebugLogger : BaseLogger
{
	public this(LogLevel logLevel) : base(logLevel)
	{
	}

	protected override void Log(StringView message)
	{
		Diagnostics.Debug.WriteLine(message);
	}
}