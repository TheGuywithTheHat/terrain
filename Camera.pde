float moveSpeed;
float vyRotation;
float vxRotation;

PVector camPos;
PVector camDir;

float camFOV;

void setupCamera() {
  camFOV = (PI + QUARTER_PI) / 3.0;
  perspective(camFOV, float(width) / float(height), 0.01, 256);
  
  moveSpeed = 0.4;
  vyRotation = HALF_PI;
  vxRotation = 0;
  
  camPos = new PVector(1024, 24, 1024);
  camDir = new PVector();
  
  centerX = int(camPos.x) / chunkSize;
  centerZ = int(camPos.z) / chunkSize;
  
  recalcCamera();
}

void recalcCamera() {
  camDir.y = sin(vxRotation);
  camDir.z = cos(vxRotation);
  
  camDir.x = sin(vyRotation) * cos(vxRotation);
  camDir.z = cos(vyRotation) * cos(vxRotation);
  
  camDir.normalize();
  
  camera(camPos.x, camPos.y, camPos.z, camDir.x + camPos.x, camDir.y + camPos.y, camDir.z + camPos.z, 0, -1, 0);
  
  int currentCenterX = int(camPos.x) / chunkSize;
  int currentCenterZ = int(camPos.z) / chunkSize;
  
  if(currentCenterX != centerX || currentCenterZ != centerZ) {
    generateGround(currentCenterX, currentCenterZ);
  }
}

int horizonLine() {
  float horizonAngle = atan((waterLevel - camPos.y) / (renderDistance * chunkSize - chunkSize / 2));
  float camAngle = vxRotation;
  float deltaAngle = (camAngle - horizonAngle) - camFOV / 2;
  return height - int(deltaAngle / camFOV * -height);
}

int zenithLine() {
  float camAngle = vxRotation;
  float deltaAngle = (camAngle - HALF_PI) - camFOV / 2;
  return height - int(deltaAngle / camFOV * -height);
}