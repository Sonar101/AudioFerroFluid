Shader "Shaders/FerroFluidShader"
{
	Properties
	{
		_SpikeMap("Spike Map", 2D) = "white" {}
		//_Spikyness("Spiky-ness", Range(0.0, 1.0)) = 1.0
		_Color("Color", Color) = (1,1,1,1)
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_Albedo("Albedo", 2D) = "white" {}
		_Metalness("Metalness Tex", 2D) = "white" {}
		_MetalnessVal("Metalness Value", Range(0, 1)) = 0.5
		_Roughness("Roughness Tex", 2D) = "white" {}
		//  _RoughnessVal("Roughness", Range(0.00000001, 1)) = 0.5;

	}
	
	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma glsl

			#include "UnityCG.cginc"

			sampler2D _SpikeMap;
			uniform float _Spikyness;
			//----------------------------
			float4 _LightColor0;  //Light color, declared in UnityCG
			float4 _Color;
			float4 _SpecularColor;

			sampler2D _Albedo;
			sampler2D _Metalness;
			float _MetalnessVal;
			sampler2D _Roughness;
			//----------------------------

			struct VertexShaderInput
			{
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 vertex : POSITION;
			};

			struct VertexShaderOutput
			{
				float2 uv : TEXCOORD0;
				float3 normDir : TEXCOORD1;
				float4 worldPos : TEXCOORD2;
				float4 clipPos : SV_POSITION;
			};

			VertexShaderOutput vert(VertexShaderInput v)
			{
				VertexShaderOutput o;
				o.uv = v.uv;
				//o.normal = UnityObjectToWorldNormal(v.normal);

				// vertex manipulation
				float spikeVal = tex2Dlod(_SpikeMap, float4(v.uv.xy, 0, 0)).r;
				v.vertex = v.vertex + float4(v.normal, 1) * spikeVal * _Spikyness;

				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.clipPos = UnityObjectToClipPos(v.vertex);
				//----------------------------
				float4x4 modelMatrix = unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject;

				o.normDir = normalize(mul(float4(v.normal, 0.0), modelMatrixInverse).xyz);
				//----------------------------
				return o;
			}
			//-------------------------------------------------------------------------------
			float DistributionGGX(float NdotH, float roughness) {
				float a2 = roughness * roughness;
				float NdotH2 = NdotH * NdotH;

				float nom = a2;
				float denom = (NdotH2 * (a2 - 1.0) + 1.0);
				denom = 3.14 * denom * denom;

				return nom / denom;
			}

			float GeometrySchlickGGX(float NdotV, float roughness) {
				float nom = NdotV;
				float denom = NdotV * (1.0 - roughness) + roughness;

				return nom / denom;
			}
			float GeometrySmith(float NdotV, float NdotL, float roughness) {
				float ggx1 = GeometrySchlickGGX(NdotV, roughness);
				float ggx2 = GeometrySchlickGGX(NdotL, roughness);

				return ggx1 * ggx2;
			}

			float3 FresnelSchlick(float3 F0, float NdotV) {
				return F0 + (1.0 - F0) * pow(1.0 - NdotV, 5.0);
			}
			//-------------------------------------------------------------------------------


			fixed4 frag(VertexShaderOutput i) : SV_Target
			{ 
				//-------------------------------------------------------------------------------
				float3 posDir = i.worldPos.xyz;
				float3 L = normalize(_WorldSpaceLightPos0.xyz);
				float3 N = normalize(i.normDir);
				float3 V = normalize(_WorldSpaceCameraPos - posDir);
				float3 H = normalize(L + V);

				float NdotL = max(dot(N, L), 0.0);
				float NdotH = max(dot(N, H), 0.0);
				float NdotV = max(dot(N, V), 0.0);

				float3 albedo = tex2D(_Albedo, i.uv) * _Color;
				float roughness = tex2D(_Roughness, i.uv).r; //* _RoughnessVal;
				float metalness = tex2D(_Metalness, i.uv).r; //* _MetalnessVal;
				//float metalness = _MetalnessVal;
				float3 F0 = lerp(_SpecularColor, tex2D(_Albedo, i.uv).rgb , metalness);

				float D = DistributionGGX(NdotH, roughness);
				float G = GeometrySmith(NdotV, NdotL, roughness);
				float3 F = FresnelSchlick(F0, NdotV);
				float3 Specular_BRDF = (D * G * F) / (4.0 * NdotV * NdotL);
				float3 d_factor = 1.0 - F;
				float3 Diffuse_factor = d_factor * (1 - metalness);
				float3 Diffuse_BRDF = albedo;

				float4 helpD = float4 (Diffuse_BRDF, 0.0);
				float4 helpS = float4 (Specular_BRDF, 0.0);

				float3 Reflect_Direction = reflect(-L, N);
				float3 Refract_Direction = refract(-V, N, 0.65);
				//float4 ReflectColor = texCUBE(_Cube, Reflect_Direction);
				//float4 RefractColor = texCUBE(_Cube, Refract_Direction);
				//-------------------------------------------------------------------------------
				float4 final = _LightColor0 * NdotL * (helpD + helpS);

				float spikeColor = tex2D(_SpikeMap, i.uv).r * _Spikyness;
				return final;
				//return float4(spikeColor * final[0], final[1], final[2], final[3]);
			}
			ENDCG
		}
	}
}
