// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/fire"
{
    Properties
    {
    }

    CGINCLUDE
    #include "UnityCG.cginc"
    #pragma target 3.0

    #define vec2 float2
    #define vec3 float3
    #define vec4 float4
    #define iGlobalTime _Time.y
    #define mix lerp
    #define iResolution _ScreenParams
    //#define gl_FragCoord ((_iParam.pos.xy / _iParam.pos.w) * _ScreenParams.xy)
    #define gl_FragCoord _iParam.pos.xy

    vec4 main(in vec2 outCoord);

    struct v2f
    {
        float4 pos : SV_POSITION;
        float4 scrPos : TEXCOORD0;
    };

    v2f vert(appdata_base v)
    {
        v2f o;
        //o.pos = UnityObjectToClipPos(mul(unity_ObjectToWorld, v.vertex));
        //o.pos=mul(unity_ObjectToWorld, v.vertex);
        o.pos = UnityObjectToClipPos(v.vertex);
        //o.pos = UnityObjectToClipPos(v.vertex);
        //o.scrPos = ComputeScreenPos(o.pos);
        return o;
    }

    fixed4 frag(v2f _iParam) : COLOR0
    {
        //vec2 outCoord = gl_FragCoord;
        return main(gl_FragCoord);
    }

    float noise(vec3 p)
    {
        vec3 i = floor(p);
        vec4 a = dot(i, vec3(1.0, 57.0, 21.0)) + vec4(0.0, 57.0, 21.0, 78.0);
        vec3 f = cos((p - i) * acos(-1.0)) * (-0.5) + 0.5;
        a = mix(sin(cos(a) * a), sin(cos(1.0 + a) * (1.0 + a)), f.x);
        a.xy = mix(a.xz, a.yw, f.y);
        return mix(a.x, a.y, f.z);
    }
    
    float sphere(vec3 p, vec4 spr)
    {
        return length(spr.xyz - p) - spr.w;
    }

    float flame(vec3 p)
    {
        // range of fire, and origin point
        float d = sphere(p * vec3(0.8, 0.7, 0.8), vec4(0.0, -1.0, 0.0, 1.0));
        return d + (noise(p + vec3(0.0, iGlobalTime * 2.0, 0.0)) + noise(p * 3.0) * 0.5) * 0.25 * (p.y);
    }

    float scene(vec3 p)
    {
        return min(100.0 - length(p), abs(flame(p)));
    }

    vec4 raymarch(vec3 org, vec3 dir)
    {
        float d = 0.0, glow = 0.0, eps = 0.02;
        vec3 p = org;
        bool glowed = false;

        for (int i = 0; i < 64; i++)
        {
            d = scene(p) + eps;
            p += d * dir;
            if (d > eps)
            {
                if (flame(p) < 0.0)
                    glowed = true;
                if (glowed)
                    glow = float(i) / 64.0;
            }
        }
        return vec4(p, glow);
    }

    vec4 main(in vec2 outCoord)
    {
        vec2 v = -1.0 + 2.0 * outCoord.xy / iResolution.xy;
        v.x *= iResolution.x / iResolution.y;

        vec3 origin = vec3(0.0, -2.0, 4.0);
        vec3 direction = normalize(vec3(v.x * 1.6, -v.y, -1.5));


        vec4 p = raymarch(origin, direction);
        float glow = p.w;

        // color mixture
        vec4 color = mix(vec4(1.0, 1.0, 0.6, 1.0), vec4(1.0, 0.5, 0.1, 1.0), distance(vec2(outCoord.x, outCoord.y - 1.0), vec2(0.0, -1.0)) * (3.5 / sqrt(pow(iResolution.x, 2.0) + pow(iResolution.y, 2.0))) + 0.0);

        vec4 color_out = mix(vec4(0.0, 0.0, 0.0, 0.0), color, pow(glow * 2.0, 4.0));
        
        //Debug.log(gl_FragCoord);
        return color_out;
    }

    ENDCG

    SubShader
    {
        Tags { "Queue" = "Overlay" }
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
