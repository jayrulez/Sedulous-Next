using Sedulous.Foundation.Logging.Abstractions;
namespace Sedulous.Foundation.Logging.Console;

class ConsoleLogger : ILogger
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
			System.Console.WriteLine(scope $"{logLevel}: {message}", params args);
		}
	}
}