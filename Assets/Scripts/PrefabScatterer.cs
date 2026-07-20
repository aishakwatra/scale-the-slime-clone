using System.Collections.Generic;
using UnityEngine;

/// Editor scatter tool: fills a rectangle centered on this transform with
/// randomized instances of the given prefabs. See PrefabScattererEditor for the
/// Scatter / Clear buttons.
public class PrefabScatterer : MonoBehaviour
{
    public List<GameObject> prefabs = new List<GameObject>(); //pool of prefabs to scatter
    public Vector2 areaSize = new Vector2(10f, 2f); //width/height of the scatter rectangle, centred on this object
    public int count = 12; //instances to place
    public float minSpacing = 0.75f; //min distance between 2 points
    public Vector2 uniformScaleRange = new Vector2(0.9f, 1.1f); //random scale range
    public bool randomFlipX = true; //random mirror prefab
    public int maxAttemptsPerInstance = 30; //give up on a point after this many rejected candidates

    [HideInInspector] public List<GameObject> spawnedInstances = new List<GameObject>(); //keep track of spawned instances

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.cyan;
        Gizmos.DrawWireCube(transform.position, new Vector3(areaSize.x, areaSize.y, 0f)); //draws the scatter bounds in Scene view when selected
    }
}
