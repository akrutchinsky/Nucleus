// ======================================================================
// Best-effort uniform point distribution on a sphere (no drawing)
// Pipeline:
//   1) Dense icosphere generation
//   2) Farthest-point sampling
//   3) Riesz-s energy polishing
//
// Outputs CSV coordinates for N = 10, 25, 46, 73, 106, 146 and exits.
// ======================================================================


// ------------------------------ math utilities --------------------------
float dist2(PVector a, PVector b){
  float dx = a.x - b.x;
  float dy = a.y - b.y;
  float dz = a.z - b.z;
  return dx*dx + dy*dy + dz*dz;
}


// ------------------------------ icosphere -------------------------------
class Face {
  int a, b, c;
  Face(int A, int B, int C){ a = A; b = B; c = C; }
}

// Unit icosahedron vertices
PVector[] icosahedronVerts() {
  float t = (1 + sqrt(5)) * 0.5f; // golden ratio
  PVector[] v = {
    new PVector(-1, t, 0), new PVector( 1, t, 0), new PVector(-1,-t, 0), new PVector( 1,-t, 0),
    new PVector( 0,-1, t), new PVector( 0, 1, t), new PVector( 0,-1,-t), new PVector( 0, 1,-t),
    new PVector( t, 0,-1), new PVector( t, 0, 1), new PVector(-t, 0,-1), new PVector(-t, 0, 1)
  };
  for (PVector p : v) p.normalize();
  return v;
}

// Icosahedron triangular faces (vertex indices)
ArrayList<Face> icosahedronFaces() {
  int[][] F = {
    {0,11,5},{0,5,1},{0,1,7},{0,7,10},{0,10,11},
    {1,5,9},{5,11,4},{11,10,2},{10,7,6},{7,1,8},
    {3,9,4},{3,4,2},{3,2,6},{3,6,8},{3,8,9},
    {4,9,5},{2,4,11},{6,2,10},{8,6,7},{9,8,1}
  };
  ArrayList<Face> faces = new ArrayList<Face>();
  for (int[] f : F) faces.add(new Face(f[0], f[1], f[2]));
  return faces;
}

// Unique key for an undirected edge (i, j)
long keyEdge(int i, int j){
  int a = min(i, j), b = max(i, j);
  return (((long)a) << 32) | (long)b;
}

// Midpoint vertex creation with edge caching
int midpointIndex(ArrayList<PVector> V, HashMap<Long,Integer> cache, int i, int j) {
  long key = keyEdge(i, j);
  Integer idx = cache.get(key);
  if (idx != null) return idx;

  PVector m = PVector.add(V.get(i), V.get(j)).mult(0.5f);
  m.normalize();
  V.add(m);

  int id = V.size() - 1;
  cache.put(key, id);
  return id;
}

// Builds a subdivided unit icosphere
// level = 2 → ~162 vertices
// level = 3 → ~642 vertices (recommended)
PVector[] buildIcosphereVerts(int level) {

  // Start from base icosahedron
  PVector[] base = icosahedronVerts();
  ArrayList<PVector> V = new ArrayList<PVector>();
  for (int i = 0; i < base.length; i++) V.add(base[i]);
  ArrayList<Face> F = icosahedronFaces();

  // Recursive subdivision
  for (int s = 0; s < level; s++) {
    HashMap<Long,Integer> mid = new HashMap<Long,Integer>();
    ArrayList<Face> Fn = new ArrayList<Face>();

    for (Face f : F) {
      int a = f.a, b = f.b, c = f.c;
      int ab = midpointIndex(V, mid, a, b);
      int bc = midpointIndex(V, mid, b, c);
      int ca = midpointIndex(V, mid, c, a);

      Fn.add(new Face(a,  ab, ca));
      Fn.add(new Face(b,  bc, ab));
      Fn.add(new Face(c,  ca, bc));
      Fn.add(new Face(ab, bc, ca));
    }
    F = Fn;
  }

  // Ensure unit radius
  for (PVector p : V) p.normalize();
  return V.toArray(new PVector[V.size()]);
}


// -------------------------- farthest-point sampling ----------------------
// Greedy max–min sampling from candidate points
PVector[] fpsSample(PVector[] candidates, int N, int seed){

  Random rng = new Random(seed);
  int M = candidates.length;

  // Initial random seed point
  int i0 = rng.nextInt(M);
  boolean[] chosen = new boolean[M];
  ArrayList<Integer> idx = new ArrayList<Integer>();
  idx.add(i0);
  chosen[i0] = true;

  // Distance-to-nearest-selected array
  float[] d2 = new float[M];
  for (int i = 0; i < M; i++)
    d2[i] = dist2(candidates[i], candidates[i0]);

  // Iteratively select farthest points
  for (int k = 1; k < N; k++) {
    int best = -1;
    float bestD = -1;

    for (int i = 0; i < M; i++)
      if (!chosen[i] && d2[i] > bestD) {
        bestD = d2[i];
        best  = i;
      }

    idx.add(best);
    chosen[best] = true;

    // Update distances
    for (int i = 0; i < M; i++) {
      float di = dist2(candidates[i], candidates[best]);
      if (di < d2[i]) d2[i] = di;
    }
  }

  // Extract sampled points
  PVector[] X = new PVector[N];
  for (int k = 0; k < N; k++)
    X[k] = candidates[idx.get(k)].copy();

  return X;
}


// ------------------------------ Riesz polish -----------------------------
// Riesz s-energy: sum_{i<j} |x_i - x_j|^{-s}
double rieszEnergy(PVector[] X, float s) {
  double E = 0.0;
  for (int i = 0; i < X.length; i++) {
    for (int j = i+1; j < X.length; j++) {
      double d = Math.sqrt(dist2(X[i], X[j])) + 1e-12;
      E += Math.pow(d, -s);
    }
  }
  return E;
}

// Gradient of Riesz s-energy projected to sphere tangent plane
PVector[] rieszGrad(PVector[] X, float s){

  int N = X.length;
  PVector[] G = new PVector[N];
  for (int i = 0; i < N; i++) G[i] = new PVector();

  for (int i = 0; i < N; i++) {
    for (int j = i+1; j < N; j++) {
      PVector rij = PVector.sub(X[i], X[j]);
      float d2 = max(dist2(X[i], X[j]), 1e-18f);
      float d  = sqrt(d2);
      float c  = -s * (float)Math.pow(d, -(s+2)); // ∇(d^{-s})
      PVector f = PVector.mult(rij, c);
      G[i].add(f);
      G[j].sub(f);
    }
  }

  // Project gradient onto tangent plane of the sphere
  for (int i = 0; i < N; i++) {
    PVector n = X[i].copy().normalize();
    float gn = G[i].dot(n);
    G[i].sub(PVector.mult(n, gn));
  }
  return G;
}


// Line-search step container
class Step {
  PVector[] Xn;
  float a;
  double En;
  Step(PVector[] Xn, float a, double En){ this.Xn = Xn; this.a = a; this.En = En; }
}

// Backtracking line search with Armijo condition
Step backtrack(PVector[] X, PVector[] G, double E0, float R, float a0, float s) {

  float c = 1e-4f, tau = 0.5f;
  float g2 = 0;
  for (PVector g : G) g2 += g.dot(g);
  if (g2 == 0) return new Step(X, 0, E0);

  float a = a0;
  for (int t = 0; t < 25; t++) {
    PVector[] Xn = new PVector[X.length];

    for (int i = 0; i < X.length; i++) {
      PVector p = PVector.sub(X[i], PVector.mult(G[i], a));
      p.normalize();
      p.mult(R);
      Xn[i] = p;
    }

    double En = rieszEnergy(Xn, s);
    if (En <= E0 - c * a * g2) return new Step(Xn, a, En);
    a *= tau;
  }
  return new Step(X, 0, E0);
}

// In-place Riesz energy minimization
void polishRieszInPlace(PVector[] X, float R, float s, int iters, float a0){

  double E = rieszEnergy(X, s);
  float a = a0;

  for (int k = 0; k < iters; k++) {
    PVector[] G = rieszGrad(X, s);
    Step st = backtrack(X, G, E, R, a, s);
    if (st.a == 0) break;

    // Periodic Barzilai–Borwein step-size refresh
    if (k % 5 == 0) {
      PVector[] G2 = rieszGrad(st.Xn, s);
      float sy = 0, yy = 0;

      for (int i = 0; i < X.length; i++) {
        PVector dX = PVector.sub(st.Xn[i], X[i]);
        PVector dG = PVector.sub(G2[i], G[i]);
        sy += dX.dot(dG);
        yy += dG.dot(dG);
      }
      if (yy > 1e-12)
        a = constrain(abs(sy/yy), 1e-4f, 0.5f);
    }

    // Accept step
    for (int i = 0; i < X.length; i++) X[i] = st.Xn[i];
    E = st.En;
  }
}


// --------------------------- master generator ----------------------------
PVector[] spherePointsBest(int N, float R, int seed){

  // 1) Generate dense candidate set
  int level = 3; // ~642 vertices; reduce to 2 for faster generation
  PVector[] candidates = buildIcosphereVerts(level);

  // 2) Farthest-point sampling
  PVector[] X = fpsSample(candidates, N, seed);

  // 3) Riesz-s polishing (strong repulsion to equalize spacing)
  polishRieszInPlace(X, R, 8,  600, 0.25f);
  polishRieszInPlace(X, R, 12, 800, 0.25f);

  // Enforce exact radius
  for (PVector p : X) {
    p.normalize();
    p.mult(R);
  }
  return X;
}


/* ------------------------------- example run ------------------------------
void setup() {

  float R = 1.0f;
  int seed = 7;
  int[] Ns = {10, 25, 46, 73, 106, 146};

  for (int N : Ns) {
    println("N=" + N);
    PVector[] x = spherePointsBest(N, R, seed);
    for (int i = 0; i < x.length; i++) {
      println(nf(x[i].x,0,6) + "," + nf(x[i].y,0,6) + "," + nf(x[i].z,0,6));
    }
    println();
  }

  exit(); // no draw()
}
*/
