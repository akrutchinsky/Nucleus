/**
 **************************************************************************************************
 *
 * several useful classes
 *
 **************************************************************************************************
 */

class Point {

  public float x, y, z;   // Cartesian coordinates of the particle

  // Constructor: initializes the point with its spatial coordinates
  Point(float X, float Y, float Z) {
    x = X;
    y = Y;
    z = Z;
  }
}


class Geometry {

  public float x, y, z;    // Cartesian coordinates
  public String structure; // Name or type of the geometric structure
  public int n;            // Identifier or index of the structure

  // Constructor: initializes geometry with coordinates and structural metadata
  Geometry(float X, float Y, float Z, String definition, int number) {
    x = X;
    y = Y;
    z = Z;
    structure = definition;  ;
    n = number;
  }
}


class Result {

  public float value;  // Computed result value
  public float error;  // Associated uncertainty or error estimate

  // Constructor: initializes the result with its value and error
  Result(float v, float e) {
    value = v;
    error = e;
  }
}
