using System.Collections;
using System.Threading;
using Sedulous.Foundation.Utilities;
using Sedulous.Foundation.Mathematics;
using System;
namespace Sedulous.Core;

enum WorldUpdatePhase
{
	PreUpdate,
	Update,
	PostUpdate,
	FixedUpdate,
	Transform
}
struct Entity : IEquatable<Entity>,  IHashable
{
	public uint Id { get; }

	public this(uint id)
	{
		Id = id;
	}

	public int GetHashCode()
	{
		return (.)Id;
	}

	public bool Equals(Entity other)
	{
		return Id == other.Id;
	}
}

class World
{
	struct EntityTransform
	{
		public Vector3 Position;
		public Quaternion Rotation;
		public Vector3 Scale;
	}

	struct EntityHierarchy
	{
		public Entity Entity;
		public Entity Parent;
		public Entity FirstChild;
		public Entity NextSibling;
		public Entity PrevSibling;

		public EntityTransform LocalTransform;
	}

	private uint8 Id { get; set; }

	private readonly Clock mWorldClock = new .() ~ delete _;
	private readonly Monitor mModulesMonitor = new .() ~ delete _;
	private readonly List<WorldModule> mModules = new .() ~ delete _;
	private readonly List<WorldModule> mModulesToActivate = new .() ~ delete _;

	private List<Entity> mEntities = new .() ~ delete _;
	private List<EntityTransform> mTransforms = new .() ~ delete _;
	private List<EntityHierarchy> mHierarchies = new .() ~ delete _;

#region WorldModules
	public WorldModule GetOrCreateModule<T>() where T : WorldModule
	{
		using (mModulesMonitor.Enter())
		{
			for (var module in mModules)
			{
				if ((module as T) != null)
				{
					return module;
				}
			}

			WorldModule module = new T();
			module.Initialize();

			mModules.Add(module);

			mModulesToActivate.Add(module);

			return module;
		}
	}

	public void RemoveModule<T>() where T : WorldModule
	{
		using (mModulesMonitor.Enter())
		{
			WorldModule moduleToRemove = null;

			for (var module in mModules)
			{
				if ((module as T) != null)
				{
					moduleToRemove = module;
					break;
				}
			}

			if (moduleToRemove == null)
				return;

			moduleToRemove.Shutdown();

			mModules.Remove(moduleToRemove);

			delete moduleToRemove;
		}
	}

	public void RemoveModule(WorldModule moduleToRemove)
	{
		using (mModulesMonitor.Enter())
		{
			bool moduleFound = false;
			for (var module in mModules)
			{
				if (module == moduleToRemove)
				{
					moduleFound = true;
					break;
				}
			}

			if (!moduleFound)
				return;

			moduleToRemove.Shutdown();

			mModules.Remove(moduleToRemove);

			delete moduleToRemove;
		}
	}
#endregion

#region Entities
	public void CreateEntity() { }

	public void GetEntity(uint id) { }

	public void RemoveEntity(Entity entity) { }

	public void RemoveEntity(uint id)
	{
	}


#endregion

	public void Update()
	{
		mWorldClock.Update();

		// Initialize components

		// Activate World Modules
		for (var module in mModulesToActivate)
		{
			module.Activate();
		}
		mModulesToActivate.Clear();

		// Register update functions

		// Run pre-update functions
		// Run update functions
		// Run post-update functions

		// Remove dead entities, and world modules
	}
}