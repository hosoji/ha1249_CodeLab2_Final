using UnityEngine;
using System.Collections;

[RequireComponent(typeof(AudioSource))]
public class AudioManager : MonoBehaviour {
	// feel free to change the sampling (1024s) to 512s or 2048s.
	//public const int SampleCount = 2048;
	public const int SampleCount = 1024;

	public static float[] spectrum= new float[SampleCount];
	//public static float[] spectrum2= new float[SampleCount];
	AudioSource source;

	void Start() {
		source = GetComponent<AudioSource> ();
	}

	void  Update (){
		//source.GetSpectrumData(spectrum, 0, FFTWindow.BlackmanHarris);
		//source.GetSpectrumData(spectrum, 0, FFTWindow.Hamming);
		//source.GetSpectrumData(spectrum, 0, FFTWindow.Blackman);
		source.GetSpectrumData(spectrum, 0, FFTWindow.Rectangular);
	}
}
