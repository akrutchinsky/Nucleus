/**
 ************************************************************************************************************************
 *
 * Simulates trajectories of particles diffusing from the center of either:
 *   (1) a spherical nucleus (press F1 for options), or
 *   (2) a cubic nucleus (press F2 for options),
 *
 * and computes the particle flux through varying numbers of pores,
 * normalized to the flux at the inner surface of the nucleus.
 *
 * @author Andrew Krutchinsky
 * @organization The Rockefeller University
 *
 ************************************************************************************************************************
 */


import javax.swing.JOptionPane;
import java.awt.event.KeyEvent;
import javax.swing.SwingUtilities;
import java.util.Scanner;
import javax.swing.ImageIcon;
import javax.swing.JFrame;
import java.lang.Math;
import java.util.Random;

// ------------------------------------------------------------------------------------------------
// File paths (currently unused, retained for future extensions)
// ------------------------------------------------------------------------------------------------
// String Directory = "/home/tiapa/Processing Projects/MQ_Q12mm_tao01/";
// String DEFAULT_RFPOT_FILE = Directory + "RF";  // Path to RF potential file


// ------------------------------------------------------------------------------------------------
// Geometry and physical units
// ------------------------------------------------------------------------------------------------
float UNITS = 1e-9;        // Base unit: nanometers expressed in meters
float s     = 1;          // Seconds
float um    = 1000*UNITS; // Micrometer [m]
float cm    = 1e7*UNITS;  // Centimeter [m]

// ------------------------------------------------------------------------------------------------
// Diffusion constants (only one active at a time)
// ------------------------------------------------------------------------------------------------
// float D = 1e-5*cm*cm/s; // Small molecule in water at room temperature [Berg, near Eq. (1.11)]
// float D = 100*um*um/s; // GFP in water
// float D = 10*um*um/s;  // GFP in E. coli cytoplasm
float D = 1.7*um*um/s;    // 60S ribosomal subunits diffusion constant

// ------------------------------------------------------------------------------------------------
// Nucleus and pore geometry
// ------------------------------------------------------------------------------------------------
float R     = 900*UNITS;  // Nuclear radius (0.9 µm)
float Dpore = 60*UNITS;   // Nuclear pore diameter
int   Npores = 140;       // Default number of pores

float spaceSTEP = Dpore/10;  // Spatial step size for diffusion


// ------------------------------------------------------------------------------------------------
// Simulation switches
// ------------------------------------------------------------------------------------------------
char PORE_POSITIONING = 'R'; // 'F' = Fibonacci (hard-coded for Npores ≤ 18)
                             // 'R' = Random (hard-coded for small Npores ≤ 18)

int NUCLEUS_SHAPE = 1;       // 1 = sphere (default), 2 = cube


// ------------------------------------------------------------------------------------------------
// Visualization parameters
// ------------------------------------------------------------------------------------------------
float DRAWING_SCALE = 0.2 * 1/UNITS;


// ------------------------------------------------------------------------------------------------
// Time discretization
// ------------------------------------------------------------------------------------------------
float dt = spaceSTEP*spaceSTEP/(2*D); // Chosen so that sqrt(2*D*dt) << Dpore

int   Nsteps    = 100000;
float end_time  = 10;
float timeInside = 0;


// ------------------------------------------------------------------------------------------------
// Trajectory bookkeeping
// ------------------------------------------------------------------------------------------------
String TRAJECTORY = "line";
int COUNT = 1;

// Counters
int Ninside = 0;
int Nout    = 0;


// ------------------------------------------------------------------------------------------------
// Initial particle position
// ------------------------------------------------------------------------------------------------
float startX = 0;
float startY = 0;
float startZ = 0;


// ------------------------------------------------------------------------------------------------
// Rotation angles for 3D visualization
// ------------------------------------------------------------------------------------------------
float a1 = 0.0;  // Rotation about X-axis
float a2 = 0.0;  // Rotation about Y-axis
float a3 = 0.0;  // Rotation about Z-axis


// ------------------------------------------------------------------------------------------------
// Miscellaneous state variables
// ------------------------------------------------------------------------------------------------
float flag = 1;
int npo = 0;


// ------------------------------------------------------------------------------------------------
// Geometry containers
// ------------------------------------------------------------------------------------------------
ArrayList<Geometry> nucleus    = new ArrayList<Geometry>();
ArrayList<Geometry> NPCs       = new ArrayList<Geometry>();
ArrayList<Geometry> trajectory = new ArrayList<Geometry>();

// Array for particle trajectory data
ArrayList<Geometry> particleTrajectory;

// Auxiliary integer storage
int[] aN = new int[10];


// ------------------------------------------------------------------------------------------------
// Window dimensions (pixels)
// ------------------------------------------------------------------------------------------------
int w = 800;
int h = 800;


// ------------------------------------------------------------------------------------------------
// Setup function: initializes simulation and visualization
// ------------------------------------------------------------------------------------------------
void setup() {

  println("Radius R = " + R + "; D = " + D + "; Pore positioning = " + PORE_POSITIONING);
  println("dt = " + dt);

  // Ensure compatibility with JOGL backend
  System.setProperty("jogl.disable.openglcore", "false");

  size(800, 800, P3D);
  background(255);

  keyPressed();  // Trigger initial redraw
}
