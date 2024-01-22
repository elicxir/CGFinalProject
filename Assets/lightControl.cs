using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class lightControl : MonoBehaviour
{
    public float maxIntensity=5.0f;
    public float minIntensity=0.0f;
    public float speed=1.0f;
    public Light lightSource;
    // Start is called before the first frame update
    void Start()
    {
        lightSource = GetComponent<Light>();

    }

    // Update is called once per frame
    void Update()
    {
        lightSource.intensity=Mathf.PingPong(Time.time*speed,maxIntensity-minIntensity)+minIntensity;
    }
}
