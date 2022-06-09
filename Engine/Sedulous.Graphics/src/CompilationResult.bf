using System;
namespace Sedulous.Graphics
{
	/// <summary>
	/// This struct represent the result of a compilation process in a shader.
	/// </summary>
	public struct CompilationResult
	{
		/// <summary>
		/// The uint8 code before compile a shader.
		/// </summary>
		public readonly uint8[] ByteCode;

		/// <summary>
		/// True if the compilation was wrong.
		/// </summary>
		public readonly bool HasErrors;

		/// <summary>
		/// The error line number.
		/// </summary>
		public readonly uint32 ErrorLine;

		/// <summary>
		/// Error message if hasErrors is true.
		/// </summary>
		public readonly String Message;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.Graphics.CompilationResult" /> struct.
		/// </summary>
		/// <param name="bytecode">The compile uint8 code.</param>
		/// <param name="hasErrors">Whether the compilation was success or not.</param>
		/// <param name="errorLine">The error line number if hasError is true.</param>
		/// <param name="message">The error message if hasErrors is true.</param>
		public this(uint8[] bytecode, bool hasErrors, uint32 errorLine = 0u, String message = null)
		{
			ByteCode = bytecode;
			HasErrors = hasErrors;
			ErrorLine = errorLine;
			Message = message;
		}
	}
}
