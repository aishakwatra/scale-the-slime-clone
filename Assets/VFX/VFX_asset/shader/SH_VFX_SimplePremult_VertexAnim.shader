// Made with Amplify Shader Editor v1.9.9.9
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "/_Kass_/SH_VFX_SimplePremult_VertexAnim"
{
	Properties
	{
		[Header(Main Alpha)] _Texture( "Texture", 2D ) = "white" {}
		_TextureChannel( "Texture Channel", Vector ) = ( 0, 0, 0, 0 )
		_TextureRotation( "Texture Rotation", Float ) = 0
		[Header(Different Center Color)] _CorePower( "Core Power", Float ) = 0
		_CoreIntensity( "Core Intensity", Float ) = 0
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


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

		//[HideInInspector][ToggleUI] _AddPrecomputedVelocity("Add Precomputed Velocity", Float) = 1
		[HideInInspector][ToggleUI] _ReceiveShadows("Receive Shadows", Float) = 1.0

		//[HideInInspector] _XRMotionVectorsPass("_XRMotionVectorsPass", Float) = 1

		//[HideInInspector] _AlphaClip("__clip", Float) = 0.0
	}

	SubShader
	{
		PackageRequirements
		{
			"com.unity.render-pipelines.universal": "[17.0,18.0]"
		}

		

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Unlit" }

	LOD 0

		Cull Back
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma shader_feature_local_fragment _RECEIVE_SHADOWS_OFF
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#define UNLIT_DEFAULT_SSAO 1
			#define UNLIT_DEFAULT_DECAL_BLENDING 1
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define ASE_VERSION 19909
			#define ASE_SRP_VERSION 170300
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			// Option "Keep Lighting Variants" @david please keep this note for future changes in Unlit  lighting
			//#define UNLIT_REALTIME_LIGHTING 1
			//#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			//#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			//#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			//#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			//#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			//#pragma multi_compile_fragment _ _REFLECTION_PROBE_ATLAS
			//#pragma multi_compile _ REFLECTION_PROBE_ROTATION
			//#pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
			//#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			//#pragma multi_compile _ SHADOWS_SHADOWMASK
			//#pragma multi_compile_fragment _ _LIGHT_LAYERS
			//#pragma multi_compile_fragment _ _LIGHT_COOKIES
			//#pragma multi_compile _ _CLUSTER_LIGHT_LOOP

			#define SHADERPASS SHADERPASS_UNLIT

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#if ( UNITY_VERSION >= 60010000 )
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
			#else
			#pragma multi_compile_fog
			#endif
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_VERT_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 positionWSAndFogFactor : TEXCOORD0;
				half3 normalWS : TEXCOORD1;
				half4 tangentWS : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _UVBasedDisplacementMaskChannel;
			float4 _VertexDisplacementNoise_ST;
			float4 _TextureChannel;
			float4 _Texture_ST;
			float4 _VertexDisplacementNoiseChannel;
			float3 _VertexDisplacementAmount;
			float2 _UVSinWaveStrength;
			float2 _VertexDisplacementNoisePanSpeed;
			float _CustomData1XAffectsStrength;
			float _UseVertexNormals;
			float _TextureRotation;
			float _CorePower;
			float _CoreIntensity;
			float _AlphaBoldness;
			float _FlatAlpha;
			float _UVBasedDisplacementMaskDisplacement;
			float _Cull;
			float _ClampDisplacement;
			float _DepthFadeDivide;
			float _UVSinWaveSpeed;
			float _UVSinWaveFrequency;
			float _VertexDisplacementNoiseStrength;
			float _CustomData1YAffectsSpeed;
			float _VertexDisplacementNoiseRotation;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _UVBasedDisplacementMaskSoften;
			float _UseDepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VertexDisplacementNoise;
			sampler2D _Texture;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float2 uv_VertexDisplacementNoise = input.ase_texcoord * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float cos204 = cos( radians( _VertexDisplacementNoiseRotation ) );
				float sin204 = sin( radians( _VertexDisplacementNoiseRotation ) );
				float2 rotator204 = mul( uv_VertexDisplacementNoise - float2( 0.5,0.5 ) , float2x2( cos204 , -sin204 , sin204 , cos204 )) + float2( 0.5,0.5 );
				float4 texCoord188 = input.ase_texcoord;
				texCoord188.xy = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult189 = lerp( 1.0 , texCoord188.w , _CustomData1YAffectsSpeed);
				float SpeedVariant192 = lerpResult189;
				float4 uvs4_VertexDisplacementNoise = input.ase_texcoord;
				uvs4_VertexDisplacementNoise.xy = input.ase_texcoord.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 uv2s4_VertexDisplacementNoise = input.ase_texcoord1;
				uv2s4_VertexDisplacementNoise.xy = input.ase_texcoord1.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 appendResult209 = (float4(uv2s4_VertexDisplacementNoise.z , uv2s4_VertexDisplacementNoise.w , 0.0 , 0.0));
				float dotResult223 = dot( tex2Dlod( _VertexDisplacementNoise, float4( ( float4( rotator204, 0.0 , 0.0 ) + float4( ( _TimeParameters.x * _VertexDisplacementNoisePanSpeed * SpeedVariant192 ), 0.0 , 0.0 ) + uvs4_VertexDisplacementNoise.w + appendResult209 ).xy, 0, 0.0) ) , _VertexDisplacementNoiseChannel );
				float2 texCoord205 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime213 = _TimeParameters.x * ( _UVSinWaveSpeed * SpeedVariant192 );
				float dotResult228 = dot( sin( ( ( texCoord205 * _UVSinWaveFrequency ) + mulTime213 ) ) , _UVSinWaveStrength );
				float temp_output_234_0 = ( ( dotResult223 * _VertexDisplacementNoiseStrength ) + dotResult228 );
				float lerpResult243 = lerp( -1.0 , 1.0 , temp_output_234_0);
				float lerpResult261 = lerp( 0.0 , 1.0 , temp_output_234_0);
				float lerpResult262 = lerp( lerpResult243 , lerpResult261 , _ClampDisplacement);
				float2 texCoord214 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult217 = dot( float4( texCoord214, 0.0 , 0.0 ) , _UVBasedDisplacementMaskChannel );
				float smoothstepResult233 = smoothstep( 0.0 , _UVBasedDisplacementMaskSoften , saturate( ( dotResult217 + _UVBasedDisplacementMaskDisplacement ) ));
				float lerpResult211 = lerp( 1.0 , texCoord188.z , _CustomData1XAffectsStrength);
				float StrengthVariant216 = lerpResult211;
				float VertexDisplacement236 = ( lerpResult262 * smoothstepResult233 * StrengthVariant216 );
				float3 lerpResult267 = lerp( float3( 1,1,1 ) , input.normalOS , _UseVertexNormals);
				
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord4.x = eyeDepth;
				
				output.ase_texcoord3 = input.ase_texcoord;
				output.ase_color = input.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord4.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( VertexDisplacement236 * lerpResult267 * _VertexDisplacementAmount );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				float fogFactor = 0;
				#if defined(ASE_FOG) && !defined(_FOG_FRAGMENT)
					fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
				#endif

				output.positionCS = vertexInput.positionCS;
				output.positionWSAndFogFactor = float4( vertexInput.positionWS, fogFactor );
				output.normalWS = normalInput.normalWS;
				output.tangentWS = half4( normalInput.tangentWS, ( input.tangentOS.w > 0.0 ? 1.0 : -1.0 ) * GetOddNegativeScale() );;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag ( PackedVaryings input
						#if defined( ASE_DEPTH_WRITE_ON )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						#if ( UNITY_VERSION >= 60020000 )
						, out uint outRenderingLayers : SV_Target1
						#else
						, out float4 outRenderingLayers : SV_Target1
						#endif
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined( _SURFACE_TYPE_TRANSPARENT )
					const bool isTransparent = true;
				#else
					const bool isTransparent = false;
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					float4 shadowCoord = TransformWorldToShadowCoord( input.positionWSAndFogFactor.xyz );
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				// @diogo: mikktspace compliant
				float renormFactor = 1.0 / max( FLT_MIN, length( input.normalWS ) );

				float3 PositionWS = input.positionWSAndFogFactor.xyz;
				float3 PositionRWS = GetCameraRelativePositionWS( PositionWS );
				half3 ViewDirWS = GetWorldSpaceNormalizeViewDir( PositionWS );
				float4 ShadowCoord = shadowCoord;
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );
				float3 TangentWS = input.tangentWS.xyz * renormFactor;
				float3 BitangentWS = cross( input.normalWS, input.tangentWS.xyz ) * input.tangentWS.w * renormFactor;
				float3 NormalWS = input.normalWS * renormFactor;

				float2 uv_Texture = input.ase_texcoord3.xy * _Texture_ST.xy + _Texture_ST.zw;
				float cos138 = cos( radians( _TextureRotation ) );
				float sin138 = sin( radians( _TextureRotation ) );
				float2 rotator138 = mul( uv_Texture - float2( 0.5,0.5 ) , float2x2( cos138 , -sin138 , sin138 , cos138 )) + float2( 0.5,0.5 );
				float dotResult126 = dot( tex2D( _Texture, rotator138 ) , _TextureChannel );
				float temp_output_86_0 = ( pow( dotResult126 , _CorePower ) * _CoreIntensity );
				float temp_output_135_0 = saturate( ( dotResult126 + temp_output_86_0 ) );
				float lerpResult184 = lerp( temp_output_135_0 , saturate( round( ( temp_output_135_0 * _AlphaBoldness ) ) ) , _FlatAlpha);
				float depthLinearEye174 = LinearEyeDepth( SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ), _ZBufferParams );
				float eyeDepth = input.ase_texcoord4.x;
				float cameraDepthFade175 = (( eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
				float lerpResult179 = lerp( 1.0 , saturate( ( ( depthLinearEye174 - cameraDepthFade175 ) / _DepthFadeDivide ) ) , _UseDepthFade);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = float3(0.5, 0.5, 0.5);
				float Alpha = saturate( ( lerpResult184 * saturate( lerpResult179 ) * input.ase_color.a ) );
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _Cutoff;
					float AlphaClipThresholdShadow = 0.5;
				#endif


				#if defined( ASE_DEPTH_WRITE_ON )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_CHANGES_WORLD_POS)
					ShadowCoord = TransformWorldToShadowCoord( PositionWS );
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = PositionWS;
				inputData.positionCS = input.positionCS;
				inputData.normalizedScreenSpaceUV = ScreenPosNorm.xy;
				inputData.normalWS = NormalWS;
				inputData.viewDirectionWS = ViewDirWS;

				#if defined(_SCREEN_SPACE_OCCLUSION) && !defined(_SURFACE_TYPE_TRANSPARENT) && defined(UNLIT_DEFAULT_SSAO)
					float2 normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
					AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(normalizedScreenSpaceUV);
					Color.rgb *= aoFactor.directAmbientOcclusion;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.positionWSAndFogFactor.w);
				#endif

				#if defined(_DBUFFER) && defined(UNLIT_DEFAULT_DECAL_BLENDING)
					ApplyDecalToBaseColor(input.positionCS, Color);
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						Color.rgb = MixFogColor(Color.rgb, half3(0,0,0), inputData.fogCoord);
					#else
						Color.rgb = MixFog(Color.rgb, inputData.fogCoord);
					#endif
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					outputDepth = input.positionCS.z;
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					#if ( UNITY_VERSION >= 60020000 )
					outRenderingLayers = EncodeMeshRenderingLayer();
					#else
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
					#endif
				#endif

				#if defined( ASE_OPAQUE_KEEP_ALPHA )
					return half4( Color, Alpha );
				#else
					return half4( Color, OutputAlpha( Alpha, isTransparent ) );
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define ASE_VERSION 19909
			#define ASE_SRP_VERSION 170300
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_VERT_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _UVBasedDisplacementMaskChannel;
			float4 _VertexDisplacementNoise_ST;
			float4 _TextureChannel;
			float4 _Texture_ST;
			float4 _VertexDisplacementNoiseChannel;
			float3 _VertexDisplacementAmount;
			float2 _UVSinWaveStrength;
			float2 _VertexDisplacementNoisePanSpeed;
			float _CustomData1XAffectsStrength;
			float _UseVertexNormals;
			float _TextureRotation;
			float _CorePower;
			float _CoreIntensity;
			float _AlphaBoldness;
			float _FlatAlpha;
			float _UVBasedDisplacementMaskDisplacement;
			float _Cull;
			float _ClampDisplacement;
			float _DepthFadeDivide;
			float _UVSinWaveSpeed;
			float _UVSinWaveFrequency;
			float _VertexDisplacementNoiseStrength;
			float _CustomData1YAffectsSpeed;
			float _VertexDisplacementNoiseRotation;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _UVBasedDisplacementMaskSoften;
			float _UseDepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VertexDisplacementNoise;
			sampler2D _Texture;


			
			float3 _LightDirection;
			float3 _LightPosition;

			PackedVaryings VertexFunction( Attributes input )
			{
				PackedVaryings output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output );

				float2 uv_VertexDisplacementNoise = input.ase_texcoord * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float cos204 = cos( radians( _VertexDisplacementNoiseRotation ) );
				float sin204 = sin( radians( _VertexDisplacementNoiseRotation ) );
				float2 rotator204 = mul( uv_VertexDisplacementNoise - float2( 0.5,0.5 ) , float2x2( cos204 , -sin204 , sin204 , cos204 )) + float2( 0.5,0.5 );
				float4 texCoord188 = input.ase_texcoord;
				texCoord188.xy = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult189 = lerp( 1.0 , texCoord188.w , _CustomData1YAffectsSpeed);
				float SpeedVariant192 = lerpResult189;
				float4 uvs4_VertexDisplacementNoise = input.ase_texcoord;
				uvs4_VertexDisplacementNoise.xy = input.ase_texcoord.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 uv2s4_VertexDisplacementNoise = input.ase_texcoord1;
				uv2s4_VertexDisplacementNoise.xy = input.ase_texcoord1.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 appendResult209 = (float4(uv2s4_VertexDisplacementNoise.z , uv2s4_VertexDisplacementNoise.w , 0.0 , 0.0));
				float dotResult223 = dot( tex2Dlod( _VertexDisplacementNoise, float4( ( float4( rotator204, 0.0 , 0.0 ) + float4( ( _TimeParameters.x * _VertexDisplacementNoisePanSpeed * SpeedVariant192 ), 0.0 , 0.0 ) + uvs4_VertexDisplacementNoise.w + appendResult209 ).xy, 0, 0.0) ) , _VertexDisplacementNoiseChannel );
				float2 texCoord205 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime213 = _TimeParameters.x * ( _UVSinWaveSpeed * SpeedVariant192 );
				float dotResult228 = dot( sin( ( ( texCoord205 * _UVSinWaveFrequency ) + mulTime213 ) ) , _UVSinWaveStrength );
				float temp_output_234_0 = ( ( dotResult223 * _VertexDisplacementNoiseStrength ) + dotResult228 );
				float lerpResult243 = lerp( -1.0 , 1.0 , temp_output_234_0);
				float lerpResult261 = lerp( 0.0 , 1.0 , temp_output_234_0);
				float lerpResult262 = lerp( lerpResult243 , lerpResult261 , _ClampDisplacement);
				float2 texCoord214 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult217 = dot( float4( texCoord214, 0.0 , 0.0 ) , _UVBasedDisplacementMaskChannel );
				float smoothstepResult233 = smoothstep( 0.0 , _UVBasedDisplacementMaskSoften , saturate( ( dotResult217 + _UVBasedDisplacementMaskDisplacement ) ));
				float lerpResult211 = lerp( 1.0 , texCoord188.z , _CustomData1XAffectsStrength);
				float StrengthVariant216 = lerpResult211;
				float VertexDisplacement236 = ( lerpResult262 * smoothstepResult233 * StrengthVariant216 );
				float3 lerpResult267 = lerp( float3( 1,1,1 ) , input.normalOS , _UseVertexNormals);
				
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord1.x = eyeDepth;
				
				output.ase_texcoord = input.ase_texcoord;
				output.ase_color = input.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord1.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( VertexDisplacement236 * lerpResult267 * _VertexDisplacementAmount );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				float3 positionWS = TransformObjectToWorld( input.positionOS.xyz );
				half3 normalWS = TransformObjectToWorldDir(input.normalOS);

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				#if UNITY_REVERSED_Z
					positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
				#else
					positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
				#endif

				output.positionCS = positionCS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input
						#if defined( ASE_DEPTH_WRITE_ON )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( input );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );

				float2 uv_Texture = input.ase_texcoord.xy * _Texture_ST.xy + _Texture_ST.zw;
				float cos138 = cos( radians( _TextureRotation ) );
				float sin138 = sin( radians( _TextureRotation ) );
				float2 rotator138 = mul( uv_Texture - float2( 0.5,0.5 ) , float2x2( cos138 , -sin138 , sin138 , cos138 )) + float2( 0.5,0.5 );
				float dotResult126 = dot( tex2D( _Texture, rotator138 ) , _TextureChannel );
				float temp_output_86_0 = ( pow( dotResult126 , _CorePower ) * _CoreIntensity );
				float temp_output_135_0 = saturate( ( dotResult126 + temp_output_86_0 ) );
				float lerpResult184 = lerp( temp_output_135_0 , saturate( round( ( temp_output_135_0 * _AlphaBoldness ) ) ) , _FlatAlpha);
				float depthLinearEye174 = LinearEyeDepth( SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ), _ZBufferParams );
				float eyeDepth = input.ase_texcoord1.x;
				float cameraDepthFade175 = (( eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
				float lerpResult179 = lerp( 1.0 , saturate( ( ( depthLinearEye174 - cameraDepthFade175 ) / _DepthFadeDivide ) ) , _UseDepthFade);
				

				float Alpha = saturate( ( lerpResult184 * saturate( lerpResult179 ) * input.ase_color.a ) );
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _Cutoff;
					float AlphaClipThresholdShadow = 0.5;
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					#if defined( _ALPHATEST_SHADOW_ON )
						AlphaDiscard( Alpha, AlphaClipThresholdShadow );
					#else
						AlphaDiscard( Alpha, AlphaClipThreshold );
					#endif
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					outputDepth = input.positionCS.z;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define ASE_VERSION 19909
			#define ASE_SRP_VERSION 170300
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_VERT_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _UVBasedDisplacementMaskChannel;
			float4 _VertexDisplacementNoise_ST;
			float4 _TextureChannel;
			float4 _Texture_ST;
			float4 _VertexDisplacementNoiseChannel;
			float3 _VertexDisplacementAmount;
			float2 _UVSinWaveStrength;
			float2 _VertexDisplacementNoisePanSpeed;
			float _CustomData1XAffectsStrength;
			float _UseVertexNormals;
			float _TextureRotation;
			float _CorePower;
			float _CoreIntensity;
			float _AlphaBoldness;
			float _FlatAlpha;
			float _UVBasedDisplacementMaskDisplacement;
			float _Cull;
			float _ClampDisplacement;
			float _DepthFadeDivide;
			float _UVSinWaveSpeed;
			float _UVSinWaveFrequency;
			float _VertexDisplacementNoiseStrength;
			float _CustomData1YAffectsSpeed;
			float _VertexDisplacementNoiseRotation;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _UVBasedDisplacementMaskSoften;
			float _UseDepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VertexDisplacementNoise;
			sampler2D _Texture;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float2 uv_VertexDisplacementNoise = input.ase_texcoord * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float cos204 = cos( radians( _VertexDisplacementNoiseRotation ) );
				float sin204 = sin( radians( _VertexDisplacementNoiseRotation ) );
				float2 rotator204 = mul( uv_VertexDisplacementNoise - float2( 0.5,0.5 ) , float2x2( cos204 , -sin204 , sin204 , cos204 )) + float2( 0.5,0.5 );
				float4 texCoord188 = input.ase_texcoord;
				texCoord188.xy = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult189 = lerp( 1.0 , texCoord188.w , _CustomData1YAffectsSpeed);
				float SpeedVariant192 = lerpResult189;
				float4 uvs4_VertexDisplacementNoise = input.ase_texcoord;
				uvs4_VertexDisplacementNoise.xy = input.ase_texcoord.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 uv2s4_VertexDisplacementNoise = input.ase_texcoord1;
				uv2s4_VertexDisplacementNoise.xy = input.ase_texcoord1.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 appendResult209 = (float4(uv2s4_VertexDisplacementNoise.z , uv2s4_VertexDisplacementNoise.w , 0.0 , 0.0));
				float dotResult223 = dot( tex2Dlod( _VertexDisplacementNoise, float4( ( float4( rotator204, 0.0 , 0.0 ) + float4( ( _TimeParameters.x * _VertexDisplacementNoisePanSpeed * SpeedVariant192 ), 0.0 , 0.0 ) + uvs4_VertexDisplacementNoise.w + appendResult209 ).xy, 0, 0.0) ) , _VertexDisplacementNoiseChannel );
				float2 texCoord205 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime213 = _TimeParameters.x * ( _UVSinWaveSpeed * SpeedVariant192 );
				float dotResult228 = dot( sin( ( ( texCoord205 * _UVSinWaveFrequency ) + mulTime213 ) ) , _UVSinWaveStrength );
				float temp_output_234_0 = ( ( dotResult223 * _VertexDisplacementNoiseStrength ) + dotResult228 );
				float lerpResult243 = lerp( -1.0 , 1.0 , temp_output_234_0);
				float lerpResult261 = lerp( 0.0 , 1.0 , temp_output_234_0);
				float lerpResult262 = lerp( lerpResult243 , lerpResult261 , _ClampDisplacement);
				float2 texCoord214 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult217 = dot( float4( texCoord214, 0.0 , 0.0 ) , _UVBasedDisplacementMaskChannel );
				float smoothstepResult233 = smoothstep( 0.0 , _UVBasedDisplacementMaskSoften , saturate( ( dotResult217 + _UVBasedDisplacementMaskDisplacement ) ));
				float lerpResult211 = lerp( 1.0 , texCoord188.z , _CustomData1XAffectsStrength);
				float StrengthVariant216 = lerpResult211;
				float VertexDisplacement236 = ( lerpResult262 * smoothstepResult233 * StrengthVariant216 );
				float3 lerpResult267 = lerp( float3( 1,1,1 ) , input.normalOS , _UseVertexNormals);
				
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord1.x = eyeDepth;
				
				output.ase_texcoord = input.ase_texcoord;
				output.ase_color = input.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord1.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( VertexDisplacement236 * lerpResult267 * _VertexDisplacementAmount );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = vertexInput.positionCS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input
						#if defined( ASE_DEPTH_WRITE_ON )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );

				float2 uv_Texture = input.ase_texcoord.xy * _Texture_ST.xy + _Texture_ST.zw;
				float cos138 = cos( radians( _TextureRotation ) );
				float sin138 = sin( radians( _TextureRotation ) );
				float2 rotator138 = mul( uv_Texture - float2( 0.5,0.5 ) , float2x2( cos138 , -sin138 , sin138 , cos138 )) + float2( 0.5,0.5 );
				float dotResult126 = dot( tex2D( _Texture, rotator138 ) , _TextureChannel );
				float temp_output_86_0 = ( pow( dotResult126 , _CorePower ) * _CoreIntensity );
				float temp_output_135_0 = saturate( ( dotResult126 + temp_output_86_0 ) );
				float lerpResult184 = lerp( temp_output_135_0 , saturate( round( ( temp_output_135_0 * _AlphaBoldness ) ) ) , _FlatAlpha);
				float depthLinearEye174 = LinearEyeDepth( SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ), _ZBufferParams );
				float eyeDepth = input.ase_texcoord1.x;
				float cameraDepthFade175 = (( eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
				float lerpResult179 = lerp( 1.0 , saturate( ( ( depthLinearEye174 - cameraDepthFade175 ) / _DepthFadeDivide ) ) , _UseDepthFade);
				

				float Alpha = saturate( ( lerpResult184 * saturate( lerpResult179 ) * input.ase_color.a ) );
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _Cutoff;
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					outputDepth = input.positionCS.z;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }

			Cull Off
			AlphaToMask Off

			HLSLPROGRAM

			#define ASE_FOG 1
			#define ASE_VERSION 19909
			#define ASE_SRP_VERSION 170300
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION


			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _UVBasedDisplacementMaskChannel;
			float4 _VertexDisplacementNoise_ST;
			float4 _TextureChannel;
			float4 _Texture_ST;
			float4 _VertexDisplacementNoiseChannel;
			float3 _VertexDisplacementAmount;
			float2 _UVSinWaveStrength;
			float2 _VertexDisplacementNoisePanSpeed;
			float _CustomData1XAffectsStrength;
			float _UseVertexNormals;
			float _TextureRotation;
			float _CorePower;
			float _CoreIntensity;
			float _AlphaBoldness;
			float _FlatAlpha;
			float _UVBasedDisplacementMaskDisplacement;
			float _Cull;
			float _ClampDisplacement;
			float _DepthFadeDivide;
			float _UVSinWaveSpeed;
			float _UVSinWaveFrequency;
			float _VertexDisplacementNoiseStrength;
			float _CustomData1YAffectsSpeed;
			float _VertexDisplacementNoiseRotation;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _UVBasedDisplacementMaskSoften;
			float _UseDepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VertexDisplacementNoise;
			sampler2D _Texture;


			
			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			PackedVaryings VertexFunction(Attributes input  )
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float2 uv_VertexDisplacementNoise = input.ase_texcoord * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float cos204 = cos( radians( _VertexDisplacementNoiseRotation ) );
				float sin204 = sin( radians( _VertexDisplacementNoiseRotation ) );
				float2 rotator204 = mul( uv_VertexDisplacementNoise - float2( 0.5,0.5 ) , float2x2( cos204 , -sin204 , sin204 , cos204 )) + float2( 0.5,0.5 );
				float4 texCoord188 = input.ase_texcoord;
				texCoord188.xy = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult189 = lerp( 1.0 , texCoord188.w , _CustomData1YAffectsSpeed);
				float SpeedVariant192 = lerpResult189;
				float4 uvs4_VertexDisplacementNoise = input.ase_texcoord;
				uvs4_VertexDisplacementNoise.xy = input.ase_texcoord.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 uv2s4_VertexDisplacementNoise = input.ase_texcoord1;
				uv2s4_VertexDisplacementNoise.xy = input.ase_texcoord1.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 appendResult209 = (float4(uv2s4_VertexDisplacementNoise.z , uv2s4_VertexDisplacementNoise.w , 0.0 , 0.0));
				float dotResult223 = dot( tex2Dlod( _VertexDisplacementNoise, float4( ( float4( rotator204, 0.0 , 0.0 ) + float4( ( _TimeParameters.x * _VertexDisplacementNoisePanSpeed * SpeedVariant192 ), 0.0 , 0.0 ) + uvs4_VertexDisplacementNoise.w + appendResult209 ).xy, 0, 0.0) ) , _VertexDisplacementNoiseChannel );
				float2 texCoord205 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime213 = _TimeParameters.x * ( _UVSinWaveSpeed * SpeedVariant192 );
				float dotResult228 = dot( sin( ( ( texCoord205 * _UVSinWaveFrequency ) + mulTime213 ) ) , _UVSinWaveStrength );
				float temp_output_234_0 = ( ( dotResult223 * _VertexDisplacementNoiseStrength ) + dotResult228 );
				float lerpResult243 = lerp( -1.0 , 1.0 , temp_output_234_0);
				float lerpResult261 = lerp( 0.0 , 1.0 , temp_output_234_0);
				float lerpResult262 = lerp( lerpResult243 , lerpResult261 , _ClampDisplacement);
				float2 texCoord214 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult217 = dot( float4( texCoord214, 0.0 , 0.0 ) , _UVBasedDisplacementMaskChannel );
				float smoothstepResult233 = smoothstep( 0.0 , _UVBasedDisplacementMaskSoften , saturate( ( dotResult217 + _UVBasedDisplacementMaskDisplacement ) ));
				float lerpResult211 = lerp( 1.0 , texCoord188.z , _CustomData1XAffectsStrength);
				float StrengthVariant216 = lerpResult211;
				float VertexDisplacement236 = ( lerpResult262 * smoothstepResult233 * StrengthVariant216 );
				float3 lerpResult267 = lerp( float3( 1,1,1 ) , input.normalOS , _UseVertexNormals);
				
				float4 ase_positionCS = TransformObjectToHClip( ( input.positionOS ).xyz );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				output.ase_texcoord1 = screenPos;
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord2.x = eyeDepth;
				
				output.ase_texcoord = input.ase_texcoord;
				output.ase_color = input.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord2.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( VertexDisplacement236 * lerpResult267 * _VertexDisplacementAmount );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = vertexInput.positionCS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input ) : SV_Target
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_Texture = input.ase_texcoord.xy * _Texture_ST.xy + _Texture_ST.zw;
				float cos138 = cos( radians( _TextureRotation ) );
				float sin138 = sin( radians( _TextureRotation ) );
				float2 rotator138 = mul( uv_Texture - float2( 0.5,0.5 ) , float2x2( cos138 , -sin138 , sin138 , cos138 )) + float2( 0.5,0.5 );
				float dotResult126 = dot( tex2D( _Texture, rotator138 ) , _TextureChannel );
				float temp_output_86_0 = ( pow( dotResult126 , _CorePower ) * _CoreIntensity );
				float temp_output_135_0 = saturate( ( dotResult126 + temp_output_86_0 ) );
				float lerpResult184 = lerp( temp_output_135_0 , saturate( round( ( temp_output_135_0 * _AlphaBoldness ) ) ) , _FlatAlpha);
				float4 screenPos = input.ase_texcoord1;
				float4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float depthLinearEye174 = LinearEyeDepth( SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ), _ZBufferParams );
				float eyeDepth = input.ase_texcoord2.x;
				float cameraDepthFade175 = (( eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
				float lerpResult179 = lerp( 1.0 , saturate( ( ( depthLinearEye174 - cameraDepthFade175 ) / _DepthFadeDivide ) ) , _UseDepthFade);
				

				surfaceDescription.Alpha = saturate( ( lerpResult184 * saturate( lerpResult179 ) * input.ase_color.a ) );
				#if defined( _ALPHATEST_ON )
					surfaceDescription.AlphaClipThreshold = _Cutoff;
				#endif

				#ifdef _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "ScenePickingPass"
			Tags { "LightMode"="Picking" }

			AlphaToMask Off

			HLSLPROGRAM

			#define ASE_FOG 1
			#define ASE_VERSION 19909
			#define ASE_SRP_VERSION 170300
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT

			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION


			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _UVBasedDisplacementMaskChannel;
			float4 _VertexDisplacementNoise_ST;
			float4 _TextureChannel;
			float4 _Texture_ST;
			float4 _VertexDisplacementNoiseChannel;
			float3 _VertexDisplacementAmount;
			float2 _UVSinWaveStrength;
			float2 _VertexDisplacementNoisePanSpeed;
			float _CustomData1XAffectsStrength;
			float _UseVertexNormals;
			float _TextureRotation;
			float _CorePower;
			float _CoreIntensity;
			float _AlphaBoldness;
			float _FlatAlpha;
			float _UVBasedDisplacementMaskDisplacement;
			float _Cull;
			float _ClampDisplacement;
			float _DepthFadeDivide;
			float _UVSinWaveSpeed;
			float _UVSinWaveFrequency;
			float _VertexDisplacementNoiseStrength;
			float _CustomData1YAffectsSpeed;
			float _VertexDisplacementNoiseRotation;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _UVBasedDisplacementMaskSoften;
			float _UseDepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VertexDisplacementNoise;
			sampler2D _Texture;


			
			float4 _SelectionID;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			PackedVaryings VertexFunction(Attributes input  )
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float2 uv_VertexDisplacementNoise = input.ase_texcoord * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float cos204 = cos( radians( _VertexDisplacementNoiseRotation ) );
				float sin204 = sin( radians( _VertexDisplacementNoiseRotation ) );
				float2 rotator204 = mul( uv_VertexDisplacementNoise - float2( 0.5,0.5 ) , float2x2( cos204 , -sin204 , sin204 , cos204 )) + float2( 0.5,0.5 );
				float4 texCoord188 = input.ase_texcoord;
				texCoord188.xy = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult189 = lerp( 1.0 , texCoord188.w , _CustomData1YAffectsSpeed);
				float SpeedVariant192 = lerpResult189;
				float4 uvs4_VertexDisplacementNoise = input.ase_texcoord;
				uvs4_VertexDisplacementNoise.xy = input.ase_texcoord.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 uv2s4_VertexDisplacementNoise = input.ase_texcoord1;
				uv2s4_VertexDisplacementNoise.xy = input.ase_texcoord1.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 appendResult209 = (float4(uv2s4_VertexDisplacementNoise.z , uv2s4_VertexDisplacementNoise.w , 0.0 , 0.0));
				float dotResult223 = dot( tex2Dlod( _VertexDisplacementNoise, float4( ( float4( rotator204, 0.0 , 0.0 ) + float4( ( _TimeParameters.x * _VertexDisplacementNoisePanSpeed * SpeedVariant192 ), 0.0 , 0.0 ) + uvs4_VertexDisplacementNoise.w + appendResult209 ).xy, 0, 0.0) ) , _VertexDisplacementNoiseChannel );
				float2 texCoord205 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime213 = _TimeParameters.x * ( _UVSinWaveSpeed * SpeedVariant192 );
				float dotResult228 = dot( sin( ( ( texCoord205 * _UVSinWaveFrequency ) + mulTime213 ) ) , _UVSinWaveStrength );
				float temp_output_234_0 = ( ( dotResult223 * _VertexDisplacementNoiseStrength ) + dotResult228 );
				float lerpResult243 = lerp( -1.0 , 1.0 , temp_output_234_0);
				float lerpResult261 = lerp( 0.0 , 1.0 , temp_output_234_0);
				float lerpResult262 = lerp( lerpResult243 , lerpResult261 , _ClampDisplacement);
				float2 texCoord214 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult217 = dot( float4( texCoord214, 0.0 , 0.0 ) , _UVBasedDisplacementMaskChannel );
				float smoothstepResult233 = smoothstep( 0.0 , _UVBasedDisplacementMaskSoften , saturate( ( dotResult217 + _UVBasedDisplacementMaskDisplacement ) ));
				float lerpResult211 = lerp( 1.0 , texCoord188.z , _CustomData1XAffectsStrength);
				float StrengthVariant216 = lerpResult211;
				float VertexDisplacement236 = ( lerpResult262 * smoothstepResult233 * StrengthVariant216 );
				float3 lerpResult267 = lerp( float3( 1,1,1 ) , input.normalOS , _UseVertexNormals);
				
				float4 ase_positionCS = TransformObjectToHClip( ( input.positionOS ).xyz );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				output.ase_texcoord1 = screenPos;
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord2.x = eyeDepth;
				
				output.ase_texcoord = input.ase_texcoord;
				output.ase_color = input.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord2.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( VertexDisplacement236 * lerpResult267 * _VertexDisplacementAmount );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = vertexInput.positionCS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input ) : SV_Target
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_Texture = input.ase_texcoord.xy * _Texture_ST.xy + _Texture_ST.zw;
				float cos138 = cos( radians( _TextureRotation ) );
				float sin138 = sin( radians( _TextureRotation ) );
				float2 rotator138 = mul( uv_Texture - float2( 0.5,0.5 ) , float2x2( cos138 , -sin138 , sin138 , cos138 )) + float2( 0.5,0.5 );
				float dotResult126 = dot( tex2D( _Texture, rotator138 ) , _TextureChannel );
				float temp_output_86_0 = ( pow( dotResult126 , _CorePower ) * _CoreIntensity );
				float temp_output_135_0 = saturate( ( dotResult126 + temp_output_86_0 ) );
				float lerpResult184 = lerp( temp_output_135_0 , saturate( round( ( temp_output_135_0 * _AlphaBoldness ) ) ) , _FlatAlpha);
				float4 screenPos = input.ase_texcoord1;
				float4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float depthLinearEye174 = LinearEyeDepth( SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ), _ZBufferParams );
				float eyeDepth = input.ase_texcoord2.x;
				float cameraDepthFade175 = (( eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
				float lerpResult179 = lerp( 1.0 , saturate( ( ( depthLinearEye174 - cameraDepthFade175 ) / _DepthFadeDivide ) ) , _UseDepthFade);
				

				surfaceDescription.Alpha = saturate( ( lerpResult184 * saturate( lerpResult179 ) * input.ase_color.a ) );
				#if defined( _ALPHATEST_ON )
					surfaceDescription.AlphaClipThreshold = _Cutoff;
				#endif

				#ifdef _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = unity_SelectionID;

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

        	#pragma multi_compile_instancing
        	#pragma multi_compile _ LOD_FADE_CROSSFADE
        	#define ASE_FOG 1
        	#define ASE_VERSION 19909
        	#define ASE_SRP_VERSION 170300
        	#define REQUIRE_DEPTH_TEXTURE 1


        	#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

            #if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_VERT_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				half3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _UVBasedDisplacementMaskChannel;
			float4 _VertexDisplacementNoise_ST;
			float4 _TextureChannel;
			float4 _Texture_ST;
			float4 _VertexDisplacementNoiseChannel;
			float3 _VertexDisplacementAmount;
			float2 _UVSinWaveStrength;
			float2 _VertexDisplacementNoisePanSpeed;
			float _CustomData1XAffectsStrength;
			float _UseVertexNormals;
			float _TextureRotation;
			float _CorePower;
			float _CoreIntensity;
			float _AlphaBoldness;
			float _FlatAlpha;
			float _UVBasedDisplacementMaskDisplacement;
			float _Cull;
			float _ClampDisplacement;
			float _DepthFadeDivide;
			float _UVSinWaveSpeed;
			float _UVSinWaveFrequency;
			float _VertexDisplacementNoiseStrength;
			float _CustomData1YAffectsSpeed;
			float _VertexDisplacementNoiseRotation;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _UVBasedDisplacementMaskSoften;
			float _UseDepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VertexDisplacementNoise;
			sampler2D _Texture;


			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float2 uv_VertexDisplacementNoise = input.ase_texcoord * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float cos204 = cos( radians( _VertexDisplacementNoiseRotation ) );
				float sin204 = sin( radians( _VertexDisplacementNoiseRotation ) );
				float2 rotator204 = mul( uv_VertexDisplacementNoise - float2( 0.5,0.5 ) , float2x2( cos204 , -sin204 , sin204 , cos204 )) + float2( 0.5,0.5 );
				float4 texCoord188 = input.ase_texcoord;
				texCoord188.xy = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult189 = lerp( 1.0 , texCoord188.w , _CustomData1YAffectsSpeed);
				float SpeedVariant192 = lerpResult189;
				float4 uvs4_VertexDisplacementNoise = input.ase_texcoord;
				uvs4_VertexDisplacementNoise.xy = input.ase_texcoord.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 uv2s4_VertexDisplacementNoise = input.ase_texcoord1;
				uv2s4_VertexDisplacementNoise.xy = input.ase_texcoord1.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 appendResult209 = (float4(uv2s4_VertexDisplacementNoise.z , uv2s4_VertexDisplacementNoise.w , 0.0 , 0.0));
				float dotResult223 = dot( tex2Dlod( _VertexDisplacementNoise, float4( ( float4( rotator204, 0.0 , 0.0 ) + float4( ( _TimeParameters.x * _VertexDisplacementNoisePanSpeed * SpeedVariant192 ), 0.0 , 0.0 ) + uvs4_VertexDisplacementNoise.w + appendResult209 ).xy, 0, 0.0) ) , _VertexDisplacementNoiseChannel );
				float2 texCoord205 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime213 = _TimeParameters.x * ( _UVSinWaveSpeed * SpeedVariant192 );
				float dotResult228 = dot( sin( ( ( texCoord205 * _UVSinWaveFrequency ) + mulTime213 ) ) , _UVSinWaveStrength );
				float temp_output_234_0 = ( ( dotResult223 * _VertexDisplacementNoiseStrength ) + dotResult228 );
				float lerpResult243 = lerp( -1.0 , 1.0 , temp_output_234_0);
				float lerpResult261 = lerp( 0.0 , 1.0 , temp_output_234_0);
				float lerpResult262 = lerp( lerpResult243 , lerpResult261 , _ClampDisplacement);
				float2 texCoord214 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult217 = dot( float4( texCoord214, 0.0 , 0.0 ) , _UVBasedDisplacementMaskChannel );
				float smoothstepResult233 = smoothstep( 0.0 , _UVBasedDisplacementMaskSoften , saturate( ( dotResult217 + _UVBasedDisplacementMaskDisplacement ) ));
				float lerpResult211 = lerp( 1.0 , texCoord188.z , _CustomData1XAffectsStrength);
				float StrengthVariant216 = lerpResult211;
				float VertexDisplacement236 = ( lerpResult262 * smoothstepResult233 * StrengthVariant216 );
				float3 lerpResult267 = lerp( float3( 1,1,1 ) , input.normalOS , _UseVertexNormals);
				
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord2.x = eyeDepth;
				
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_color = input.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord2.yzw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( VertexDisplacement236 * lerpResult267 * _VertexDisplacementAmount );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS );

				output.positionCS = vertexInput.positionCS;
				output.normalWS = normalInput.normalWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			void frag(PackedVaryings input
						, out half4 outNormalWS : SV_Target0
						#if defined( ASE_DEPTH_WRITE_ON )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						#if ( UNITY_VERSION >= 60020000 )
						, out uint outRenderingLayers : SV_Target1
						#else
						, out float4 outRenderingLayers : SV_Target1
						#endif
						#endif
						 )
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				half3 NormalWS = normalize( input.normalWS );
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );

				float2 uv_Texture = input.ase_texcoord1.xy * _Texture_ST.xy + _Texture_ST.zw;
				float cos138 = cos( radians( _TextureRotation ) );
				float sin138 = sin( radians( _TextureRotation ) );
				float2 rotator138 = mul( uv_Texture - float2( 0.5,0.5 ) , float2x2( cos138 , -sin138 , sin138 , cos138 )) + float2( 0.5,0.5 );
				float dotResult126 = dot( tex2D( _Texture, rotator138 ) , _TextureChannel );
				float temp_output_86_0 = ( pow( dotResult126 , _CorePower ) * _CoreIntensity );
				float temp_output_135_0 = saturate( ( dotResult126 + temp_output_86_0 ) );
				float lerpResult184 = lerp( temp_output_135_0 , saturate( round( ( temp_output_135_0 * _AlphaBoldness ) ) ) , _FlatAlpha);
				float depthLinearEye174 = LinearEyeDepth( SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ), _ZBufferParams );
				float eyeDepth = input.ase_texcoord2.x;
				float cameraDepthFade175 = (( eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
				float lerpResult179 = lerp( 1.0 , saturate( ( ( depthLinearEye174 - cameraDepthFade175 ) / _DepthFadeDivide ) ) , _UseDepthFade);
				

				float Alpha = saturate( ( lerpResult184 * saturate( lerpResult179 ) * input.ase_color.a ) );
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _Cutoff;
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					input.positionCS.z = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					outputDepth = input.positionCS.z;
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float2 octNormalWS = PackNormalOctQuadEncode(NormalWS);
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					outNormalWS = half4(NormalizeNormalPerPixel( NormalWS ), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					#if ( UNITY_VERSION >= 60020000 )
					outRenderingLayers = EncodeMeshRenderingLayer();
					#else
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
					#endif
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "MotionVectors"
			Tags { "LightMode"="MotionVectors" }

			ColorMask RG

			HLSLPROGRAM

			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define ASE_VERSION 19909
			#define ASE_SRP_VERSION 170300
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

            #define SHADERPASS SHADERPASS_MOTION_VECTORS

            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
			#endif

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MotionVectorsCommon.hlsl"

			#if ( UNITY_VERSION < 60010000 )
				#define APPLICATION_SPACE_WARP_MOTION APLICATION_SPACE_WARP_MOTION
			#endif

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_VERT_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 positionOld : TEXCOORD4;
				#if _ADD_PRECOMPUTED_VELOCITY
					float3 alembicMotionVector : TEXCOORD5;
				#endif
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 positionCSNoJitter : TEXCOORD0;
				float4 previousPositionCSNoJitter : TEXCOORD1;
				float3 positionWS : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _UVBasedDisplacementMaskChannel;
			float4 _VertexDisplacementNoise_ST;
			float4 _TextureChannel;
			float4 _Texture_ST;
			float4 _VertexDisplacementNoiseChannel;
			float3 _VertexDisplacementAmount;
			float2 _UVSinWaveStrength;
			float2 _VertexDisplacementNoisePanSpeed;
			float _CustomData1XAffectsStrength;
			float _UseVertexNormals;
			float _TextureRotation;
			float _CorePower;
			float _CoreIntensity;
			float _AlphaBoldness;
			float _FlatAlpha;
			float _UVBasedDisplacementMaskDisplacement;
			float _Cull;
			float _ClampDisplacement;
			float _DepthFadeDivide;
			float _UVSinWaveSpeed;
			float _UVSinWaveFrequency;
			float _VertexDisplacementNoiseStrength;
			float _CustomData1YAffectsSpeed;
			float _VertexDisplacementNoiseRotation;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _UVBasedDisplacementMaskSoften;
			float _UseDepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _VertexDisplacementNoise;
			sampler2D _Texture;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float2 uv_VertexDisplacementNoise = input.ase_texcoord * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float cos204 = cos( radians( _VertexDisplacementNoiseRotation ) );
				float sin204 = sin( radians( _VertexDisplacementNoiseRotation ) );
				float2 rotator204 = mul( uv_VertexDisplacementNoise - float2( 0.5,0.5 ) , float2x2( cos204 , -sin204 , sin204 , cos204 )) + float2( 0.5,0.5 );
				float4 texCoord188 = input.ase_texcoord;
				texCoord188.xy = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult189 = lerp( 1.0 , texCoord188.w , _CustomData1YAffectsSpeed);
				float SpeedVariant192 = lerpResult189;
				float4 uvs4_VertexDisplacementNoise = input.ase_texcoord;
				uvs4_VertexDisplacementNoise.xy = input.ase_texcoord.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 uv2s4_VertexDisplacementNoise = input.ase_texcoord1;
				uv2s4_VertexDisplacementNoise.xy = input.ase_texcoord1.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 appendResult209 = (float4(uv2s4_VertexDisplacementNoise.z , uv2s4_VertexDisplacementNoise.w , 0.0 , 0.0));
				float dotResult223 = dot( tex2Dlod( _VertexDisplacementNoise, float4( ( float4( rotator204, 0.0 , 0.0 ) + float4( ( _TimeParameters.x * _VertexDisplacementNoisePanSpeed * SpeedVariant192 ), 0.0 , 0.0 ) + uvs4_VertexDisplacementNoise.w + appendResult209 ).xy, 0, 0.0) ) , _VertexDisplacementNoiseChannel );
				float2 texCoord205 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime213 = _TimeParameters.x * ( _UVSinWaveSpeed * SpeedVariant192 );
				float dotResult228 = dot( sin( ( ( texCoord205 * _UVSinWaveFrequency ) + mulTime213 ) ) , _UVSinWaveStrength );
				float temp_output_234_0 = ( ( dotResult223 * _VertexDisplacementNoiseStrength ) + dotResult228 );
				float lerpResult243 = lerp( -1.0 , 1.0 , temp_output_234_0);
				float lerpResult261 = lerp( 0.0 , 1.0 , temp_output_234_0);
				float lerpResult262 = lerp( lerpResult243 , lerpResult261 , _ClampDisplacement);
				float2 texCoord214 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult217 = dot( float4( texCoord214, 0.0 , 0.0 ) , _UVBasedDisplacementMaskChannel );
				float smoothstepResult233 = smoothstep( 0.0 , _UVBasedDisplacementMaskSoften , saturate( ( dotResult217 + _UVBasedDisplacementMaskDisplacement ) ));
				float lerpResult211 = lerp( 1.0 , texCoord188.z , _CustomData1XAffectsStrength);
				float StrengthVariant216 = lerpResult211;
				float VertexDisplacement236 = ( lerpResult262 * smoothstepResult233 * StrengthVariant216 );
				float3 lerpResult267 = lerp( float3( 1,1,1 ) , input.normalOS , _UseVertexNormals);
				
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord4.x = eyeDepth;
				
				output.ase_texcoord3 = input.ase_texcoord;
				output.ase_color = input.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord4.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( VertexDisplacement236 * lerpResult267 * _VertexDisplacementAmount );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				#if defined(APPLICATION_SPACE_WARP_MOTION)
					output.positionCSNoJitter = mul(_NonJitteredViewProjMatrix, mul(UNITY_MATRIX_M, input.positionOS));
					output.positionCS = output.positionCSNoJitter;
				#else
					output.positionCS = vertexInput.positionCS;
					output.positionCSNoJitter = mul(_NonJitteredViewProjMatrix, mul(UNITY_MATRIX_M, input.positionOS));
				#endif

				float4 prevPos = ( unity_MotionVectorsParams.x == 1 ) ? float4( input.positionOld, 1 ) : input.positionOS;

				#if _ADD_PRECOMPUTED_VELOCITY
					prevPos = prevPos - float4(input.alembicMotionVector, 0);
				#endif

				output.previousPositionCSNoJitter = mul( _PrevViewProjMatrix, mul( UNITY_PREV_MATRIX_M, prevPos ) );
				output.positionWS = vertexInput.positionWS;
				return output;
			}

			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}

			half4 frag(	PackedVaryings input
				#if defined( ASE_DEPTH_WRITE_ON )
				,out float outputDepth : ASE_SV_DEPTH
				#endif
				 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( PositionWS );
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;

				float2 uv_Texture = input.ase_texcoord3.xy * _Texture_ST.xy + _Texture_ST.zw;
				float cos138 = cos( radians( _TextureRotation ) );
				float sin138 = sin( radians( _TextureRotation ) );
				float2 rotator138 = mul( uv_Texture - float2( 0.5,0.5 ) , float2x2( cos138 , -sin138 , sin138 , cos138 )) + float2( 0.5,0.5 );
				float dotResult126 = dot( tex2D( _Texture, rotator138 ) , _TextureChannel );
				float temp_output_86_0 = ( pow( dotResult126 , _CorePower ) * _CoreIntensity );
				float temp_output_135_0 = saturate( ( dotResult126 + temp_output_86_0 ) );
				float lerpResult184 = lerp( temp_output_135_0 , saturate( round( ( temp_output_135_0 * _AlphaBoldness ) ) ) , _FlatAlpha);
				float depthLinearEye174 = LinearEyeDepth( SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ), _ZBufferParams );
				float eyeDepth = input.ase_texcoord4.x;
				float cameraDepthFade175 = (( eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
				float lerpResult179 = lerp( 1.0 , saturate( ( ( depthLinearEye174 - cameraDepthFade175 ) / _DepthFadeDivide ) ) , _UseDepthFade);
				

				float Alpha = saturate( ( lerpResult184 * saturate( lerpResult179 ) * input.ase_color.a ) );
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _Cutoff;
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					input.positionCS.z = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#if defined( ASE_CHANGES_WORLD_POS )
					float3 positionOS = mul( GetWorldToObjectMatrix(),  float4( PositionWS, 1.0 ) ).xyz;
					float3 previousPositionWS = mul( GetPrevObjectToWorldMatrix(),  float4( positionOS, 1.0 ) ).xyz;
					input.positionCSNoJitter = mul( _NonJitteredViewProjMatrix, float4( PositionWS, 1.0 ) );
					input.previousPositionCSNoJitter = mul( _PrevViewProjMatrix, float4( previousPositionWS, 1.0 ) );
				#endif

				#if defined( LOD_FADE_CROSSFADE )
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					outputDepth = input.positionCS.z;
				#endif

				#if defined(APPLICATION_SPACE_WARP_MOTION)
					return float4( CalcAswNdcMotionVectorFromCsPositions( input.positionCSNoJitter, input.previousPositionCSNoJitter ), 1 );
				#else
					return float4( CalcNdcMotionVectorFromCsPositions( input.positionCSNoJitter, input.previousPositionCSNoJitter ), 0, 0 );
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "GBuffer"
			Tags { "LightMode"="UniversalGBuffer" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma shader_feature_local_fragment _RECEIVE_SHADOWS_OFF
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#define UNLIT_DEFAULT_DECAL_BLENDING 1
			#define ASE_FOG 1
			#define ASE_VERSION 19909
			#define ASE_SRP_VERSION 170300
			#define REQUIRE_DEPTH_TEXTURE 1


			// Deferred Rendering Path does not support the OpenGL-based graphics API:
			// Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
			#pragma exclude_renderers glcore gles3 

			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_GBUFFER

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_VERT_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				half3 normalWS : TEXCOORD1;
				half4 tangentWS : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _UVBasedDisplacementMaskChannel;
			float4 _VertexDisplacementNoise_ST;
			float4 _TextureChannel;
			float4 _Texture_ST;
			float4 _VertexDisplacementNoiseChannel;
			float3 _VertexDisplacementAmount;
			float2 _UVSinWaveStrength;
			float2 _VertexDisplacementNoisePanSpeed;
			float _CustomData1XAffectsStrength;
			float _UseVertexNormals;
			float _TextureRotation;
			float _CorePower;
			float _CoreIntensity;
			float _AlphaBoldness;
			float _FlatAlpha;
			float _UVBasedDisplacementMaskDisplacement;
			float _Cull;
			float _ClampDisplacement;
			float _DepthFadeDivide;
			float _UVSinWaveSpeed;
			float _UVSinWaveFrequency;
			float _VertexDisplacementNoiseStrength;
			float _CustomData1YAffectsSpeed;
			float _VertexDisplacementNoiseRotation;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _UVBasedDisplacementMaskSoften;
			float _UseDepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _VertexDisplacementNoise;
			sampler2D _Texture;


			#if ( UNITY_VERSION >= 60010000 )
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GBufferOutput.hlsl"
			#else
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
			#endif

			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float2 uv_VertexDisplacementNoise = input.ase_texcoord * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float cos204 = cos( radians( _VertexDisplacementNoiseRotation ) );
				float sin204 = sin( radians( _VertexDisplacementNoiseRotation ) );
				float2 rotator204 = mul( uv_VertexDisplacementNoise - float2( 0.5,0.5 ) , float2x2( cos204 , -sin204 , sin204 , cos204 )) + float2( 0.5,0.5 );
				float4 texCoord188 = input.ase_texcoord;
				texCoord188.xy = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult189 = lerp( 1.0 , texCoord188.w , _CustomData1YAffectsSpeed);
				float SpeedVariant192 = lerpResult189;
				float4 uvs4_VertexDisplacementNoise = input.ase_texcoord;
				uvs4_VertexDisplacementNoise.xy = input.ase_texcoord.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 uv2s4_VertexDisplacementNoise = input.ase_texcoord1;
				uv2s4_VertexDisplacementNoise.xy = input.ase_texcoord1.xy * _VertexDisplacementNoise_ST.xy + _VertexDisplacementNoise_ST.zw;
				float4 appendResult209 = (float4(uv2s4_VertexDisplacementNoise.z , uv2s4_VertexDisplacementNoise.w , 0.0 , 0.0));
				float dotResult223 = dot( tex2Dlod( _VertexDisplacementNoise, float4( ( float4( rotator204, 0.0 , 0.0 ) + float4( ( _TimeParameters.x * _VertexDisplacementNoisePanSpeed * SpeedVariant192 ), 0.0 , 0.0 ) + uvs4_VertexDisplacementNoise.w + appendResult209 ).xy, 0, 0.0) ) , _VertexDisplacementNoiseChannel );
				float2 texCoord205 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime213 = _TimeParameters.x * ( _UVSinWaveSpeed * SpeedVariant192 );
				float dotResult228 = dot( sin( ( ( texCoord205 * _UVSinWaveFrequency ) + mulTime213 ) ) , _UVSinWaveStrength );
				float temp_output_234_0 = ( ( dotResult223 * _VertexDisplacementNoiseStrength ) + dotResult228 );
				float lerpResult243 = lerp( -1.0 , 1.0 , temp_output_234_0);
				float lerpResult261 = lerp( 0.0 , 1.0 , temp_output_234_0);
				float lerpResult262 = lerp( lerpResult243 , lerpResult261 , _ClampDisplacement);
				float2 texCoord214 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult217 = dot( float4( texCoord214, 0.0 , 0.0 ) , _UVBasedDisplacementMaskChannel );
				float smoothstepResult233 = smoothstep( 0.0 , _UVBasedDisplacementMaskSoften , saturate( ( dotResult217 + _UVBasedDisplacementMaskDisplacement ) ));
				float lerpResult211 = lerp( 1.0 , texCoord188.z , _CustomData1XAffectsStrength);
				float StrengthVariant216 = lerpResult211;
				float VertexDisplacement236 = ( lerpResult262 * smoothstepResult233 * StrengthVariant216 );
				float3 lerpResult267 = lerp( float3( 1,1,1 ) , input.normalOS , _UseVertexNormals);
				
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord4.x = eyeDepth;
				
				output.ase_texcoord3 = input.ase_texcoord;
				output.ase_color = input.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord4.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( VertexDisplacement236 * lerpResult267 * _VertexDisplacementAmount );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				output.positionCS = vertexInput.positionCS;
				output.positionWS = vertexInput.positionWS;
				output.normalWS = normalInput.normalWS;
				output.tangentWS = half4( normalInput.tangentWS, ( input.tangentOS.w > 0.0 ? 1.0 : -1.0 ) * GetOddNegativeScale() );;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

		#if ( UNITY_VERSION >= 60010000 )
			GBufferFragOutput frag ( PackedVaryings input
		#else
			FragmentOutput frag ( PackedVaryings input
		#endif
								#if defined( ASE_DEPTH_WRITE_ON )
								,out float outputDepth : ASE_SV_DEPTH
								#endif
								 )
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				// @diogo: mikktspace compliant
				float renormFactor = 1.0 / max( FLT_MIN, length( input.normalWS ) );

				float3 PositionWS = input.positionWS;
				float3 ViewDirWS = GetWorldSpaceNormalizeViewDir( PositionWS );
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );
				float3 TangentWS = input.tangentWS.xyz * renormFactor;
				float3 BitangentWS = cross( input.normalWS, input.tangentWS.xyz ) * input.tangentWS.w * renormFactor;
				float3 NormalWS = input.normalWS * renormFactor;

				float2 uv_Texture = input.ase_texcoord3.xy * _Texture_ST.xy + _Texture_ST.zw;
				float cos138 = cos( radians( _TextureRotation ) );
				float sin138 = sin( radians( _TextureRotation ) );
				float2 rotator138 = mul( uv_Texture - float2( 0.5,0.5 ) , float2x2( cos138 , -sin138 , sin138 , cos138 )) + float2( 0.5,0.5 );
				float dotResult126 = dot( tex2D( _Texture, rotator138 ) , _TextureChannel );
				float temp_output_86_0 = ( pow( dotResult126 , _CorePower ) * _CoreIntensity );
				float temp_output_135_0 = saturate( ( dotResult126 + temp_output_86_0 ) );
				float lerpResult184 = lerp( temp_output_135_0 , saturate( round( ( temp_output_135_0 * _AlphaBoldness ) ) ) , _FlatAlpha);
				float depthLinearEye174 = LinearEyeDepth( SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ), _ZBufferParams );
				float eyeDepth = input.ase_texcoord4.x;
				float cameraDepthFade175 = (( eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
				float lerpResult179 = lerp( 1.0 , saturate( ( ( depthLinearEye174 - cameraDepthFade175 ) / _DepthFadeDivide ) ) , _UseDepthFade);
				

				float3 Color = float3(0.5, 0.5, 0.5);
				float Alpha = saturate( ( lerpResult184 * saturate( lerpResult179 ) * input.ase_color.a ) );
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _Cutoff;
					float AlphaClipThresholdShadow = 0.5;
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					input.positionCS.z = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = PositionWS;
				inputData.positionCS = input.positionCS;
				inputData.normalizedScreenSpaceUV = ScreenPosNorm.xy;
				inputData.normalWS = NormalWS;
				inputData.viewDirectionWS = ViewDirWS;

				#if defined(_DBUFFER) && defined(UNLIT_DEFAULT_DECAL_BLENDING)
					ApplyDecalToBaseColor(input.positionCS, Color);
				#endif

				#if defined( ASE_DEPTH_WRITE_ON )
					outputDepth = input.positionCS.z;
				#endif

				SurfaceData surfaceData = (SurfaceData)0;
				surfaceData.albedo = Color;
				surfaceData.alpha = Alpha;

			#if defined( _SCREEN_SPACE_OCCLUSION ) // GBuffer never has transparents
				float2 normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV( input.positionCS );
				AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion( normalizedScreenSpaceUV );
				surfaceData.occlusion = aoFactor.directAmbientOcclusion;
			#else
				surfaceData.occlusion = 1;
			#endif

			#if ( UNITY_VERSION >= 60010000 )
				return PackGBuffersSurfaceData( surfaceData, inputData, float3( 0, 0, 0 ) );
			#else
				return SurfaceDataToGbuffer( surfaceData, inputData, float3( 0, 0, 0 ), kLightingInvalid );
			#endif
			}

			ENDHLSL
		}
		
	}
	

	

	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19909
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;187;-3850.873,2377.648;Inherit;False;Property;_CustomData1YAffectsSpeed;Custom Data 1 Y Affects Speed;24;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;188;-3954.056,2499.001;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;190;-2924.894,1469.528;Inherit;False;3676.525;1880.749;Vertex Animation Noise;45;236;235;234;233;231;230;229;228;227;226;225;224;223;222;221;220;219;218;217;215;214;213;212;210;209;207;206;205;204;203;202;201;200;199;198;197;196;195;194;193;191;243;260;261;262;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;189;-3467.014,2338.019;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;191;-2849.126,1898.568;Inherit;False;Property;_VertexDisplacementNoiseRotation;Vertex Displacement Noise Rotation;32;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;192;-3263.014,2329.019;Inherit;False;SpeedVariant;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;199;-2272.072,2414.983;Inherit;False;192;SpeedVariant;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;195;-2302.556,1519.528;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;194;-2587.721,1751.229;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;201;-2353.716,2111.429;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;196;-2489.722,1913.229;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;200;-1894.66,2852.677;Inherit;False;192;SpeedVariant;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;197;-2355.959,2205.188;Inherit;False;Property;_VertexDisplacementNoisePanSpeed;Vertex Displacement Noise  Pan Speed;30;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;198;-1945.03,2715.673;Inherit;False;Property;_UVSinWaveSpeed;UV Sin Wave Speed;27;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;202;-2342.282,1887.337;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;205;-1833.031,2393.073;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotatorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;204;-2307.723,1777.229;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;207;-1694.461,2748.677;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;209;-1998.897,1527.557;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;206;-1913.031,2583.073;Inherit;False;Property;_UVSinWaveFrequency;UV Sin Wave Frequency;26;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;203;-1943.718,2039.429;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;193;-2905.891,1511.318;Inherit;True;Property;_VertexDisplacementNoise;Vertex Displacement Noise;28;1;[Header];Create;True;1;Vertex Displacement Noise;0;0;False;0;False;None;None;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;213;-1593.032,2585.073;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;210;-1777.42,1890.689;Inherit;False;4;4;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;215;-1529.032,2409.073;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;10;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;129;-2868.836,20.70718;Inherit;True;Property;_Texture;Texture;0;1;[Header];Create;True;1;Main Alpha;0;0;False;0;False;None;None;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;131;-2718.298,308.4864;Inherit;False;Property;_TextureRotation;Texture Rotation;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;218;-1369.032,2409.073;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;219;-1394.624,1864.858;Inherit;True;Property;_TextureSample10;Texture Sample 10;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;221;-1330.158,2104.75;Inherit;False;Property;_VertexDisplacementNoiseChannel;Vertex Displacement Noise Channel;29;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;128;-2572.296,152.4865;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RadiansOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;133;-2474.296,314.4864;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;222;-1232.587,2409.196;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;223;-999.1991,1877.321;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;212;-1103.545,2969.234;Inherit;False;Property;_UVBasedDisplacementMaskChannel;UV Based Displacement Mask Channel;33;1;[Header];Create;True;1;UV Based Displacement Mask;0;0;False;0;False;0,0,0,0;0,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;226;-1209.931,2287.917;Inherit;False;Property;_VertexDisplacementNoiseStrength;Vertex Displacement Noise Strength;31;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;214;-1091.094,2778.021;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;227;-1486.837,2748.605;Inherit;False;Property;_UVSinWaveStrength;UV Sin Wave Strength;25;1;[Header];Create;True;1;UV Based Sin Wave Displacement;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RotatorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;138;-2292.296,178.4865;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;87;-1625.092,443.9026;Inherit;False;Property;_CorePower;Core Power;11;1;[Header];Create;False;1;Different Center Color;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;230;-753.931,1925.917;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;220;-1017.476,3173.58;Inherit;False;Property;_UVBasedDisplacementMaskDisplacement;UV Based Displacement Mask Displacement;34;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;174;-234.0835,823.6605;Inherit;False;0;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;228;-898.328,2507.051;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;217;-759.0612,2827.593;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;208;-3817.549,2744.891;Inherit;False;Property;_CustomData1XAffectsStrength;Custom Data 1 X Affects Strength;23;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;175;-386.6537,1001.82;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;127;-2071.739,360.816;Inherit;False;Property;_TextureChannel;Texture Channel;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;134;-2052.625,139.7253;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;140;-1651.129,603.5795;Inherit;False;Property;_CoreIntensity;Core Intensity;12;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;85;-1325.956,371.7473;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;211;-3461.014,2704.019;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;73;-1160.116,640.0095;Inherit;False;Property;_AlphaBoldness;Alpha Boldness;16;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;180;-142.3401,1241.271;Inherit;False;Property;_DepthFadeDivide;Depth Fade Divide;19;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;176;-1.912445,848.1799;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;224;-608.9033,3153.058;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;234;-563.5752,2176.828;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;126;-1638.4,142.6949;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;86;-1152.641,435.9595;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;243;-351.2736,1993.285;Inherit;False;3;0;FLOAT;-1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;177;141.0238,896.6915;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;745.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;229;-466.4311,3027.579;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;216;-3263.014,2707.019;Inherit;False;StrengthVariant;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;260;-410.7454,1757.837;Inherit;False;Property;_ClampDisplacement;Clamp Displacement;22;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;231;-532.431,3249.579;Inherit;False;Property;_UVBasedDisplacementMaskSoften;UV Based Displacement Mask Soften;35;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;261;-330.7454,1855.837;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;186;-701.5504,524.4108;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;83;-1009.835,265.0002;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;171;150.51,1037.263;Inherit;False;Property;_UseDepthFade;Use Depth Fade;18;1;[Header];Create;True;1;Depth Fade;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;178;298.9942,844.6931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;183;-567.5531,548.8067;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;225;-426.0021,2309.871;Inherit;False;216;StrengthVariant;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;262;-120.7454,1863.837;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;233;-256.4311,2909.578;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;135;-843.8864,368.1976;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;182;-399.721,477.3039;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;235;-80.00522,2108.895;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;179;450.4449,759.957;Inherit;True;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;185;-429.4622,604.2207;Inherit;False;Property;_FlatAlpha;Flat Alpha;17;0;Create;True;0;0;0;False;0;False;0;0.144;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;268;596.0069,1087.14;Inherit;False;Property;_UseVertexNormals;Use Vertex Normals;21;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;236;92.34973,1866.991;Inherit;False;VertexDisplacement;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;181;734.7398,756.7349;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;106;62.4616,-428.677;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;184;-120.7252,394.7925;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;258;674.0466,1228.15;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;237;778.3668,842.0676;Inherit;False;236;VertexDisplacement;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;267;992.576,1005.707;Inherit;False;3;0;FLOAT3;1,1,1;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;110;634.7449,390.9565;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;239;979.2106,1433.628;Inherit;False;Property;_VertexDisplacementAmount;Vertex Displacement Amount;20;1;[Header];Create;True;1;Vertex Displacement;0;0;False;0;False;0,0,0;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;74;-2367.268,-617.0903;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;78;1238.077,-63.43907;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;75;901.9648,-199.1521;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;81;445.8063,-151.9188;Inherit;False;Property;_CoreColor;Core Color;14;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RotatorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;107;-312.6609,-1030.307;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;168;1323.081,579.4114;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;102;-1832.032,-705.4958;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;79;1188.4,-162.607;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;167;997.7284,699.9562;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;80;993.318,-32.62639;Inherit;False;Property;_Brightness;Brightness;15;1;[Header];Create;True;1;Brightness and Opacity;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;116;-1130.521,-374.8206;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;98;-1381.646,-479.0361;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;166;991.7284,471.9562;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;169;1363.882,422.1359;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;120;-291.1222,-781.3338;Inherit;True;Property;_GradientMap;Gradient Map;8;1;[Header];Create;True;1;Gradient Map;0;0;False;0;False;None;None;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;170;1611.882,378.1359;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;114;-897.9782,-250.6806;Inherit;False;Property;_InvertGradient;Invert Gradient;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;105;760.417,-78.32274;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;118;-649.9781,-482.6806;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;113;-999.9781,-408.6806;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;125;-889.1999,-1184.606;Inherit;True;Property;_ColorTexture;Color Texture;3;1;[Header];Create;True;1;Overlay Color;0;0;False;0;False;None;None;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;130;384.7512,-285.808;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RadiansOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;100;-2269.268,-455.09;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;121;771.9019,-749.282;Inherit;False;Property;_Cull;Cull;36;1;[Header];Create;True;1;Rendering;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;117;-583.9781,-218.6806;Inherit;False;Property;_GradientMapDisplacement;Gradient Map Displacement;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;97;-2513.271,-461.0901;Inherit;False;Property;_GradientShapeRotation;Gradient Shape Rotation;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;160;1064.511,-715.4269;Inherit;False;Property;_Src;Src;39;0;Create;True;0;0;0;True;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;124;-592.6614,-1056.307;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;115;-837.9782,-438.6806;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;158;1322.511,-717.4269;Inherit;False;Property;_Dst;Dst;40;0;Create;True;0;0;0;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;112;1008.103,344.5316;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;99;-2673.34,-825.0892;Inherit;True;Property;_GradientShape;Gradient Shape;5;1;[Header];Create;True;1;Gradient Shape;0;0;False;0;False;None;None;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;136;354.8574,-852.2254;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotatorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;101;-2087.267,-591.0903;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;157;1576.511,-715.4269;Inherit;False;Property;_ZWrite;ZWrite;37;0;Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;122;-72.98848,-1069.069;Inherit;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;103;500.2039,66.3109;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;159;1834.511,-717.4269;Inherit;False;Property;_ZTest;ZTest;38;0;Create;True;0;0;0;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;76;1094.851,-305.3001;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;108;386.0715,-376.6457;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;132;-1772.814,-465.6055;Inherit;False;Property;_GradientShapeChannel;Gradient Shape Channel;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;240;1370.643,950.847;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RadiansOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;123;-494.6613,-894.308;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;104;655.0266,-310.9217;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;82;943.4619,-129.8322;Inherit;False;Property;_DifferentCoreColor;Different Core Color;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;119;14.34905,-674.3876;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;109;-270.9781,-360.6806;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;137;-738.6611,-900.308;Inherit;False;Property;_ColorRotation;Color Rotation;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;289;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;14;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;290;1799.307,34.03413;Float;False;True;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;19;/_Kass_/SH_VFX_SimplePremult_VertexAnim;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;10;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;14;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;31;Surface;0;0;  Keep Alpha;0;0;  Blend;0;0;Two Sided;1;0;Alpha Clipping;0;0;  Use Shadow Threshold;0;0;Forward Only;0;0;Cast Shadows;1;0;Receive Shadows;2;0;Receive SSAO;1;0;Default Decal Blending;1;0;Motion Vectors;1;0;  Add Precomputed Velocity;0;0;  XR Motion Vectors;0;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position;1;0;0;13;False;True;True;True;False;False;True;True;True;False;True;False;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;291;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;292;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;293;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;294;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;14;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;295;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;296;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;297;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;298;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;False;True;1;LightMode=DepthNormalsOnly;False;True;11;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;switch2;webgpu;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;299;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;MotionVectors;0;10;MotionVectors;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;False;False;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=MotionVectors;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;300;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;XRMotionVectors;0;11;XRMotionVectors;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;14;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;True;1;False;;255;False;;1;False;;7;False;;3;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;1;LightMode=XRMotionVectors;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;301;1799.307,34.03413;Float;False;False;-1;3;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;GBuffer;0;12;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;14;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;1;LightMode=UniversalGBuffer;False;True;12;d3d11;gles;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;switch2;webgpu;0;;0;0;Standard;0;False;0
WireConnection;189;1;188;4
WireConnection;189;2;187;0
WireConnection;192;0;189;0
WireConnection;195;2;193;0
WireConnection;194;2;193;0
WireConnection;196;0;191;0
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
WireConnection;213;0;207;0
WireConnection;210;0;204;0
WireConnection;210;1;203;0
WireConnection;210;2;202;4
WireConnection;210;3;209;0
WireConnection;215;0;205;0
WireConnection;215;1;206;0
WireConnection;218;0;215;0
WireConnection;218;1;213;0
WireConnection;219;0;193;0
WireConnection;219;1;210;0
WireConnection;128;2;129;0
WireConnection;133;0;131;0
WireConnection;222;0;218;0
WireConnection;223;0;219;0
WireConnection;223;1;221;0
WireConnection;138;0;128;0
WireConnection;138;2;133;0
WireConnection;230;0;223;0
WireConnection;230;1;226;0
WireConnection;228;0;222;0
WireConnection;228;1;227;0
WireConnection;217;0;214;0
WireConnection;217;1;212;0
WireConnection;134;0;129;0
WireConnection;134;1;138;0
WireConnection;85;0;126;0
WireConnection;85;1;87;0
WireConnection;211;1;188;3
WireConnection;211;2;208;0
WireConnection;176;0;174;0
WireConnection;176;1;175;0
WireConnection;224;0;217;0
WireConnection;224;1;220;0
WireConnection;234;0;230;0
WireConnection;234;1;228;0
WireConnection;126;0;134;0
WireConnection;126;1;127;0
WireConnection;86;0;85;0
WireConnection;86;1;140;0
WireConnection;243;2;234;0
WireConnection;177;0;176;0
WireConnection;177;1;180;0
WireConnection;229;0;224;0
WireConnection;216;0;211;0
WireConnection;261;2;234;0
WireConnection;186;0;135;0
WireConnection;186;1;73;0
WireConnection;83;0;126;0
WireConnection;83;1;86;0
WireConnection;178;0;177;0
WireConnection;183;0;186;0
WireConnection;262;0;243;0
WireConnection;262;1;261;0
WireConnection;262;2;260;0
WireConnection;233;0;229;0
WireConnection;233;2;231;0
WireConnection;135;0;83;0
WireConnection;182;0;183;0
WireConnection;235;0;262;0
WireConnection;235;1;233;0
WireConnection;235;2;225;0
WireConnection;179;1;178;0
WireConnection;179;2;171;0
WireConnection;236;0;235;0
WireConnection;181;0;179;0
WireConnection;184;0;135;0
WireConnection;184;1;182;0
WireConnection;184;2;185;0
WireConnection;267;1;258;0
WireConnection;267;2;268;0
WireConnection;110;0;184;0
WireConnection;110;1;181;0
WireConnection;110;2;106;4
WireConnection;74;2;99;0
WireConnection;78;0;79;0
WireConnection;78;1;80;0
WireConnection;75;0;105;0
WireConnection;107;0;124;0
WireConnection;107;2;123;0
WireConnection;102;0;99;0
WireConnection;102;1;101;0
WireConnection;79;0;76;0
WireConnection;116;0;98;0
WireConnection;98;0;102;0
WireConnection;98;1;132;0
WireConnection;169;0;166;0
WireConnection;169;1;167;0
WireConnection;170;0;169;0
WireConnection;170;1;168;3
WireConnection;105;0;104;0
WireConnection;105;1;81;0
WireConnection;105;2;103;0
WireConnection;118;0;115;0
WireConnection;118;1;116;0
WireConnection;118;2;114;0
WireConnection;113;0;116;0
WireConnection;130;0;106;0
WireConnection;100;0;97;0
WireConnection;124;2;125;0
WireConnection;115;0;113;0
WireConnection;112;0;110;0
WireConnection;136;0;122;0
WireConnection;101;0;74;0
WireConnection;101;2;100;0
WireConnection;122;0;125;0
WireConnection;122;1;107;0
WireConnection;103;0;86;0
WireConnection;76;0;104;0
WireConnection;76;1;75;0
WireConnection;76;2;82;0
WireConnection;108;0;119;0
WireConnection;240;0;237;0
WireConnection;240;1;267;0
WireConnection;240;2;239;0
WireConnection;123;0;137;0
WireConnection;104;0;136;0
WireConnection;104;1;108;0
WireConnection;104;2;130;0
WireConnection;119;0;120;0
WireConnection;119;1;109;0
WireConnection;109;0;118;0
WireConnection;109;1;117;0
WireConnection;290;3;112;0
WireConnection;290;5;240;0
ASEEND*/
//CHKSM=3BF45C38387635527AC013C057E970F276005EC6