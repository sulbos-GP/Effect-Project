Shader "Custom/Radial Blur"
{
	CGINCLUDE
#include "UnityCG.cginc"
		struct appdata {
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};
	struct v2f {
		float4 vertex : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	float _Intensity;           //  반경 효과의 강도
	float _FadeRadius;          //  반경 효과의 반지름 페이드아웃
	float _SampleDistance;      //  샘플의 거리
	sampler2D _DownSampleRT;    //  다운 샘플링 후 텍스처
	sampler2D _SrcTex;          //  원본 이미지 질감
	v2f vert(appdata v) {
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex); // 오브젝트 공간의 버텍스를 화면으로 변환해주는 함수
		o.uv = v.uv;
		return o;
	}
	fixed4 frag(v2f i) : SV_Target{
		const int sampleCount = 5; 
		const float invSampleCount = 1.0 / ((float)sampleCount * 2);
		float2 vec = i.uv - 0.5;
		float len = length(vec);
		float fade = smoothstep(0, _FadeRadius, len); //블러 효과를 부드럽게 페이드아웃
		float2 stepDir = normalize(vec) * _SampleDistance;  // 샘플링 방향 
		float stepLenFactor = len * 0.1 * _Intensity;         // len:0~0.5 , len*0.1=0~0.05 가운데 가까울수록 표본 추출 거리가 작아지고 가장자리의 모호성이 작아짐.
		stepDir *= stepLenFactor; 
		fixed4 sum = 0;
		for (int it = 0; it < sampleCount; it++) {
			float2 appliedStep = stepDir * it;
			sum += tex2D(_DownSampleRT, i.uv + appliedStep); 
			sum += tex2D(_DownSampleRT, i.uv - appliedStep); 
		}
		sum *= invSampleCount; 
		return lerp(tex2D(_SrcTex, i.uv), sum, fade * _Intensity);
	}
		ENDCG
		SubShader {
		Cull Off ZWrite Off ZTest Always
			Pass{
				NAME "RADIA_BLUR"
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				ENDCG
		}
	}
}