using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ShaderRendering : MonoBehaviour {

	[SerializeField] private float integrity;

	[SerializeField] private Material material;
	[SerializeField] private float color;
	[SerializeField] private float distance;
	[SerializeField] Texture2D texture;
	private float adjustment;
	private float depthAdjust;

	private float inputHor;
	private float inputVer;

	public float maxIntegrity;
	public int spectrumIndex;
	public float responseSpeed = 25;

	void Awake () {
		material = new Material(Shader.Find("GLSL/Pulsar"));
	}
	
	void OnRenderImage(RenderTexture source, RenderTexture destination){
		var scale = (AudioManager.spectrum[spectrumIndex]*maxIntegrity ) * 20;
		var depth = distance + ((AudioManager.spectrum[spectrumIndex] ) * 10);


		if (scale >= 0.025f) {
			adjustment = Mathf.Lerp (integrity, scale, Time.deltaTime * responseSpeed);
			depthAdjust = Mathf.Lerp (distance, depth, Time.deltaTime * 8);

		} else {
			adjustment = 0.5f;
			depthAdjust = distance;
		}

		float inputHor = Input.GetAxis ("Horizontal");
		float inputVer = Input.GetAxis ("Vertical");

		float inputR_Hor = Input.GetAxis ("R_Horizontal");
		float inputR_Ver = Input.GetAxis ("R_Vertical");


		material.SetTexture ("_MainTexture", texture);
		material.SetFloat ("_Adjustment", adjustment);
		material.SetFloat ("_Color", color);
		material.SetFloat ("_Distance", depthAdjust);
		material.SetFloat ("_InputX", inputHor);
		material.SetFloat ("_InputY", inputVer);
		material.SetFloat ("_InputRX", RemapRange(inputR_Hor, -1, 1, 1, 7));
		//material.SetFloat ("_InputRY", inputR_Ver);
		Graphics.Blit (texture, destination, material);
	}

	float RemapRange(float oldValue, float oldMin, float oldMax, float newMin, float newMax ){
		float newValue = 0;
		float oldRange = (oldMax - oldMin);
		float newRange = (newMax - newMin);
		newValue = (((oldValue - oldMin) * newRange) / oldRange) + newMin;
		return newValue;
	}


}
