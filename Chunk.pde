PImage grassTex;

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
    textureWrap(REPEAT);
    PShape aStrip = createShape();
    aStrip.beginShape(QUAD_STRIP);
    aStrip.texture(grassTex);
    aStrip.noStroke();
    
    for(int x = 0; x < heights[0].length - 2; x++) {
      aStrip.normal(vertexNormals[0][x].x, vertexNormals[0][x].y, vertexNormals[0][x].z);
      aStrip.vertex(locationX * chunkSize + x, heights[1][x + 1], locationZ * chunkSize + z, x * 10240, 0);
      
      aStrip.normal(vertexNormals[1][x].x, vertexNormals[1][x].y, vertexNormals[1][x].z);
      aStrip.vertex(locationX * chunkSize + x, heights[2][x + 1], locationZ * chunkSize + z + 1, x * 10240, 10240);
    }
    
    aStrip.endShape();
    return aStrip;
  }
  
  PVector getNormal(int x) {
    return calculateNormal(heights[1][x + 1], heights[2][x + 1], heights[0][x + 1], heights[1][x + 2], heights[1][x    ]);
  }
}