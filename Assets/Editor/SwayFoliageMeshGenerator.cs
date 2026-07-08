using UnityEditor;
using UnityEngine;
using System.IO;

// Generates a vertical strip mesh (a "ladder" of quads) in the XY plane,
// pivoted at the bottom-center, for use with SH_VFX_SimplePremult_VertexAnim.
// UV.y runs 0 (bottom) -> 1 (top) to match the shader's UV-based sway mask.
public class SwayFoliageMeshGenerator : EditorWindow
{
    private float width = 1f;
    private float height = 2f;
    private int rows = 8;
    private string meshName = "SwayQuad";
    private const string SaveFolder = "Assets/VFX/VFX_asset/meshes";

    [MenuItem("Tools/Foliage/Generate Sway Mesh...")]
    private static void Open()
    {
        GetWindow<SwayFoliageMeshGenerator>(true, "Generate Sway Mesh");
    }

    private void OnGUI()
    {
        meshName = EditorGUILayout.TextField("Mesh Name", meshName);
        width = EditorGUILayout.FloatField("Width", width);
        height = EditorGUILayout.FloatField("Height", height);
        rows = EditorGUILayout.IntField("Vertical Rows", rows);
        rows = Mathf.Max(1, rows);

        if (GUILayout.Button("Generate"))
        {
            Generate();
        }
    }

    private void Generate()
    {
        var mesh = BuildMesh(width, height, rows);

        if (!Directory.Exists(SaveFolder))
        {
            Directory.CreateDirectory(SaveFolder);
        }

        string path = AssetDatabase.GenerateUniqueAssetPath($"{SaveFolder}/{meshName}.asset");
        AssetDatabase.CreateAsset(mesh, path);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        EditorGUIUtility.PingObject(mesh);
        Selection.activeObject = mesh;
    }

    private static Mesh BuildMesh(float width, float height, int rows)
    {
        int vertsPerRow = 2;
        int rowCount = rows + 1;

        var vertices = new Vector3[rowCount * vertsPerRow];
        var uvs = new Vector2[vertices.Length];
        var normals = new Vector3[vertices.Length];
        var triangles = new int[rows * 6];

        float halfWidth = width * 0.5f;

        for (int row = 0; row < rowCount; row++)
        {
            float v = (float)row / rows;
            float y = v * height;

            int leftIndex = row * vertsPerRow;
            int rightIndex = leftIndex + 1;

            vertices[leftIndex] = new Vector3(-halfWidth, y, 0f);
            vertices[rightIndex] = new Vector3(halfWidth, y, 0f);

            uvs[leftIndex] = new Vector2(0f, v);
            uvs[rightIndex] = new Vector2(1f, v);

            normals[leftIndex] = Vector3.back;
            normals[rightIndex] = Vector3.back;
        }

        int triIndex = 0;
        for (int row = 0; row < rows; row++)
        {
            int bl = row * vertsPerRow;
            int br = bl + 1;
            int tl = bl + vertsPerRow;
            int tr = tl + 1;

            triangles[triIndex++] = bl;
            triangles[triIndex++] = tl;
            triangles[triIndex++] = br;

            triangles[triIndex++] = br;
            triangles[triIndex++] = tl;
            triangles[triIndex++] = tr;
        }

        var mesh = new Mesh { name = "SwayQuad" };
        mesh.SetVertices(vertices);
        mesh.SetUVs(0, uvs);
        mesh.SetNormals(normals);
        mesh.SetTriangles(triangles, 0);
        mesh.RecalculateBounds();

        return mesh;
    }
}
