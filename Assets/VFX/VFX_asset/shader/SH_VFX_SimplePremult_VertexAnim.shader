// Made with Amplify Shader Editor v1.9.9.9
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "/_Kass_/SH_VFX_SimplePremult_VertexAnim"
{
	Properties
	{
		[Header(Main Alpha)] _MainTex( "MainTex", 2D ) = "white" {}
		_TextureChannel( "Texture Channel", Vector ) = ( 0, 0, 0, 0 )
		_TextureRotation( "Texture Rotation", Float ) = 0
		[Header(Overlay Color)] _ColorTexture( "Color Texture", 2D ) = "white" {}
		_ColorRotation( "Color Rotation", Float ) = 0
		[Header(Gradient Shape)] _GradientShape( "Gradient Shape", 2D ) = "white" {}
		_GradientShapeChannel( "Gradient Shape Channel", Vector ) = ( 0, 0, 0, 0 )
		_GradientShapeRotation( "Gradient Shape Rotation", Float ) = 0
		[Header(Gradient Map)] _GradientMap( "Gradient Map", 2D ) = "white" {}
		_GradientMapDisplacement( "Gradient Map Displacement", Float ) = 0
		_InvertGradient( "Invert Gradient", Float ) = 0
		[Header(Different Center Color)] _CorePower( "Core Power", Float ) = 0
		_CoreIntensity( "Core Intensity", Float ) = 0
		_DifferentCoreColor( "Different Core Color", Float ) = 0
		_CoreColor( "Core Color", Color ) = ( 0, 0, 0, 0 )
		[Header(Brightness and Opacity)] _Brightness( "Brightness", Float ) = 1
		_AlphaBoldness( "Alpha Boldness", Float ) = 1
		_FlatAlpha( "Flat Alpha", Range( 0, 1 ) ) = 0
		[Header(Depth Fade)] _UseDepthFade( "Use Depth Fade", Float ) = 1
		_DepthFadeDivide( "Depth Fade Divide", Float ) = 1
		[Header(Vertex Displacement)] _VertexDisplacementAmount( "Vertex Displacement Amount", Vector ) = ( 0, 0, 0, 0 )
		_UseVertexNormals( "Use Vertex Normals", Range( 0, 1 ) ) = 1
		_ClampDisplacement( "Clamp Displacement", Range( 0, 1 ) ) = 0
		_CustomData1XAffectsStrength( "Custom Data 1 X Affects Strength", Range( 0, 1 ) ) = 1
		_CustomData1YAffectsSpeed( "Custom Data 1 Y Affects Speed", Range( 0, 1 ) ) = 1
		[Header(UV Based Sin Wave Displacement)] _UVSinWaveStrength( "UV Sin Wave Strength", Vector ) = ( 0, 0, 0, 0 )
		_UVSinWaveFrequency( "UV Sin Wave Frequency", Float ) = 1
		_UVSinWaveSpeed( "UV Sin Wave Speed", Float ) = 1
		[Header(Vertex Displacement Noise)] _VertexDisplacementNoise( "Vertex Displacement Noise", 2D ) = "white" {}
		_VertexDisplacementNoiseChannel( "Vertex Displacement Noise Channel", Vector ) = ( 0, 0, 0, 0 )
		_VertexDisplacementNoisePanSpeed( "Vertex Displacement Noise  Pan Speed", Vector ) = ( 0, 0, 0, 0 )
		_VertexDisplacementNoiseStrength( "Vertex Displacement Noise Strength", Float ) = 0
		_VertexDisplacementNoiseRotation( "Vertex Displacement Noise Rotation", Float ) = 0
		[Header(UV Based Displacement Mask)] _UVBasedDisplacementMaskChannel( "UV Based Displacement Mask Channel", Vector ) = ( 0, 0, 0, 0 )
		_UVBasedDisplacementMaskDisplacement( "UV Based Displacement Mask Displacement", Float ) = 0
		_UVBasedDisplacementMaskSoften( "UV Based Displacement Mask Soften", Float ) = 1
		[Header(Rendering)] _Cull( "Cull", Float ) = 0
		_ZWrite( "ZWrite", Float ) = 0
		_ZTest( "ZTest", Float ) = 2
		_Src( "Src", Float ) = 5
		_Dst( "Dst", Float ) = 10


		[HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		PackageRequirements
		{
			"com.unity.render-pipelines.universal": "[17.0,18.0]"
		}

		

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Lit" "ShaderGraphShader"="true" }

	LOD 0

		Cull Off

		HLSLINCLUDE
		#pragma target 2.0
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		ENDHLSL

		
		Pass
		{
			
			Name "Sprite Lit"
            Tags { "LightMode"="Universal2D" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define _DISABLE_COLOR_TINT
			#define ASE_VERSION 19909
			#define ASE_SRP_VERSION 170300
			#define REQUIRE_DEPTH_TEXTURE 1


			#if ( UNITY_VERSION >= 60010000 )
			#pragma multi_compile_instancing
			#endif

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ DEBUG_DISPLAY SKINNED_SPRITE

            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
            #define FEATURES_GRAPH_VERTEX

			#define SHADERPASS SHADERPASS_SPRITELIT

			#if ( UNITY_VERSION >= 60010000 )
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
			#endif
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/Core2D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/SurfaceData2D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging2D.hlsl"

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_VERT_POSITION


			half4 _RendererColor;

			sampler2D _VertexDisplacementNoise;
			sampler2D _ColorTexture;
			sampler2D _GradientMap;
			sampler2D _GradientShape;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _GradientShape_ST;
			float4 _GradientShapeChannel;
			float4 _VertexDisplacementNoise_ST;
			float4 _UVBasedDisplacementMaskChannel;
			float4 _VertexDisplacementNoiseChannel;
			float4 _TextureChannel;
			float4 _ColorTexture_ST;
			float4 _MainTex_ST;
			float4 _CoreColor;
			float3 _VertexDisplacementAmount;
			float2 _VertexDisplacementNoisePanSpeed;
			float2 _UVSinWaveStrength;
			float _GradientShapeRotation;
			float _InvertGradient;
			float _GradientMapDisplacement;
			float _TextureRotation;
			float _CoreIntensity;
			float _DifferentCoreColor;
			float _Brightness;
			float _AlphaBoldness;
			float _FlatAlpha;
			float _CorePower;
			float _Cull;
			float _UseVertexNormals;
			float _DepthFadeDivide;
			float _CustomData1XAffectsStrength;
			float _UVBasedDisplacementMaskDisplacement;
			float _UVBasedDisplacementMaskSoften;
			float _ClampDisplacement;
			float _UVSinWaveSpeed;
			float _UVSinWaveFrequency;
			float _VertexDisplacementNoiseStrength;
			float _CustomData1YAffectsSpeed;
			float _VertexDisplacementNoiseRotation;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _ColorRotation;
			float _UseDepthFade;
			CBUFFER_END


			struct VertexInput
			{
				float3 positionOS : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_SKINNED_VERTEX_INPUTS
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0 : TEXCOORD0;
				float4 color : TEXCOORD1;
				float3 positionWS : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#if ETC1_EXTERNAL_ALPHA
				TEXTURE2D(_AlphaTex); SAMPLER(sampler_AlphaTex);
				float _EnableAlphaTexture;
			#endif

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_SKINNED_VERTEX_COMPUTE(v);

				v.positionOS = UnityFlipSprite( v.positionOS, unity_SpriteProps.xy );

				float2 uv_VertexDisplacementNoise = v.uv0.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float cos204 = cos( radians( _VertexDisplacementNoiseRotation ) );
				float sin204 = sin( radians( _VertexDisplacementNoiseRotation ) );
				float2 rotator204 = mul( uv_VertexDisplacementNoise - float2( 0.5,0.5 ) , float2x2( cos204 , -sin204 , sin204 , cos204 )) + float2( 0.5,0.5 );
				float4 texCoord188 = v.uv0;
				texCoord188.xy = v.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult189 = lerp( 1.0 , texCoord188.w , _CustomData1YAffectsSpeed);
				float SpeedVariant192 = lerpResult189;
				float4 uvs4_VertexDisplacementNoise = v.uv0;
				uvs4_VertexDisplacementNoise.xy = v.uv0.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 uv2s4_VertexDisplacementNoise = v.ase_texcoord1;
				uv2s4_VertexDisplacementNoise.xy = v.ase_texcoord1.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 appendResult209 = (float4(uv2s4_VertexDisplacementNoise.z , uv2s4_VertexDisplacementNoise.w , 0.0 , 0.0));
				float dotResult223 = dot( tex2Dlod( _VertexDisplacementNoise, float4( ( float4( rotator204, 0.0 , 0.0 ) + float4( ( _TimeParameters.x * _VertexDisplacementNoisePanSpeed * SpeedVariant192 ), 0.0 , 0.0 ) + uvs4_VertexDisplacementNoise.w + appendResult209 ).xy, 0, 0.0) ) , _VertexDisplacementNoiseChannel );
				float2 texCoord205 = v.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime213 = _TimeParameters.x * ( _UVSinWaveSpeed * SpeedVariant192 );
				float dotResult228 = dot( sin( ( ( texCoord205 * _UVSinWaveFrequency ) + mulTime213 ) ) , _UVSinWaveStrength );
				float temp_output_234_0 = ( ( dotResult223 * _VertexDisplacementNoiseStrength ) + dotResult228 );
				float lerpResult243 = lerp( -1.0 , 1.0 , temp_output_234_0);
				float lerpResult261 = lerp( 0.0 , 1.0 , temp_output_234_0);
				float lerpResult262 = lerp( lerpResult243 , lerpResult261 , _ClampDisplacement);
				float2 texCoord214 = v.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult217 = dot( float4( texCoord214, 0.0 , 0.0 ) , _UVBasedDisplacementMaskChannel );
				float smoothstepResult233 = smoothstep( 0.0 , _UVBasedDisplacementMaskSoften , saturate( ( dotResult217 + _UVBasedDisplacementMaskDisplacement ) ));
				float lerpResult211 = lerp( 1.0 , texCoord188.z , _CustomData1XAffectsStrength);
				float StrengthVariant216 = lerpResult211;
				float VertexDisplacement236 = ( lerpResult262 * smoothstepResult233 * StrengthVariant216 );
				float3 lerpResult267 = lerp( float3( 1,1,1 ) , v.normal , _UseVertexNormals);
				
				float4 ase_positionCS = TransformObjectToHClip( ( v.positionOS ).xyz );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				o.ase_texcoord3 = screenPos;
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( v.positionOS ) );
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord4.x = eyeDepth;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( VertexDisplacement236 * lerpResult267 * _VertexDisplacementAmount );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS = vertexValue;
				#else
					v.positionOS += vertexValue;
				#endif
				v.normal = v.normal;
				v.tangent.xyz = v.tangent.xyz;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS);

				o.positionCS = vertexInput.positionCS;
				o.positionWS = vertexInput.positionWS;
				o.texCoord0 = v.uv0;
				o.color = v.color * _RendererColor * unity_SpriteColor;
				return o;
			}

			half4 frag( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				float4 positionCS = IN.positionCS;
				float3 positionWS = IN.positionWS;

				float2 uv_ColorTexture = IN.texCoord0.xy * _ColorTexture_ST.xy + _ColorTexture_ST.zw;
				float cos107 = cos( radians( _ColorRotation ) );
				float sin107 = sin( radians( _ColorRotation ) );
				float2 rotator107 = mul( uv_ColorTexture - float2( 0.5,0.5 ) , float2x2( cos107 , -sin107 , sin107 , cos107 )) + float2( 0.5,0.5 );
				float2 uv_GradientShape = IN.texCoord0.xy * _GradientShape_ST.xy + _GradientShape_ST.zw;
				float cos101 = cos( radians( _GradientShapeRotation ) );
				float sin101 = sin( radians( _GradientShapeRotation ) );
				float2 rotator101 = mul( uv_GradientShape - float2( 0.5,0.5 ) , float2x2( cos101 , -sin101 , sin101 , cos101 )) + float2( 0.5,0.5 );
				float dotResult98 = dot( tex2D( _GradientShape, rotator101 ) , _GradientShapeChannel );
				float temp_output_116_0 = saturate( dotResult98 );
				float lerpResult118 = lerp( saturate( ( 1.0 - temp_output_116_0 ) ) , temp_output_116_0 , _InvertGradient);
				float2 temp_cast_1 = (( lerpResult118 + _GradientMapDisplacement )).xx;
				float3 temp_output_104_0 = ( (tex2D( _ColorTexture, rotator107 )).rgb * (tex2D( _GradientMap, temp_cast_1 )).rgb * (IN.color).rgb );
				float2 uv_MainTex = IN.texCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float cos138 = cos( radians( _TextureRotation ) );
				float sin138 = sin( radians( _TextureRotation ) );
				float2 rotator138 = mul( uv_MainTex - float2( 0.5,0.5 ) , float2x2( cos138 , -sin138 , sin138 , cos138 )) + float2( 0.5,0.5 );
				float dotResult126 = dot( tex2D( _MainTex, rotator138 ) , _TextureChannel );
				float temp_output_86_0 = ( pow( dotResult126 , _CorePower ) * _CoreIntensity );
				float4 lerpResult105 = lerp( float4( temp_output_104_0 , 0.0 ) , _CoreColor , saturate( temp_output_86_0 ));
				float4 lerpResult76 = lerp( float4( temp_output_104_0 , 0.0 ) , saturate( lerpResult105 ) , _DifferentCoreColor);
				
				float temp_output_135_0 = saturate( ( dotResult126 + temp_output_86_0 ) );
				float lerpResult184 = lerp( temp_output_135_0 , saturate( round( ( temp_output_135_0 * _AlphaBoldness ) ) ) , _FlatAlpha);
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float depthLinearEye174 = LinearEyeDepth( SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ), _ZBufferParams );
				float eyeDepth = IN.ase_texcoord4.x;
				float cameraDepthFade175 = (( eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
				float lerpResult179 = lerp( 1.0 , saturate( ( ( depthLinearEye174 - cameraDepthFade175 ) / _DepthFadeDivide ) ) , _UseDepthFade);
				

				float3 BaseColor = ( saturate( lerpResult76 ) * _Brightness ).rgb;
				float Alpha = saturate( ( lerpResult184 * saturate( lerpResult179 ) * IN.color.a ) );
				float3 Normal = float3( 0, 0, 1 );
				float AlphaClipThreshold = 0.5;

				half4 Color = half4( BaseColor, Alpha );

			#if defined( ALPHA_CLIP_THRESHOLD )
				clip( Color.a - AlphaClipThreshold );
			#endif

			#if defined(DEBUG_DISPLAY)
				SurfaceData2D surfaceData;
				InitializeSurfaceData(Color.rgb, Color.a, surfaceData);
				InputData2D inputData;
				InitializeInputData(positionWS.xy, half2(IN.texCoord0.xy), inputData);
				half4 debugColor = 0;

				SETUP_DEBUG_DATA_2D(inputData, positionWS, positionCS);

				if (CanDebugOverrideOutputColor(surfaceData, inputData, debugColor))
				{
					return debugColor;
				}
			#endif

			#if ETC1_EXTERNAL_ALPHA
				float4 alpha = SAMPLE_TEXTURE2D(_AlphaTex, sampler_AlphaTex, IN.texCoord0.xy);
				Color.a = lerp( Color.a, alpha.r, _EnableAlphaTexture);
			#endif

			#if !defined( _DISABLE_COLOR_TINT )
				Color *= IN.color;
			#endif

				return Color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
            Name "Sprite Normal"
            Tags { "LightMode"="NormalsRendering" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define _DISABLE_COLOR_TINT
			#define ASE_VERSION 19909
			#define ASE_SRP_VERSION 170300
			#define REQUIRE_DEPTH_TEXTURE 1


			#if ( UNITY_VERSION >= 60010000 )
			#pragma multi_compile_instancing
			#endif

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ SKINNED_SPRITE

			#define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define FEATURES_GRAPH_VERTEX

			#define SHADERPASS SHADERPASS_SPRITENORMAL

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/Core2D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/NormalsRenderingShared.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_COLOR


			sampler2D _VertexDisplacementNoise;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _GradientShape_ST;
			float4 _GradientShapeChannel;
			float4 _VertexDisplacementNoise_ST;
			float4 _UVBasedDisplacementMaskChannel;
			float4 _VertexDisplacementNoiseChannel;
			float4 _TextureChannel;
			float4 _ColorTexture_ST;
			float4 _MainTex_ST;
			float4 _CoreColor;
			float3 _VertexDisplacementAmount;
			float2 _VertexDisplacementNoisePanSpeed;
			float2 _UVSinWaveStrength;
			float _GradientShapeRotation;
			float _InvertGradient;
			float _GradientMapDisplacement;
			float _TextureRotation;
			float _CoreIntensity;
			float _DifferentCoreColor;
			float _Brightness;
			float _AlphaBoldness;
			float _FlatAlpha;
			float _CorePower;
			float _Cull;
			float _UseVertexNormals;
			float _DepthFadeDivide;
			float _CustomData1XAffectsStrength;
			float _UVBasedDisplacementMaskDisplacement;
			float _UVBasedDisplacementMaskSoften;
			float _ClampDisplacement;
			float _UVSinWaveSpeed;
			float _UVSinWaveFrequency;
			float _VertexDisplacementNoiseStrength;
			float _CustomData1YAffectsSpeed;
			float _VertexDisplacementNoiseRotation;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _ColorRotation;
			float _UseDepthFade;
			CBUFFER_END


			struct VertexInput
			{
				float3 positionOS : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_SKINNED_VERTEX_INPUTS
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0 : TEXCOORD0;
				float4 color : TEXCOORD1;
				float3 normalWS : TEXCOORD2;
				float4 tangentWS : TEXCOORD3;
				float3 bitangentWS : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_SKINNED_VERTEX_COMPUTE(v);

				v.positionOS = UnityFlipSprite( v.positionOS, unity_SpriteProps.xy );

				float2 uv_VertexDisplacementNoise = v.uv0.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float cos204 = cos( radians( _VertexDisplacementNoiseRotation ) );
				float sin204 = sin( radians( _VertexDisplacementNoiseRotation ) );
				float2 rotator204 = mul( uv_VertexDisplacementNoise - float2( 0.5,0.5 ) , float2x2( cos204 , -sin204 , sin204 , cos204 )) + float2( 0.5,0.5 );
				float4 texCoord188 = v.uv0;
				texCoord188.xy = v.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult189 = lerp( 1.0 , texCoord188.w , _CustomData1YAffectsSpeed);
				float SpeedVariant192 = lerpResult189;
				float4 uvs4_VertexDisplacementNoise = v.uv0;
				uvs4_VertexDisplacementNoise.xy = v.uv0.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 uv2s4_VertexDisplacementNoise = v.ase_texcoord1;
				uv2s4_VertexDisplacementNoise.xy = v.ase_texcoord1.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 appendResult209 = (float4(uv2s4_VertexDisplacementNoise.z , uv2s4_VertexDisplacementNoise.w , 0.0 , 0.0));
				float dotResult223 = dot( tex2Dlod( _VertexDisplacementNoise, float4( ( float4( rotator204, 0.0 , 0.0 ) + float4( ( _TimeParameters.x * _VertexDisplacementNoisePanSpeed * SpeedVariant192 ), 0.0 , 0.0 ) + uvs4_VertexDisplacementNoise.w + appendResult209 ).xy, 0, 0.0) ) , _VertexDisplacementNoiseChannel );
				float2 texCoord205 = v.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime213 = _TimeParameters.x * ( _UVSinWaveSpeed * SpeedVariant192 );
				float dotResult228 = dot( sin( ( ( texCoord205 * _UVSinWaveFrequency ) + mulTime213 ) ) , _UVSinWaveStrength );
				float temp_output_234_0 = ( ( dotResult223 * _VertexDisplacementNoiseStrength ) + dotResult228 );
				float lerpResult243 = lerp( -1.0 , 1.0 , temp_output_234_0);
				float lerpResult261 = lerp( 0.0 , 1.0 , temp_output_234_0);
				float lerpResult262 = lerp( lerpResult243 , lerpResult261 , _ClampDisplacement);
				float2 texCoord214 = v.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult217 = dot( float4( texCoord214, 0.0 , 0.0 ) , _UVBasedDisplacementMaskChannel );
				float smoothstepResult233 = smoothstep( 0.0 , _UVBasedDisplacementMaskSoften , saturate( ( dotResult217 + _UVBasedDisplacementMaskDisplacement ) ));
				float lerpResult211 = lerp( 1.0 , texCoord188.z , _CustomData1XAffectsStrength);
				float StrengthVariant216 = lerpResult211;
				float VertexDisplacement236 = ( lerpResult262 * smoothstepResult233 * StrengthVariant216 );
				float3 lerpResult267 = lerp( float3( 1,1,1 ) , v.normal , _UseVertexNormals);
				
				float4 ase_positionCS = TransformObjectToHClip( ( v.positionOS ).xyz );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				o.ase_texcoord5 = screenPos;
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( v.positionOS ) );
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord6.x = eyeDepth;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord6.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( VertexDisplacement236 * lerpResult267 * _VertexDisplacementAmount );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS = vertexValue;
				#else
					v.positionOS += vertexValue;
				#endif
				v.normal = v.normal;
				v.tangent.xyz = v.tangent.xyz;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS);

				o.texCoord0 = v.uv0;
				o.color = v.color * unity_SpriteColor;
				o.positionCS = vertexInput.positionCS;

				float3 normalWS = TransformObjectToWorldNormal(v.normal);
				o.normalWS = -GetViewForwardDir();
				float4 tangentWS = float4( TransformObjectToWorldDir(v.tangent.xyz), v.tangent.w);
				o.tangentWS = normalize(tangentWS);
				half crossSign = (tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
				o.bitangentWS = crossSign * cross(normalWS, tangentWS.xyz) * tangentWS.w;
				return o;
			}

			half4 frag( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				float2 uv_MainTex = IN.texCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float cos138 = cos( radians( _TextureRotation ) );
				float sin138 = sin( radians( _TextureRotation ) );
				float2 rotator138 = mul( uv_MainTex - float2( 0.5,0.5 ) , float2x2( cos138 , -sin138 , sin138 , cos138 )) + float2( 0.5,0.5 );
				float dotResult126 = dot( tex2D( _MainTex, rotator138 ) , _TextureChannel );
				float temp_output_86_0 = ( pow( dotResult126 , _CorePower ) * _CoreIntensity );
				float temp_output_135_0 = saturate( ( dotResult126 + temp_output_86_0 ) );
				float lerpResult184 = lerp( temp_output_135_0 , saturate( round( ( temp_output_135_0 * _AlphaBoldness ) ) ) , _FlatAlpha);
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float depthLinearEye174 = LinearEyeDepth( SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ), _ZBufferParams );
				float eyeDepth = IN.ase_texcoord6.x;
				float cameraDepthFade175 = (( eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
				float lerpResult179 = lerp( 1.0 , saturate( ( ( depthLinearEye174 - cameraDepthFade175 ) / _DepthFadeDivide ) ) , _UseDepthFade);
				

				float Alpha = saturate( ( lerpResult184 * saturate( lerpResult179 ) * IN.color.a ) );
				float3 Normal = float3( 0, 0, 1 );
				float AlphaClipThreshold = 0.5;

				half4 Color = half4(1.0,1.0,1.0, Alpha);

				#if defined( ALPHA_CLIP_THRESHOLD )
					clip( Color.a - AlphaClipThreshold );
				#endif

				return NormalsRenderingShared(Color, Normal, IN.tangentWS.xyz, IN.bitangentWS, IN.normalWS);
			}

			ENDHLSL
		}

		
        Pass
        {
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }

            Cull Off

            HLSLPROGRAM

			#define _DISABLE_COLOR_TINT
			#define ASE_VERSION 19909
			#define ASE_SRP_VERSION 170300
			#define REQUIRE_DEPTH_TEXTURE 1


			#if ( UNITY_VERSION >= 60010000 )
			#pragma multi_compile_instancing
			#endif

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ DEBUG_DISPLAY SKINNED_SPRITE

            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define FEATURES_GRAPH_VERTEX

            #define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENESELECTIONPASS 1

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/Core2D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION


			sampler2D _VertexDisplacementNoise;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _GradientShape_ST;
			float4 _GradientShapeChannel;
			float4 _VertexDisplacementNoise_ST;
			float4 _UVBasedDisplacementMaskChannel;
			float4 _VertexDisplacementNoiseChannel;
			float4 _TextureChannel;
			float4 _ColorTexture_ST;
			float4 _MainTex_ST;
			float4 _CoreColor;
			float3 _VertexDisplacementAmount;
			float2 _VertexDisplacementNoisePanSpeed;
			float2 _UVSinWaveStrength;
			float _GradientShapeRotation;
			float _InvertGradient;
			float _GradientMapDisplacement;
			float _TextureRotation;
			float _CoreIntensity;
			float _DifferentCoreColor;
			float _Brightness;
			float _AlphaBoldness;
			float _FlatAlpha;
			float _CorePower;
			float _Cull;
			float _UseVertexNormals;
			float _DepthFadeDivide;
			float _CustomData1XAffectsStrength;
			float _UVBasedDisplacementMaskDisplacement;
			float _UVBasedDisplacementMaskSoften;
			float _ClampDisplacement;
			float _UVSinWaveSpeed;
			float _UVSinWaveFrequency;
			float _VertexDisplacementNoiseStrength;
			float _CustomData1YAffectsSpeed;
			float _VertexDisplacementNoiseRotation;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _ColorRotation;
			float _UseDepthFade;
			CBUFFER_END


            struct VertexInput
			{
				float3 positionOS : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_SKINNED_VERTEX_INPUTS
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            int _ObjectId;
            int _PassValue;

			
			VertexOutput vert(VertexInput v )
			{
				VertexOutput o = (VertexOutput)0;

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_SKINNED_VERTEX_COMPUTE(v);

				v.positionOS = UnityFlipSprite( v.positionOS, unity_SpriteProps.xy );

				float2 uv_VertexDisplacementNoise = v.ase_texcoord * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float cos204 = cos( radians( _VertexDisplacementNoiseRotation ) );
				float sin204 = sin( radians( _VertexDisplacementNoiseRotation ) );
				float2 rotator204 = mul( uv_VertexDisplacementNoise - float2( 0.5,0.5 ) , float2x2( cos204 , -sin204 , sin204 , cos204 )) + float2( 0.5,0.5 );
				float4 texCoord188 = v.ase_texcoord;
				texCoord188.xy = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult189 = lerp( 1.0 , texCoord188.w , _CustomData1YAffectsSpeed);
				float SpeedVariant192 = lerpResult189;
				float4 uvs4_VertexDisplacementNoise = v.ase_texcoord;
				uvs4_VertexDisplacementNoise.xy = v.ase_texcoord.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 uv2s4_VertexDisplacementNoise = v.ase_texcoord1;
				uv2s4_VertexDisplacementNoise.xy = v.ase_texcoord1.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 appendResult209 = (float4(uv2s4_VertexDisplacementNoise.z , uv2s4_VertexDisplacementNoise.w , 0.0 , 0.0));
				float dotResult223 = dot( tex2Dlod( _VertexDisplacementNoise, float4( ( float4( rotator204, 0.0 , 0.0 ) + float4( ( _TimeParameters.x * _VertexDisplacementNoisePanSpeed * SpeedVariant192 ), 0.0 , 0.0 ) + uvs4_VertexDisplacementNoise.w + appendResult209 ).xy, 0, 0.0) ) , _VertexDisplacementNoiseChannel );
				float2 texCoord205 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime213 = _TimeParameters.x * ( _UVSinWaveSpeed * SpeedVariant192 );
				float dotResult228 = dot( sin( ( ( texCoord205 * _UVSinWaveFrequency ) + mulTime213 ) ) , _UVSinWaveStrength );
				float temp_output_234_0 = ( ( dotResult223 * _VertexDisplacementNoiseStrength ) + dotResult228 );
				float lerpResult243 = lerp( -1.0 , 1.0 , temp_output_234_0);
				float lerpResult261 = lerp( 0.0 , 1.0 , temp_output_234_0);
				float lerpResult262 = lerp( lerpResult243 , lerpResult261 , _ClampDisplacement);
				float2 texCoord214 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult217 = dot( float4( texCoord214, 0.0 , 0.0 ) , _UVBasedDisplacementMaskChannel );
				float smoothstepResult233 = smoothstep( 0.0 , _UVBasedDisplacementMaskSoften , saturate( ( dotResult217 + _UVBasedDisplacementMaskDisplacement ) ));
				float lerpResult211 = lerp( 1.0 , texCoord188.z , _CustomData1XAffectsStrength);
				float StrengthVariant216 = lerpResult211;
				float VertexDisplacement236 = ( lerpResult262 * smoothstepResult233 * StrengthVariant216 );
				float3 lerpResult267 = lerp( float3( 1,1,1 ) , v.normal , _UseVertexNormals);
				
				float4 ase_positionCS = TransformObjectToHClip( ( v.positionOS ).xyz );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				o.ase_texcoord1 = screenPos;
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( v.positionOS ) );
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord2.x = eyeDepth;
				
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.yzw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( VertexDisplacement236 * lerpResult267 * _VertexDisplacementAmount );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS = vertexValue;
				#else
					v.positionOS += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS);

				o.positionCS = vertexInput.positionCS;
				return o;
			}

			half4 frag(VertexOutput IN) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				float2 uv_MainTex = IN.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float cos138 = cos( radians( _TextureRotation ) );
				float sin138 = sin( radians( _TextureRotation ) );
				float2 rotator138 = mul( uv_MainTex - float2( 0.5,0.5 ) , float2x2( cos138 , -sin138 , sin138 , cos138 )) + float2( 0.5,0.5 );
				float dotResult126 = dot( tex2D( _MainTex, rotator138 ) , _TextureChannel );
				float temp_output_86_0 = ( pow( dotResult126 , _CorePower ) * _CoreIntensity );
				float temp_output_135_0 = saturate( ( dotResult126 + temp_output_86_0 ) );
				float lerpResult184 = lerp( temp_output_135_0 , saturate( round( ( temp_output_135_0 * _AlphaBoldness ) ) ) , _FlatAlpha);
				float4 screenPos = IN.ase_texcoord1;
				float4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float depthLinearEye174 = LinearEyeDepth( SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ), _ZBufferParams );
				float eyeDepth = IN.ase_texcoord2.x;
				float cameraDepthFade175 = (( eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
				float lerpResult179 = lerp( 1.0 , saturate( ( ( depthLinearEye174 - cameraDepthFade175 ) / _DepthFadeDivide ) ) , _UseDepthFade);
				

				float Alpha = saturate( ( lerpResult184 * saturate( lerpResult179 ) * IN.ase_color.a ) );
				float AlphaClipThreshold = 0.5;

				#if defined( ALPHA_CLIP_THRESHOLD )
					clip( Alpha - AlphaClipThreshold );
				#endif

				return half4(_ObjectId, _PassValue, 1.0, 1.0);
			}

            ENDHLSL
        }

		
        Pass
        {
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }

			Cull Off

            HLSLPROGRAM

			#define _DISABLE_COLOR_TINT
			#define ASE_VERSION 19909
			#define ASE_SRP_VERSION 170300
			#define REQUIRE_DEPTH_TEXTURE 1


			#if ( UNITY_VERSION >= 60010000 )
			#pragma multi_compile_instancing
			#endif

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ DEBUG_DISPLAY SKINNED_SPRITE

            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define FEATURES_GRAPH_VERTEX

            #define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENEPICKINGPASS 1

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/Core2D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        	#define ASE_NEEDS_TEXTURE_COORDINATES0
        	#define ASE_NEEDS_VERT_TEXTURE_COORDINATES0
        	#define ASE_NEEDS_TEXTURE_COORDINATES1
        	#define ASE_NEEDS_VERT_NORMAL
        	#define ASE_NEEDS_VERT_POSITION


			sampler2D _VertexDisplacementNoise;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _GradientShape_ST;
			float4 _GradientShapeChannel;
			float4 _VertexDisplacementNoise_ST;
			float4 _UVBasedDisplacementMaskChannel;
			float4 _VertexDisplacementNoiseChannel;
			float4 _TextureChannel;
			float4 _ColorTexture_ST;
			float4 _MainTex_ST;
			float4 _CoreColor;
			float3 _VertexDisplacementAmount;
			float2 _VertexDisplacementNoisePanSpeed;
			float2 _UVSinWaveStrength;
			float _GradientShapeRotation;
			float _InvertGradient;
			float _GradientMapDisplacement;
			float _TextureRotation;
			float _CoreIntensity;
			float _DifferentCoreColor;
			float _Brightness;
			float _AlphaBoldness;
			float _FlatAlpha;
			float _CorePower;
			float _Cull;
			float _UseVertexNormals;
			float _DepthFadeDivide;
			float _CustomData1XAffectsStrength;
			float _UVBasedDisplacementMaskDisplacement;
			float _UVBasedDisplacementMaskSoften;
			float _ClampDisplacement;
			float _UVSinWaveSpeed;
			float _UVSinWaveFrequency;
			float _VertexDisplacementNoiseStrength;
			float _CustomData1YAffectsSpeed;
			float _VertexDisplacementNoiseRotation;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _ColorRotation;
			float _UseDepthFade;
			CBUFFER_END


            struct VertexInput
			{
				float3 positionOS : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_SKINNED_VERTEX_INPUTS
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            float4 _SelectionID;

			
			VertexOutput vert(VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_SKINNED_VERTEX_COMPUTE(v);

				v.positionOS = UnityFlipSprite( v.positionOS, unity_SpriteProps.xy );

				float2 uv_VertexDisplacementNoise = v.ase_texcoord * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float cos204 = cos( radians( _VertexDisplacementNoiseRotation ) );
				float sin204 = sin( radians( _VertexDisplacementNoiseRotation ) );
				float2 rotator204 = mul( uv_VertexDisplacementNoise - float2( 0.5,0.5 ) , float2x2( cos204 , -sin204 , sin204 , cos204 )) + float2( 0.5,0.5 );
				float4 texCoord188 = v.ase_texcoord;
				texCoord188.xy = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult189 = lerp( 1.0 , texCoord188.w , _CustomData1YAffectsSpeed);
				float SpeedVariant192 = lerpResult189;
				float4 uvs4_VertexDisplacementNoise = v.ase_texcoord;
				uvs4_VertexDisplacementNoise.xy = v.ase_texcoord.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 uv2s4_VertexDisplacementNoise = v.ase_texcoord1;
				uv2s4_VertexDisplacementNoise.xy = v.ase_texcoord1.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 appendResult209 = (float4(uv2s4_VertexDisplacementNoise.z , uv2s4_VertexDisplacementNoise.w , 0.0 , 0.0));
				float dotResult223 = dot( tex2Dlod( _VertexDisplacementNoise, float4( ( float4( rotator204, 0.0 , 0.0 ) + float4( ( _TimeParameters.x * _VertexDisplacementNoisePanSpeed * SpeedVariant192 ), 0.0 , 0.0 ) + uvs4_VertexDisplacementNoise.w + appendResult209 ).xy, 0, 0.0) ) , _VertexDisplacementNoiseChannel );
				float2 texCoord205 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime213 = _TimeParameters.x * ( _UVSinWaveSpeed * SpeedVariant192 );
				float dotResult228 = dot( sin( ( ( texCoord205 * _UVSinWaveFrequency ) + mulTime213 ) ) , _UVSinWaveStrength );
				float temp_output_234_0 = ( ( dotResult223 * _VertexDisplacementNoiseStrength ) + dotResult228 );
				float lerpResult243 = lerp( -1.0 , 1.0 , temp_output_234_0);
				float lerpResult261 = lerp( 0.0 , 1.0 , temp_output_234_0);
				float lerpResult262 = lerp( lerpResult243 , lerpResult261 , _ClampDisplacement);
				float2 texCoord214 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult217 = dot( float4( texCoord214, 0.0 , 0.0 ) , _UVBasedDisplacementMaskChannel );
				float smoothstepResult233 = smoothstep( 0.0 , _UVBasedDisplacementMaskSoften , saturate( ( dotResult217 + _UVBasedDisplacementMaskDisplacement ) ));
				float lerpResult211 = lerp( 1.0 , texCoord188.z , _CustomData1XAffectsStrength);
				float StrengthVariant216 = lerpResult211;
				float VertexDisplacement236 = ( lerpResult262 * smoothstepResult233 * StrengthVariant216 );
				float3 lerpResult267 = lerp( float3( 1,1,1 ) , v.normal , _UseVertexNormals);
				
				float4 ase_positionCS = TransformObjectToHClip( ( v.positionOS ).xyz );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				o.ase_texcoord1 = screenPos;
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( v.positionOS ) );
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord2.x = eyeDepth;
				
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( VertexDisplacement236 * lerpResult267 * _VertexDisplacementAmount );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS = vertexValue;
				#else
					v.positionOS += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS);

				o.positionCS = vertexInput.positionCS;
				return o;
			}

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				float2 uv_MainTex = IN.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float cos138 = cos( radians( _TextureRotation ) );
				float sin138 = sin( radians( _TextureRotation ) );
				float2 rotator138 = mul( uv_MainTex - float2( 0.5,0.5 ) , float2x2( cos138 , -sin138 , sin138 , cos138 )) + float2( 0.5,0.5 );
				float dotResult126 = dot( tex2D( _MainTex, rotator138 ) , _TextureChannel );
				float temp_output_86_0 = ( pow( dotResult126 , _CorePower ) * _CoreIntensity );
				float temp_output_135_0 = saturate( ( dotResult126 + temp_output_86_0 ) );
				float lerpResult184 = lerp( temp_output_135_0 , saturate( round( ( temp_output_135_0 * _AlphaBoldness ) ) ) , _FlatAlpha);
				float4 screenPos = IN.ase_texcoord1;
				float4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float depthLinearEye174 = LinearEyeDepth( SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ), _ZBufferParams );
				float eyeDepth = IN.ase_texcoord2.x;
				float cameraDepthFade175 = (( eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
				float lerpResult179 = lerp( 1.0 , saturate( ( ( depthLinearEye174 - cameraDepthFade175 ) / _DepthFadeDivide ) ) , _UseDepthFade);
				

				float Alpha = saturate( ( lerpResult184 * saturate( lerpResult179 ) * IN.ase_color.a ) );
				float AlphaClipThreshold = 0.5;

				#if defined( ALPHA_CLIP_THRESHOLD )
					clip( Alpha - AlphaClipThreshold );
				#endif

				return unity_SelectionID;
			}

            ENDHLSL
        }

		
		Pass
		{
			
            Name "Sprite Forward"
            Tags { "LightMode"="UniversalForward" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define _DISABLE_COLOR_TINT
			#define ASE_VERSION 19909
			#define ASE_SRP_VERSION 170300
			#define REQUIRE_DEPTH_TEXTURE 1


			#if ( UNITY_VERSION >= 60010000 )
			#pragma multi_compile_instancing
			#endif

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ DEBUG_DISPLAY SKINNED_SPRITE

            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
            #define FEATURES_GRAPH_VERTEX

			#define SHADERPASS SHADERPASS_SPRITEFORWARD

			#if ( UNITY_VERSION >= 60010000 )
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
			#endif
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/Core2D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/SurfaceData2D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging2D.hlsl"

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_VERT_POSITION


			half4 _RendererColor;

			sampler2D _VertexDisplacementNoise;
			sampler2D _ColorTexture;
			sampler2D _GradientMap;
			sampler2D _GradientShape;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _GradientShape_ST;
			float4 _GradientShapeChannel;
			float4 _VertexDisplacementNoise_ST;
			float4 _UVBasedDisplacementMaskChannel;
			float4 _VertexDisplacementNoiseChannel;
			float4 _TextureChannel;
			float4 _ColorTexture_ST;
			float4 _MainTex_ST;
			float4 _CoreColor;
			float3 _VertexDisplacementAmount;
			float2 _VertexDisplacementNoisePanSpeed;
			float2 _UVSinWaveStrength;
			float _GradientShapeRotation;
			float _InvertGradient;
			float _GradientMapDisplacement;
			float _TextureRotation;
			float _CoreIntensity;
			float _DifferentCoreColor;
			float _Brightness;
			float _AlphaBoldness;
			float _FlatAlpha;
			float _CorePower;
			float _Cull;
			float _UseVertexNormals;
			float _DepthFadeDivide;
			float _CustomData1XAffectsStrength;
			float _UVBasedDisplacementMaskDisplacement;
			float _UVBasedDisplacementMaskSoften;
			float _ClampDisplacement;
			float _UVSinWaveSpeed;
			float _UVSinWaveFrequency;
			float _VertexDisplacementNoiseStrength;
			float _CustomData1YAffectsSpeed;
			float _VertexDisplacementNoiseRotation;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _ColorRotation;
			float _UseDepthFade;
			CBUFFER_END


			struct VertexInput
			{
				float3 positionOS : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_SKINNED_VERTEX_INPUTS
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0 : TEXCOORD0;
				float4 color : TEXCOORD1;
				float3 positionWS : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#if ETC1_EXTERNAL_ALPHA
				TEXTURE2D( _AlphaTex ); SAMPLER( sampler_AlphaTex );
				float _EnableAlphaTexture;
			#endif

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_SKINNED_VERTEX_COMPUTE(v);

				v.positionOS = UnityFlipSprite( v.positionOS, unity_SpriteProps.xy );

				float2 uv_VertexDisplacementNoise = v.uv0.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float cos204 = cos( radians( _VertexDisplacementNoiseRotation ) );
				float sin204 = sin( radians( _VertexDisplacementNoiseRotation ) );
				float2 rotator204 = mul( uv_VertexDisplacementNoise - float2( 0.5,0.5 ) , float2x2( cos204 , -sin204 , sin204 , cos204 )) + float2( 0.5,0.5 );
				float4 texCoord188 = v.uv0;
				texCoord188.xy = v.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult189 = lerp( 1.0 , texCoord188.w , _CustomData1YAffectsSpeed);
				float SpeedVariant192 = lerpResult189;
				float4 uvs4_VertexDisplacementNoise = v.uv0;
				uvs4_VertexDisplacementNoise.xy = v.uv0.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 uv2s4_VertexDisplacementNoise = v.ase_texcoord1;
				uv2s4_VertexDisplacementNoise.xy = v.ase_texcoord1.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 appendResult209 = (float4(uv2s4_VertexDisplacementNoise.z , uv2s4_VertexDisplacementNoise.w , 0.0 , 0.0));
				float dotResult223 = dot( tex2Dlod( _VertexDisplacementNoise, float4( ( float4( rotator204, 0.0 , 0.0 ) + float4( ( _TimeParameters.x * _VertexDisplacementNoisePanSpeed * SpeedVariant192 ), 0.0 , 0.0 ) + uvs4_VertexDisplacementNoise.w + appendResult209 ).xy, 0, 0.0) ) , _VertexDisplacementNoiseChannel );
				float2 texCoord205 = v.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime213 = _TimeParameters.x * ( _UVSinWaveSpeed * SpeedVariant192 );
				float dotResult228 = dot( sin( ( ( texCoord205 * _UVSinWaveFrequency ) + mulTime213 ) ) , _UVSinWaveStrength );
				float temp_output_234_0 = ( ( dotResult223 * _VertexDisplacementNoiseStrength ) + dotResult228 );
				float lerpResult243 = lerp( -1.0 , 1.0 , temp_output_234_0);
				float lerpResult261 = lerp( 0.0 , 1.0 , temp_output_234_0);
				float lerpResult262 = lerp( lerpResult243 , lerpResult261 , _ClampDisplacement);
				float2 texCoord214 = v.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult217 = dot( float4( texCoord214, 0.0 , 0.0 ) , _UVBasedDisplacementMaskChannel );
				float smoothstepResult233 = smoothstep( 0.0 , _UVBasedDisplacementMaskSoften , saturate( ( dotResult217 + _UVBasedDisplacementMaskDisplacement ) ));
				float lerpResult211 = lerp( 1.0 , texCoord188.z , _CustomData1XAffectsStrength);
				float StrengthVariant216 = lerpResult211;
				float VertexDisplacement236 = ( lerpResult262 * smoothstepResult233 * StrengthVariant216 );
				float3 lerpResult267 = lerp( float3( 1,1,1 ) , v.normal , _UseVertexNormals);
				
				float4 ase_positionCS = TransformObjectToHClip( ( v.positionOS ).xyz );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				o.ase_texcoord3 = screenPos;
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( v.positionOS ) );
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord4.x = eyeDepth;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS;
				#else
					float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = ( VertexDisplacement236 * lerpResult267 * _VertexDisplacementAmount );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS = vertexValue;
				#else
					v.positionOS += vertexValue;
				#endif
				v.normal = v.normal;
				v.tangent.xyz = v.tangent.xyz;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS);

				o.positionCS = vertexInput.positionCS;
				o.positionWS = vertexInput.positionWS;
				o.texCoord0 = v.uv0;
				o.color = v.color * _RendererColor * unity_SpriteColor;
				return o;
			}

			half4 frag( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				float4 positionCS = IN.positionCS;
				float3 positionWS = IN.positionWS;

				float2 uv_ColorTexture = IN.texCoord0.xy * _ColorTexture_ST.xy + _ColorTexture_ST.zw;
				float cos107 = cos( radians( _ColorRotation ) );
				float sin107 = sin( radians( _ColorRotation ) );
				float2 rotator107 = mul( uv_ColorTexture - float2( 0.5,0.5 ) , float2x2( cos107 , -sin107 , sin107 , cos107 )) + float2( 0.5,0.5 );
				float2 uv_GradientShape = IN.texCoord0.xy * _GradientShape_ST.xy + _GradientShape_ST.zw;
				float cos101 = cos( radians( _GradientShapeRotation ) );
				float sin101 = sin( radians( _GradientShapeRotation ) );
				float2 rotator101 = mul( uv_GradientShape - float2( 0.5,0.5 ) , float2x2( cos101 , -sin101 , sin101 , cos101 )) + float2( 0.5,0.5 );
				float dotResult98 = dot( tex2D( _GradientShape, rotator101 ) , _GradientShapeChannel );
				float temp_output_116_0 = saturate( dotResult98 );
				float lerpResult118 = lerp( saturate( ( 1.0 - temp_output_116_0 ) ) , temp_output_116_0 , _InvertGradient);
				float2 temp_cast_1 = (( lerpResult118 + _GradientMapDisplacement )).xx;
				float3 temp_output_104_0 = ( (tex2D( _ColorTexture, rotator107 )).rgb * (tex2D( _GradientMap, temp_cast_1 )).rgb * (IN.color).rgb );
				float2 uv_MainTex = IN.texCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float cos138 = cos( radians( _TextureRotation ) );
				float sin138 = sin( radians( _TextureRotation ) );
				float2 rotator138 = mul( uv_MainTex - float2( 0.5,0.5 ) , float2x2( cos138 , -sin138 , sin138 , cos138 )) + float2( 0.5,0.5 );
				float dotResult126 = dot( tex2D( _MainTex, rotator138 ) , _TextureChannel );
				float temp_output_86_0 = ( pow( dotResult126 , _CorePower ) * _CoreIntensity );
				float4 lerpResult105 = lerp( float4( temp_output_104_0 , 0.0 ) , _CoreColor , saturate( temp_output_86_0 ));
				float4 lerpResult76 = lerp( float4( temp_output_104_0 , 0.0 ) , saturate( lerpResult105 ) , _DifferentCoreColor);
				
				float temp_output_135_0 = saturate( ( dotResult126 + temp_output_86_0 ) );
				float lerpResult184 = lerp( temp_output_135_0 , saturate( round( ( temp_output_135_0 * _AlphaBoldness ) ) ) , _FlatAlpha);
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float depthLinearEye174 = LinearEyeDepth( SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ), _ZBufferParams );
				float eyeDepth = IN.ase_texcoord4.x;
				float cameraDepthFade175 = (( eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
				float lerpResult179 = lerp( 1.0 , saturate( ( ( depthLinearEye174 - cameraDepthFade175 ) / _DepthFadeDivide ) ) , _UseDepthFade);
				

				float3 BaseColor = ( saturate( lerpResult76 ) * _Brightness ).rgb;
				float Alpha = saturate( ( lerpResult184 * saturate( lerpResult179 ) * IN.color.a ) );
				float3 Normal = float3( 0, 0, 1 );
				float AlphaClipThreshold = 0.5;

				half4 Color = half4( BaseColor,  Alpha);

			#if defined( ALPHA_CLIP_THRESHOLD )
				clip( Color.a - AlphaClipThreshold );
			#endif

			#if defined(DEBUG_DISPLAY)
				SurfaceData2D surfaceData;
				InitializeSurfaceData(Color.rgb, Color.a, surfaceData);
				InputData2D inputData;
				InitializeInputData(positionWS.xy, half2(IN.texCoord0.xy), inputData);
				half4 debugColor = 0;

				SETUP_DEBUG_DATA_2D(inputData, positionWS, positionCS);

				if (CanDebugOverrideOutputColor(surfaceData, inputData, debugColor))
				{
					return debugColor;
				}
			#endif

			#if ETC1_EXTERNAL_ALPHA
				float4 alpha = SAMPLE_TEXTURE2D( _AlphaTex, sampler_AlphaTex, IN.texCoord0.xy );
				Color.a = lerp( Color.a, alpha.r, _EnableAlphaTexture );
			#endif

			#if !defined( _DISABLE_COLOR_TINT )
				Color *= IN.color;
			#endif

				return Color;
			}

			ENDHLSL
		}
		
	}
	

	

	CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19909
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;187;-3850.873,2377.648;Inherit;False;Property;_CustomData1YAffectsSpeed;Custom Data 1 Y Affects Speed;24;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;188;-3954.056,2499.001;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;97;-2513.271,-461.0901;Inherit;False;Property;_GradientShapeRotation;Gradient Shape Rotation;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;99;-2673.34,-825.0892;Inherit;True;Property;_GradientShape;Gradient Shape;5;1;[Header];Create;True;1;Gradient Shape;0;0;False;0;False;None;None;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;190;-2924.894,1469.528;Inherit;False;3676.525;1880.749;Vertex Animation Noise;45;236;235;234;233;231;230;229;228;227;226;225;224;223;222;221;220;219;218;217;215;214;213;212;210;209;207;206;205;204;203;202;201;200;199;198;197;196;195;194;193;191;243;260;261;262;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;189;-3467.014,2338.019;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;74;-2367.268,-617.0903;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RadiansOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;100;-2269.268,-455.09;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;191;-2849.126,1898.568;Inherit;False;Property;_VertexDisplacementNoiseRotation;Vertex Displacement Noise Rotation;32;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;192;-3263.014,2329.019;Inherit;False;SpeedVariant;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;101;-2087.267,-591.0903;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;199;-2272.072,2414.983;Inherit;False;192;SpeedVariant;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;195;-2302.556,1519.528;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;194;-2587.721,1751.229;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;201;-2353.716,2111.429;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;196;-2489.722,1913.229;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;200;-1894.66,2852.677;Inherit;False;192;SpeedVariant;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;197;-2355.959,2205.188;Inherit;False;Property;_VertexDisplacementNoisePanSpeed;Vertex Displacement Noise  Pan Speed;30;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;198;-1945.03,2715.673;Inherit;False;Property;_UVSinWaveSpeed;UV Sin Wave Speed;27;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;131;-2718.298,308.4864;Inherit;False;Property;_TextureRotation;Texture Rotation;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;129;-2868.836,20.70718;Inherit;True;Property;_MainTex;MainTex;0;1;[Header];Create;True;1;Main Alpha;0;0;False;0;False;None;None;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;102;-1832.032,-705.4958;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;132;-1772.814,-465.6055;Inherit;False;Property;_GradientShapeChannel;Gradient Shape Channel;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;202;-2342.282,1887.337;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;205;-1833.031,2393.073;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotatorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;204;-2307.723,1777.229;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;207;-1694.461,2748.677;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;209;-1998.897,1527.557;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;206;-1913.031,2583.073;Inherit;False;Property;_UVSinWaveFrequency;UV Sin Wave Frequency;26;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;203;-1943.718,2039.429;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;128;-2572.296,152.4865;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RadiansOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;133;-2474.296,314.4864;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;98;-1381.646,-479.0361;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;193;-2905.891,1511.318;Inherit;True;Property;_VertexDisplacementNoise;Vertex Displacement Noise;28;1;[Header];Create;True;1;Vertex Displacement Noise;0;0;False;0;False;None;None;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;213;-1593.032,2585.073;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;210;-1777.42,1890.689;Inherit;False;4;4;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;215;-1529.032,2409.073;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;10;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;138;-2292.296,178.4865;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;116;-1130.521,-374.8206;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;218;-1369.032,2409.073;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;219;-1394.624,1864.858;Inherit;True;Property;_TextureSample10;Texture Sample 10;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;221;-1330.158,2104.75;Inherit;False;Property;_VertexDisplacementNoiseChannel;Vertex Displacement Noise Channel;29;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;127;-2071.739,360.816;Inherit;False;Property;_TextureChannel;Texture Channel;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;134;-2052.625,139.7253;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;113;-999.9781,-408.6806;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;222;-1232.587,2409.196;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;223;-999.1991,1877.321;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;212;-1103.545,2969.234;Inherit;False;Property;_UVBasedDisplacementMaskChannel;UV Based Displacement Mask Channel;33;1;[Header];Create;True;1;UV Based Displacement Mask;0;0;False;0;False;0,0,0,0;0,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;226;-1209.931,2287.917;Inherit;False;Property;_VertexDisplacementNoiseStrength;Vertex Displacement Noise Strength;31;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;214;-1091.094,2778.021;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;227;-1486.837,2748.605;Inherit;False;Property;_UVSinWaveStrength;UV Sin Wave Strength;25;1;[Header];Create;True;1;UV Based Sin Wave Displacement;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;87;-1625.092,443.9026;Inherit;False;Property;_CorePower;Core Power;11;1;[Header];Create;False;1;Different Center Color;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;126;-1638.4,142.6949;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;114;-897.9782,-250.6806;Inherit;False;Property;_InvertGradient;Invert Gradient;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;125;-889.1999,-1184.606;Inherit;True;Property;_ColorTexture;Color Texture;3;1;[Header];Create;True;1;Overlay Color;0;0;False;0;False;None;None;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;115;-837.9782,-438.6806;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;137;-738.6611,-900.308;Inherit;False;Property;_ColorRotation;Color Rotation;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;230;-753.931,1925.917;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;220;-1017.476,3173.58;Inherit;False;Property;_UVBasedDisplacementMaskDisplacement;UV Based Displacement Mask Displacement;34;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;228;-898.328,2507.051;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;217;-759.0612,2827.593;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;208;-3817.549,2744.891;Inherit;False;Property;_CustomData1XAffectsStrength;Custom Data 1 X Affects Strength;23;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;140;-1651.129,603.5795;Inherit;False;Property;_CoreIntensity;Core Intensity;12;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;85;-1325.956,371.7473;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;118;-649.9781,-482.6806;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;117;-583.9781,-218.6806;Inherit;False;Property;_GradientMapDisplacement;Gradient Map Displacement;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;124;-592.6614,-1056.307;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RadiansOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;123;-494.6613,-894.308;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;174;-560,800;Inherit;False;0;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;175;-720,976;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;211;-3461.014,2704.019;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;224;-608.9033,3153.058;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;234;-563.5752,2176.828;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;86;-1152,448;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;107;-312.6609,-1030.307;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;120;-291.1222,-781.3338;Inherit;True;Property;_GradientMap;Gradient Map;8;1;[Header];Create;True;1;Gradient Map;0;0;False;0;False;None;None;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;109;-270.9781,-360.6806;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;73;-1160.116,640.0095;Inherit;False;Property;_AlphaBoldness;Alpha Boldness;16;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;180;-480,1216;Inherit;False;Property;_DepthFadeDivide;Depth Fade Divide;19;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;176;-336,832;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;243;-351.2736,1993.285;Inherit;False;3;0;FLOAT;-1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;229;-466.4311,3027.579;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;216;-3263.014,2707.019;Inherit;False;StrengthVariant;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;260;-410.7454,1757.837;Inherit;False;Property;_ClampDisplacement;Clamp Displacement;22;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;231;-532.431,3249.579;Inherit;False;Property;_UVBasedDisplacementMaskSoften;UV Based Displacement Mask Soften;35;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;261;-330.7454,1855.837;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;81;445.8063,-151.9188;Inherit;False;Property;_CoreColor;Core Color;14;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;122;-72.98848,-1069.069;Inherit;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;103;500.2039,66.3109;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;119;14.34905,-674.3876;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.VertexColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;106;62.4616,-428.677;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;186;-701.5504,524.4108;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;177;-192,880;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;745.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;225;-426.0021,2309.871;Inherit;False;216;StrengthVariant;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;262;-120.7454,1863.837;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;233;-256.4311,2909.578;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;105;760.417,-78.32274;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;136;354.8574,-852.2254;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;108;386.0715,-376.6457;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;130;384.7512,-285.808;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;83;-1009.835,265.0002;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;183;-567.5531,548.8067;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;171;-176,1008;Inherit;False;Property;_UseDepthFade;Use Depth Fade;18;1;[Header];Create;True;1;Depth Fade;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;178;-32,816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;235;-80.00522,2108.895;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;75;901.9648,-199.1521;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;82;943.4619,-129.8322;Inherit;False;Property;_DifferentCoreColor;Different Core Color;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;104;655.0266,-310.9217;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;135;-843.8864,368.1976;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;182;-399.721,477.3039;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;185;-429.4622,604.2207;Inherit;False;Property;_FlatAlpha;Flat Alpha;17;0;Create;True;0;0;0;False;0;False;0;0.144;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;179;112,736;Inherit;True;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;268;596.0069,1087.14;Inherit;False;Property;_UseVertexNormals;Use Vertex Normals;21;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;236;92.34973,1866.991;Inherit;False;VertexDisplacement;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;258;674.0466,1228.15;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;76;1094.851,-305.3001;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;184;-120.7252,394.7925;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;181;400,736;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;237;778.3668,842.0676;Inherit;False;236;VertexDisplacement;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;267;992.576,1005.707;Inherit;False;3;0;FLOAT3;1,1,1;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;239;979.2106,1433.628;Inherit;False;Property;_VertexDisplacementAmount;Vertex Displacement Amount;20;1;[Header];Create;True;1;Vertex Displacement;0;0;False;0;False;0,0,0;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;79;1188.4,-162.607;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;80;1168,-32;Inherit;False;Property;_Brightness;Brightness;15;1;[Header];Create;True;1;Brightness and Opacity;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;110;634.7449,390.9565;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;78;1392,-48;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;160;1064.511,-715.4269;Inherit;False;Property;_Src;Src;39;0;Create;True;0;0;0;True;0;False;5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;158;1322.511,-717.4269;Inherit;False;Property;_Dst;Dst;40;0;Create;True;0;0;0;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;157;1576.511,-715.4269;Inherit;False;Property;_ZWrite;ZWrite;37;0;Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;159;1834.511,-717.4269;Inherit;False;Property;_ZTest;ZTest;38;0;Create;True;0;0;0;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;240;1370.643,950.847;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;168;2472,944;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;166;2136,832;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;169;2520,784;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;167;2104,976;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;170;2760,784;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;112;1008.103,344.5316;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;121;771.9019,-749.282;Inherit;False;Property;_Cull;Cull;36;1;[Header];Create;True;1;Rendering;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;335;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI;0;16;New Amplify Shader;ece0159bad6633944bf6b818f4dd296c;True;Sprite Lit;0;0;Sprite Lit;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Lit;ShaderGraphShader=true;True;0;True;14;all;0;False;True;2;5;False;;10;False;;3;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;False;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;336;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI;0;16;New Amplify Shader;ece0159bad6633944bf6b818f4dd296c;True;Sprite Normal;0;1;Sprite Normal;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Lit;ShaderGraphShader=true;True;0;True;14;all;0;False;True;2;5;False;;10;False;;3;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;False;True;1;LightMode=NormalsRendering;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;337;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI;0;16;New Amplify Shader;ece0159bad6633944bf6b818f4dd296c;True;SceneSelectionPass;0;2;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Lit;ShaderGraphShader=true;True;0;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;338;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI;0;16;New Amplify Shader;ece0159bad6633944bf6b818f4dd296c;True;ScenePickingPass;0;3;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Lit;ShaderGraphShader=true;True;0;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;339;1799.307,34.03413;Float;False;True;-1;3;UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI;0;16;/_Kass_/SH_VFX_SimplePremult_VertexAnim;ece0159bad6633944bf6b818f4dd296c;True;Sprite Forward;0;4;Sprite Forward;7;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Lit;ShaderGraphShader=true;True;0;True;14;all;0;False;True;2;5;False;;10;False;;3;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;False;True;1;LightMode=UniversalForward;False;False;0;;0;0;Standard;5;Alpha Clipping;0;0;Disable Color Tint;1;0;Vertex Position;1;0;Debug Display;0;0;External Alpha;0;0;0;5;True;True;True;True;True;False;;False;0
WireConnection;189;1;188;4
WireConnection;189;2;187;0
WireConnection;74;2;99;0
WireConnection;100;0;97;0
WireConnection;192;0;189;0
WireConnection;101;0;74;0
WireConnection;101;2;100;0
WireConnection;195;2;193;0
WireConnection;194;2;193;0
WireConnection;196;0;191;0
WireConnection;102;0;99;0
WireConnection;102;1;101;0
WireConnection;202;2;193;0
WireConnection;204;0;194;0
WireConnection;204;2;196;0
WireConnection;207;0;198;0
WireConnection;207;1;200;0
WireConnection;209;0;195;3
WireConnection;209;1;195;4
WireConnection;203;0;201;0
WireConnection;203;1;197;0
WireConnection;203;2;199;0
WireConnection;128;2;129;0
WireConnection;133;0;131;0
WireConnection;98;0;102;0
WireConnection;98;1;132;0
WireConnection;213;0;207;0
WireConnection;210;0;204;0
WireConnection;210;1;203;0
WireConnection;210;2;202;4
WireConnection;210;3;209;0
WireConnection;215;0;205;0
WireConnection;215;1;206;0
WireConnection;138;0;128;0
WireConnection;138;2;133;0
WireConnection;116;0;98;0
WireConnection;218;0;215;0
WireConnection;218;1;213;0
WireConnection;219;0;193;0
WireConnection;219;1;210;0
WireConnection;134;0;129;0
WireConnection;134;1;138;0
WireConnection;113;0;116;0
WireConnection;222;0;218;0
WireConnection;223;0;219;0
WireConnection;223;1;221;0
WireConnection;126;0;134;0
WireConnection;126;1;127;0
WireConnection;115;0;113;0
WireConnection;230;0;223;0
WireConnection;230;1;226;0
WireConnection;228;0;222;0
WireConnection;228;1;227;0
WireConnection;217;0;214;0
WireConnection;217;1;212;0
WireConnection;85;0;126;0
WireConnection;85;1;87;0
WireConnection;118;0;115;0
WireConnection;118;1;116;0
WireConnection;118;2;114;0
WireConnection;124;2;125;0
WireConnection;123;0;137;0
WireConnection;211;1;188;3
WireConnection;211;2;208;0
WireConnection;224;0;217;0
WireConnection;224;1;220;0
WireConnection;234;0;230;0
WireConnection;234;1;228;0
WireConnection;86;0;85;0
WireConnection;86;1;140;0
WireConnection;107;0;124;0
WireConnection;107;2;123;0
WireConnection;109;0;118;0
WireConnection;109;1;117;0
WireConnection;176;0;174;0
WireConnection;176;1;175;0
WireConnection;243;2;234;0
WireConnection;229;0;224;0
WireConnection;216;0;211;0
WireConnection;261;2;234;0
WireConnection;122;0;125;0
WireConnection;122;1;107;0
WireConnection;103;0;86;0
WireConnection;119;0;120;0
WireConnection;119;1;109;0
WireConnection;186;0;135;0
WireConnection;186;1;73;0
WireConnection;177;0;176;0
WireConnection;177;1;180;0
WireConnection;262;0;243;0
WireConnection;262;1;261;0
WireConnection;262;2;260;0
WireConnection;233;0;229;0
WireConnection;233;2;231;0
WireConnection;105;0;104;0
WireConnection;105;1;81;0
WireConnection;105;2;103;0
WireConnection;136;0;122;0
WireConnection;108;0;119;0
WireConnection;130;0;106;0
WireConnection;83;0;126;0
WireConnection;83;1;86;0
WireConnection;183;0;186;0
WireConnection;178;0;177;0
WireConnection;235;0;262;0
WireConnection;235;1;233;0
WireConnection;235;2;225;0
WireConnection;75;0;105;0
WireConnection;104;0;136;0
WireConnection;104;1;108;0
WireConnection;104;2;130;0
WireConnection;135;0;83;0
WireConnection;182;0;183;0
WireConnection;179;1;178;0
WireConnection;179;2;171;0
WireConnection;236;0;235;0
WireConnection;76;0;104;0
WireConnection;76;1;75;0
WireConnection;76;2;82;0
WireConnection;184;0;135;0
WireConnection;184;1;182;0
WireConnection;184;2;185;0
WireConnection;181;0;179;0
WireConnection;267;1;258;0
WireConnection;267;2;268;0
WireConnection;79;0;76;0
WireConnection;110;0;184;0
WireConnection;110;1;181;0
WireConnection;110;2;106;4
WireConnection;78;0;79;0
WireConnection;78;1;80;0
WireConnection;240;0;237;0
WireConnection;240;1;267;0
WireConnection;240;2;239;0
WireConnection;169;0;166;0
WireConnection;169;1;167;0
WireConnection;170;0;169;0
WireConnection;170;1;168;3
WireConnection;112;0;110;0
WireConnection;339;0;78;0
WireConnection;339;1;112;0
WireConnection;339;4;240;0
ASEEND*/
//CHKSM=3B56E9F8CBDCBBEF6826BD0F898E7CC28183C399