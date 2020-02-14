Shader "KVY/Fake Lit PBR test"
{
    Properties
    {
        _Color ("BaseColor", Color) = (1, 1, 1)
        _Metalness ("Metalness", Range(0, 1)) = 0
        _Roughness ("Roughness", Range(0, 1)) = 1
        //_SkyBox ("Cubemap", CUBE) = "" {} 

        _remap1 ("remap1", Float) = 0
        _remap2 ("remap2", Float) = 1
        _pow ("pow", Float) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM 
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "FunctionLib.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                half3 worldNormal : TEXCOORD2;

                half3x3 tangentSpace : TEXCOORD3;
                // tangent Space = { {tangent.x [0][0], bitangent.x [0][1], normal.x[0][2]},
                //                   {tangent.y [1][0], bitangent.y [1][1], normal.y[1][2]},
                //                   {tangent.z [2][0], bitangent.z [2][1], normal.z[2][2]} }
                half3 normal : NORMAL;
            };

            samplerCUBE _SkyBox;
            sampler2D _MainTex, _AOMap, _BumpMap, _MetalnessMap, _RoughnessMap, _EmissiveMap;
            half _Metalness, _Roughness, _AOIntensity, _Emissive, _SunIntensity, _ShadowContrast;
            fixed3 _SunColor, _Color, _ShadowColor;
            float3 _Sun;

            half _remap1, _remap2, _pow;

            v2f vert(float4 vertex : POSITION, float3 normal : NORMAL, float2 uv : TEXCOORD0, float4 tangent : TANGENT)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(vertex);
                o.uv = uv;

                o.worldPos = mul(unity_ObjectToWorld, vertex);
                o.worldNormal = UnityObjectToWorldNormal(normal);
                o.normal = o.worldNormal;

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
                half3 worldReflect = reflect(-worldViewDir, i.normal);
                half4 sky = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldReflect); // sample the default reflection cubemap, using the reflection vector
                //half4 sky = texCUBE(_SkyBox, worldReflect);

                fixed3 emis = tex2D(_EmissiveMap, i.uv) * _Emissive;

                // fixed3 bliki = saturate(dot(normalize(_Sun), normalize(worldReflect)));
                // bliki = pow(bliki, pow(_Roughness * 10, _Roughness * 5));
                // bliki += pow(1 - dot(worldViewDir, i.normal), 5);
                 
                // fixed3 roughness = lerp(
                //     lerp(_Color, lerp(1, sky, _Roughness), _Roughness * (bliki + 0.05)) * _SunColor,
                //     sky,
                //     _Roughness * 0
                //     );  
                // roughness = contrast(roughness, sin(3.14 * _Roughness) * 1.5 + 1);

                // return roughness;
                fixed3 col = _Color;

                fixed3 lightData = dot(normalize(i.normal), normalize(_Sun));
                lightData = contrast(lightData, _ShadowContrast) * _SunIntensity;
                fixed3 light = lerp(_ShadowColor, _SunColor, lightData);

                fixed3 col_light = col * light;
                fixed3 rim = pow(1 - dot(worldViewDir, i.normal), 4) + 0.1;
                fixed3 reflex = saturate(dot(normalize(_Sun), normalize(worldReflect))) * _SunColor;

                fixed3 col_light_rim = lerp(col_light, sky, rim * _Roughness);

                fixed3 final = 1;
                final = col_light_rim + pow(remap(reflex, 0, 1, _remap1, _remap2), _pow);
                return final;
            }
            ENDCG
        }
    }
}
