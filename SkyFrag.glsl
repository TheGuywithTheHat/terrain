#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform int horizonLine;
uniform int screenHeight;
uniform int zenithLine;
uniform float skylight;
uniform float b1;
uniform float a1;

vec4 skyColor(float altitude) {
  vec3 zenith = vec3(0.4, 0.5, 1);
  vec3 horizon = mix(vec3(0.9, 0.5, 0.3), vec3(0.9, 1, 1), skylight);
  return vec4(mix(zenith, horizon, b1 / (a1 + 1 - altitude) - a1) * skylight, 1);
}

float altitude() {
  float altitude = (screenHeight - gl_FragCoord.y - zenithLine) / (horizonLine - zenithLine);
  altitude = 1 - abs(1 - mod(altitude, 2));
  return altitude;
}

void main() {
  gl_FragColor = skyColor(altitude());
}