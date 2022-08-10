using System;
using System.Collections;
namespace Sedulous.Core.Scenes;

class SceneModule
{
	typealias UpdateFunction = delegate void();

	private readonly Scene mScene;

	public Scene Scene => mScene;

	public this(Scene scene)
	{
		mScene = scene;
	}

	public virtual Result<void> Initialize() => .Ok;
	public virtual void Activate() => void();
	public virtual Result<void> Shutdown() => .Ok;

	public void AddUpdateFunction()
	{
	}

	public void RemoveUpdateFunction()
	{
	}
}