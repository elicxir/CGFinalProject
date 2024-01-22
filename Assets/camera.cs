using UnityEngine;
using System.Collections;
 
[ExecuteInEditMode]
public class CamRendImage : MonoBehaviour {
 
	[SerializeField]
	private Material m_mat;
 
	// Use this for initialization
	void Start () {	
	}
	
	// Update is called once per frame
	void Update () {
 
	}
	void OnRenderImage(RenderTexture src,RenderTexture dest)
	{
		Graphics.Blit (src,dest,m_mat);
	}
	void OnMouseDown()
	{
		
	}
	void OnMouseUp()
	{
		
	}
}