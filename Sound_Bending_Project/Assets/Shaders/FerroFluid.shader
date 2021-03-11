Shader "Shaders/FerroFluid"
{
	Properties
	{
		_SpikeMap("Spike Map", 2D) = "white" {}
		_Spikyness("Spiky-ness", Range(0.0, 1.0)) = 1.0
		_SpikeFreq("Spike frequency", float) = 25.0
		_SpikeSpread("Spike spread", float) = 2.0
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

			// --- helper functions
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

			float3 Dots(float2 uv, float frequency, float spread)
			{
				float2 circleCenter;
				circleCenter.x = round(uv.x * frequency) / frequency;
				circleCenter.y = round(uv.y * frequency) / frequency;

				return (1 - InverseLerp(distance(circleCenter, uv), 0.0, 1 / (frequency * spread))).xxx;
			}
			
			// --- main functions 
			sampler2D _SpikeMap;
			float _Spikyness;
			float _SpikeFreq;
			float _SpikeSpread;

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
				float spikeVal = Dots(v.uv0, _SpikeFreq, _SpikeSpread).x;
				o.uv0 = v.uv0;
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.clipPos = UnityObjectToClipPos(v.vertex + o.normal * _Spikyness * Dots(o.uv0, _SpikeFreq, _SpikeSpread).x);

				return o;

				/*
				// Sliding uv effect

				float slideVal = _Time.y * .1;
				o.uv0 = v.uv0 + slideVal;
				*/
			}

			fixed4 frag(VertexShaderOutput i) : SV_Target
			{
				//float spikeColor = tex2D(_SpikeMap, i.uv0).r * _Spikyness;



				return float4(Dots(i.uv0, _SpikeFreq, _SpikeSpread).x, 0, 0, 1);
			}
			ENDCG
		}
	}
}
