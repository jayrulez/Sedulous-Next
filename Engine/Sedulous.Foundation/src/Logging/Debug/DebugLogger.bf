using Sedulous.Foundation.Logging.Abstractions;
namespace Sedulous.Foundation.Logging.Debug;

class DebugLogger : ILogger
{
	public void Log(LogLevel logLevel, System.StringView message, params System.Object[] args)
	{
		if (logLevel != .None)
		{
			System.Diagnostics.Debug.WriteLine(scope $"{logLevel}: {message}", params args);
		}
	}
}