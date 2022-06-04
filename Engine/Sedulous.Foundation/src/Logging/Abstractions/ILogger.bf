using System;
namespace Sedulous.Foundation.Logging.Abstractions;

interface ILogger
{
	void Log(LogLevel logLevel, StringView message, params Object[] args);
}