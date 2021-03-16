using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FreqBandTester : MonoBehaviour
{
    public AudioPeer audioPeer;
    public int freqBand = 0;
    public float maxScale = 1;

    private Vector3 dScale;

    void Start()
    {
        dScale = transform.localScale;
    }

    // Update is called once per frame
    void Update()
    {
        transform.localScale = new Vector3(dScale.x, dScale.y * audioPeer.freqBands[freqBand] * maxScale, dScale.z);
    }
}
