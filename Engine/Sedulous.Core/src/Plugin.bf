using System;
namespace Sedulous.Core;

abstract class Plugin
{
	private readonly Engine mEngine;
	public Engine Engine => mEngine;

	public this(Engine engine)
	{
		mEngine = engine;
	}

	public virtual void OnStartup() { }
	public virtual void OnInitialize() { }
	public virtual void OnShutdown() { }
}