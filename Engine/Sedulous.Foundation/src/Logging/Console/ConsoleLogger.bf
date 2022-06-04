using Sedulous.Foundation.Logging.Abstractions;
namespace Sedulous.Foundation.Logging.Console;

class ConsoleLogger : ILogger
{
	public void Log(LogLevel logLevel, System.StringView message, params System.Object[] args)
	{
		if (logLevel != .None)
		{
			System.Console.WriteLine(scope $"{logLevel}: {message}", params args);
		}
	}
}