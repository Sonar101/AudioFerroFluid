Shader "Shaders/FeatherShader"
{
	Properties
	{
		//_Spikyness("Spiky-ness", Range(0.0, 1.0)) = 1.0
		_SpikeSpread("Spike spread", float) = 2.0
		_RoundPlace("Rounding Place", float) = 10			//		Rounding the point's UV coordinates to every 
															// 10th place, 100th place, and so on, to select 
															// a circle center position to compare its distance to
		_ModComp("Modulus Comparison Value", float) = 7.0	//		Using 7 means the spike modulus key values 
															// repeat every 7 circles, which is good for
															// 7 frequency bands.
		_MaxSpike("Max Spike Scale", float) = 0.006
		_Color("Color", Color) = (1,1,1,1)
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_Albedo("Albedo", 2D) = "white" {}
		_AlbedoVal("Albedo Value", Range(0, 1)) = 0.5
		_Metalness("Metalness Tex", 2D) = "white" {}
		_MetalnessVal("Metalness Value", Range(0, 1)) = 0.5
		_Roughness("Roughness Tex", 2D) = "white" {}
		_RoughnessVal("Roughness Value", Range(0, 1)) = 0.5

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

			//----------------------------
			float4 _LightColor0;  //Light color, declared in UnityCG
			float4 _Color;
			float4 _SpecularColor;

			sampler2D _Albedo;
			sampler2D _Metalness;
			sampler2D _Roughness;
			float _AlbedoVal;
			float _MetalnessVal;
			float _RoughnessVal;

			//----------------------------

		// --- linked variables
			float _freq0;
			float _freq1;
			float _freq2;
			float _freq3;
			float _freq4;
			float _freq5;
			float _freq6;
			float _freq7;

			float _RoundPlace;
			float _SpikeSpread;
			float _ModComp;
			float _MaxSpike;
			// --- helper functions
			float ModulusKeyValue(float circleCenterVal)
			{
				float key = fmod(circleCenterVal, _ModComp * (1 / _RoundPlace));
				key *= _RoundPlace;
				return round(key);
			}

			float4 InverseLerp(float a, float b, float c)
			{
				a = clamp(a, b, c);
				if (a == b)
					return 0.0;
				else if (a == c)
					return 1.0;
				else {
					float d = c - b;
					float f = c - a;
					return (d - f) / d;
				}
			}

			float3 Dots(float2 uv)
			{
				// This function is currently what the vertex shader bases it's spiky value on
				float2 circleCenter;
				circleCenter.x = round(uv.x * _RoundPlace) / _RoundPlace;
				circleCenter.y = round(uv.y * _RoundPlace) / _RoundPlace;

				float closeness2Center = (1 - InverseLerp(distance(circleCenter, uv), 0.0, 1 / (_RoundPlace * _SpikeSpread)));

				return float3(closeness2Center, 0, 0);
			}

			float SpikyVal(float2 uv) {
				float2 circleCenter;
				circleCenter.x = round(uv.x * _RoundPlace) / _RoundPlace;
				circleCenter.y = round(uv.y * _RoundPlace) / _RoundPlace;
				float closeness2Center = (1 - InverseLerp(distance(circleCenter, uv), 0.0, 1 / (_RoundPlace * _SpikeSpread)));


				if (ModulusKeyValue(circleCenter.x) == 0) {
					return _freq0;
				}
				else if (ModulusKeyValue(circleCenter.x) == 1) {
					return _freq1;
				}
				else if (ModulusKeyValue(circleCenter.x) == 2) {
					return _freq2;
				}
				else if (ModulusKeyValue(circleCenter.x) == 3) {
					return _freq3;
				}
				else if (ModulusKeyValue(circleCenter.x) == 4) {
					return _freq4;
				}
				else if (ModulusKeyValue(circleCenter.x) == 5) {
					return _freq5;
				}
				else if (ModulusKeyValue(circleCenter.x) == 6) {
					return _freq6;
				}
				else {
					return _freq7;
				}
			}

			float3 ModDots(float2 uv)
			{
				float2 circleCenter;
				circleCenter.x = round(uv.x * _RoundPlace) / _RoundPlace;
				circleCenter.y = round(uv.y * _RoundPlace) / _RoundPlace;

				float closeness2Center = (1 - InverseLerp(distance(circleCenter, uv), 0.0, 1 / (_RoundPlace * _SpikeSpread)));

				// Look at this for an example of using modulus to choose specific spikes
				if (ModulusKeyValue(circleCenter.x) == 0) {
					return float3(closeness2Center, 0, 0);					// red
				}
				else if (ModulusKeyValue(circleCenter.x) == 1) {
					return float3(0, closeness2Center, 0);					// green
				}
				else if (ModulusKeyValue(circleCenter.x) == 2) {
					return float3(0, 0, closeness2Center);					// blue
				}
				else if (ModulusKeyValue(circleCenter.x) == 3) {
					return float3(closeness2Center, 0, closeness2Center);	// magenta
				}
				else if (ModulusKeyValue(circleCenter.x) == 4) {
					return float3(closeness2Center, closeness2Center, 0);	// yellow
				}
				else if (ModulusKeyValue(circleCenter.x) == 5) {
					return float3(0, closeness2Center, closeness2Center);	// cyan
				}
				else if (ModulusKeyValue(circleCenter.x) == 6) {
					return float3(closeness2Center.xxx);					// white
				}
				else {// ERROR
					return float3(0, 0, 0);
				}// black
			}

			// --- main functions
			struct VertexShaderInput
			{
				float2 uv0 : TEXCOORD0;
				float3 normal : NORMAL;
				float4 vertex : POSITION;
			};

			struct VertexShaderOutput
			{
				float2 uv0 : TEXCOORD0;
				float3 normDir : TEXCOORD1;
				float4 worldPos : TEXCOORD2;
				float4 clipPos : SV_POSITION;
			};

			/*VertexShaderOutput vert(VertexShaderInput v)
			{
				VertexShaderOutput o;
				o.uv0 = v.uv0;
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				// Makes Spike
				o.clipPos = UnityObjectToClipPos(v.vertex + v.normal * SpikyVal(o.uv0) * _MaxSpike * Dots(o.uv0).x);

				return o;
			}*/

			VertexShaderOutput vert(VertexShaderInput v)
			{
				VertexShaderOutput o;
				o.uv0 = v.uv0;
				o.normDir = UnityObjectToWorldNormal(v.normal);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.clipPos = UnityObjectToClipPos(v.vertex + o.normDir * SpikyVal(o.uv0) * _MaxSpike * Dots(o.uv0).x);
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

				//float3 albedo = tex2D(_Albedo, i.uv0) * _Color;
				float3 albedo = _AlbedoVal * _Color;
				//float roughness = tex2D(_Roughness, i.uv0).r; //* _RoughnessVal;
				float roughness = _RoughnessVal;
				//float metalness = tex2D(_Metalness, i.uv0).r; //* _MetalnessVal
				float metalness = _MetalnessVal;
				float3 F0 = lerp(_SpecularColor, tex2D(_Albedo, i.uv0).rgb , metalness);

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

				return float4(ModDots(i.uv0),1);
				//return final;
		}
		ENDCG
	}
		}
}
