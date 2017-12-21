Shader "GLSL/Pulsar"
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
				float d = sin(a) * (b* (t -(1.0 * 5.0)));
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

			float2 _time;
//			float2 colMod;
//			float2 disMod;
			float brightness = 0.1;

			float fade = 0.0;

			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target{

    			if( brightness < 0.15 ) {
       				 brightness = max( ( cos(_time.y) * 0.25 + sin(_time.y) * 0.25 ), 0.1); 
    				}
				float radius = 0.24 + brightness * 1.2;
				float invRadius = 1.0/radius; // Sphere outer glow radius variable
	
				float3 colorMain = float3( 0.2  , 0.65 * 0.06 , 0.5 * 1.0/2.0 ); 
				float3 colorSecondary = float3( 0.1 * 0.5.x/2.0, 0.25,0.81);
				//float _time = time.x * 2.1;
				float2 _res = float2(1.0,1.0);
				float aspect = _res.x/_res.y;
				float2 uv = TEXCOORD0 / aspect  ;
				float2 p  = -0.5 + uv  ;
				p.x  mul(aspect) ;
	
				fade = pow( length( 2.0 * p  ) , (0.5*0.2) * disMod.x ) ;
	
				float fVal1 = 1.0 - fade;
				float fVal2 = 1.0 - fade;
	
				float angle = atan2( p.y, p.x )/6.2832 ;
				float dist = getDistance(length(p), 1.0);
				float3 coord = float3( angle, dist, _time.y * 0.1 );
	
				float newTime1 = abs( snoise( coord + float3( 0.0, -_time * ( 0.35 + brightness * 0.001 ), _time * 0.015 ), 15.0 * shpMod.x));
				float newTime2 = abs( snoise( coord + float3( 0.0, -_time * ( 0.15 + brightness * 0.001 ), _time * 0.015 ), 45.0* shpMod.x));	

				for( int i=1; i<=7; i++ ){
					float power = pow( 2.0, float(i + 1) );
					fVal1 += ( 0.5 / power ) * snoise( coord + float3( 0.0, -_time, _time * 0.2 ), ( power * ( 10.0 ) * ( newTime1 + 1.0 ) ) );
					fVal2 += ( 0.5 / power ) * snoise( coord + float3( 0.0, -_time, _time * 0.2 ), ( power * ( 25.0 ) * ( newTime2 + 1.0 ) ) );
				}

				float corona = pow( fVal1 * max( 1.1 - fade, 0.0 ), 2.0 ) * 50.0;
				corona += pow( fVal2 * max( 1.1 - fade, 0.0 ), 2.0 ) * 50.0;
				corona mul(1.2 - newTime1);
				float3 sphereNormal = float3( 0.0, 0.0, 1.0 );
				float3 dir = float3( 0.0 );
				float3 center = float3( 0.5, 0.5, 1.0 );
				float3 starSphere = float3( 0.0 );
	
				float2 sp = -1.0 + 2.0 / uv;
				sp.x mul(aspect);
				sp mul( 2.0 - brightness );
  				float r = dot(sp,sp);
				float f = (1.0-sqrt(abs(1.0-r)))/(r) + brightness *0.5;
				if( dist < radius ){
					corona mul( pow( dist * invRadius, 24.0 ));
  	  				float2 newUv;
 	   				newUv.x = sp.x*f;
  	 				newUv.y = sp.y*f;
					newUv += vec2( _time , 0.0 );
		
					//float3 texSample = tex2D( _MainTex, newUv ).rgb * colMod.x;
					//float uOff = ( texSample.g * brightness * 3.14 + _time * 0.5 );
					//float2 starUV = newUv + float2( uOff, 0.0 );
					//starSphere = tex2D( _MainTex, starUV ).rgb * disMod.x/10.0; // Set the values to the texture inside the sphere
				}
	
				float starGlow = min( max( 1.0 - dist * ( 1.0 - brightness  ), 0.0 ), 1.0 );

   				return float4((  f * ( 0.75 + brightness * 0.3 ) * colorMain ) + starSphere + corona * colorMain + starGlow * colorSecondary,1);
   				ENDCG
   			}
 
   			
   		}
	}
}


//uniform lowp vec4 time; // time user-controlled constant
//uniform lowp vec4 colMod; // color user-controlled constant
//uniform lowp vec4 shpMod; // shape user-controlled constant
//uniform lowp vec4 disMod; // distance user-controlled constant


