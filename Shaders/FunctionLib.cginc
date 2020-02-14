#ifndef INTERPOLATION
#define INTERPOLATION

float4 remap(float4 input, float4 from1, float4 to1, float4 from2, float4 to2)
{
    return (input - from1) / (to1 - from1) * (to2 - from2) + from2;
}

float remap(float input, float from1, float to1, float from2, float to2)
{
    return (input - from1) / (to1 - from1) * (to2 - from2) + from2;
}

float3 posterize(float3 In, float3 Steps)
{
    return floor(In / (1 / Steps)) * (1 / Steps);
}

float3 contrast(float3 In, float Contrast)
{
    float midpoint = pow(0.5, 2.2);
    return (In - midpoint) * Contrast + midpoint;
}

#endif