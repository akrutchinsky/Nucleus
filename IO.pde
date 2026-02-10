/**
 ***********************************************************************************************************************
 *
 *                                             PROGRAM OPTIONS & CONTROLS
 *
 ***********************************************************************************************************************
 */


void keyPressed() {

  // ------------------------------------------------------------------
  // Increment pore count (PAGE UP)
  // ------------------------------------------------------------------
  if (keyCode == 16) { // PAGE UP
    npo = COUNT * COUNT * 3 - 2;
    println("Npores = " + npo + "   nucleus mode = " + NUCLEUS_SHAPE);

    CreateGeometry(npo, NUCLEUS_SHAPE);
    CalculateDiffusion(npo, NUCLEUS_SHAPE);

    COUNT++;
    flag = 2;  // Switch to 2D visualization
  }

  // ------------------------------------------------------------------
  // Decrement pore count (backward)
  // ------------------------------------------------------------------
  if (keyCode == 11) { // backward key
    npo = COUNT * COUNT * 3 - 2;
    println("Npores = " + npo);

    CreateGeometry(npo, NUCLEUS_SHAPE);
    COUNT = COUNT - 1;
    CalculateDiffusion(npo, NUCLEUS_SHAPE);

    flag = 2;
  }

  // ------------------------------------------------------------------
  // Decrease pore count manually
  // ------------------------------------------------------------------
  if (keyCode == 68) { // key 'D'
    npo = npo - 2;
    println("Npores = " + npo);

    CreateGeometry(npo, NUCLEUS_SHAPE);
    Npores = npo;
    CalculateDiffusion(npo, NUCLEUS_SHAPE);

    flag = 2;
  }

  // ------------------------------------------------------------------
  // Visualization mode switches
  // ------------------------------------------------------------------
  if (keyCode == KeyEvent.VK_1) flag = 1;
  if (keyCode == KeyEvent.VK_2) flag = 2;
  if (keyCode == KeyEvent.VK_3) flag = 3;
  if (keyCode == KeyEvent.VK_4) flag = 4;
  if (keyCode == KeyEvent.VK_5) flag = 5;
  if (keyCode == KeyEvent.VK_6) flag = 6;

  // ------------------------------------------------------------------
  // Show geometry/diffusion options
  // ------------------------------------------------------------------
  if (keyCode == 97) { // F2
    showOptions_F1();
  }

  if (keyCode == 98 || keyCode == 112) { // F1 or 'p'
    showOptions_F2();
  }

  // ------------------------------------------------------------------
  // Rotate 3D view using arrow keys
  // ------------------------------------------------------------------
  if (keyCode == 38) a1 += PI / 16;  // UP
  if (keyCode == 40) a1 -= PI / 16;  // DOWN
  if (keyCode == 37) a2 += PI / 16;  // LEFT
  if (keyCode == 39) a2 -= PI / 16;  // RIGHT

  if (keyCode == KeyEvent.VK_PAGE_UP)   a3 += PI / 16;
  if (keyCode == KeyEvent.VK_PAGE_DOWN) a3 -= PI / 16;

} // end keyPressed()



/**
 *************************************************************************************************************************
 *
 *                                           SPHERICAL NUCLEUS OPTIONS
 *
 *************************************************************************************************************************
 */

// GUI dialog for spherical nucleus actions
public void showOptions_F1() {

  SwingUtilities.invokeLater(new Runnable() {
    public void run() {

      String[] plays = new String[] {
        "Create Spherical Geometry",
        "Calculate Diffusion in a Sphere",
        "Calculate Berg's curve (random pores)",
        "Calculate Berg's curve (Fibonacci pores)",
        "Calculate Berg's curve (FPS–Riesz pores)"
      };

      String input = (String) JOptionPane.showInputDialog(
        new JFrame(),
        "Please select the action",
        "Geometry & Diffusion",
        JOptionPane.INFORMATION_MESSAGE,
        new ImageIcon("java2sLogo.GIF"),
        plays,
        "Actions"
      );

      if (input == "Create Spherical Geometry")
        CreateGeometry(Npores, 1);

      if (input == "Calculate Diffusion in a Sphere")
        CalculateDiffusion(Npores, 1);

      if (input == "Calculate Berg's curve (random pores)")
        CalculateBergsCurve(1000, 1, 'R');

      if (input == "Calculate Berg's curve (Fibonacci pores)")
        CalculateBergsCurve(1000, 1, 'F');

      if (input == "Calculate Berg's curve (FPS–Riesz pores)")
        CalculateBergsCurve(1000, 1, 'U');
    }
  });
}



/**
 *************************************************************************************************************************
 *
 *                                             CUBIC NUCLEUS OPTIONS
 *
 *************************************************************************************************************************
 */

// GUI dialog for cubic nucleus actions
public void showOptions_F2() {

  SwingUtilities.invokeLater(new Runnable() {
    public void run() {

      String[] plays = new String[] {
        "Create Cubic Geometry",
        "Calculate Diffusion in a Cube",
        "Calculate Berg's curve (random pores)",
        "Calculate Berg's curve (arrayed pores)"
      };

      String input = (String) JOptionPane.showInputDialog(
        new JFrame(),
        "Please select the action",
        "Geometry & Diffusion",
        JOptionPane.INFORMATION_MESSAGE,
        new ImageIcon("java2sLogo.GIF"),
        plays,
        "Actions"
      );

      if (input == "Create Cubic Geometry")
        CreateGeometry(Npores, 2);

      if (input == "Calculate Diffusion in a Cube")
        CalculateDiffusion(Npores, 2);

      if (input == "Calculate Berg's curve (random pores)")
        CalculateBergsCurve(1000, 2, 'R');

      if (input == "Calculate Berg's curve (arrayed pores)")
        CalculateBergsCurve(1000, 2, 'A');
    }
  });
}



// =================================================================================================
// Geometry creation
// =================================================================================================
public void CreateGeometry(int Np, int shape) {

  switch (shape) {

    case 1: // Sphere
      NUCLEUS_SHAPE = 1;
      nucleus = nucleusGeometry_GLOBE(Np, PORE_POSITIONING);
      break;

    case 2: // Cube
      NUCLEUS_SHAPE = 2;
      nucleus = nucleusGeometry_CUBE(Np, PORE_POSITIONING);
      break;
  }

  flag = 1;  // Display geometry
}



// =================================================================================================
// Diffusion simulation
// =================================================================================================
public void CalculateDiffusion(int Np, int nucleusShape) {

  CreateGeometry(Np, nucleusShape);

  particleTrajectory =
    calculateSingleParticleTrajectory("diffusion to pore", nucleusShape);

  println("Time of a single particle inside = " + timeInside);
}



// =================================================================================================
// Berg's curve: flux vs number of pores
// =================================================================================================
public void CalculateBergsCurve(int Ns, int nucleusShape, char porePostioning) {

  flag = 0;
  noLoop();

  PORE_POSITIONING = porePostioning;
  CreateGeometry(0, nucleusShape);

  // Baseline flux to the wall (I0)
  Result flux_0 = averageTimeToGetOut(0, Ns, nucleusShape, "diffusion to wall");
  float value_flux_0 = flux_0.value;
  float error_flux_0 = flux_0.error;

  println("0\t" + value_flux_0 + "\t" + error_flux_0);
  flag = 1;

  println("n\tvalue_flux_n\terror_flux_n\tI0/I\terror");

  for (int i = 1; i <= 12; i++) {

    int n = i * i * 3 - 2;
    CreateGeometry(n, nucleusShape);

    Result flux_n = averageTimeToGetOut(n, Ns, nucleusShape, "diffusion to pore");

    float value = value_flux_0 / flux_n.value;
    float error =
      value * sqrt(
        sq(error_flux_0 / value_flux_0) +
        sq(flux_n.error / flux_n.value)
      );

    println(n + "\t" + flux_n.value + "\t" + flux_n.error + "\t" + value + "\t" + error);
  }

  loop();
}



// =================================================================================================
// Averaged escape time / flux estimation
// =================================================================================================
Result averageTimeToGetOut(int N_pores, int Ns, int nucleusShape, String mode) {

  Result result = new Result(0, 0);

  switch (nucleusShape) {
    case 1:
      NPCs = definePostionsOfPoresOnSPHERE(N_pores, PORE_POSITIONING);
      break;
    case 2:
      NPCs = definePostionsOfPoresOnCUBE(N_pores, PORE_POSITIONING);
      break;
  }

  float xt = 0;
  float nt = 0;
  float mean = 0;
  float M2 = 0;

  // Online mean and variance (Welford algorithm)
  for (int i = 0; i < Ns; i++) {

    particleTrajectory =
      calculateSingleParticleTrajectory(mode, NUCLEUS_SHAPE);

    xt += timeInside;
    nt++;

    float delta = timeInside - mean;
    mean += delta / nt;
    float delta2 = timeInside - mean;
    M2 += delta * delta2;

    flag = 2;
  }

  float sample_variance = M2 / (nt - 1);
  float standard_error = sqrt(sample_variance) / sqrt(nt);

  result.value = xt / Ns;
  result.error = standard_error;

  return result;
}
