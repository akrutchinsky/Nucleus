// =======================================   DRAW  ===============================================
void draw() {

  // -------------------------------------------------------------------
  // Status screen: simulation in progress
  // -------------------------------------------------------------------
  if (flag == 0) {
    background(255);
    textSize(128);
    text("Calculating!", 400, 400);
    return;
  }

  // ===================================================================
  // Draw 3D geometry and particle trajectories
  // ===================================================================
  if (flag == 1) { // Render 3D nuclear geometry and trajectories

    background(255);                       // White background
    translate(width/2, height/2, -width);  // Move origin to scene center
    rotateX(a1);
    rotateY(a2);
    rotateZ(a3);
    scale(2);                              // Global visualization scale

    // ---------------------------------------------------------------
    // Draw coordinate axes
    // ---------------------------------------------------------------
    stroke(#E69F00);
    float sW = 0.5;
    strokeWeight(sW);

    float L = 450; // Axis length
    fill(0);

    line(-L, 0, 0,  L, 0, 0);
    text(" Z ", L, 0, 0);

    line(0, -L, 0,  0, L, 0);
    text(" Y ", 0, L, 0);

    line(0, 0, -L,  0, 0, L);
    text(" X ", 0, 0, L);

    // ---------------------------------------------------------------
    // Scaling and offsets
    // ---------------------------------------------------------------
    float SCALE   = 0.2 * 1/UNITS;
    float xOFFSET = 0;
    float yOFFSET = 0;
    float zOFFSET = 0;

    // Colors for nuclear wall and pores
    color C1 = color(#cccccc);  // Nuclear wall
    color C2 = color(#0072B2);  // Nuclear pores

    // ---------------------------------------------------------------
    // Draw 3D nuclear geometry (walls and pores)
    // ---------------------------------------------------------------
    try {
      for (Geometry g : nucleus) {
        strokeWeight(sW);

        if (g.structure == "wall") {
          stroke(C1);
          point(g.z * SCALE + zOFFSET,
                g.x * SCALE + xOFFSET,
                g.y * SCALE + yOFFSET);
        }

        if (g.structure == "pore") {
          stroke(C2);
          strokeWeight(1);
          point(g.z * SCALE + zOFFSET,
                g.x * SCALE + xOFFSET,
                g.y * SCALE + yOFFSET);
        }
        strokeWeight(1);
      }
    } catch (Exception error) {}

    // ---------------------------------------------------------------
    // Draw 3D particle trajectories
    // ---------------------------------------------------------------
    float previousX = 0;
    float previousY = 0;
    float previousZ = 0;

    try {
      for (Geometry t : particleTrajectory) {
        strokeWeight(1);

        if (TRAJECTORY == "line") {
          // Draw connected 3D trajectory segments
          line(xOFFSET + t.x * SCALE,
               yOFFSET + t.y * SCALE,
               zOFFSET + t.z * SCALE,
               xOFFSET + previousX * SCALE,
               yOFFSET + previousY * SCALE,
               zOFFSET + previousZ * SCALE);

          previousX = t.x;
          previousY = t.y;
          previousZ = t.z;
        }
        else {
          // Draw trajectory as discrete points
          point(xOFFSET + t.x * SCALE,
                yOFFSET + t.y * SCALE,
                zOFFSET + t.z * SCALE);
        }

        stroke(0);
      }
    } catch (Exception error) {}
  }


  // ===================================================================
  // Draw 2D projection of geometry and trajectories
  // ===================================================================
  if (flag == 2) {

    background(255);

    float SCALE   = DRAWING_SCALE;
    float xOFFSET = w / 2;
    float yOFFSET = h / 2;

    color C1 = color(#cccccc);  // Nuclear wall
    color C2 = color(#0072B2);  // Nuclear pores

    // ---------------------------------------------------------------
    // Draw 2D nuclear geometry
    // ---------------------------------------------------------------
    try {
      for (Geometry g : nucleus) {
        strokeWeight(1);

        if (g.structure == "wall") {
          stroke(C1);
          point(g.x * SCALE + xOFFSET,
                g.y * SCALE + yOFFSET);
        }

        if (g.structure == "pore") {
          stroke(C2);
          strokeWeight(5);
          point(g.x * SCALE + xOFFSET,
                g.y * SCALE + yOFFSET);
        }
        strokeWeight(1);
      }
    } catch (Exception error) {
      println(error);
    }

    // ---------------------------------------------------------------
    // Draw 2D particle trajectories
    // ---------------------------------------------------------------
    float previousX = 0;
    float previousY = 0;

    try {
      for (Geometry t : particleTrajectory) {
        strokeWeight(1);

        if (TRAJECTORY == "line") {
          line(xOFFSET + t.x * SCALE,
               yOFFSET + t.y * SCALE,
               xOFFSET + previousX * SCALE,
               yOFFSET + previousY * SCALE);

          previousX = t.x;
          previousY = t.y;
        }
        else {
          point(xOFFSET + t.x * SCALE,
                yOFFSET + t.y * SCALE);
        }

        stroke(0);
      }
    } catch (Exception error) {}
  }
}
