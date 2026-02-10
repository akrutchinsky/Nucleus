/**
 *************************************************************************************************************************
 *
 *                                           Diffusion dynamics
 *
 *************************************************************************************************************************
 */

ArrayList<Geometry> calculateSingleParticleTrajectory(String mode, int nucleusShape) {

  ArrayList<Geometry> trajectory = new ArrayList<Geometry>();

  float time = 0;
  float x = startX;
  float y = startY;
  float z = startZ;
  float r = 0;

  // Propagate particle trajectory until exit or maximum simulation time
  while (time < end_time) {

    // ------------------------------------------------------------------
    // Brownian displacement: <Δx^2> = 2 D dt
    // ------------------------------------------------------------------
    float sigma = sqrt(2 * D * dt);
    x += sigma * randomGaussian();
    y += sigma * randomGaussian();
    z += sigma * randomGaussian();

    r = vectorLength(x, y, z);

    switch (nucleusShape) {

      // ================================================================
      // Spherical nucleus
      // ================================================================
      case 1:
        if (r >= R) {

          // Case 1: measure flux to the nuclear wall (I0)
          if (mode == "diffusion to wall") {
            timeInside = time;
            return trajectory;
          }

          // Case 2: check whether the particle exits through a pore
          if (atPore(x, y, z, NPCs) > 0) {
            timeInside = time;
            return trajectory;
          }

          // Case 3: reflecting boundary condition at spherical wall
          x = reflectSphericalBorder(x, r);
          y = reflectSphericalBorder(y, r);
          z = reflectSphericalBorder(z, r);
        }
        break;

      // ================================================================
      // Cubic nucleus
      // ================================================================
      case 2:
        if (hitCubicWall(x, y, z)) {

          // Case 1: measure flux to the nuclear wall (I0)
          if (mode == "diffusion to wall") {
            timeInside = time;
            return trajectory;
          }

          // Case 2: check whether the particle exits through a pore
          int Np = atPore(x, y, z, NPCs);
          if (Np > 0) {
            timeInside = time;
            // println("Exited through pore " + Np);
            return trajectory;
          }

          // Case 3: reflecting boundary condition at cubic walls
          if (sqrt(x * x) >= R) x = reflectCubicBorder(x, R);
          if (sqrt(y * y) >= R) y = reflectCubicBorder(y, R);
          if (sqrt(z * z) >= R) z = reflectCubicBorder(z, R);
        }
        break;
    }

    // ------------------------------------------------------------------
    // Record trajectory point
    // ------------------------------------------------------------------
    trajectory.add(new Geometry(x, y, z, "trajectory", 1));

    time += dt;
    timeInside = time;
  }

  return trajectory;
}


// =================================================================================================
// Boundary reflection utilities
// =================================================================================================

// Reflecting boundary for cubic geometry
float reflectCubicBorder(float coordinate, float w) {

  // Randomized inward displacement after wall collision
  float delta = sqrt(2 * D * dt) * randomGaussian();

  if (coordinate > 0) return  w - abs(delta);
  else               return -w + abs(delta);
}


// Reflecting boundary for spherical geometry
float reflectSphericalBorder(float coordinate, float r) {

  // Radial reflection preserving angular direction
  return coordinate * (2 * R - r) / r;
}


// Alternative folding reflection (unused helper)
float fold(float u, float L) {

  float half = L / 2.0;
  float up = u + half;
  int   l  = floor(up / L);
  float r  = up - l * L;
  float s  = ((l & 1) == 0) ? r : (L - r);

  return s - half;
}


// =================================================================================================
// Collision / boundary detection helpers
// =================================================================================================

boolean hitNuclearPore(float x, float y, float z) {
  return atPore_on_CUBE(x, y, z, NPCs) > 0;
}

boolean hitSphericalWall(float x, float y, float z) {
  return sqrt(x * x + y * y + z * z) >= R;
}

boolean hitCubicWall(float x, float y, float z) {
  return (sqrt(x * x) >= R || sqrt(y * y) >= R || sqrt(z * z) >= R);
}
