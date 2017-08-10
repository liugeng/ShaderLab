Shader "Custom/MotionBlurEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

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
			float2 _Center;
			float _Intensity;
			int _IterateCount;

			
			// 算出纹理坐标离动态模糊中心的差值
			// 在循环里，每次对这个差值做一点缩放
			// 然后用这个缩放后的uv坐标去采样得到一个颜色值
			// 将多次采样得到的颜色相加再求出一个平均值
			// 就得到最终的颜色了
			
			// 现在用的是x、y轴缩放相同的值
			// 如果只在x方向上对uv坐标缩放
			// 就能得到沿x方向的径向模糊效果了
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv - _Center;
				float scale = 1;
				float4 color = 0;
				
				for (int j = 0; j < _IterateCount; j++) {
					color += tex2D(_MainTex, uv * scale + _Center);
					scale = 1 + j * _Intensity;
				}
				
				color /= _IterateCount;
				
				return color;
			}
			ENDCG
		}
	}
}
