using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AudioMove : MonoBehaviour
{
    AudioSource _audio;
    public bool useMicAsAudioClip = true;
    public static float[] _samples = new float[512];
    public static float[] _freqBand = new float[8];

    public float sensitivity = 100;
    public float loudness;
    float yDefault;
    float xDefault;
    public float rotationVal = 0.0f;
    public float spikyness;
    public float aggressiveness;
    float xspin;
    float yspin;
    float zspin;
    static readonly string[] bandNames = {
        "_Spikyness0",
        "_Spikyness1",
        "_Spikyness2",
        "_Spikyness3",
        "_pikyness4",
        "_Spikyness5",
        "_Spikyness6",
        "_Spikyness7"
    };
    float[] spikyVals = new float[8];

    //private Slider aggressive;

    Mesh mesh;
    Vector3[] vertices;
    Vector3[] defaultVertices;
    // Start is called before the first frame update
    void Start()
    {
        _audio = GetComponent<AudioSource>();
        if (useMicAsAudioClip) 
            _audio.clip = Microphone.Start(null, true, 10, 44100);
        _audio.loop = true;
        //_audio.mute = true;
        if (useMicAsAudioClip)
            while (!(Microphone.GetPosition(null) > 0)){}
        _audio.Play();
        yDefault = this.transform.localScale.y;
        xDefault = this.transform.localScale.x;
        this.transform.Rotate(0.0f, 0.0f, rotationVal, Space.Self);

        mesh = GetComponent<MeshFilter>().mesh;
        vertices = mesh.vertices;
        defaultVertices = mesh.vertices;
        //slider for flow
        //aggressive = GameObject.Find("Aggressiveness_Slider").GetComponent<Slider>();
    }

    // Update is called once per frame
    void Update()
    {
        loudness = GetAverageVolume() * sensitivity;
        GetSpectrumAudioSource();
        MakeFrequencyBands();

        AssignBandValues();
        AssignFrequencyBands();

        //print(_freqBand[4]);
        if(Time.time % 3.0f < 0.5f)
        {
            RandomSpin();
        }
        gameObject.transform.Rotate(xspin, yspin, zspin);

        Shader.SetGlobalFloat("_Spikyness", spikyness);
        //assign slider value to sphere
        aggressiveness = 0.006f;//aggressive.value;
        //reset to original position
        /*for (var i = 0; i < vertices.Length; i++)
        {
            vertices[i][0] = defaultVertices[i][0];
            vertices[i][1] = defaultVertices[i][1];
            vertices[i][2] = defaultVertices[i][2];
        }
        mesh.vertices = vertices;
        mesh.RecalculateBounds();

        Vector3[] normals = mesh.normals;*/
        //this.transform.Rotate(10.0f, 0.0f, 0.0f, Space.Self);
        //resets to default scale
        /*this.transform.localScale = new Vector3(this.transform.localScale.x, yDefault, this.transform.localScale.z);
        //this.transform.localScale = new Vector3(xDefault, this.transform.localScale.y, this.transform.localScale.z);
        for(int i = 0; i < spikyVals.Length; i++)
        {
            if (loudness > 0.4)
            {
                //this.GetComponent<Rigidbody>().velocity = new Vector3(this.GetComponent<Rigidbody>().∂velocity.x, 4, this.GetComponent<Rigidbody>().velocity.z);
                //this.transform.localScale = new Vector3(this.transform.localScale.x, this.transform.localScale.y + (loudness), this.transform.localScale.z);
                //move vertice out along the normal vector

                if (loudness < 2.0)
                {
                    if (spikyVals[i] < loudness)
                    {
                        spikyVals[i] += aggressiveness;
                    }
                    else if (spikyVals[i] > loudness)
                    {
                        spikyVals[i] -= aggressiveness;
                    }
                    //set cap at 2
                }
                else if (loudness >= 2.0)
                {
                    if (spikyVals[i] < loudness && spikyVals[i] < 0.05)
                    {
                        spikyVals[i] += aggressiveness;
                    }
                    else if (spikyVals[i] > loudness && spikyVals[i] > 0.0)
                    {
                        spikyVals[i] -= aggressiveness;
                    }
                }

            }
            else
            {
                if (spikyVals[i] > 0.0)
                {
                    spikyVals[i] -= aggressiveness;
                }
            }

        }*/
        // assign the local vertices array into the vertices array of the Mesh.
        //mesh.vertices = vertices;
        //mesh.RecalculateBounds();
    }

    private void RandomSpin()
    {
        yspin = Random.Range(0.0f, 0.4f);
        xspin = Random.Range(0.0f, 0.4f);
        zspin = Random.Range(0.0f, 0.4f);
    }

    float GetAverageVolume()
    {
        float[] data = new float[256];
        float a = 0;
        _audio.GetOutputData(data, 0);
        foreach(float s in data){
            a += Mathf.Abs(s);
        }

        return a / 256;
    }

    void MakeFrequencyBands()
    {
        if(loudness > 0.4)
        {
            int count = 0;
            for (int i = 0; i < 8; i++)
            {
                float average = 0;
                int sampleCount = (int)Mathf.Pow(2, i) * 2;

                if (i == 7)
                {
                    sampleCount += 2;
                }

                for (int j = 0; j < sampleCount; j++)
                {
                    average += _samples[count] * (count + 1);
                    _freqBand[i] = average * 10;
                }
            }

        } else
        {
            for (int i = 0; i < 8; i++)
            {
                int sampleCount = (int)Mathf.Pow(2, i) * 2;

                if (i == 7)
                {
                    sampleCount += 2;
                }

                for (int j = 0; j < sampleCount; j++)
                {
                    if(_freqBand[i] > 0.09f)
                    {
                        _freqBand[i] = _freqBand[i] - 0.1f;
                    }
                }
            }

        }

        float val = (1 / (_freqBand[0] + 1)) * _freqBand[0];
        print(_freqBand[0] + ":     " + val);
    }

    void AssignBandValues()
    {
        int i = 0;
        while(i < spikyVals.Length){
            spikyVals[i] = _freqBand[i];
            i++;
        }
    }

    void AssignFrequencyBands()
    {
        foreach (string name in bandNames)
        {
            foreach (float val in spikyVals)
            {
                Shader.SetGlobalFloat(name, val);
            }
        }
    }

    void GetSpectrumAudioSource()
    {
        _audio.GetSpectrumData(_samples, 0, FFTWindow.Blackman);
    }

    public float[] GetFreqBands()
    {
        return _freqBand;
    }
}
