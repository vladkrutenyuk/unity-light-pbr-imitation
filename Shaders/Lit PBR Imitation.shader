Shader "KVY/Lit PBR Imitation"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1)
        _MainTex ("Base Color", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _Metalness ("Metalness", Range(0, 1)) = 0
        _MetalnessMap ("Mask", 2D) = "white" {}
        _Roughness ("Roughness", Range(0, 1)) = 1
        _RoughnessMap ("Mask", 2D) = "white" {}
        _AOIntensity ("AO Intensity", Range(0, 2)) = 1
        _AOMap ("AO Map", 2D) = "white" {}
        _EmissiveMap ("Emissive Map", 2D) = "black" {}

        [Toggle(USE_CUSTOM_SKY)] _UseCustomSky("Use custom sky", Int) = 0
    }
    SubShader
    {   
        Pass
        {
            CGPROGRAM 
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature USE_CUSTOM_SKY

            #include "UnityCG.cginc"
            #include "FunctionLib.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                half3 worldNormal : TEXCOORD2;
                half3x3 tangentSpace : TEXCOORD3;
            };

            float3 _Sun;
            fixed3 _SunColor, _ShadowColor;
            half _SunIntensity, _ShadowContrast;

            samplerCUBE _SkyBox;

            sampler2D _MainTex, _AOMap, _BumpMap, _MetalnessMap, _RoughnessMap, _EmissiveMap;
            half _Metalness, _Roughness, _AOIntensity, _Emissive;
            fixed3 _Color;

            v2f vert(float4 vertex : POSITION, float3 normal : NORMAL, float2 uv : TEXCOORD0, float4 tangent : TANGENT)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(vertex);
                o.uv = uv;

                o.worldPos = mul(unity_ObjectToWorld, vertex);
                o.worldNormal = UnityObjectToWorldNormal(normal);

                half3 worldTangent = UnityObjectToWorldDir(tangent);
                half3 worldBitangent = cross(o.worldNormal, worldTangent) * tangent.w * unity_WorldTransformParams.w;

                o.tangentSpace[0] = half3(worldTangent.x, worldBitangent.x, o.worldNormal.x);
                o.tangentSpace[1] = half3(worldTangent.y, worldBitangent.y, o.worldNormal.y);
                o.tangentSpace[2] = half3(worldTangent.z, worldBitangent.z, o.worldNormal.z);

                return o;
            }

            fixed3 frag(v2f i) : SV_TARGET
            {
                half3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
                i.worldNormal = half3
                                    (
                                    dot(i.tangentSpace[0], tangentNormal),
                                    dot(i.tangentSpace[1], tangentNormal),
                                    dot(i.tangentSpace[2], tangentNormal)
                                    );
                half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half3 worldReflect = reflect(-worldViewDir, i.worldNormal);

    #ifdef USE_CUSTOM_SKY
                            half4 sky = texCUBE(_SkyBox, worldReflect);
    #else
                            half4 sky = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldReflect);
    #endif

                _Roughness *= tex2D(_RoughnessMap, i.uv);
                _Metalness *= tex2D(_MetalnessMap, i.uv);

                fixed3 col = _Color * tex2D(_MainTex, i.uv);
                fixed3 lightData = dot(normalize(i.worldNormal), normalize(_Sun));
                lightData = contrast(lightData, _ShadowContrast) * _SunIntensity;
                fixed3 light = lerp(_ShadowColor, _SunColor, lightData);

                col = lerp(col * light, col * sky, _Metalness);

                fixed3 rim = pow(1 - dot(worldViewDir, i.worldNormal), 4) + 0.1;
                fixed3 col_light_rim = lerp(col, sky, rim * (1 - _Roughness));

                fixed3 reflex = saturate(dot(normalize(_Sun), normalize(worldReflect))) * _SunColor;
                reflex = pow(remap(reflex, 0, 1, 0, sin(3.14 * _Roughness)), 1 * (1 + pow(_Roughness, 8)));

                col = col_light_rim + reflex;

                col *= lerp(1, tex2D(_AOMap, i.uv), _AOIntensity);
                col += tex2D(_EmissiveMap, i.uv);

                return col;
            }
            ENDCG
        }
    }
}