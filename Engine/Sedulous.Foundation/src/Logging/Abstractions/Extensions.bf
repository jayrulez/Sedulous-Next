using System;
namespace Sedulous.Foundation.Logging.Abstractions;

extension ILogger
{
	void LogTrace(StringView format, params Object[] args)
	{
		Log(.Trace, format, params args);
	}

	void LogDebug(StringView format, params Object[] args)
	{
		Log(.Debug, format, params args);
	}

	void LogInformation(StringView format, params Object[] args)
	{
		Log(.Information, format, params args);
	}

	void LogWarning(StringView format, params Object[] args)
	{
		Log(.Warning, format, params args);
	}

	void LogError(StringView format, params Object[] args)
	{
		Log(.Error, format, params args);
	}

	void LogCritical(StringView format, params Object[] args)
	{
		Log(.Critical, format, params args);
	}
}