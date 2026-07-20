using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(PrefabScatterer))]
public class PrefabScattererEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        var scatterer = (PrefabScatterer)target;

        EditorGUILayout.Space();
        using (new EditorGUILayout.HorizontalScope())
        {
            if (GUILayout.Button("Scatter"))
            {
                Scatter(scatterer);
            }
            if (GUILayout.Button("Clear"))
            {
                Clear(scatterer);
            }
        }
    }


    // Places random prefabs inside the area, spaced apart, standing on the ground line.
    static void Scatter(PrefabScatterer scatterer)
    {

        // stop if there is nothing to place
        if (scatterer.prefabs == null || scatterer.prefabs.Count == 0)
        {
            Debug.LogWarning("PrefabScatterer: no prefabs assigned.", scatterer);
            return;
        }

        // points we have already used, so new points can avoid them
        var placedPoints = new List<Vector2>();

        // decide ahead of time which prefab goes in which slot
        var pickOrder = BuildPickOrder(scatterer.prefabs, scatterer.count);


        // do this once for every prefab we want to place
        for (int i = 0; i < scatterer.count; i++)
        {
            Vector2 point = Vector2.zero;
            bool found = false;

            // try a few times to find a spot that is not too close to another one
            for (int attempt = 0; attempt < scatterer.maxAttemptsPerInstance; attempt++)
            {

                // pick a random point inside the area
                var candidate = new Vector2(
                    Random.Range(-scatterer.areaSize.x * 0.5f, scatterer.areaSize.x * 0.5f),
                    Random.Range(-scatterer.areaSize.y * 0.5f, scatterer.areaSize.y * 0.5f));

                bool tooClose = false;

                // check it against every point we already placed

                foreach (var p in placedPoints)
                {
                    if (Vector2.Distance(p, candidate) < scatterer.minSpacing)
                    {
                        tooClose = true;
                        break;
                    }
                }

                // good spot, stop trying
                if (!tooClose)
                {
                    point = candidate;
                    found = true;
                    break;
                }
            }


            // no spot found after all tries, skip this one
            if (!found)
                continue;

            // save the spot so later prefabs avoid it too
            placedPoints.Add(point);

            // get the prefab that belongs in this slot
            var prefab = pickOrder[i];

            // spawn it and hook it into undo (ctrl+z)
            var instance = (GameObject)PrefabUtility.InstantiatePrefab(prefab, scatterer.transform);
            Undo.RegisterCreatedObjectUndo(instance, "Scatter Prefab");

            // pick a random size
            float scale = Random.Range(scatterer.uniformScaleRange.x, scatterer.uniformScaleRange.y);

            //maybe flip it left / right
            float flip = (scatterer.randomFlipX && Random.value > 0.5f) ? -1f : 1f;

            // cancel out the parent's own scale so this size is the real size on screen
            var parentLossyScale = scatterer.transform.lossyScale;
            instance.transform.localScale = new Vector3( scale * flip / parentLossyScale.x, scale / parentLossyScale.y, 1f);

            //put it on the target spot
            Vector3 targetGroundPos = scatterer.transform.position + new Vector3(point.x, point.y, 0f);
            instance.transform.position = targetGroundPos;


            // Move the sprite so its bottom edge sits on the ground point, not its own pivot.
            // Prefabs can have different pivots, so we place first, then fix the height.

            var spriteRenderer = instance.GetComponentInChildren<SpriteRenderer>();
            if (spriteRenderer != null)
            {
                float bottomY = spriteRenderer.bounds.min.y;
                float correction = targetGroundPos.y - bottomY;
                instance.transform.position += new Vector3(0f, correction, 0f);
            }

            // remember it so Clear can delete it later
            scatterer.spawnedInstances.Add(instance);
        }

        // save the changes
        EditorUtility.SetDirty(scatterer);
    }


    // Decides which prefab goes in which slot before we start placing.
    // If count is big enough, every prefab is used at least once. If not, picks are just random.
    static List<GameObject> BuildPickOrder(List<GameObject> prefabs, int count)
    {
        var order = new List<GameObject>(count);

        if (count >= prefabs.Count)
        {
            var shuffled = new List<GameObject>(prefabs);
            Shuffle(shuffled);
            order.AddRange(shuffled);
        }

        while (order.Count < count)
            order.Add(prefabs[Random.Range(0, prefabs.Count)]);

        return order;
    }

    // Mixes up the order of a list. Used so the guaranteed prefabs don't always come in the same order.
    static void Shuffle<T>(List<T> list)
    {
        for (int i = list.Count - 1; i > 0; i--)
        {
            int j = Random.Range(0, i + 1);
            (list[i], list[j]) = (list[j], list[i]);
        }
    }

    // Deletes everything Scatter made and empties the list.
    static void Clear(PrefabScatterer scatterer)
    {
        for (int i = scatterer.spawnedInstances.Count - 1; i >= 0; i--)
        {
            var instance = scatterer.spawnedInstances[i];
            if (instance != null)
                Undo.DestroyObjectImmediate(instance);
        }
        scatterer.spawnedInstances.Clear();
        EditorUtility.SetDirty(scatterer);
    }
}
