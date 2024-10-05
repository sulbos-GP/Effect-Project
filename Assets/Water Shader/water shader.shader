Shader "Custom/water shader"
{
    Properties
    {
		_CUBE("Cubemap",CUBE) = ""{}
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump",2D) = "white"{}
    }
		SubShader
	{
		Tags { "RenderType" = "Opaque"  }
		LOD 200

		GrabPass{}

		CGPROGRAM
		#pragma surface surf water  noambient vertex:vert addshadow
		#pragma target 3.0

		sampler2D _GrabTexture;
		sampler2D _MainTex;
		samplerCUBE _CUBE;
		sampler2D _BumpMap;

		struct Input
		{
			float2 uv_MainTex;
			float3 worldRefl;
			float2 uv_BumpMap;
			float4 screenPos;
			float3 viewDir;

			INTERNAL_DATA
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void vert(inout appdata_full v)
		{
			v.vertex.y += cos(abs(v.texcoord.x * 2 - 1) * 10 + _Time.y)*0.05;
		}
		void surf(Input IN, inout SurfaceOutput o)
		{

			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);

			float3 normal1 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap + _Time.y*0.03));
			float3 normal2 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap + _Time.y*0.01));
			o.Normal = lerp(normal1, normal2, 0.5);
			o.Normal *= float3(0.5, 0.5, 1);

			//rim
			float rim = saturate(dot(o.Normal, IN.viewDir));
			float rim1 = pow(1 - rim, 20);
			float rim2 = pow(1 - rim, 2);


			float4 reflection = texCUBE(_CUBE, WorldReflectionVector(IN, o.Normal));
			//o.Emission = reflection*1.05;

			float3 srcUV = IN.screenPos.rgb / (IN.screenPos.a + 0.0000001);
			//o.Emission = tex2D(_GrabTexture, srcUV+o.Normal.xy*0.03)*0.5;
			float3 fGrab = tex2D(_GrabTexture, srcUV + o.Normal.xy*0.03)*0.5;
			o.Emission = lerp(fGrab, reflection, rim2) + (rim1 * _LightColor0);
			o.Alpha = 1;
		}
		float4 Lightingwater(SurfaceOutput o, float3 lightDir, float3 viewDir, float atten)
		{
			//rim
			/*float rim = saturate(dot(o.Normal, viewDir));
			float rim1 = pow(1 - rim, 20);
			float rim2 = pow(1 - rim, 2);*/

			//spec
			float3 H = normalize(lightDir + viewDir);
			float spec = saturate(dot(o.Normal, H));
			spec = pow(spec, 1050) * 10;

			float4 final;
			final.rgb = spec * _LightColor0;
			final.a = o.Alpha + spec;

			return final;
		}
		ENDCG
	}
		FallBack "Tranparent"
}
