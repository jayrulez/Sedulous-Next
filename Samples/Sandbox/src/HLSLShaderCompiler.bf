using System;
using Dxc_Beef;
using System.IO;
using System.Collections;
using System.Diagnostics;
using Sedulous.GAL;
namespace Sandbox
{
	struct CompileOptions
	{
		public StringView Source;
		public StringView EntryPoint;
		public ShaderBlobType BlobType;
		public ShaderStages Stage;
	}

	enum ShaderBlobType
	{
		DXIL,
		SPIRV
	}

	static class HLSLShaderCompiler
	{
		public static bool IsInitialized { get; private set; }
		private static IDxcLibrary* pLibrary = null;

		public static this()
		{
		}

		public static Result<void> Initialize()
		{
			var result = Dxc.CreateInstance(out pLibrary);
			if (result != .OK)
				return .Err;
			IsInitialized = true;
			return .Ok;
		}

		public static Result<void> Compile(CompileOptions options, out List<uint8> compiledByteCode)
		{
			compiledByteCode = null;
			String shadersPath = Path.InternalCombine(.. scope .(), Directory.GetCurrentDirectory(.. scope String()), "shaders");

			uint32 codePage = 0;
			IDxcBlobEncoding* pSource = null;
			var result = pLibrary.CreateBlobWithEncodingOnHeapCopy(options.Source.Ptr, (.)options.Source.Length, codePage, out pSource);
			if (result != .OK)
				return .Err;

			uint32 space = 0;
			List<char16*> arguments = scope .();
			{
				arguments.Add(scope String("-E").ToScopedNativeWChar!::());
				arguments.Add(scope String(options.EntryPoint).ToScopedNativeWChar!::());

				arguments.Add(scope String("-T").ToScopedNativeWChar!::());
				if (options.Stage == .Fragment)
					arguments.Add(scope String("ps_6_2").ToScopedNativeWChar!::());

				if (options.Stage == .Vertex)
					arguments.Add(scope String("vs_6_2").ToScopedNativeWChar!::());

				arguments.Add(scope String("-Qstrip_debug").ToScopedNativeWChar!::());
				arguments.Add(scope String("-Qstrip_reflect").ToScopedNativeWChar!::());

				if (options.BlobType == .SPIRV)
				{
					arguments.Add(scope String("-spirv").ToScopedNativeWChar!::());
					arguments.Add(scope String("-fspv-target-env=vulkan1.1").ToScopedNativeWChar!::());
					arguments.Add(scope String("-fspv-extension=KHR").ToScopedNativeWChar!::());
					arguments.Add(scope String("-fspv-extension=SPV_NV_mesh_shader").ToScopedNativeWChar!::());
					arguments.Add(scope String("-fspv-extension=SPV_EXT_descriptor_indexing").ToScopedNativeWChar!::());
					arguments.Add(scope String("-fspv-extension=SPV_EXT_shader_viewport_index_layer").ToScopedNativeWChar!::());
					//arguments.Add(scope String("-fspv-extension=SPV_GOOGLE_hlsl_functionality1").ToScopedNativeWChar!::());
					arguments.Add(scope String("-fspv-extension=SPV_GOOGLE_user_type").ToScopedNativeWChar!::());
					arguments.Add(scope String("-fvk-use-dx-layout").ToScopedNativeWChar!::());
					//arguments.Add(scope String("-fspv-reflect").ToScopedNativeWChar!::());

					//space = (.)options.Stage;
				}

				arguments.Add(DXC_ARG_WARNINGS_ARE_ERRORS.ToScopedNativeWChar!::());
				arguments.Add(DXC_ARG_DEBUG.ToScopedNativeWChar!::());
				arguments.Add(DXC_ARG_PACK_MATRIX_ROW_MAJOR.ToScopedNativeWChar!::());


				arguments.Add(scope String("-auto-binding-space").ToScopedNativeWChar!::());
				arguments.Add(scope $"{space}".ToScopedNativeWChar!::());
			}

			IDxcCompiler3* pCompiler = null;

			result = Dxc.CreateInstance(out pCompiler);
			if (result != .OK)
				return .Err;

			DxcBuffer buffer = .()
				{
					Ptr = pSource.GetBufferPointer(),
					Size = pSource.GetBufferSize(),
					Encoding = 0
				};

			IncludeHandler includeHandler = .(pLibrary, shadersPath);

			result = pCompiler.VT.Compile(pCompiler, &buffer, arguments.Ptr, (.)arguments.Count, &includeHandler, ref IDxcResult.sIID, var ppResult);
			if (result != .OK)
				return .Err;

			IDxcResult* pResult = (.)ppResult;

			result = pResult.GetStatus(var status);

			if (status != .OK)
			{
				IDxcBlobEncoding* pErrors = null;
				result = pResult.GetErrorBuffer(out pErrors);
				if (pErrors != null && pErrors.GetBufferSize() > 0)
				{
					Debug.WriteLine(scope String((char8*)pErrors.GetBufferPointer()));
				}
				return .Err;
			}

			IDxcBlob* pBlob = null;

			result = pResult.GetResult(out pBlob);
			if (result != .OK)
				return .Err;

			compiledByteCode = new .();

			compiledByteCode.AddRange(Span<uint8>((.)pBlob.GetBufferPointer(), pBlob.GetBufferSize()));

			return .Ok;
		}

		public static ~this()
		{
		}
	}

	public struct IncludeHandler : IDxcIncludeHandler
	{
		public this(IDxcLibrary* pLibrary, in String basePath)
		{
			m_pLibrary = pLibrary;
			m_BasePath = basePath;

			function [CallingConvention(.Stdcall)] HResult(IncludeHandler* this, ref Guid riid, void** result) queryInterface = => QueryInterface;
			function [CallingConvention(.Stdcall)] uint32(IncludeHandler* this) addRef = => AddRef;
			function [CallingConvention(.Stdcall)] uint32(IncludeHandler* this) release = => Release;
			function [CallingConvention(.Stdcall)] HResult(IncludeHandler* this, char16* pFilename, out IDxcBlob* ppIncludeSource) loadSource = => LoadSource;

			mDVT = .();
			mDVT.QueryInterface = (.)(void*)queryInterface;
			mDVT.AddRef = (.)(void*)addRef;
			mDVT.Release = (.)(void*)release;
			mDVT.LoadSource = (.)(void*)loadSource;

			mVT = &mDVT;
		}

		private HResult LoadSource(char16* pFilename, out IDxcBlob* ppIncludeSource)
		{
			IDxcBlobEncoding* pSource = null;

			String path = Path.InternalCombine(.. scope .(), m_BasePath, scope String(pFilename));

			HResult result = m_pLibrary.CreateBlobFromFile(path, null, out pSource);

			if (result == .OK && pSource != null)
				ppIncludeSource = pSource;
			else
				ppIncludeSource = ?;

			return result;
		}

		private HResult QueryInterface(ref Guid riid, void** result)
		{
			return (.)0x80004001;
		}

		private uint32 AddRef()
		{
			return (.)0x80004001;
		}

		private uint32 Release()
		{
			return (.)0x80004001;
		}


		public new VTable* VT
		{
			get
			{
				return (.)mVT;
			}
		}

		private IDxcIncludeHandler.VTable mDVT;
		private IDxcLibrary* m_pLibrary = null;
		private String m_BasePath = null;
	}
}