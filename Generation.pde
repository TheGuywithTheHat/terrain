Chunk[][] map;

int tempcx = 32;
int tempcz = 32;

int chunkSize;
int renderDistance;

int centerX;
int centerZ;

float waterLevel;
float fakeWaterLevel;

float xScale, yScale, zScale;

void setupGeneration() {
  noiseSeed(int(random(Float.MAX_VALUE)));
  
  chunkSize = 32;
  renderDistance = 32;
  
  xScale = 0.01;
  yScale = 64;
  zScale = 0.01;
  
  waterLevel = 24;
  
  fakeWaterLevel = fakeWaterLevel(waterLevel, yScale);
}

void generateGround(int newCenterX, int newCenterZ) {
  int deltaX = newCenterX - centerX;
  int deltaZ = newCenterZ - centerZ;
  
  centerX = newCenterX;
  centerZ = newCenterZ;
  
  if(deltaX >= 0) {
    if(deltaZ >= 0) {
      for(int cz = 0; cz < map.length; cz++) {
        for(int cx = 0; cx < map[0].length; cx++) {
          placeChunk(cx, cz, deltaX, deltaZ, newCenterX, newCenterZ);
        }
      }
    } else {
      for(int cz = map.length - 1; cz >= 0; cz--) {
        for(int cx = 0; cx < map[0].length; cx++) {
          placeChunk(cx, cz, deltaX, deltaZ, newCenterX, newCenterZ);
        }
      }
    }
  } else {
    if(deltaZ >= 0) {
      for(int cz = 0; cz < map.length; cz++) {
        for(int cx = map[0].length - 1; cx >= 0; cx--) {
          placeChunk(cx, cz, deltaX, deltaZ, newCenterX, newCenterZ);
        }
      }
    } else {
      for(int cz = map.length - 1; cz >= 0; cz--) {
        for(int cx = map[0].length - 1; cx >= 0; cx--) {
          placeChunk(cx, cz, deltaX, deltaZ, newCenterX, newCenterZ);
        }
      }
    }
  }
}

void placeChunk(int cx, int cz, int deltaX, int deltaZ, int newCenterX, int newCenterZ) {
  float distance = sqrt(pow(cx - renderDistance, 2) + pow(cz - renderDistance, 2));
  
  if(distance > 0.5 + renderDistance) {
    map[cz][cx] = null;
  } else if(cz + deltaZ < map.length && cz + deltaZ >= 0 && cx + deltaX < map[0].length && cx + deltaX >= 0 && map[cz + deltaZ][cx + deltaX] != null) {
    map[cz][cx] = new Chunk(map[cz + deltaZ][cx + deltaX], distance);
  } else {
    map[cz][cx] = new Chunk(newCenterX - renderDistance + cx, newCenterZ - renderDistance + cz, distance);
  }
}

void generateGround() {
  map = new Chunk[renderDistance * 2 + 1][renderDistance * 2 + 1];
  
  generateGround(centerX, centerZ);
  /*for(int cz = 0; cz < map.length ; cz++) {
    for(int cx = 0; cx < map[0].length; cx++) {
      map[cz][cx] = new Chunk(centerX - renderDistance + cx, centerZ - renderDistance + cz);
    }
  }*/
}

float calculateHeight(float x, float z) {
  noiseDetail(8, 0.52);
  float value = noise(x * xScale, z * zScale);
  
  value *= yScale;
  
  value = yScale
      * (pow(value - fakeWaterLevel, 3) + pow(fakeWaterLevel, 3))
      / (pow(yScale - fakeWaterLevel, 3) + pow(fakeWaterLevel, 3));
      
  value = nsqrt(value - waterLevel) * sqrt(yScale - waterLevel) + waterLevel;
  
  float delta = 0.1;
  if(value >= waterLevel && value < waterLevel + delta) {
    value += delta;
  } else if(value <= waterLevel && value > waterLevel - delta) {
    value -= delta;
  }
  
  return value;
}

PVector getVector(int x, int z) {
  return new PVector(x, calculateHeight(x, z), z);
}

color getColor(float value1, float value2, float value3) {
  
  if(value1 <= 32 && value2 <= 32 && value3 <= 32) {
    return color(64, 64, 255);
  }
  
  else if(value1 > 68 && value2 > 68 && value3 > 68) {
    return color(250, 250, 255);
  } else if(value1 > 52 && value2 > 52 && value3 > 52) {
    return color(140, 130, 160);
  }
  
  else {
    return color(100, 160, 90);
  }
}

PVector calculateNormal(float c, float n, float s, float e, float w) {
  PVector normal = new PVector(2 * ((w - c) - (e - c)), 4, 2 * ((s - c) - (n - c)));
  normal.normalize();
  return normal;
}

float fakeWaterLevel(float w, float h) {
  float a = pow(pow(h, 2) * w
      + sqrt((pow(h, 4) * pow(w, 2)) - (2 * pow(h, 3) * pow(w, 3)) + (pow(h, 2) * pow(w, 4)))
      - 3 * h * pow(w, 2)
      + 2 * pow(w, 3), 1.0 / 3);
      
   float b = a / pow(2, 1.0 / 3)
       - (pow(2, 1.0 / 3) * (9 * h * w - 9 * pow(w, 2)))
       / (9 * a) + w;
   
   return b;
}

float nsqrt(float a) {
  if(a >= 0) {
    return sqrt(a);
  } else {
    return -sqrt(-a);
  }
}

class ChunkGenerator {
  
}