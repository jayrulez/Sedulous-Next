using System;
namespace Sedulous.Foundation.Logging.Abstractions;

abstract class BaseLogger : ILogger
{
	public LogLevel LogLevel { get; private set; }

	public this(LogLevel logLevel)
	{
		LogLevel = logLevel;
	}

	public void Log(LogLevel logLevel, StringView format, params Object[] args)
	{
		if (logLevel >= LogLevel && logLevel != .None)
		{
			String formattedMessage = scope String();
			formattedMessage.AppendF(format, params args);

			Log(scope $"{logLevel}: {formattedMessage}");
		}
	}

	public abstract void Log(StringView message);
}