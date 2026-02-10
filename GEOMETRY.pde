
/**
 **************************************************************************************************
 *
 *                                   define geometry of a Nucleus
 *
 **************************************************************************************************
 */
 
ArrayList<Geometry> nucleusGeometry_GLOBE(int N, char porePositionMethod) { 
 
  
  // List to store coordinates of electrodes for fast plotting
  ArrayList<Geometry> nucleus = new ArrayList<Geometry>();
    
   int Nl = 600;
   int S = 600;
   // Longitudes
   for (int k=0; k<Nl; k++) {
     float lambda = 2*PI*k/Nl;
     for( int i=0; i<S; i++) {
       float phi = -PI/2 + PI*i/S;
       float x = R*cos(phi)*cos(lambda);
       float y = R*cos(phi)*sin(lambda);
       float z = R*sin(phi);
       nucleus.add(new Geometry(x, y, z, "wall", 1));
     }
   } 
   // Latitudes
   for( int m = 1; m<Nl; m++) {
     float phi = -PI/2 + PI*m/(Nl+1);
     for(int j=0; j<S; j++) {
       float lambda = 2*PI*j/S;
       float x = R*cos(phi)*cos(lambda);
       float y = R*cos(phi)*sin(lambda);
       float z = R*sin(phi);
       nucleus.add(new Geometry(x, y, z, "wall",1));
     }
   }
   // here NUPs postions are degined for a given geometry
   NPCs = definePostionsOfPoresOnSPHERE(N, porePositionMethod); 
   nucleus.addAll(NPCs); //FibonacciPorePositions());   
   return nucleus; // Return the list of electrode potentials
}


/**
 **************************************************************************************************
 *
 *                                   define geometry of a Nucleus
 *
 **************************************************************************************************
 */
 
ArrayList<Geometry> nucleusGeometry_CUBE(int N, char porePositionMethod) { 
 
  
  // List to store coordinates of electrodes for fast plotting
  ArrayList<Geometry> nucleus = new ArrayList<Geometry>();
    
   int Nl = 100;
   int S = 100; 
   float Ro = R;
   //X
   for(float x =-Ro; x<=Ro; x=x+2*Ro) {
     for (int k=0; k<Nl; k++) {
       float y = -Ro+k*2*Ro/Nl;
         for (int j=0; j<S; j++) { 
           float z = -Ro+j*2*Ro/Nl;
           nucleus.add(new Geometry(x, y, z, "wall", 1));
        }
      } 
    }
   //Y
   for(float y =-Ro; y<=Ro; y=y+2*Ro) {
     for (int k=0; k<Nl; k++) {
       float x = -Ro+k*2*Ro/Nl;
         for (int j=0; j<S; j++) { 
           float z = -Ro+j*2*Ro/Nl;
           nucleus.add(new Geometry(x, y, z, "wall", 1));
        }
      } 
    }
   //Z
   for(float z =-Ro; z<=Ro; z=z+2*Ro) {
     for (int k=0; k<Nl; k++) {
       float x = -Ro+k*2*Ro/Nl;
         for (int j=0; j<S; j++) { 
           float y = -Ro+j*2*Ro/Nl;
           nucleus.add(new Geometry(x, y, z, "wall", 1));
        }
      } 
    }  
  
  
   // here NPCs postions are degined for a given geometry
   NPCs = definePostionsOfPoresOnCUBE(N, porePositionMethod); 
   nucleus.addAll(NPCs); //FibonacciPorePositions());   
   return nucleus; // Return the list of electrode potentials
}


//---------------------------------------------------------------------------------------------------
ArrayList<Geometry> definePostionsOfPoresOnSPHERE (int N, char porePositionMethod) { 
  ArrayList<Geometry> pores = new ArrayList<Geometry>();
  // switching between different positioning of NPCs
  switch(porePositionMethod) {
    case 'F': //Fibonacci spiral
    NPCs = FibonacciPorePositions(N);
    break;
    
    case 'f': //semi Ribonacci (hard coded for smal n + Fibonacci)
    NPCs = semiFibonacciPorePositions(N);
    break;
   
    case 'R': // Random 
    NPCs = randomPorePositions(N);
    break;
  
    case 'S': // Random 
    NPCs = semiRandomPorePositions(N);
    break;
    
    case 'U':
    //println("using Farthest-point sampled icosphere with Riesz-energy polishing method to position pores");
    NPCs = uniformRieszPorePositions(N);
    break;
  }
  
  float r = Dpore/2;
  float w = 5*UNITS;
  for(Geometry p: NPCs) {
    for(float x=p.x- r; x<=p.x+r; x=x+2*UNITS) {
      for(float y=p.y-r; y<=p.y+r; y=y+2*UNITS) {
        for(float z=p.z-r; z<=p.z+r; z=z+2*UNITS) {
          if(((x-p.x)*(x-p.x)+(y-p.y)*(y-p.y)+(z-p.z)*(z-p.z))<=Dpore*Dpore/4 &&
          ((x-p.x)*(x-p.x)+(y-p.y)*(y-p.y)+(z-p.z)*(z-p.z))>((Dpore-w)*(Dpore-w)/4) &&
          vectorLength(x,y,z) <= R+2*w &&  vectorLength(x,y,z) >= R-2*w
          ) pores.add(new Geometry(x, y, z, "pore", p.n));
        }
      }
    }
  }
  return pores;
}
//------------------------------------------------------------------------------------
ArrayList<Geometry> definePostionsOfPoresOnCUBE (int N, char porePostionMethod) { 
  ArrayList<Geometry> pores = new ArrayList<Geometry>();
  // switching between different positioning of NPCs
  switch(porePostionMethod) {
    case 'A': //Fibonacci spiral
    NPCs = arrayedPorePositionsOnCube(N);
    break;   
   
    case 'R': // Random 
    NPCs = randomPorePositionsOnCUBE(N);
    //for (Geometry n : NPCs) {
      //println(n.x + " " +n.y + " " + n.z);
    //}
    break;
    
    
  
  }
  
  float r = Dpore/2;
  float w = 5*UNITS;
  float Rminus = R-w;
  float Rplus = R+w;
  for(Geometry p: NPCs) {
    for(float x=p.x- r; x<=p.x+r; x=x+2*UNITS) {
      for(float y=p.y-r; y<=p.y+r; y=y+2*UNITS) {
        for(float z=p.z-r; z<=p.z+r; z=z+2*UNITS) {
          if(((x-p.x)*(x-p.x)+(y-p.y)*(y-p.y)+(z-p.z)*(z-p.z))<=Dpore*Dpore/4 &&
             ((x-p.x)*(x-p.x)+(y-p.y)*(y-p.y)+(z-p.z)*(z-p.z))>((Dpore-w)*(Dpore-w)/4) &&
              (( sqrt(x*x)>=Rminus && sqrt(x*x)<=Rplus) || ( sqrt(y*y)>=Rminus && sqrt(y*y)<=Rplus) || ( sqrt(z*z)>=Rminus && sqrt(z*z)<=Rplus))
          ) pores.add(new Geometry(x, y, z, "pore", p.n));
        }
      }
    }
  }
  return pores;
}


//------------------------------------------------------------------------------------
float vectorLength(float x, float y, float z) {
  return sqrt(x*x+y*y+z*z);
}

int atPore (float x, float y, float z, ArrayList<Geometry> pCenters) {

  if(nearTheWall(x,y,z, NUCLEUS_SHAPE)) { // if a particle close to the wall, within 100nm
    for(Geometry p: pCenters) {
     if(((x-p.x)*(x-p.x)+(y-p.y)*(y-p.y)+(z-p.z)*(z-p.z))<=Dpore*Dpore/4) return p.n;
    }
  } else return 0; // not within 100nm from the wall
  return 0;
}


//----------Returns 0 if not at the pore, othewise retuns the pore number------------
int atPore_on_CUBE (float x, float y, float z, ArrayList<Geometry> pCenters) {
  //if a particle close to the wall
  float DELTA = Dpore/2;
  if(sqrt(x*x)>(R-DELTA) || sqrt(y*y)>(R-DELTA) || sqrt(z*z)>(R-DELTA)) { // if a particle close to the wall, within 100nm
    for(Geometry p: pCenters) {
     if(((x-p.x)*(x-p.x)+(y-p.y)*(y-p.y)+(z-p.z)*(z-p.z))<=Dpore*Dpore/4) return p.n;
    }
  } else return 0; // not within 100nm from the wall
  return 0;
}
//--------------------------------------------------------------------------------
int atPore_on_SPHERE (float x, float y, float z, ArrayList<Geometry> pCenters) {
  float vn = vectorLength(x,y,z);
  float DELTA = Dpore/2+10*UNITS;
  if(vn>(R-DELTA)) { // if a particle close to the wall, within 100nm
    for(Geometry p: pCenters) {
     if(((x-p.x)*(x-p.x)+(y-p.y)*(y-p.y)+(z-p.z)*(z-p.z))<=Dpore*Dpore/4) return p.n;
    }
  } else return 0; // not within 100nm from the wall
  return 0;
}

boolean nearTheWall(float x, float y, float z, int nucleusShape) {
  
  boolean result = false;
  float DELTA = Dpore/2;
  
  switch (nucleusShape) {
    
    case 1: // SPHERE 
     float vn = vectorLength(x,y,z);
     DELTA = Dpore/2+10*UNITS;
     result = vn>(R-DELTA);
     break;
    
    case 2: //CUBE
     result = (sqrt(x*x)>(R-DELTA) || sqrt(y*y)>(R-DELTA) || sqrt(z*z)>(R-DELTA));
     break;
  }
  return result;
}


//------------------------ define position of pores randomly ---------------------
ArrayList<Geometry> randomPorePositions(int Np) { 
  ArrayList<Geometry> pores = new ArrayList<Geometry>();
  for(int i = 1; i<=Np; i++) {
    float theta  = random(0, 2*PI);
    float z = random(-1, 1);
    float v = sqrt(1-z*z);
    float x = v*cos(theta);
    float y = v*sin(theta);
    String def = "pore";
    pores.add(new Geometry(R*x, R*y, R*z, def, i));
  }
  return pores;
}

//------------------------ define position of pores randomly ---------------------
ArrayList<Geometry> uniformRieszPorePositions(int Np) { 
  
    ArrayList<Geometry> pores = new ArrayList<Geometry>();

 //float R = 1.0f;
  int seed = 7;

 PVector[] x = spherePointsBest(Np, R, seed);
    
  for (int i = 0; i < x.length; i++) {
    //println(i, x[i].x, x[i].y, x[i].z +" ---> " +sqrt(x[i].x*x[i].x+x[i].y*x[i].y+x[i].z*x[i].z));
    pores.add(new Geometry(x[i].x, x[i].y, x[i].z, "pore", (i+1)));
  }
  
  
  return pores;
}

//---------------------------------------------------------------------------------
ArrayList<Geometry> randomPorePositionsOnCUBE(int Np) { 
  ArrayList<Geometry> pores = new ArrayList<Geometry>();
  String def = "pore";
  float Ro = R;
  for(int i = 1; i<=Np; i++) {
    int side  = int(random(1, 7));
    float u = random(-1,1);
    float v = random (-1,1);
    
    switch (side) {
     case 1: 
      pores.add(new Geometry(Ro, Ro*u, Ro*v, def, i));
      break;
      
     case 2: 
      pores.add(new Geometry(-Ro, Ro*u, Ro*v, def, i));
      break;
           
     case 3: 
      pores.add(new Geometry(Ro*u, Ro, Ro*v, def, i));
      break;
      
     case 4: 
      pores.add(new Geometry(Ro*u, -Ro, Ro*v, def, i));
      break;
      
     case 5: 
      pores.add(new Geometry(Ro*u, Ro*v, Ro,  def, i));
      break;
      
     case 6: 
      pores.add(new Geometry(Ro*u, Ro*v, -Ro, def, i));
      break;
      
    }
    
  }
  return pores;
}

//--------------------------------------------------------------------------------

ArrayList<Geometry> arrayedPorePositionsOnCube(int Np) {
  
  ArrayList<Geometry> pores = new ArrayList<Geometry>();
  String def = "pore";

  // 1) Split across faces
  int base = Np / 6 + 1;
  int rem  = Np % 6;
  int[] faceOrder = {0,1,2,3,4,5}; // 0:+X,1:-X,2:+Y,3:-Y,4:+Z,5:-Z
  int[] c = {base, base, base, base, base, base};
  for (int k = 0; k < rem; k++) c[k]++;//c[faceOrder[k]]++;

  // 2) For each face, build a grid and map to 3D
  for (int f = 0; f < 6; f++) {
    int cf = c[f];
    if (cf == 0) continue;

    int rows = (int)floor(sqrt(cf));
    int cols = (int)ceil((float)cf / rows);

    int placed = 1;
    outer:
    for (int i = 0; i < rows && placed < cf; i++) {
      for (int j = 0; j < cols && placed < cf; j++) {
        if (placed >= cf) break outer;
        float u = (i + 0.5f) / rows; // (0,1)
        float v = (j + 0.5f) / cols; // (0,1)
        Geometry g = mapToFace(f, u, v, R, def, placed);
        pores.add(g);
        placed++;
      }
    }
  }
  return pores;
}


//--------------------------------------------------------------------------------

// Face indices: 0:+X,1:-X,2:+Y,3:-Y,4:+Z,5:-Z
Geometry mapToFace(int face, float u, float v, float a, String def, int index) {
  float U = (2*u - 1) * a;
  float V = (2*v - 1) * a;
  switch (face) {
    case 0:  return new Geometry( a,  U,  V, def, index); // +X
    case 1:  return new Geometry(-a,  U,  V, def, index); // -X
    case 2:  return new Geometry( U,  a,  V, def, index); // +Y
    case 3:  return new Geometry( U, -a,  V, def, index); // -Y
    case 4:  return new Geometry( U,  V,  a, def, index); // +Z
    default: return new Geometry( U,  V, -a, def, index); // -Z
  }
}


//------------------------ define position of pores randomly ---------------------
ArrayList<Geometry> semiRandomPorePositions(int Np) { 
  ArrayList<Geometry> pores = new ArrayList<Geometry>();
  
  if(Np<=18) { return pores = forSmallNp(Np); }
  else { pores = forSmallNp(18);
    for(int i = 19; i<=Np; i++) {
      float theta  = random(0, 2*PI);
      float z = random(-1, 1);
      float v = sqrt(1-z*z);
      float x = v*cos(theta);
      float y = v*sin(theta);
      String def = "pore";
      pores.add(new Geometry(R*x, R*y, R*z, def, i));
    }
  }
  return pores;
}

//------------------------ define position of pores using Fibonacci spiral ---------------------
ArrayList<Geometry> semiFibonacciPorePositions (int Np) { 
  ArrayList<Geometry> pores = new ArrayList<Geometry>();  
  
  if(Np<=18) { return pores = forSmallNp(Np); }
  else { pores = forSmallNp(18);
    float golden_angle = PI*(3-sqrt(5));
    for(int i = 19; i<=Np; i++) {
      float z = 1-2*i/((float)Npores-1);
      float r = sqrt(1-z*z);
      float phi = i*golden_angle;
      float x = r*cos(phi);
      float y = r*sin(phi); 
      String def = "pore";
      pores.add(new Geometry(x*R, y*R, z*R, def, i));
    }
  }
  return pores;
}


//------------------------ define position of pores using Fibonacci spiral ---------------------
ArrayList<Geometry> FibonacciPorePositions (int Np) { 
  ArrayList<Geometry> pores = new ArrayList<Geometry>();  
    float golden_angle = PI*(3-sqrt(5));
    for(int i = 1; i<=Np; i++) {
      float z = 1-2*i/((float)Npores-1);
      float r = sqrt(1-z*z);
      float phi = i*golden_angle;
      float x = r*cos(phi);
      float y = r*sin(phi); 
      String def = "pore";
      pores.add(new Geometry(x*R, y*R, z*R, def, i));
    }
  
  return pores;
}

//----------------------- Postion reasonably uniformly for Npores<=18---------------------------------------

ArrayList<Geometry> forSmallNp(int Np) { 
 
  ArrayList<Geometry> pores = new ArrayList<Geometry>();
  
  float k = sqrt(2);
  float l =sqrt(3);
  
  String def = "pore";
   
  if(Np == 1) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    return pores;
  }                       
  if(Np == 2) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2)); 
    return pores;
  }
                          
  if(Np == 3) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    return pores;
  }
                          
  if(Np == 4) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    return pores;
  }
                          
  if(Np == 5) {
     pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    pores.add(new Geometry(0, 0, R, def, 5));
    return pores;
  }
  
  if(Np == 6) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    pores.add(new Geometry(0, 0, R, def, 5));
    pores.add(new Geometry(0, 0, -R, def, 6));
    return pores;
  }

  if(Np == 7) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    pores.add(new Geometry(0, 0, R, def, 5));
    pores.add(new Geometry(0, 0, -R, def, 6));
    pores.add(new Geometry(R/l, R/l, R/l, def, 7));
    return pores;
  }
  
  if(Np == 8) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    pores.add(new Geometry(0, 0, R, def, 5));
    pores.add(new Geometry(0, 0, -R, def, 6));
    pores.add(new Geometry(R/l, R/l, R/l, def, 7));
    pores.add(new Geometry(-R/l, -R/l, -R/l, def, 8));
    return pores;
  }
  
if(Np == 9) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    pores.add(new Geometry(0, 0, R, def, 5));
    pores.add(new Geometry(0, 0, -R, def, 6));
    pores.add(new Geometry(R/l, R/l, R/l, def, 7));
    pores.add(new Geometry(-R/l, -R/l, -R/l, def, 8));
    pores.add(new Geometry(0, R/k, R/k, def, 9));
    return pores;
  }
  
  if(Np == 10) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    pores.add(new Geometry(0, 0, R, def, 5));
    pores.add(new Geometry(0, 0, -R, def, 6));
    pores.add(new Geometry(R/l, R/l, R/l, def, 7));
    pores.add(new Geometry(-R/l, -R/l, -R/l, def, 8));
    pores.add(new Geometry(0, R/k, R/k, def, 9));
    pores.add(new Geometry(0, -R/k, -R/k, def, 10));
    return pores;
  }
  
    if(Np == 11) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    pores.add(new Geometry(0, 0, R, def, 5));
    pores.add(new Geometry(0, 0, -R, def, 6));
    pores.add(new Geometry(R/l, R/l, R/l, def, 7));
    pores.add(new Geometry(-R/l, -R/l, -R/l, def, 8));
    pores.add(new Geometry(0, R/k, R/k, def, 9));
    pores.add(new Geometry(0, -R/k, -R/k, def, 10));
    pores.add(new Geometry(R/k, 0, R/k, def, 11));
    return pores;
  }
  
    if(Np == 12) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    pores.add(new Geometry(0, 0, R, def, 5));
    pores.add(new Geometry(0, 0, -R, def, 6));
    pores.add(new Geometry(R/l, R/l, R/l, def, 7));
    pores.add(new Geometry(-R/l, -R/l, -R/l, def, 8));
    pores.add(new Geometry(0, R/k, R/k, def, 9));
    pores.add(new Geometry(0, -R/k, -R/k, def, 10));
    pores.add(new Geometry(-R/k, 0, -R/k, def, 11));
    pores.add(new Geometry(-R/k, 0, -R/k, def, 12));
    return pores;
  }
  
  if(Np == 13) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    pores.add(new Geometry(0, 0, R, def, 5));
    pores.add(new Geometry(0, 0, -R, def, 6));
    pores.add(new Geometry(R/l, R/l, R/l, def, 7));
    pores.add(new Geometry(-R/l, -R/l, -R/l, def, 8));
    pores.add(new Geometry(0, R/k, R/k, def, 9));
    pores.add(new Geometry(0, -R/k, -R/k, def, 10));
    pores.add(new Geometry(-R/k, 0, -R/k, def, 11));
    pores.add(new Geometry(-R/k, 0, -R/k, def, 12));
    pores.add(new Geometry(R/k, R/k, 0, def, 13));
    return pores;
  }
  
  if(Np == 14) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    pores.add(new Geometry(0, 0, R, def, 5));
    pores.add(new Geometry(0, 0, -R, def, 6));
    pores.add(new Geometry(R/l, R/l, R/l, def, 7));
    pores.add(new Geometry(-R/l, -R/l, -R/l, def, 8));
    pores.add(new Geometry(0, R/k, R/k, def, 9));
    pores.add(new Geometry(0, -R/k, -R/k, def, 10));
    pores.add(new Geometry(-R/k, 0, -R/k, def, 11));
    pores.add(new Geometry(-R/k, 0, -R/k, def, 12));
    pores.add(new Geometry(R/k, R/k, 0, def, 13));
    pores.add(new Geometry(-R/k, -R/k, 0, def, 14));
    return pores;
  }
  
  if(Np == 15) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    pores.add(new Geometry(0, 0, R, def, 5));
    pores.add(new Geometry(0, 0, -R, def, 6));
    pores.add(new Geometry(R/l, R/l, R/l, def, 7));
    pores.add(new Geometry(-R/l, -R/l, -R/l, def, 8));
    pores.add(new Geometry(0, R/k, R/k, def, 9));
    pores.add(new Geometry(0, -R/k, -R/k, def, 10));
    pores.add(new Geometry(-R/k, 0, -R/k, def, 11));
    pores.add(new Geometry(-R/k, 0, -R/k, def, 12));
    pores.add(new Geometry(R/k, R/k, 0, def, 13));
    pores.add(new Geometry(-R/k, -R/k, 0, def, 14));
    pores.add(new Geometry(R/l, -R/l, R/l, def, 15));
    return pores;
  }
  
  if(Np == 16) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    pores.add(new Geometry(0, 0, R, def, 5));
    pores.add(new Geometry(0, 0, -R, def, 6));
    pores.add(new Geometry(R/l, R/l, R/l, def, 7));
    pores.add(new Geometry(-R/l, -R/l, -R/l, def, 8));
    pores.add(new Geometry(0, R/k, R/k, def, 9));
    pores.add(new Geometry(0, -R/k, -R/k, def, 10));
    pores.add(new Geometry(-R/k, 0, -R/k, def, 11));
    pores.add(new Geometry(-R/k, 0, -R/k, def, 12));
    pores.add(new Geometry(R/k, R/k, 0, def, 13));
    pores.add(new Geometry(-R/k, -R/k, 0, def, 14));
    pores.add(new Geometry(R/l, -R/l, R/l, def, 15));
    pores.add(new Geometry(-R/l, R/l, -R/l, def, 16));
    return pores;
  }
  
   if(Np == 17) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    pores.add(new Geometry(0, 0, R, def, 5));
    pores.add(new Geometry(0, 0, -R, def, 6));
    pores.add(new Geometry(R/l, R/l, R/l, def, 7));
    pores.add(new Geometry(-R/l, -R/l, -R/l, def, 8));
    pores.add(new Geometry(0, R/k, R/k, def, 9));
    pores.add(new Geometry(0, -R/k, -R/k, def, 10));
    pores.add(new Geometry(-R/k, 0, -R/k, def, 11));
    pores.add(new Geometry(-R/k, 0, -R/k, def, 12));
    pores.add(new Geometry(R/k, R/k, 0, def, 13));
    pores.add(new Geometry(-R/k, -R/k, 0, def, 14));
    pores.add(new Geometry(R/l, -R/l, R/l, def, 15));
    pores.add(new Geometry(-R/l, R/l, -R/l, def, 16));
    pores.add(new Geometry(R/l, R/l, -R/l, def, 17));
    return pores;
  }
  
  if(Np == 18) {
    pores.add(new Geometry(R, 0, 0, def, 1));
    pores.add(new Geometry(-R, 0, 0, def, 2));
    pores.add(new Geometry(0, R, 0, def, 3));
    pores.add(new Geometry(0, -R, 0, def, 4));
    pores.add(new Geometry(0, 0, R, def, 5));
    pores.add(new Geometry(0, 0, -R, def, 6));
    pores.add(new Geometry(R/l, R/l, R/l, def, 7));
    pores.add(new Geometry(-R/l, -R/l, -R/l, def, 8));
    pores.add(new Geometry(0, R/k, R/k, def, 9));
    pores.add(new Geometry(0, -R/k, -R/k, def, 10));
    pores.add(new Geometry(-R/k, 0, -R/k, def, 11));
    pores.add(new Geometry(-R/k, 0, -R/k, def, 12));
    pores.add(new Geometry(R/k, R/k, 0, def, 13));
    pores.add(new Geometry(-R/k, -R/k, 0, def, 14));
    pores.add(new Geometry(R/l, -R/l, R/l, def, 15));
    pores.add(new Geometry(-R/l, R/l, -R/l, def, 16));
    pores.add(new Geometry(R/l, R/l, -R/l, def, 17));
    pores.add(new Geometry(-R/l, -R/l, R/l, def, 18));
    return pores;
  }
  
  return pores;
}
