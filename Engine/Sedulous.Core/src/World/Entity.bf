using System;
namespace Sedulous.Core.World;

struct Entity : IEquatable<Entity>, IHashable
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