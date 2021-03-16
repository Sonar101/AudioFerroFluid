using System.Collections;
using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class AudioPeer : MonoBehaviour
{
    public int specDataChannelNum = 0;

    public float[] samples;
    public float[] freqBands = new float[8]; // 8 frequency bands

    int spectrumDivisions = 512; // must be a multiple of 512
    int numFreqBands = 8;

    AudioSource audioSource;

    // Start is called before the first frame update
    void Start()
    {
        samples = new float[spectrumDivisions];
        audioSource = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        getSpectrumAudioSource();
        MakeFrequencyBands();
    }

    void getSpectrumAudioSource() // Pulls frequncy samples and puts them into the array 'samples'
    {
        audioSource.GetSpectrumData(samples, specDataChannelNum, FFTWindow.Blackman);
    }

    void MakeFrequencyBands()
    {
        /*
         * ------------ Audio spectrum
         * (0) 20 to 60 Hz          - Sub Bass
         * (1) 60 to 250 Hz         - Bass
         * (2) 250 to 500 Hz        - Low Midrange
         * (3) 500 to 2000 Hz       - Midrange
         * (4) 2000 to 4000 Hz      - Upper Midrange
         * (5) 4000 to 6000 Hz      - Presence
         * (6) 6000 to 20,000 Hz    - Brilliance
         * 
         * ------------ 8 band divisions
         * (0) 2 samples -> Covers 86 Hz (from 0 to 86)
         * (1) 4 samples -> Covers 172 Hz (from 87 to 258) 
         * (2) 8 samples -> Covers 344 Hz (from 259 to 602)
         * (3) 16 samples -> Covers 688 Hz (from 603 to 1290)
         * (4) 32 samples -> Covers 1376 Hz (from 1291 to 2666)
         * (5) 64 samples -> Covers 2752 Hz (from 2667 to 5418)
         * (6) 128 samples -> Covers 5504 Hz (from 5419 to 10922)
         * (7) 256 samples -> Covers 11008 Hz (from 10923 to 21930)
         * (sample size can be represented as 2^(n+1) )
         * 
         * 510 samples being banded in total (so we can add 2 extra samples to the last band
         *  to put at 512 samples perfectly)
         * 
         */

        int currSample = 0;

        // for every frequency band, add up and average all of the samples between the start and end of that band
        for (int i = 1; i <= numFreqBands; i++)
        {
            float averageInBand = 0;
            int currBandSize = (int)Mathf.Pow(2, i);

            if (i == numFreqBands)
            {
                currBandSize += 2; // adding extra samples to sum to 512
            }

            for (int j = 0; j < currBandSize; j++)
            {
                averageInBand += samples[currSample];
                currSample++;
            }

            averageInBand /= currBandSize;
            freqBands[i - 1] = averageInBand;
        }
    }
}