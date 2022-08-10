using System.Collections;
using System.Threading;
using Sedulous.Foundation.Utilities;
using Sedulous.Foundation.Mathematics;
using System;
namespace Sedulous.Core.Scenes;

enum SceneUpdatePhase
{
	PreUpdate,
	Update,
	PostUpdate,
	FixedUpdate,
	TransformUpdate
}

class Scene
{
	public struct EntityTransform
	{
		public Vector3 Position;
		public Quaternion Rotation;
		public Vector3 Scale;
	}

	struct EntityHierarchy
	{
		public Entity Entity;
		public Entity? Parent;
		public Entity? FirstChild;
		public Entity? NextSibling;
		public Entity? PrevSibling;

		public EntityTransform LocalTransform;
	}

	private uint8 Id { get; set; }

	private readonly Clock mWorldClock = new .() ~ delete _;
	private readonly Monitor mModulesMonitor = new .() ~ delete _;
	private readonly List<SceneModule> mModules = new .() ~ delete _;
	private readonly List<SceneModule> mModulesToActivate = new .() ~ delete _;

	private List<Entity> mEntities = new .() ~ delete _;
	private List<EntityTransform> mTransforms = new .() ~ delete _;
	private List<EntityHierarchy> mHierarchies = new .() ~ delete _;

#region WorldModules
	public SceneModule GetOrCreateModule<T>() where T : SceneModule
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

			SceneModule module = new T();
			module.Initialize();

			mModules.Add(module);

			mModulesToActivate.Add(module);

			return module;
		}
	}

	public void RemoveModule<T>() where T : SceneModule
	{
		using (mModulesMonitor.Enter())
		{
			SceneModule moduleToRemove = null;

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

	public void RemoveModule(SceneModule moduleToRemove)
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

	private readonly Monitor mNextEntityIdMonitor = new .() ~ delete _;
	private uint mNextEntityId = 0;

	public Entity CreateEntity(Entity? parent = null, EntityTransform? transform = null)
	{
		mNextEntityIdMonitor.Enter();
		Entity entity = .(++mNextEntityId);
		mEntities.Add(entity);

		EntityTransform entityTransform = transform ?? .();

		mTransforms.Add(entityTransform);

		EntityHierarchy hierarchy = .()
			{
				Entity = entity,
				Parent = parent
			};

		if (parent != null)
		{
			SetParent(parent.Value, entity);
		}

		mNextEntityIdMonitor.Exit();



		return entity;
	}

	private void SetParent(Entity parent, Entity child)
	{
		int parentHierarchyIndex = mHierarchies.FindIndex(scope (hierarchy) =>
			{
				return hierarchy.Entity.Equals(parent);
			});

		ref EntityHierarchy parentHierarchy = ref mHierarchies[parentHierarchyIndex];
		
		int childHierarchyIndex = mHierarchies.FindIndex(scope (hierarchy) =>
			{
				return hierarchy.Entity.Equals(child);
			});
	}

	public void GetEntity(uint id) { }

	public void RemoveEntity(Entity entity) {

	}

	public void RemoveEntity(uint id)
	{
		RemoveEntity(Entity(id));
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