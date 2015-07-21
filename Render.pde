
//PShape[][] ground;
PShader groundShader;
PShader waterShader;
PShader sunShader;
PShader skyShader;

float daylight;
float sunlight;
float moonlight;
float skylight;

float skylightOffset;

float skyRed;
float skyGreen;
float skyBlue;

float sunRed;
float sunGreen;
float sunBlue;

float sunA;
float sunB;

//color skyColor;

void setupRender() {
  skyRed = 0.7;
  skyGreen = 0.85;
  skyBlue = 1.0;
  
  sunRed = 2;
  sunGreen = 1.5;
  sunBlue = 0.95;
  
  float skyB = 0.5;
  float skyA = (sqrt(1 + 4 * skyB) - 1) / 2;
  
  sunB = 0.05;
  sunA = (sqrt(1 + 4 * sunB) - 1) / 2;
  skylightOffset = skylightBase(0);
  
  groundShader = loadShader("GroundFrag.glsl", "GroundVert.glsl");
  waterShader = loadShader("WaterFrag.glsl", "WaterVert.glsl");
  sunShader = loadShader("SunFrag.glsl");
  skyShader = loadShader("SkyFrag.glsl");
  
  recalcDayLight();
  
  groundShader.set("a1", skyA);
  skyShader.set("a1", skyA);
  waterShader.set("a1", skyA);
  groundShader.set("b1", skyB);
  skyShader.set("b1", skyB);
  waterShader.set("b1", skyB);
  
  groundShader.set("fogDistance", renderDistance * chunkSize - chunkSize / 2);
  groundShader.set("waterLevel", waterLevel);
  
  waterShader.set("fogDistance", renderDistance * chunkSize - chunkSize / 2);
  
  //ground = new PShape[renderDistance * 2 + 1][renderDistance * 2 + 1];
  
  /*for(int z = 0; z < ground.length; z++) {
    for(int x = 0; x < ground[0].length; x++) {
      ground[z][x] = makeChunk(centerX + x - renderDistance, centerZ + z - renderDistance);
      /*for(int x = 0; x < heightMap.length; x++) {
        ground.vertex(x, heightMap[z][x] / 655.36, z);
      }*/
    /*}
  }*/
}

void render() {
  recalcDayLight();
  
  skyShader.set("horizonLine", horizonLine());
  skyShader.set("zenithLine", zenithLine());
  skyShader.set("screenHeight", height);
  groundShader.set("horizonLine", horizonLine());
  groundShader.set("zenithLine", zenithLine());
  groundShader.set("screenHeight", height);
  waterShader.set("horizonLine", horizonLine());
  waterShader.set("zenithLine", zenithLine());
  waterShader.set("screenHeight", height);
  
  
  
  drawSky();
  
  ambientLight(max(skylight * 200, 4), max(skylight * 200, 4), max(skylight * 255, 4));
  directionalLight(sunlight * 255, sunlight * 255, sunlight * 200, -cos(time * PI), -sin(time * PI), 0);
  directionalLight(moonlight * 200, moonlight * 200, moonlight * 255, cos(time * PI), sin(time * PI), 0);
  
  drawGround();
  drawWater();
}

void drawSky() {
  hint(DISABLE_DEPTH_TEST);
  camera();
  perspective();
  noLights();
  //resetMatrix();
  
  shader(skyShader);
  
  camera();
  noStroke();
  
  fill(128, 0, 0, 255);
  rect(0, 0, width, height);
  
  hint(ENABLE_DEPTH_TEST);
  perspective(camFOV, float(width) / float(height), 0.1, 256);
  
  camera(camPos.x, camPos.y, camPos.z, camDir.x + camPos.x, camDir.y + camPos.y, camDir.z + camPos.z, 0, -1, 0);
  //background(skyRed * light * 255, skyGreen * light * 255, skyBlue * light * 255);
  
  PShape sun = createShape();
  sun.beginShape(TRIANGLE_FAN);
  
  sun.fill(sunRed * skylight * 255 * 3, sunGreen * skylight * 255 * 3, sunBlue * skylight * 255 * 3, 255);
  sun.vertex(0, 16, 0);
  
  sun.fill(sunRed * skylight * 50 * 3, sunGreen * skylight * 50 * 3, sunBlue * skylight * 50 * 3, 0);
  for(int i = 0; i < 33; i++) {
    sun.vertex(cos(TWO_PI * i / 16.0), 16, sin(TWO_PI * i / 16.0));
  }
  
  sun.endShape();
  
  /*PShape moon = createShape();
  moon.beginShape(TRIANGLE_FAN);
  
  moon.fill(192);
  moon.vertex(0, -16, 0);
  for(int i = 0; i < 33; i++) {
    moon.vertex(cos(TWO_PI * i / 16.0), -16, sin(TWO_PI * i / 16.0));
  }
  
  moon.endShape();*/
  
  fill(192);
  noStroke();
  PShape moon = createShape(ELLIPSE, new float[] {0, -16, 2, 2});
  
  shader(sunShader);
  hint(DISABLE_DEPTH_TEST);
  pushMatrix();
  
  translate(camPos.x, camPos.y, camPos.z);
  rotateZ(time * PI - HALF_PI);
  
  shape(sun);
  
  resetShader();
  
  shape(moon);
  
  popMatrix();
  hint(ENABLE_DEPTH_TEST);
}

void drawGround() {
  shader(groundShader);
  
  for(int z = 0; z < map.length; z++) {
    for(int x = 0; x < map[0].length; x++) {
      //pushMatrix();
      //translate((centerX - renderDistance + x) * chunkSize, 0, (centerZ - renderDistance + z) * chunkSize);
      shape(map[z][x].shape);
      //popMatrix();
    }
  }
  resetShader();
}

void drawWater() {
  shader(waterShader);
  waterShader.set("time", frameCount);
  waterShader.set("camPos", camPos.x - (centerX - renderDistance) * chunkSize, camPos.y - waterLevel, camPos.z - (centerZ - renderDistance) * chunkSize, 1);
  waterShader.set("modelviewInv", ((PGraphicsOpenGL)g).modelviewInv);
  noStroke();
  fill(120 * daylight, 160 * daylight, 255 * daylight, 128);
  
  pushMatrix();
  translate(centerX * chunkSize, waterLevel, centerZ * chunkSize);
  rotateX(HALF_PI);
  rect(-(renderDistance * chunkSize), -(renderDistance * chunkSize), (renderDistance * 2 + 1) * chunkSize, (renderDistance * 2 + 1) * chunkSize);
  popMatrix();
}

/*void recalcDayLight() {
  light = constrain(sin(time * PI) + 0.5, 0, 1);
  skyShader.set("light", float(1));
  groundShader.set("light", light);
  waterShader.set("light", light);
  
  //////
  float time1 = time % 2;
  if(time1 > 1) {
    print("night     ");
    daylight = 0.0f;
  } else if(time1 > 0.5) {
    print("afternoon ");
    daylight = max(1.0 - (-4.0 * pow(-1.0 + 2 * time1, 5.0) + 5.0 * pow(-1.0 + 2 * time1, 4)), 0.0);
  } else {
    print("morning  ");
    daylight = max(1.0 - (-4.0 * pow(1.0 - 2 * time1, 5.0) + 5.0 * pow(1.0 - 2 * time1, 4.0)), 0.0);
  }
  //////
  
  //skyColor = color(skyRed * light, skyGreen * light, skyBlue * light);
  
  //groundShader.set("skyColor", skyRed * light, skyGreen * light, skyBlue * light, 1);
  //waterShader.set("skyColor", skyRed * light, skyGreen * light, skyBlue * light, 1);
}*/

void recalcDayLight() {
  float time1 = time % 2;
  
  if(time1 <= 0.25) {
    skylight = skylight(time1);
  } else if(time1 < 0.75) {
    skylight = 1.0 / 3;
  } else if(time1 <= 1) {
    skylight = skylight(1 - time1);
  } else if(time1 <= 1.25) {
    skylight = 1.0 / 3 - skylight(time1 - 1);
  } else if(time1 <= 1.75) {
    skylight = 0.0;
  } else {
    skylight = 1.0 / 3 - skylight(2 - time1);
  }
  
  if(time1 <= 0.5) {
    sunlight = sunlight(time1);
  } else if(time1 < 1) {
    sunlight = sunlight(1 - time1);
  } else {
    sunlight = 0;
  }
  
  if(time1 < 1) {
    moonlight = 0;
  } else if(time1 < 1.5) {
    moonlight = sunlight(time1 - 1) / 6;
  } else {
    moonlight = sunlight(2 - time1) / 6;
  }
  //println(skylight);
  daylight = sunlight + skylight + moonlight;
  
  skyShader.set("skylight", skylight * 3);
  groundShader.set("skylight", skylight * 3);
  waterShader.set("skylight", skylight * 3);
  
  //skyColor = color(skyRed * light, skyGreen * light, skyBlue * light);
  
  //groundShader.set("skyColor", skyRed * light, skyGreen * light, skyBlue * light, 1);
  //waterShader.set("skyColor", skyRed * light, skyGreen * light, skyBlue * light, 1);
}

float sunlight(float x) {
  return 2.0 / 3 * (1 + sunA - sunB / (2 * x + sunA));
}

float skylight(float x) {
  return (((skylightBase(x) - skylightOffset) / (1.0 - skylightOffset)) + 1) / 6.0;
  //return (1 + sin(3 * PI * (x + (PI % 1) / 12))) / 6;
}

float skylightBase(float x) {
  return (1.0 + sin(sqrt(3 * PI * (x + PI / 12 - 0.25)))) / 2;
}

void drawRGBXYZ() {
  stroke(255, 0, 0);
  line(1024, 64, 1024, 1026, 64, 1024);
  
  stroke(0, 255, 0);
  line(1024, 64, 1024, 1024, 66, 1024);
  
  stroke(0, 0, 255);
  line(1024, 64, 1024, 1024, 64, 1026);
}
