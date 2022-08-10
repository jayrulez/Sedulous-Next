using System;
namespace Sedulous.Foundation.Logging.Abstractions;

interface ILogger
{
	LogLevel LogLevel { get; }

	void Log(LogLevel logLevel, StringView message, params Object[] args);
}