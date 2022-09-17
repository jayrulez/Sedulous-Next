using Sedulous.Foundation.Logging.Abstractions;
using System;
namespace Sedulous.Foundation.Utilities;

public static
{
	public static mixin ReturnOnFailure<T>(ILogger logger, bool condition, T returnCode, StringView format, params Object[] args)
	{
		if (condition == false)
		{
			logger.LogError(format, args);

			return returnCode;
		}
	}
}