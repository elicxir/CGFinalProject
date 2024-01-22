using UnityEngine;

public class LookAtCamera : MonoBehaviour
{
    void Update()
    {
        // get camera position
        Vector3 cameraPosition = Camera.main.transform.position;

        // place lookat the camera
        //transform.rotation *= Quaternion.Euler(90,0,0);
        transform.LookAt(cameraPosition);
    }
}
