Shader "GLSL/Pulsar"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Adjustment ("Adjustment", Range(0.600000,10.00000)) = 0.6
		_Color ("Color", Range(0.100000,25.00000)) = 0.6
		_Distance ("Distance", Range(1.500000,10.50000)) = 5.0
		_InputX ("Input X", Float) = 0.0
		_InputY ("Input Y", Float) = 0.0
		_InputRX ("Input RX", Float) = 0.0
		_InputRY ("Input RY", Float) = 0.0

	}
	SubShader
	{
		// No culling or depth
		//Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			float _Adjustment = 0.6;
			float _Color = 0.6;
			float _Distance = 5.0;
			texture2D <float4> _MainTex;
			float _InputX = 0.0;
			float _InputY = 0.0;
			float _InputRX = 0.0;
			float _InputRY = 0.0;

			SamplerState MeshTextureSampler
			{
   				Filter = MIN_MAG_POINT_MIP_LINEAR ;
   				AddressU = Wrap;
   				AddressV = Wrap;
			};


			float snoise(float3 uv, float res)
			{
				static const float3 s = float3(1e0, 1e2, 1e4);
				uv *= res;
	
				float3 uv0 = floor( uv %res)*s;
				float3 uv1 = floor(uv+float3(1,1,1) % res)*s;
	
				float3 f = frac(uv); f = f*f*(3.0-2.0*f);
	
				float4 v = float4(uv0.x + uv0.y + uv0.z, uv1.x + uv0.y + uv0.z,
		      	  uv0.x +uv1.y + uv0.z, uv1.x +uv1.y + uv0.z);
	
				float4 r = frac(sin(v*1e-3)*1e5);
				float r0 = lerp(lerp(r.x, r.y, f.x), lerp(r.z, r.w, f.x), f.y);
	
				r = frac(sin((v + uv1.z - uv0.z)*1e-3)*1e5);
				float r1 = lerp(lerp(r.x, r.y, f.x), lerp(r.z, r.w, f.x), f.y);
	
				return lerp(r0, r1, f.z)*2.0-1.0;
			}

			float getDistance(float a, float b)
			{
				float t = 50.0;
				float d = sin(a) * (b* (t -(_Distance * 5.0)));
				return d;
			}

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

			float brightness = 0.1;

			float fade = 0.0;

			fixed4 frag (v2f i) : SV_Target
				{
   				 if( brightness < 0.15 ) {
      			 	 brightness	= max( ( cos(_Time.y) * 0.09 + sin(_Time.y) * 0.09 ), 0.1); 
    			}
				float radius = 0.24 + brightness * 1.2;
				float invRadius = 1.0/radius;

				_Color = _InputRX;
	
				float3 colorMain = float3( 0.2, 0.65 * (0.06 ), 0.5 * _Color/_Distance );
				float3 colorSecondary = float3( 0.1 * _Color, 0.25, 0.81 );
				float time = _Time.y * 0.1;
				float aspect = _ScreenParams.x/_ScreenParams.y;
				float2 uv = i.vertex.xy / _ScreenParams.xy;
				float2 p = uv - 0.5;
				p.x *= aspect;

				float fade	= pow( length( 2.0 * p ), (0.5 * 0.2) * _Distance );
				float fVal1	= 1.0 - fade;
				float fVal2	= 1.0 - fade;
	
				float angle	= atan2( p.x, p.y  ) / 6.2832;
				float dist = getDistance(length(p), 1.0);
				float3 coord = float3( angle, dist, time * 0.1 );
	
				float newTime1	= abs( snoise( coord + float3( 0.0, -time * ( 0.35 + brightness * 0.01 ), time * 0.001 ), 45.0 * _Adjustment ) );
				float newTime2	= abs( snoise( coord + float3( 0.0, -time * ( 0.15 + brightness * 0.01 ), time * 0.001 ), 45.0 * _Adjustment ) );	
				for( int i=1; i<=7; i++ ){
					float power = pow( 2.0, float(i + 1) );
					fVal1 += ( 0.5 / power ) * snoise( coord + float3( 0.0, -time, time * 0.2 ), ( power * ( 10.0 ) * ( newTime1 + 1.0 ) ) );
					fVal2 += ( 0.5 / power ) * snoise( coord + float3( 0.0, -time, time * 0.2 ), ( power * ( 25.0 ) * ( newTime2 + 1.0 ) ) );
				}
	
				float corona = pow( fVal1 * max( 1.1 - fade, 0.0 ), 2.0 ) * 100.0;
				corona += pow( fVal2 * max( 1.1 - fade, 0.0 ), 2.0 ) * 100.0;
				corona *= 1.2 - newTime1;
				float3 sphereNormal = float3( 0.0, 0.0, 1.0 );
				float3 dir = float3( 0.0, 0.0, 0.0 );
				float3 center = float3( 0.5, 0.5, 1.0 );
				float3 starSphere = float3( 0.0,0.0,0.0 );
	
				float2 sp = -1.0 + 2.0 * uv;
				sp.x *= aspect;
				sp *= ( 2.0 - brightness );
  				float r = dot(sp,sp);
				float f = (1.0-sqrt(abs(1.0-r)))/(r) + brightness * 0.5;
				if( dist < radius ){
					corona *= pow( dist * invRadius, 24.0 );
  					float2 newUv;
 					newUv.x = sp.x * cos((_InputX * 0.6) * 0.7 ) - sp.y * sin(( _InputY * 0.6) * 0.7);
					newUv.y = sp.y * cos((_InputY * 0.6) * 0.7 ) + sp.x * sin((_InputX * 0.6) * 0.7);
					//newUv.x = sp.x*f;
  					//newUv.y = sp.y*f;
					//newUv += float2( time, 0.0 );
					//newUv *= 2.0;

				float3 texSample = _MainTex.Sample( MeshTextureSampler, newUv * 0.001 ).rgb * _Color;
				float uOff	= ( texSample.x * brightness * 0.84 + time * 0.5 );
				float2 starUV = newUv + float2( 0.5, 0.5 );
			
				starSphere	= _MainTex.Sample( MeshTextureSampler, starUV ).rgb * _Distance/10;
				}

				float starGlow	= min( max( 1.0 - dist * ( 1.0 - brightness ), 0.0 ), 1.0 );
				//fragColor.rgb	= vec3( r );
				float3 e = float3((f * ( 0.75 + brightness * 0.3 ) * colorMain ) + starSphere + corona * colorMain + starGlow * colorSecondary);
				return fixed4(e, 1.0);
			}

			ENDCG
		}
	}
}

