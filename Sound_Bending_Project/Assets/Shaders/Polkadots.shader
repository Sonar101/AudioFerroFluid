Shader "Shaders/Polkadots"
{
	Properties
	{
		//_SpikeMap("Spike Map", 2D) = "white" {}
		//_Spikyness("Spiky-ness", Range(0.0, 1.0)) = 1.0
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
					return (d-f)/d;
				}
			}

			float Dots(float2 uv, float frequency, float spread)
			{
				float2 circleCenter;
				circleCenter.x = round(uv.x * frequency) / frequency;
				circleCenter.y = round(uv.y * frequency) / frequency;

				return 1 - InverseLerp(distance(circleCenter, uv), 0.0, 1 / (frequency * spread));
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
				o.clipPos = UnityObjectToClipPos(v.vertex);

				return o;
			}

			fixed4 frag(VertexShaderOutput i) : SV_Target
			{
				float3 col = Dots(i.uv0, 25, 2).xxx;

				return float4(col, 1);
			}
			ENDCG
		}
	}
}
