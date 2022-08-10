using Sedulous.Foundation.Logging.Abstractions;
using System;
namespace Sedulous.Foundation.Logging.Console;

class ConsoleLogger : BaseLogger
{
	public this(LogLevel logLevel) : base(logLevel)
	{
	}

	protected override void Log(StringView message)
	{
		Console.WriteLine(message);
	}
}