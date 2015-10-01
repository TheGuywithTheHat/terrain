PImage grassTex;

class Chunk {
  PShape shape;
  
  int quads;
  int nquads;
  int squads;
  int equads;
  int wquads;
  float quadSize;
  
  int centerOffsetX;
  int centerOffsetZ;
  int locationX;
  int locationZ;
  
  float[][] heightMap;
  
  float[][] heights;
  PVector[][] vertexNormals;
  
  Chunk(int locationX, int locationZ, float distance) {
    quads = getQuadNum(locationX, locationZ);
    nquads = getQuadNum(locationX, locationZ + 1);
    squads = getQuadNum(locationX, locationZ - 1);
    equads = getQuadNum(locationX + 1, locationZ);
    wquads = getQuadNum(locationX - 1, locationZ);
    
    quadSize = float(chunkSize) / quads;
    
    heightMap = new float[quads][quads];
    heights = new float[3][quads + 3];
    vertexNormals = new PVector[2][quads + 1];
    
    shape = createShape(GROUP);
    this.locationX = locationX;
    this.locationZ = locationZ;
    generate();
  }

  void generate() {
    for(int x = 0; x < heights[1].length; x++) {
      for(int z = 0; z < 3; z++) {
        heights[z][x] = getHeight(locationX * chunkSize + (x - 1) * quadSize, locationZ * chunkSize + (z - 2) * quadSize);
      }
    }
    
    for(int x = 0; x < vertexNormals[1].length; x++) {
      vertexNormals[1][x] = getNormal(x);
    }
    
    for(int z = 0; z < heightMap.length; z++) {
      heights[0] = heights[1];
      heights[1] = heights[2];
      heights[2] = new float[quads + 3];
      
      for(int x = 0; x < heights[2].length; x++) {
        heights[2][x] = getHeight(locationX * chunkSize + (x - 1) * quadSize, locationZ * chunkSize + (z + 1) * quadSize);
        if(x > 0 && x < quads + 1) {
          heightMap[z][x - 1] = heights[0][x];
        }
      }
      
      vertexNormals[0] = vertexNormals[1];
      vertexNormals[1] = new PVector[quads + 1];
      
      for(int x = 0; x < vertexNormals[1].length; x++) {
        vertexNormals[1][x] = getNormal(x);
      }
      
      shape.addChild(makeStrip(z));
    }
    heights = null;
    vertexNormals = null;
  }
  
  PShape makeStrip(int z) {
    textureWrap(REPEAT);
    PShape aStrip = createShape();
    aStrip.beginShape(QUAD_STRIP);
    aStrip.texture(grassTex);
    aStrip.noStroke();
    
    for(int x = 0; x < heights[0].length - 2; x++) {
      aStrip.normal(vertexNormals[0][x].x, vertexNormals[0][x].y, vertexNormals[0][x].z);
      aStrip.vertex(locationX * chunkSize + x * quadSize, heights[1][x + 1], locationZ * chunkSize + z * quadSize, x * quadSize * 10240, 0);
      
      aStrip.normal(vertexNormals[1][x].x, vertexNormals[1][x].y, vertexNormals[1][x].z);
      aStrip.vertex(locationX * chunkSize + x * quadSize, heights[2][x + 1], locationZ * chunkSize + (z + 1) * quadSize, x * quadSize * 10240, 10240 * quadSize);
    }
    
    aStrip.endShape();
    return aStrip;
  }
  
  PVector getNormal(int x) {
    return calculateNormal(heights[1][x + 1], heights[2][x + 1], heights[0][x + 1], heights[1][x + 2], heights[1][x    ]);
  }
  
  int getQuadNum(int locationX, int locationZ) {
    int quads;
    float distance = sqrt(pow(centerX - locationX, 2) + pow(centerZ - locationZ, 2));
    
    if(distance < 1.5) {
      quads = chunkSize * 2;
    } else if(distance < 3.5) {
      quads = chunkSize;
    } else if(distance < 7.5) {
      quads = round(chunkSize / 2);
    } else if(distance < 15.5) {
      quads = round(chunkSize / 4);
    } else if(distance < 31.5) {
      quads = round(chunkSize / 8);
    } else {
      quads = round(chunkSize / 16);
    }
    
    return quads;
  }
}