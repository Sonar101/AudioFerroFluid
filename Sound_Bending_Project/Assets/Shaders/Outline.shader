Shader "Shaders/Outline"
{
	Properties
	{
		_SpikeMap("Spike Map", 2D) = "white" {}
		_Spikyness("Spiky-ness", Range(0.0, 1.0)) = 1.0
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
			float _Spikyness;

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
				float3 normal = normalize(i.normal);
				float3 fragToViewDirec = _WorldSpaceCameraPos - i.worldPos;
				float3 viewDirec = normalize(fragToViewDirec);				
				float angle = dot(normal, viewDirec);

				float4 color = 0;

				if (.7 > angle)
				{
					color = float4(1, 1, 1, 1);
				}
				else
				{
					discard;
				}

				return color;
			}
			ENDCG
		}
	}
}
