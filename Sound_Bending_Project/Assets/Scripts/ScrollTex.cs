using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScrollTex : MonoBehaviour
{
    public float scrollx = 0.5f;
    public float scrolly = 0.5f;

    // Update is called once per frame
    void Update()
    {
        float OffsetX = Time.time * scrollx;
        float OffsetY = Time.time * scrolly;
        GetComponent<Renderer>().material.mainTextureOffset = new Vector2(OffsetX, OffsetY);
    }
}
