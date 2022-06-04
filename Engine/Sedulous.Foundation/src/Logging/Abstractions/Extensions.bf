using System;
namespace Sedulous.Foundation.Logging.Abstractions;

extension ILogger
{
	void LogTrace(StringView message, params Object[] args)
	{
		Log(.Trace, message, params args);
	}

	void LogDebug(StringView message, params Object[] args)
	{
		Log(.Debug, message, params args);
	}

	void LogInformation(StringView message, params Object[] args)
	{
		Log(.Information, message, params args);
	}

	void LogWarning(StringView message, params Object[] args)
	{
		Log(.Warning, message, params args);
	}

	void LogError(StringView message, params Object[] args)
	{
		Log(.Error, message, params args);
	}

	void LogCritical(StringView message, params Object[] args)
	{
		Log(.Critical, message, params args);
	}
}