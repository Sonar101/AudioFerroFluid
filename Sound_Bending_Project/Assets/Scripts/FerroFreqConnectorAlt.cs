using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FerroFreqConnectorAlt : MonoBehaviour
{
    public AudioPeer audioPeer;
    public Material material;

    private float yspin = 0;
    private float xspin = 0;
    private float zspin = 0;


    void Update()
    {
        material.SetFloat("_freq0", audioPeer.freqBands[0]);
        material.SetFloat("_freq1", audioPeer.freqBands[1]);
        material.SetFloat("_freq2", audioPeer.freqBands[2]);
        material.SetFloat("_freq3", audioPeer.freqBands[3]);
        material.SetFloat("_freq4", audioPeer.freqBands[4]);
        material.SetFloat("_freq5", audioPeer.freqBands[5]);
        material.SetFloat("_freq6", audioPeer.freqBands[6]);
        material.SetFloat("_freq7", audioPeer.freqBands[7]);

        if (Time.time % 3.0f < 0.5f)
        {
            RandomSpin();
        }
        gameObject.transform.Rotate(xspin, yspin, zspin);
    }

    private void RandomSpin()
    {
        yspin = Random.Range(0.0f, 0.4f);
        xspin = Random.Range(0.0f, 0.4f);
        zspin = Random.Range(0.0f, 0.4f);
    }
}
