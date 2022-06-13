using Sedulous.Framework.SDL;
using Sedulous.Framework;
using Sedulous.Foundation.Logging.Abstractions;
using System;
using Sedulous.Foundation.Logging.Console;
using Sedulous.Foundation.Logging.Debug;
using Sedulous.GAL;
using Sedulous.Foundation.Mathematics;
using System.Text;
using System.Collections;

namespace Sandbox;

[CRepr]
struct VertexPositionColor
{
	public Vector2 Position; // This is the position, in normalized device coordinates.
	public RgbaFloat Color; // This is the color of the vertex.
	public this(Vector2 position, RgbaFloat color)
	{
		Position = position;
		Color = color;
	}
	public const int SizeInBytes = 24;
}

class SandboxApplication : SDLApplication
{
	private readonly ILogger mLogger = null ~ delete _;

	private CommandList _commandList;
	private DeviceBuffer _vertexBuffer;
	private DeviceBuffer _indexBuffer;
	private Shader _vertexShader;
	private Shader _fragmentShader;
	private Pipeline _pipeline;

	public this(in StringView windowTitle, uint32 windowWidth, uint32 windowHeight)
		: base(mLogger = new DebugLogger(), windowTitle, windowWidth, windowHeight)
	{
	}

	protected override Result<void> OnStartup()
	{
		if (base.OnStartup() case .Err)
			return .Err;

		//base.OnStartup();

		return .Ok;
	}

	/*private static String VertexCode = """
	#version 450

layout(location = 0) in vec2 Position;
layout(location = 1) in vec4 Color;

layout(location = 0) out vec4 fsin_Color;

void main()
{
gl_Position = vec4(Position, 0, 1);
fsin_Color = Color;
}
""";*/

	private static String VertexCode = """
	struct PSInput{
		float2 Position: SV_POSITION;	
		float4 Color: COLOR;
	};

	float4 main(PSInput input) : COLOR {
		return input.Color;
	}
""";

	/*private const String FragmentCode = """
	#version 450

layout(location = 0) in vec4 fsin_Color;
layout(location = 0) out vec4 fsout_Color;

void main()
{
fsout_Color = fsin_Color;
}
""";*/
	private const String FragmentCode = """
	float4 main(in float4 color : COLOR) : SV_TARGET {
		return color;
	}
""";

	private static void CompileShader()
	{
	}

	protected override Result<void> OnInitialize()
	{
		if (base.OnInitialize() case .Err)
			return .Err;

		if (HLSLShaderCompiler.Initialize() case .Err)
		{
			return .Err;
		}

		ResourceFactory factory = GraphicsDevice.ResourceFactory;

		Compiler.Assert(sizeof(VertexPositionColor) == VertexPositionColor.SizeInBytes);

		VertexPositionColor[?] quadVertices =
			.(
			VertexPositionColor(Vector2(-0.75f, 0.75f), RgbaFloat.Red),
			VertexPositionColor(Vector2(0.75f, 0.75f), RgbaFloat.Green),
			VertexPositionColor(Vector2(-0.75f, -0.75f), RgbaFloat.Blue),
			VertexPositionColor(Vector2(0.75f, -0.75f), RgbaFloat.Yellow)
			);

		uint16[?] quadIndices = .(0, 1, 2, 3);

		_vertexBuffer = factory.CreateBuffer(BufferDescription(4 * VertexPositionColor.SizeInBytes, BufferUsage.VertexBuffer));
		_indexBuffer = factory.CreateBuffer(BufferDescription(4 * sizeof(uint16), BufferUsage.IndexBuffer));

		GraphicsDevice.UpdateBuffer(_vertexBuffer, 0, quadVertices);
		GraphicsDevice.UpdateBuffer(_indexBuffer, 0, quadIndices);

		var compileResult = HLSLShaderCompiler.Compile(.()
			{
				Source = VertexCode,
				EntryPoint = "main",
				BlobType = .SPIRV,
				Stage = .Vertex
			}, var vertexShaderBytes);

		if (compileResult == .Err)
		{
			return .Err;
		}

		defer delete vertexShaderBytes;

		ShaderDescription vertexShaderDesc = ShaderDescription(
			ShaderStages.Vertex,
			vertexShaderBytes,
			"main");

		compileResult = HLSLShaderCompiler.Compile(.()
			{
				Source = FragmentCode,
				EntryPoint = "main",
				BlobType = .SPIRV,
				Stage = .Fragment
			}, var fragmentShaderBytes);

		if (compileResult == .Err)
		{
			return .Err;
		}

		defer delete fragmentShaderBytes;

		ShaderDescription fragmentShaderDesc = ShaderDescription(
			ShaderStages.Fragment,
			fragmentShaderBytes,
			"main");

		_vertexShader = factory.CreateShader(vertexShaderDesc);
		_fragmentShader =  factory.CreateShader(fragmentShaderDesc);

		var dss = DepthStencilStateDescription( /*depthTestEnabled:*/true, /*depthWriteEnabled:*/ true, /*comparisonKind:*/ ComparisonKind.LessEqual);

		var rs = RasterizerStateDescription( /*cullMode:*/FaceCullMode.Back, /*fillMode:*/ PolygonFillMode.Solid, /*frontFace:*/ FrontFace.Clockwise, /*depthClipEnabled:*/ true, /*scissorTestEnabled:*/ false);


		VertexLayoutDescription vertexLayout = .(
			VertexElementDescription("Position", VertexElementSemantic.TextureCoordinate, VertexElementFormat.Float2),
			VertexElementDescription("Color", VertexElementSemantic.TextureCoordinate, VertexElementFormat.Float4)
			);

		/*VertexLayoutDescription vertexLayout = .(
			VertexElementDescription("Position", .Position, .Float2),
			VertexElementDescription("Color", .Color, .Float4)
		);*/

		VertexLayoutDescription[] vertexLayouts = scope .[1](vertexLayout);

		ShaderSetDescription shaderSet = .(vertexLayouts, scope Shader[2](_vertexShader, _fragmentShader));

		GraphicsPipelineDescription pipelineDescription = GraphicsPipelineDescription(BlendStateDescription.SingleOverrideBlend, dss, rs, PrimitiveTopology.TriangleStrip, shaderSet, scope ResourceLayout[](), GraphicsDevice.SwapchainFramebuffer.OutputDescription);

		_pipeline = factory.CreateGraphicsPipeline(pipelineDescription);

		_commandList = factory.CreateCommandList();

		return .Ok;
	}

	/*protected override void OnFrameBegin(){
		base.OnFrameBegin();
		_commandList.Begin();
	}
	*/

	protected override void OnFrameEnd(){
		_commandList.Begin();
		_commandList.SetFramebuffer(GraphicsDevice.SwapchainFramebuffer);
		_commandList.ClearColorTarget(0, RgbaFloat.Black);

		_commandList.SetVertexBuffer(0, _vertexBuffer);
		_commandList.SetIndexBuffer(_indexBuffer, IndexFormat.UInt16);
		_commandList.SetPipeline(_pipeline);
		_commandList.DrawIndexed(
		    /*indexCount:*/ 4,
		    /*instanceCount:*/ 1,
		    /*indexStart:*/ 0,
		    /*vertexOffset:*/ 0,
		    /*instanceStart:*/ 0);


		_commandList.End();
		GraphicsDevice.SubmitCommands(_commandList);
		GraphicsDevice..SwapBuffers();
		base.OnFrameEnd();
	}

	protected override void OnShutdown()
	{
		
		if (_commandList != null)
		{
			GraphicsDevice.DisposeWhenIdle(_commandList);
			//_commandList.Dispose();
			//delete _commandList;
			//_commandList = null;
		}

		if (_pipeline != null)
		{
			_pipeline.Dispose();
			delete _pipeline;
			_pipeline = null;
		}

		if (_fragmentShader != null)
		{
			_fragmentShader.Dispose();
			delete _fragmentShader;
		}

		if (_vertexShader != null)
		{
			_vertexShader.Dispose();
			delete _vertexShader;
		}

		_vertexBuffer.Dispose();
		delete _vertexBuffer;

		_indexBuffer.Dispose();
		delete _indexBuffer;

		base.OnShutdown();

		if (_commandList != null)
		{
			delete _commandList;
		}

	}
}