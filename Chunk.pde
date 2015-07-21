class Chunk {
  PShape shape;
  
  int centerOffsetX;
  int centerOffsetZ;
  int locationX;
  int locationZ;
  
  float[][] heightMap;
  
  float[][] heights;
  PVector[][] vertexNormals;
  
  Chunk(int locationX, int locationZ) {
    heightMap = new float[chunkSize][chunkSize];
    heights = new float[3][chunkSize + 3];
    vertexNormals = new PVector[2][chunkSize + 1];
    
    shape = createShape(GROUP);
    this.locationX = locationX;
    this.locationZ = locationZ;
    generate();
  }

  void generate() {
    for(int x = 0; x < heights[1].length; x++) {
      for(int z = 0; z < 3; z++) {
        heights[z][x] = getHeight(locationX * chunkSize + x - 1, locationZ * chunkSize + z - 2);
        /*if(z > 0 && x > 0 && x < chunkSize + 1) {
          heightMap[z - 1][x - 1] = heights[z][x];
        }*/
      }
    }
    
    for(int x = 0; x < vertexNormals[1].length; x++) {
      vertexNormals[1][x] = getNormal(x);
    }
    
    for(int z = 0; z < chunkSize; z++) {
      heights[0] = heights[1];
      heights[1] = heights[2];
      heights[2] = new float[chunkSize + 3];
      
      for(int x = 0; x < heights[2].length; x++) {
        heights[2][x] = getHeight(locationX * chunkSize + x - 1, locationZ * chunkSize + z + 1);
        if(x > 0 && x < chunkSize + 1) {
          heightMap[z][x - 1] = heights[0][x];
        }
      }
      
      vertexNormals[0] = vertexNormals[1];
      vertexNormals[1] = new PVector[chunkSize + 1];
      
      for(int x = 0; x < vertexNormals[1].length; x++) {
        vertexNormals[1][x] = getNormal(x);
      }
      
      shape.addChild(makeStrip(z));
    }
    heights = null;
    vertexNormals = null;
  }
  
  PShape makeStrip(int z) {
    PShape aStrip = createShape();
    aStrip.beginShape(QUAD_STRIP);
    aStrip.noStroke();
    
    for(int x = 0; x < heights[0].length - 2; x++) {
      aStrip.normal(vertexNormals[0][x].x, vertexNormals[0][x].y, vertexNormals[0][x].z);
      aStrip.vertex(locationX * chunkSize + x, heights[1][x + 1], locationZ * chunkSize + z);
      
      aStrip.normal(vertexNormals[1][x].x, vertexNormals[1][x].y, vertexNormals[1][x].z);
      aStrip.vertex(locationX * chunkSize + x, heights[2][x + 1], locationZ * chunkSize + z + 1);
    }
    
    aStrip.endShape();
    return aStrip;
  }
  
  PVector getNormal(int x) {
    return caclulateNormal(heights[1][x + 1], heights[2][x + 1], heights[0][x + 1], heights[1][x + 2], heights[1][x    ]);
    
    /*PVector n = new PVector( 0, heights[2][x + 1] - heights[1][x + 1],  1);
    PVector s = new PVector( 0, heights[0][x + 1] - heights[1][x + 1], -1);
    PVector e = new PVector( 1, heights[1][x + 2] - heights[1][x + 1],  0);
    PVector w = new PVector(-1, heights[1][x    ] - heights[1][x + 1],  0);
    
    PVector ne = n.cross(e);
    PVector nw = w.cross(n);
    PVector se = e.cross(s);
    PVector sw = s.cross(w);
    
    PVector normal = PVector.add(PVector.add(PVector.add(ne, nw), se), sw);
    normal.div(4);
    normal.normalize();
    
    return normal;*/
  }
}


/*

class Chunk {
  PShape shape;
  
  int centerOffsetX;
  int centerOffsetZ;
  int locationX;
  int locationZ;
  
  float[][] heights;
  PVector[][] faceNormals;
  PVector[][] vertexNormals;
  
  Chunk(int locationX, int locationZ) {
    heights = new float[3][chunkSize + 3];
    faceNormals = new PVector[2][chunkSize + 2];
    vertexNormals = new PVector[2][chunkSize + 1];
    
    shape = createShape(GROUP);
    this.locationX = locationX;
    this.locationZ = locationZ;
    generate();
  }

  void generate() {
    for(int x = 0; x < heights[1].length; x++) {
      heights[1][x] = getHeight(locationX * chunkSize + x - 1, locationZ * chunkSize);
    }
    
    for(int x = 0; x < faceNormals[1].length; x++) {
      heights[1][x] = getHeight(locationX * chunkSize + x - 1, locationZ * chunkSize);
    }
    
    for(int z = 0; z < chunkSize; z++) {
      heights[0] = heights[1];
      heights[1] = new float[chunkSize + 3];
      for(int x = 0; x < heights[0].length; x++) {
        heights[1][x] = getHeight(locationX * chunkSize + x - 1, locationZ * chunkSize + z + 1);
      }
      shape.addChild(makeStrip(z));
    }
  }
  
  PShape makeStrip(int z) {
    PShape aStrip = createShape();
    aStrip.beginShape(QUAD_STRIP);
    aStrip.noStroke();
    
    for(int x = 0; x < heights[0].length - 2; x++) {
      PVector vert1 = new PVector(x, heights[0][x + 1], z);
      PVector vert2 = new PVector(x, heights[1][x + 1], z + 1);
      
      aStrip.fill(getColor(heights[0][x + 1], heights[1][x + 1], heights[0][x + 2]));
      
      PVector normal = PVector.sub(vert2, vert1).cross(PVector.sub(new PVector(x + 1, heights[0][x + 2], z), vert1));
      normal.normalize();
      aStrip.normal(normal.x, normal.y, normal.z);
      
      aStrip.vertex(x, heights[0][x + 1], z);
      
      
      
      aStrip.fill(getColor(heights[1][x], heights[0][x + 1], heights[1][x + 1]));
      
      normal = PVector.sub(vert1, vert2).cross(PVector.sub(new PVector(x - 1, heights[1][x], z + 1), vert2));
      normal.normalize();
      aStrip.normal(normal.x, normal.y, normal.z);
      
      aStrip.vertex(x, heights[1][x + 1], z + 1);
    }
    
    aStrip.endShape();
    return aStrip;
  }
}

*/
