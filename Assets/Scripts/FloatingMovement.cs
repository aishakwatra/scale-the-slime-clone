using UnityEngine;

public class FloatingMovement : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created

    [SerializeField] private float distance = 0.2f;
    [SerializeField] private float speed = 2f;

    private Vector3 startingPosition;

    void Start()
    {
        startingPosition = transform.localPosition;
    }

    // Update is called once per frame
    void Update()
    {
        float yOffset = Mathf.Sin(Time.time * speed) * distance;

        transform.localPosition = startingPosition + new Vector3(0f, yOffset, 0f);

    }
}
