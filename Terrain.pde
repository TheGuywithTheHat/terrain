float time;

long lastFrameTime;
PGraphics graph;

void setup() {
  fullScreen(P3D);
  
  setupPermutation();
  
  setupInput();
  setupGeneration();
  setupCamera();
  setupRender();
  
  generateGround();
  
  frameRate(60);
  
  graph = createGraphics(width, height, P2D);
  graph.beginDraw();
  graph.background(0, 0);
  
  graph.stroke(0, 128);
  graph.line(0, height - (1000f / 60f), width, height - (1000f / 60f));
  graph.line(0, height - (1000f / 30f), width, height - (1000f / 30f));
  graph.line(0, height - (1000f / 15f), width, height - (1000f / 15f));
  
  graph.noStroke();
  graph.fill(255, 0, 0, 128);
  graph.endDraw();
  lastFrameTime = millis();
}

void draw() {
  time = frameCount / 18000.0;
  
  checkInput();
  
  render();
  
  if(isInDebug) {
    drawRGBXYZ();
  }
  
  to2D();
  
  int duration = (int)(millis() - lastFrameTime);
  graph.beginDraw();
  graph.rect(frameCount, height - duration, 1, duration);
  graph.endDraw();
  image(graph, 0, 0);
  lastFrameTime = millis();
  
  to3D();
}