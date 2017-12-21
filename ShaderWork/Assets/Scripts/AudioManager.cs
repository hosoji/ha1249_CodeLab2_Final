using UnityEngine;
using System.Collections;

[RequireComponent(typeof(AudioSource))]
public class AudioManager : MonoBehaviour {

	// Sampling can be 1024s, 512s or 2048s.
	public const int SampleCount = 1024;

	// Creating an array to store the samples
	public static float[] spectrum= new float[SampleCount];

	//The audio source to sample from
	AudioSource source;

	void Start() {
		source = GetComponent<AudioSource> ();
	}

	void  Update (){
		/*
		//Using the GetSpectrumData function to analyze the audiosource. Changing which FFT Window to use, 
		  changes how the samples are analyzed
		*/

		//source.GetSpectrumData(spectrum, 0, FFTWindow.BlackmanHarris);
		//source.GetSpectrumData(spectrum, 0, FFTWindow.Hamming);
		//source.GetSpectrumData(spectrum, 0, FFTWindow.Blackman);
		source.GetSpectrumData(spectrum, 0, FFTWindow.Rectangular);
	}
}
