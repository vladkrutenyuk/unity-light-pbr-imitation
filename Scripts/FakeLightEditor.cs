using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(FakeLight)), CanEditMultipleObjects]
public class FakeLightEditor : Editor
{
    public Texture aTexture;
    SerializedProperty vertical, horizontal, intensity, skyBox, temperature, shadowColor, shadowContrast; 

    private void OnSceneGUI() 
    {
        Handles.color = (target as FakeLight).SunColor(temperature.intValue);

        Vector3 p1 = (target as FakeLight).transform.position;
        Vector3 p2 = p1 - (target as FakeLight).sun;
        Handles.DrawLine(p1, p2);
        Handles.DrawLine(p1, p2);

        Vector3 p3 = p2 - p1;
        Handles.DrawWireDisc(p1 + p3 * 0.1f, p3, 0.2f);
        Handles.DrawWireDisc(p1, p3, 0.2f);
        Handles.DrawWireDisc(p1 - p3 * 0.1f, p3, 0.2f);

    }

    private void OnEnable() 
    {
        vertical = serializedObject.FindProperty("vertical");
        horizontal = serializedObject.FindProperty("horizontal");
        intensity = serializedObject.FindProperty("intensity");
        skyBox = serializedObject.FindProperty("skyBox");
        temperature = serializedObject.FindProperty("temperature");
        shadowColor = serializedObject.FindProperty("shadowColor");
        shadowContrast = serializedObject.FindProperty("shadowContrast");
    }

    public override void OnInspectorGUI() 
    {
        if(Application.isPlaying)
            return;

        serializedObject.Update();

        //EditorGUILayout.GradientField(grad);

        EditorGUILayout.Space(10);
        EditorGUILayout.LabelField("SUN", EditorStyles.toolbarButton);
        EditorGUILayout.Space(4);

        EditorGUILayout.PropertyField(vertical);
        EditorGUILayout.PropertyField(horizontal);

        EditorGUILayout.Space(10);

        EditorGUILayout.PropertyField(temperature);

        EditorGUILayout.Space(10);

        EditorGUILayout.PropertyField(intensity);

        float _sunIntensity = intensity.floatValue;
        showMessageForFloat(_sunIntensity, -0.1f, 0.2f, "Absolutely dark!", MessageType.Error);
        showMessageForFloat(_sunIntensity, 0.2f, 0.6f, "So dark!", MessageType.Warning);
        showMessageForFloat(_sunIntensity, 0.6f, 0.8f, "A bit dark.", MessageType.Info);
        showMessageForFloat(_sunIntensity, 1.6f, 2.1f, "Bright.", MessageType.Info);
        showMessageForFloat(_sunIntensity, 2.1f, 3.5f, "it's very bright!", MessageType.Warning);
        showMessageForFloat(_sunIntensity, 3.5f, 5f, "Oh, my eyes!", MessageType.Error);

        EditorGUILayout.Space(10);
        EditorGUILayout.LabelField("SHADOWS", EditorStyles.toolbarButton);
        EditorGUILayout.Space(4);

        EditorGUILayout.PropertyField(shadowColor);
        EditorGUILayout.PropertyField(shadowContrast);

        EditorGUILayout.Space(10);
        EditorGUILayout.LabelField("SKY", EditorStyles.toolbarButton);
        EditorGUILayout.Space(4);

        EditorGUILayout.HelpBox("Set toggle 'Use custom sky' in materials to enable your skybox", MessageType.Info);

        EditorGUILayout.PropertyField(skyBox);

        EditorGUILayout.Space(20);
        EditorGUILayout.HelpBox(
            "Make sure the materials of your objects have such shaders as: KVY/Lit PBR Imitation, KVY/Lit PBR Imitation Transparent", MessageType.Info);

        serializedObject.ApplyModifiedProperties();
    }

    private void showMessageForFloat(float value, float from, float to, string then, MessageType type)
    {
        if(value > from && value <= to)
        {
            EditorGUILayout.HelpBox(then, type);
        }
    }
}
