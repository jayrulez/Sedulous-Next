using System;

namespace Sedulous.Graphics.Raytracing
{
	/// <summary>
	/// This class contains all the raytracing shader stages.
	/// </summary>
	public class RaytracingShaderStateDescription : ShaderStateDescription, IEquatable<RaytracingShaderStateDescription>
	{
		/// <summary>
		/// Gets or sets the Raygeneration shader program.
		/// </summary>
		public Shader RayGenerationShader;

		/// <summary>
		/// Gets or sets the closestHit shader program.
		/// </summary>
		public Shader[] ClosestHitShader;

		/// <summary>
		/// Gets or sets the Miss shader program.
		/// </summary>
		public Shader[] MissShader;

		/// <summary>
		/// Gets or sets the AnyHit shader program.
		/// </summary>
		public Shader[] AnyHitShader;

		/// <summary>
		/// Gets or sets the Intersection shader program.
		/// </summary>
		public Shader[] IntersectionShader;

		/// <inheritdoc />
		public bool Equals(RaytracingShaderStateDescription other)
		{
			if (RayGenerationShader != other.RayGenerationShader
				|| !ClosestHitShader.SequenceEqual(other.ClosestHitShader)
				|| !MissShader.SequenceEqual(other.MissShader)
				|| !AnyHitShader.SequenceEqual(other.AnyHitShader)
				|| !IntersectionShader.SequenceEqual(other.IntersectionShader))
			{
				return false;
			}
			return true;
		}

		/// <inheritdoc />
		public override int GetHashCode()
		{
			int num = 0;
			if (RayGenerationShader != null)
			{
				num = (num * 397) ^ RayGenerationShader.GetHashCode();
			}
			if (ClosestHitShader != null)
			{
				num = (num * 397) ^ ClosestHitShader.GetHashCode();
			}
			if (MissShader != null)
			{
				num = (num * 397) ^ MissShader.GetHashCode();
			}
			if (AnyHitShader != null)
			{
				num = (num * 397) ^ AnyHitShader.GetHashCode();
			}
			if (IntersectionShader != null)
			{
				num = (num * 397) ^ IntersectionShader.GetHashCode();
			}
			return num;
		}

		/// <summary>
		/// Gets the entrypoint name from Shader stage index.
		/// </summary>
		/// <param name="stage">Shader Stage.</param>
		/// <returns>Entry point name.</returns>
		public String[] GetEntryPointByStage(ShaderStages stage)
		{
			Shader[] array;
			switch (stage)
			{
			case ShaderStages.RayGeneration:
				return new String[1] { RayGenerationShader.Description.EntryPoint };
			case ShaderStages.Miss:
				array = MissShader;
				break;
			case ShaderStages.ClosestHit:
				array = ClosestHitShader;
				break;
			case ShaderStages.AnyHit:
				array = AnyHitShader;
				break;
			case ShaderStages.Intersection:
				array = IntersectionShader;
				break;
			default:
				return null;
			}
			String[] array2 = new String[array.Count];
			for (int32 i = 0; i < array.Count; i++)
			{
				array2[i] = array[i].Description.EntryPoint;
			}
			return array2;
		}
	}
}
