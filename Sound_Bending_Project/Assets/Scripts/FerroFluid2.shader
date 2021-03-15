Shader "Shaders/FerroFluid2"
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

			// --- linked variables
			float _Spikyness;
			float _RoundPlace;
			float _SpikeSpread;
			float _ModComp;
			
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

			float3 ModDots(float2 uv)
			{
				float2 circleCenter;
				circleCenter.x = round(uv.x * _RoundPlace) / _RoundPlace;
				circleCenter.y = round(uv.y * _RoundPlace) / _RoundPlace;

				float closeness2Center = (1 - InverseLerp(distance(circleCenter, uv), 0.0, 1 / (_RoundPlace * _SpikeSpread)));

				// Look at this for an example of using modulus to choose specific spikes
				if (ModulusKeyValue(circleCenter.x) == 0)
					return float3(closeness2Center, 0, 0);					// red
				else if (ModulusKeyValue(circleCenter.x) == 1)
					return float3(0, closeness2Center, 0);					// green
				else if (ModulusKeyValue(circleCenter.x) == 2)
					return float3(0, 0, closeness2Center);					// blue
				else if (ModulusKeyValue(circleCenter.x) == 3)
					return float3(closeness2Center, 0, closeness2Center);	// magenta
				else if (ModulusKeyValue(circleCenter.x) == 4)
					return float3(closeness2Center, closeness2Center, 0);	// yellow
				else if (ModulusKeyValue(circleCenter.x) == 5)
					return float3(0, closeness2Center, closeness2Center);	// cyan
				else if (ModulusKeyValue(circleCenter.x) == 6)
					return float3(closeness2Center.xxx);					// white
				else // ERROR
					return float3(0, 0, 0);									// black
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
				float3 normal : TEXCOORD1;
				float4 worldPos : TEXCOORD2;
				float4 clipPos : SV_POSITION;
			};

			VertexShaderOutput vert(VertexShaderInput v)
			{
				VertexShaderOutput o;
				o.uv0 = v.uv0;
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.clipPos = UnityObjectToClipPos(v.vertex + o.normal * _Spikyness * Dots(o.uv0).x); // CURRENTLY USES DOTS()

				return o;
			}

			fixed4 frag(VertexShaderOutput i) : SV_Target
			{
				return float4(ModDots(i.uv0),1);
			}
			ENDCG
		}
	}
}
