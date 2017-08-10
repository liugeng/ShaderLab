using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class MotionBlurEffect : MonoBehaviour {

	#region 属性
	
	//实现动态模糊的着色器
	[SerializeField]
	private Shader _motionBlurShader;

	//使用_motionBlurShader的材质
	private Material _motionBlurMat;
	private Material motionBlurMat { get { if (!_motionBlurMat && _motionBlurShader) { _motionBlurMat = new Material(_motionBlurShader); } return _motionBlurMat; } }

	//动态模糊的中心点
	public Vector2 _center = new Vector2(0.5f, 0.5f);

	//模糊强度
	[Range(-0.5f, 0.5f)]
	public float _intensity = 0.125f;

	//迭代次数
	[Range(5, 50)]
	public int _iterateCount = 16;

	#endregion


	void Awake () {
		//判断是否支持屏幕特效
		if (!SystemInfo.supportsImageEffects) {
			enabled = false;
			return;
		}

		if (!_motionBlurShader) {
			_motionBlurShader = Shader.Find("Custom/MotionBlurEffect");
		}
	}

	//此函数在完成所有图片渲染后调用，用来渲染图片后期效果
	private void OnRenderImage(RenderTexture source, RenderTexture destination) {
		if (motionBlurMat) {
			motionBlurMat.SetVector("_Center", _center);
			motionBlurMat.SetFloat("_Intensity", _intensity * 0.085f);
			motionBlurMat.SetInt("_IterateCount", _iterateCount);

			//---------------------------------------[ Blit ]-------------------------------------------
			// 实现从源纹理到目标纹理的拷贝过程
			// public static void Blit(Texture source,RenderTexture dest);  
			// public static void Blit(Texture source, RenderTexture dest, Material mat, int pass = -1);
			// public static void Blit(Texture source, Material mat, int pass = -1);
			//
			// 参数 source: 原始纹理
			// 参数 dest  : 目标渲染纹理，如果是null，表示直接将原始纹理拷贝到屏幕上
			// 参数 mat   : 材质，通过材质的shader实现后期效果
			// 参数 pass  : 指定使用的pass，默认值-1，表示使用所有的pass
			//------------------------------------------------------------------------------------------
			Graphics.Blit(source, motionBlurMat);

		} else {
			Graphics.Blit(source, destination);
		}
	}
}
