using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class radial_Camera : MonoBehaviour
{
    private static int _Intensity_hash = Shader.PropertyToID("_Intensity");
    private static int _FadeRadius_hash = Shader.PropertyToID("_FadeRadius");
    private static int _SampleDistance_hash = Shader.PropertyToID("_SampleDistance");
    private static int _SrcTex_hash = Shader.PropertyToID("_SrcTex");
    private static int _DownSampleRT_hash = Shader.PropertyToID("_DownSampleRT");

    public Material mat;

    [Header("Radial Blur")]
    [Range(0, 1)]
    public float intensity = 1;                         
    [Range(0f, 1f)]
    public float fadeRadius = 0.38f;                    
    [Range(0f, 1f)]
    public float sampleDistance = 0.25f;                
    [Range(1, 40)]
    public int blurDownSample = 40;                     
    private Camera cam;
    private void Start()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.Depth; // 카메라 깊이 텍스처
    }
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!mat)
        {
            Graphics.Blit(source, destination);
            return;
        }
        var rw = Screen.width / blurDownSample;
        var rh = Screen.height / blurDownSample;
        RenderTexture downSampleRT = RenderTexture.GetTemporary(rw, rh, 0);
        downSampleRT.filterMode = FilterMode.Bilinear; // 텍스쳐 샘플의 평균화
        downSampleRT.name = "downSampleRT";
        Graphics.Blit(source, downSampleRT);
        mat.SetFloat(_Intensity_hash, intensity);
        mat.SetFloat(_FadeRadius_hash, fadeRadius);
        mat.SetFloat(_SampleDistance_hash, sampleDistance);
        mat.SetTexture(_DownSampleRT_hash, downSampleRT);
        mat.SetTexture(_SrcTex_hash, source);
        Graphics.Blit(null, destination, mat, -1);
        RenderTexture.ReleaseTemporary(downSampleRT);
    }
}