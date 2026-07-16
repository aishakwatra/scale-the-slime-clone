using UnityEngine;

public class OrderinLayer : MonoBehaviour
{
    public int OrderInLayer = 0;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        MeshRenderer renderer = GetComponent<MeshRenderer>();
        renderer.sortingOrder = OrderInLayer;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
