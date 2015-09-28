float time;

void setup() {
  fullScreen(P3D);
  
  setupPermutation();
  
  setupInput();
  setupGeneration();
  setupCamera();
  setupRender();
  
  generateGround();
  
  frameRate(60);
}

void draw() {
  time = frameCount / 18000.0;
  
  checkInput();
  
  render();
  
  if(isInDebug) {
    drawRGBXYZ();
  }
}