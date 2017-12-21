using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ShaderRendering : MonoBehaviour {
	//This script should be attached to the Camera 

	// The properties are being exposed and adjusted in this script
	[SerializeField] private float integrity;

	[SerializeField] private Material material;
	[SerializeField] private float color;
	[SerializeField] private float distance;
	[SerializeField] Texture2D texture;

	// The variables for adjusting the above properties
	private float adjustment;
	private float depthAdjust;

	private float inputHor;
	private float inputVer;

	public float maxIntegrity;
	public int spectrumIndex;
	public float responseSpeed = 25;

	void Awake () {
		//We need to load the main shader immediately at runtime 
		material = new Material(Shader.Find("GLSL/Pulsar"));
	}

	//This is the function needed to initate the shader as an Image postprocessing effect
	void OnRenderImage(RenderTexture source, RenderTexture destination){
		
		// Have distortion and depth be controlled  by the spectrum data
		var distortion = (AudioManager.spectrum[spectrumIndex]*maxIntegrity ) * 20;
		var depth = distance + ((AudioManager.spectrum[spectrumIndex] ) * 10);

		// To control the properties when the spectrum data value falls below a certain threshold, this way the sahder never looks too weird
		if (distortion >= 0.025f) {
			//Using the Lerp to smoothly transition between values that are constantly changing with the spectrum data
			adjustment = Mathf.Lerp (integrity, distortion, Time.deltaTime * responseSpeed);
			depthAdjust = Mathf.Lerp (distance, depth, Time.deltaTime * 8);

		} else {
			adjustment = 0.5f;
			depthAdjust = distance;
		}

		//Getting controller input to manipulate the shader texture and color
		float inputHor = Input.GetAxis ("Horizontal");
		float inputVer = Input.GetAxis ("Vertical");

		float inputR_Hor = Input.GetAxis ("R_Horizontal");
		float inputR_Ver = Input.GetAxis ("R_Vertical");

		// Setting the property values based on user input
		material.SetTexture ("_MainTexture", texture);
		material.SetFloat ("_Adjustment", adjustment);
		material.SetFloat ("_Color", color);
		material.SetFloat ("_Distance", depthAdjust);
		material.SetFloat ("_InputX", inputHor);
		material.SetFloat ("_InputY", inputVer);
		material.SetFloat ("_InputRX", RemapRange(inputR_Hor, -1, 1, 1, 7));
		//material.SetFloat ("_InputRY", inputR_Ver);

		//This is the code that makes sure the shader is a post-processing image effect. Passing it the main texture, material and the filter's destination
		Graphics.Blit (texture, destination, material);
	}

	// Function to remap a min/max range of values to another range.
	float RemapRange(float oldValue, float oldMin, float oldMax, float newMin, float newMax ){
		float newValue = 0;
		float oldRange = (oldMax - oldMin);
		float newRange = (newMax - newMin);
		newValue = (((oldValue - oldMin) * newRange) / oldRange) + newMin;
		return newValue;
	}


}
