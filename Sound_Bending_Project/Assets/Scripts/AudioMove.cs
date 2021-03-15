using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AudioMove : MonoBehaviour
{
    public float sensitivity = 100;
    public float loudness;
    AudioSource _audio;
    float yDefault;
    float xDefault;
    public float rotationVal = 0.0f;
    public float spikyness;
    public float aggressiveness;
    float xspin;
    float yspin;
    float zspin;
    //private Slider aggressive;

    Mesh mesh;
    Vector3[] vertices;
    Vector3[] defaultVertices;
    // Start is called before the first frame update
    void Start()
    {
        _audio = GetComponent<AudioSource>();
        _audio.clip = Microphone.Start(null, true, 10, 44100);
        _audio.loop = true;
        //_audio.mute = true;
        while(!(Microphone.GetPosition(null) > 0)){}
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
        print(Time.time);
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
        this.transform.localScale = new Vector3(this.transform.localScale.x, yDefault, this.transform.localScale.z);
        //this.transform.localScale = new Vector3(xDefault, this.transform.localScale.y, this.transform.localScale.z);
        loudness = GetAverageVolume() * sensitivity;
        if(loudness > 0.4)
        {
            //this.GetComponent<Rigidbody>().velocity = new Vector3(this.GetComponent<Rigidbody>().∂velocity.x, 4, this.GetComponent<Rigidbody>().velocity.z);
            //this.transform.localScale = new Vector3(this.transform.localScale.x, this.transform.localScale.y + (loudness), this.transform.localScale.z);
            //move vertice out along the normal vector

            if(loudness < 2.0)
            {
                if(spikyness < loudness)
                {
                    spikyness += aggressiveness;
                } else if(spikyness > loudness)
                {
                    spikyness -= aggressiveness;
                }
            //set cap at 2
            } else if(loudness >= 2.0)
            {
                if (spikyness < loudness && spikyness < 0.05)
                {
                    spikyness += aggressiveness;
                }
                else if (spikyness > loudness && spikyness > 0.0)
                {
                    spikyness -= aggressiveness;
                }
            }
            
        } else
        {
            if(spikyness > 0.0)
            {
                spikyness -= aggressiveness;
            }
        }
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
}
