import java.awt.event.KeyEvent;

boolean isInDebug;
private boolean[] keys;

void setupInput() {
  isInDebug = false;
  keys = new boolean[526];
}

void checkInput() {
  if(getKey(KeyEvent.VK_W)) {
    PVector camDelta = camDir.get();
    camDelta.y = 0;
    camDelta.setMag(moveSpeed);
    camPos.add(camDelta);
    recalcCamera();
  }
  if(getKey(KeyEvent.VK_S)) {
    PVector camDelta = camDir.get();
    camDelta.y = 0;
    camDelta.setMag(moveSpeed);
    camPos.sub(camDelta);
    recalcCamera();
  }
  if(getKey(KeyEvent.VK_A)) {
    PVector camDelta = camDir.get().cross(new PVector(0, -1, 0));
    camDelta.setMag(moveSpeed);
    camPos.sub(camDelta);
    recalcCamera();
  }
  if(getKey(KeyEvent.VK_D)) {
    PVector camDelta = camDir.get().cross(new PVector(0, -1, 0));
    camDelta.setMag(moveSpeed);
    camPos.add(camDelta);
    recalcCamera();
  }
  if(getKey(KeyEvent.VK_SPACE)) {
    PVector camDelta = new PVector(0, moveSpeed, 0);
    camPos.add(camDelta);
    recalcCamera();
  }
  if(getKey(KeyEvent.VK_SHIFT)) {
    PVector camDelta = new PVector(0, -moveSpeed, 0);
    camPos.add(camDelta);
    recalcCamera();
  }
}

boolean getKey(int k) {
  if(k < keys.length) {
    return keys[k];
  }
  return false;
}

void setKey(int k, boolean value) {
  keys[k] = value;
}

void keyPressed() {
  setKey(keyCode, true);
  switch(keyCode) {
    case KeyEvent.VK_F3:
      isInDebug = !isInDebug;
      break;
    case KeyEvent.VK_F2:
      save(year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "_"  + nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2) + ".png");
      break;
    default:
      break;
  }
}

void keyReleased() {
  setKey(keyCode, false);
}

void mouseDragged() {
  float dx = pmouseX - mouseX;
  float dy = pmouseY - mouseY;
  
  vxRotation = constrain(vxRotation - (dy * 0.001), -HALF_PI + 0.01, HALF_PI - 0.01);
  vyRotation = (vyRotation + (dx * 0.001)) % TWO_PI;
  recalcCamera();
}