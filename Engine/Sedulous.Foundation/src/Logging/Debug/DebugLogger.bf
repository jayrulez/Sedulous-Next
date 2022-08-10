using Sedulous.Foundation.Logging.Abstractions;
namespace Sedulous.Foundation.Logging.Debug;

class DebugLogger : ILogger
{
	public LogLevel LogLevel { get; private set; }

	public this(LogLevel logLevel)
	{
		LogLevel = logLevel;
	}

	public void Log(LogLevel logLevel, System.StringView message, params System.Object[] args)
	{
		if (logLevel >= LogLevel && logLevel != .None)
		{
			System.Diagnostics.Debug.WriteLine(scope $"{logLevel}: {message}", params args);
		}
	}
}