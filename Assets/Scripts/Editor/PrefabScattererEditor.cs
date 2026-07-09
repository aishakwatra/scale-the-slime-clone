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

    static void Scatter(PrefabScatterer scatterer)
    {
        if (scatterer.prefabs == null || scatterer.prefabs.Count == 0)
        {
            Debug.LogWarning("PrefabScatterer: no prefabs assigned.", scatterer);
            return;
        }

        var placedPoints = new List<Vector2>();
        var rng = new System.Random();

        for (int i = 0; i < scatterer.count; i++)
        {
            Vector2 point = Vector2.zero;
            bool found = false;

            for (int attempt = 0; attempt < scatterer.maxAttemptsPerInstance; attempt++)
            {
                var candidate = new Vector2(
                    Random.Range(-scatterer.areaSize.x * 0.5f, scatterer.areaSize.x * 0.5f),
                    Random.Range(-scatterer.areaSize.y * 0.5f, scatterer.areaSize.y * 0.5f));

                bool tooClose = false;
                foreach (var p in placedPoints)
                {
                    if (Vector2.Distance(p, candidate) < scatterer.minSpacing)
                    {
                        tooClose = true;
                        break;
                    }
                }

                if (!tooClose)
                {
                    point = candidate;
                    found = true;
                    break;
                }
            }

            if (!found)
                continue;

            placedPoints.Add(point);

            var prefab = scatterer.prefabs[rng.Next(scatterer.prefabs.Count)];
            var instance = (GameObject)PrefabUtility.InstantiatePrefab(prefab, scatterer.transform);
            Undo.RegisterCreatedObjectUndo(instance, "Scatter Prefab");

            float scale = Random.Range(scatterer.uniformScaleRange.x, scatterer.uniformScaleRange.y);
            float flip = (scatterer.randomFlipX && Random.value > 0.5f) ? -1f : 1f;
            var parentLossyScale = scatterer.transform.lossyScale;
            instance.transform.localScale = new Vector3(
                scale * flip / parentLossyScale.x,
                scale / parentLossyScale.y,
                1f);

            // point.x/point.y is the target trunk position (jitter around the ground line),
            // not the sprite's transform origin. Place at that point first, then measure the
            // instance's actual rendered bounds and shift it up so its bottom edge -- not its
            // pivot -- lands on the target. Works regardless of each prefab's own pivot/height.
            Vector3 targetGroundPos = scatterer.transform.position + new Vector3(point.x, point.y, 0f);
            instance.transform.position = targetGroundPos;

            var spriteRenderer = instance.GetComponentInChildren<SpriteRenderer>();
            if (spriteRenderer != null)
            {
                float bottomY = spriteRenderer.bounds.min.y;
                float correction = targetGroundPos.y - bottomY;
                instance.transform.position += new Vector3(0f, correction, 0f);

                // Sway direction comes from _VertexDisplacementAmount.x on the material (the
                // shader adds displacement along local X only). Flip its sign per-instance via
                // a MaterialPropertyBlock so some trees sway the opposite way without touching
                // the shared material or needing a second material asset.
                if (scatterer.randomSwayDirection && Random.value > 0.5f && spriteRenderer.sharedMaterial != null
                    && spriteRenderer.sharedMaterial.HasProperty("_VertexDisplacementAmount"))
                {
                    Vector4 baseAmount = spriteRenderer.sharedMaterial.GetVector("_VertexDisplacementAmount");
                    var block = new MaterialPropertyBlock();
                    spriteRenderer.GetPropertyBlock(block);
                    block.SetVector("_VertexDisplacementAmount", new Vector4(-baseAmount.x, baseAmount.y, baseAmount.z, baseAmount.w));
                    spriteRenderer.SetPropertyBlock(block);
                }
            }

            scatterer.spawnedInstances.Add(instance);
        }

        EditorUtility.SetDirty(scatterer);
    }

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
