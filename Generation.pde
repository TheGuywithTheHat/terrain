Chunk[][] map;

int chunkSize;
int renderDistance;

int centerX;
int centerZ;

float waterLevel;

float xScale, yScale, zScale;

void setupGeneration() {
  noiseDetail(6);
  noiseSeed(int(random(Float.MAX_VALUE)));
  
  chunkSize = 32;
  renderDistance = 8;
  
  xScale = 0.02;
  yScale = 32;
  zScale = 0.02;
  
  waterLevel = 12;
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
          if(cx + deltaX >= renderDistance * 2 + 1 || cx + deltaX < 0 || cz + deltaZ >= renderDistance * 2 + 1 || cz + deltaZ < 0) {
            map[cz][cx] = new Chunk(newCenterX - renderDistance + cx, newCenterZ - renderDistance + cz);
          } else {
            map[cz][cx] = map[cz + deltaZ][cx + deltaX];
          }
        }
      }
    } else {
      for(int cz = map.length - 1; cz >= 0; cz--) {
        for(int cx = 0; cx < map[0].length; cx++) {
          if(cx + deltaX >= renderDistance * 2 + 1 || cx + deltaX < 0 || cz + deltaZ >= renderDistance * 2 + 1 || cz + deltaZ < 0) {
            map[cz][cx] = new Chunk(newCenterX - renderDistance + cx, newCenterZ - renderDistance + cz);
          } else {
            map[cz][cx] = map[cz + deltaZ][cx + deltaX];
          }
        }
      }
    }
  } else {
    if(deltaZ >= 0) {
      for(int cz = 0; cz < map.length; cz++) {
        for(int cx = map[0].length - 1; cx >= 0; cx--) {
          if(cx + deltaX >= renderDistance * 2 + 1 || cx + deltaX < 0 || cz + deltaZ >= renderDistance * 2 + 1 || cz + deltaZ < 0) {
            map[cz][cx] = new Chunk(newCenterX - renderDistance + cx, newCenterZ - renderDistance + cz);
          } else {
            map[cz][cx] = map[cz + deltaZ][cx + deltaX];
          }
        }
      }
    } else {
      for(int cz = map.length - 1; cz >= 0; cz--) {
        for(int cx = map[0].length - 1; cx >= 0; cx--) {
          if(cx + deltaX >= renderDistance * 2 + 1 || cx + deltaX < 0 || cz + deltaZ >= renderDistance * 2 + 1 || cz + deltaZ < 0) {
            map[cz][cx] = new Chunk(newCenterX - renderDistance + cx, newCenterZ - renderDistance + cz);
          } else {
            map[cz][cx] = map[cz + deltaZ][cx + deltaX];
          }
        }
      }
    }
  }
}

void generateGround() {
  map = new Chunk[renderDistance * 2 + 1][renderDistance * 2 + 1];
  
  for(int cz = 0; cz < map.length ; cz++) {
    for(int cx = 0; cx < map[0].length; cx++) {
      map[cz][cx] = new Chunk(centerX - renderDistance + cx, centerZ - renderDistance + cz);
    }
  }
}

float getHeight(int x, int z) {
  noiseDetail(6);
  float value = noise(x * xScale, z * zScale);
  
  if(value < waterLevel) {
    //value = waterLevel;
  }
  
  value *= yScale;
  
  return value;
}

PVector getVector(int x, int z) {
  return new PVector(x, getHeight(x, z), z);
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

PVector caclulateNormal(float c, float n, float s, float e, float w) {
  PVector normal = new PVector(2 * ((w - c) - (e - c)), 4, 2 * ((s - c) - (n - c)));
  normal.normalize();
  return normal;
}
