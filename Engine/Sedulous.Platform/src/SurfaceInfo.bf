using System;
using Sedulous.Foundation.Utilities;
namespace Sedulous.Platform;

/// <summary>
/// Surface info struct.
/// </summary>
public struct SurfaceInfo : IEquatable<SurfaceInfo>, IDisposable
{
	/// <summary>
	/// Surface tecnologies.
	/// </summary>
	public enum SurfaceTypes
	{
		/// <summary>
		///  Window forms
		/// </summary>
		Forms,
		/// <summary>
		/// Windows Presentation Foundation.
		/// </summary>
		WPF,
		/// <summary>
		/// Wayland window system
		/// </summary>
		Wayland,
		/// <summary>
		/// Simple DirectMedia Layter
		/// </summary>
		SDL,
		/// <summary>
		/// Android System
		/// </summary>
		Android,
		/// <summary>
		/// IOS System
		/// </summary>
		IOS,
		/// <summary>
		/// UWP System
		/// </summary>
		UWP,
		/// <summary>
		/// WinUI system.
		/// </summary>
		WinUI,
		/// <summary>
		/// Web System.
		/// </summary>
		Web,
		/// <summary>
		/// Mixed Reality.
		/// </summary>
		MixedReality
	}

	/// <summary>
	/// Surface type.
	/// </summary>
	public SurfaceTypes Type;

	/// <summary>
	/// Surface native handles.
	/// </summary>
	public readonly void*[] Handles;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.SurfaceInfo" /> struct.
	/// </summary>
	/// <param name="handle">Surface native handle.</param>
	/// <param name="type">Surface type.</param>
	public this(void* handle, SurfaceTypes type)
		: this(scope void*[1] ( handle ), type)
	{
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.SurfaceInfo" /> struct.
	/// </summary>
	/// <param name="handles">Surface native handle.</param>
	/// <param name="type">Surface type.</param>
	public this(void*[] handles, SurfaceTypes type)
	{

		Handles = new void*[handles.Count];
		for(int i = 0; i < handles.Count; i++){
			Handles[i] = handles[i];
		}
		Type = type;
	}

	/// <summary>
	/// Determines whether the specified <see cref="T:System.Object" /> is equal to this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// <c>true</c> if the specified <see cref="T:System.Object" /> is equal to this instance; otherwise, <c>false</c>.
	/// </returns>
	public bool Equals(SurfaceInfo other)
	{
		if (Handles == other.Handles)
		{
			return Type == other.Type;
		}
		return false;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public int GetHashCode()
	{
		int hash = 0;
		for (int32 i = 0; i < Handles.Count; i++)
		{
			hash = HashHelper.CombineHash(hash, (.)Handles[i]);
		}
		return HashHelper.CombineHash(hash, (.)Type);
	}

	public void Dispose()
	{
		delete Handles;
	}
}