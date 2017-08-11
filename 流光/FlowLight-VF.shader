Shader "Custom/FlowLight-VF"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FlowTex ("FlowTex", 2D) = "whiter" {}
		_MaskTex ("MaskTex", 2D) = "whiter" {}
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _FlowTex;
			sampler2D _MaskTex;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				if (col.a > 0) {
					float2 flowuv = i.uv;
					//_Time 见"ShaderLab Builtin values"
					//http://www.ceeger.com/Components/SL-BuiltinValues.html
					//speed * time, Time(t/20, t, t*2, t*3)
					//_FlowTex 的 WrapMode 需要设置成 Repeat
					flowuv.x += -0.1 * _Time.z;
					fixed4 col1 = tex2D(_FlowTex, flowuv);
					if (col1.a > 0) {
						fixed4 col2 = tex2D(_MaskTex, i.uv);
						if (col2.a > 0.01)
							col *= col.a + col1.a;
					}
				}
				return col;
			}
			ENDCG
		}
	}
}
