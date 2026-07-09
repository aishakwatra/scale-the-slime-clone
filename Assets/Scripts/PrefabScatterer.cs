using System.Collections.Generic;
using UnityEngine;

/// Editor-time scatter tool: fills a rectangle centered on this transform with
/// randomized instances of the given prefabs. See PrefabScattererEditor for the
/// Scatter / Clear buttons.
public class PrefabScatterer : MonoBehaviour
{
    public List<GameObject> prefabs = new List<GameObject>();
    public Vector2 areaSize = new Vector2(10f, 2f);
    public int count = 12;
    public float minSpacing = 0.75f;
    public Vector2 uniformScaleRange = new Vector2(0.9f, 1.1f);
    public bool randomFlipX = true;
    public bool randomSwayDirection = true;
    public int maxAttemptsPerInstance = 30;

    [HideInInspector] public List<GameObject> spawnedInstances = new List<GameObject>();

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.cyan;
        Gizmos.DrawWireCube(transform.position, new Vector3(areaSize.x, areaSize.y, 0f));
    }
}
