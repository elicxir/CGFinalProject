Shader "Unlit/fire2"
{
    Properties
    {
    }
    CGINCLUDE

    #pragma vertex vert
    #pragma fragment frag
    // make fog work
    #pragma multi_compile_fog

    #include "UnityCG.cginc"
    #pragma target 3.0
    // #define gl_FragCoord _iParam.vertex.xy
    #define vec2 float2
    #define vec3 float3
    #define vec4 float4
    #define iResolution _ScreenParams
    #define iTime _Time.y
    #define mix lerp

    vec4 main(in vec2 outCoord);

    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
    };

    struct v2f
    {
        float2 uv : TEXCOORD0;
        UNITY_FOG_COORDS(1)
        float4 vertex : SV_POSITION;
    };

    sampler2D _MainTex;
    float4 _MainTex_ST;

    v2f vert(appdata v)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        // UNITY_TRANSFER_FOG(o,o.vertex);
        return o;
    }

    fixed4 frag(v2f i) : SV_Target
    {
        // sample the texture
        // fixed4 col = tex2D(_MainTex, i.uv);
        // apply fog
        // UNITY_APPLY_FOG(i.fogCoord, col);
        return main(i.vertex.xy);
    }

    vec2 hash(vec2 p)
    {
        p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
        return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
    }

    float noise(vec2 p)
    {
        const float K1 = 0.366025404;
        const float K2 = 0.211324865;

        vec2 i = floor(p + (p.x + p.y) * K1);

        vec2 a = p - (i - (i.x + i.y) * K2);
        vec2 o = (a.x < a.y) ? vec2(0.0, 1.0) : vec2(1.0, 0.0);
        vec2 b = a - o + K2;
        vec2 c = a - 1.0 + 2.0 * K2;

        vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);

        vec3 n = pow(h, 4.0) * vec3(dot(a, hash(i + 0.0)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));

        return dot(n, vec3(70.0, 70.0, 70.0));
    }

    float fbm(vec2 uv)
    {
        float f = 0.0;
        uv = uv * 2.0;
        f = 0.5000 * noise(uv);
        uv = 2.0 * uv;
        f += 0.2500 * noise(uv);
        uv = 2.0 * uv;
        f += 0.1250 * noise(uv);
        uv = 2.0 * uv;
        f += 0.0625 * noise(uv);
        uv = 2.0 * uv;
        f = f + 0.5;
        return f;
    }

    vec4 main(in vec2 outCoord)
    {

        vec2 uv = outCoord.xy / iResolution.xy;
        vec2 q = uv;
        q.x *= 5.0;
        float strength = 1.5;
        float T = 1.5 * iTime;
        q.x -= 2.5;
        q.y -= 0.25;

        float n = fbm(strength * q - vec2(0, T));

        float c = 1.0 - 16.0 * (pow(length(q) - n * q.y, 2.0));

        float c1 = n * c * (1.0 - pow(uv.y, 4.0));
        c1 = clamp(c1, 0.0, 1.0);

        vec3 col = vec3(1.5 * c1, 1.5 * pow(c1, 3.0), pow(c1, 6.0));

        float c2 = c * (1.0 - pow(uv.y, 4.0));

        vec4 color_out = mix(vec4(0.0, 0.0, 0.0, 1.0), vec4(col, 1.0), c2);
        if(color_out[0] <= 0.3 && color_out[1] <= 0.3 && color_out[2] <= 0.3) {
            color_out[3] = 0.0;
        }
        
        return color_out;
    }
    ENDCG

    SubShader
    {
        Tags{"Queue" = "Overlay"} 
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma enable_d3d11_debug_symbols

            ENDCG
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest Always

            ColorMask RGB
            ColorMaterial AmbientAndDiffuse

            SetTexture[_MainTex]
            {
                combine primary
            }
        }
    }
    FallBack Off
}
