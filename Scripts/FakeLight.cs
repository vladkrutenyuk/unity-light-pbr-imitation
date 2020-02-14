using UnityEngine;

[DisallowMultipleComponent]
[ExecuteInEditMode]
[AddComponentMenu("KVY/KVY - Fake Light System")]
public class FakeLight : MonoBehaviour
{
    [Range(-90, 90)] public int vertical = 0;
    [Range(0, 360)] public int horizontal = 0;
    [Range(1500, 11500)] public int temperature = 6500;
    public Color shadowColor = Color.black;
    [Range(0, 2)] public float shadowContrast = 1;
    [Range(0, 5)] public float intensity = 1;
    public Cubemap skyBox;
    public Material skyMaterial;
    public Material defaultSkyMaterial;
    public Vector3 sun;
    
    private void Start()
    {

        ApplySun();
    }

    private void Update()
    {
        if(Application.isPlaying)
            return;

        ApplySun();       
    }

    private void ApplySun()
    {
        sun.x = Mathf.Cos(horizontal * Mathf.Deg2Rad) * Mathf.Sin((vertical + 90) * Mathf.Deg2Rad);
        sun.z = Mathf.Sin(horizontal * Mathf.Deg2Rad) * Mathf.Sin((vertical + 90) * Mathf.Deg2Rad);
        sun.y = ((float)vertical/ 90); 

        sun = Vector3.Normalize(sun);

        Shader.SetGlobalVector("_Sun", sun);
        Shader.SetGlobalColor("_SunColor", SunColor(temperature));
        Shader.SetGlobalFloat("_SunIntensity", intensity);
        Shader.SetGlobalFloat("_ShadowContrast", shadowContrast);
        Shader.SetGlobalTexture("_SkyBox", skyBox);
        Shader.SetGlobalColor("_ShadowColor", shadowColor);
           
    }

    public Color SunColor(int t)
    {
        Gradient gradient = new Gradient();
        GradientColorKey[] colorKeys = new GradientColorKey[3];
        GradientAlphaKey[] alphaKeys = new GradientAlphaKey[1];
        alphaKeys[0].alpha = 1f;
        alphaKeys[0].time = 0f;
        
        colorKeys[0].color = new Color32(255, 108, 0, 255);
        colorKeys[0].time = 0f;

        colorKeys[1].color = new Color32(255, 255, 255, 255);
        colorKeys[1].time = 0.5f;

        colorKeys[2].color = new Color32(193, 213, 255, 255);
        colorKeys[2].time = 1f;

        gradient.SetKeys(colorKeys, alphaKeys);

        return gradient.Evaluate((float)(t - 1500) / 10000);
    }

}
