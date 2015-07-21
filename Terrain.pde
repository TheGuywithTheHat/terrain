float time;

void setup() {
  size(displayWidth, displayHeight, P3D);
  setupPermutation();
  
  setupInput();
  setupGeneration();
  setupCamera();
  setupRender();
  
  generateGround();
  
  frameRate(60);
}

void draw() {
  time = frameCount / 1800.0;
  
  checkInput();
  
  render();
  
  if(isInDebug) {
    drawRGBXYZ();
  }
}
