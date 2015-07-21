#define PROCESSING_LIGHT_SHADER

uniform mat4 modelviewMatrix;
uniform mat4 transformMatrix;
uniform mat3 normalMatrix;
uniform mat4 modelviewInv;

uniform int lightCount;
uniform vec4 lightPosition[8];
uniform vec3 lightNormal[8];
uniform vec3 lightAmbient[8];
uniform vec3 lightDiffuse[8];
uniform vec3 lightSpecular[8];
uniform vec3 lightFalloff[8];
uniform vec2 lightSpot[8];

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;

attribute vec4 ambient;
attribute vec4 specular;
attribute vec4 emissive;
attribute float shininess;

varying vec4 vertColor;
varying vec4 vertLight;
varying vec4 fragPosition;

const float zero_float = 0.0;
const float one_float = 1.0;
const vec3 zero_vec3 = vec3(0);

float falloffFactor(vec3 lightPos, vec3 vertPos, vec3 coeff) {
  vec3 lpv = lightPos - vertPos;
  vec3 dist = vec3(one_float);
  dist.z = dot(lpv, lpv);
  dist.y = sqrt(dist.z);
  return one_float / dot(dist, coeff);
}

float spotFactor(vec3 lightPos, vec3 vertPos, vec3 lightNorm, float minCos, float spotExp) {
  vec3 lpv = normalize(lightPos - vertPos);
  vec3 nln = -one_float * lightNorm;
  float spotCos = dot(nln, lpv);
  return spotCos <= minCos ? zero_float : pow(spotCos, spotExp);
}

float lambertFactor(vec3 lightDir, vec3 vecNormal) {
  return max(zero_float, dot(lightDir, vecNormal));
}

float blinnPhongFactor(vec3 lightDir, vec3 vertPos, vec3 vecNormal, float shine) {
  vec3 np = normalize(vertPos);
  vec3 ldp = normalize(lightDir - np);
  return pow(max(zero_float, dot(ldp, vecNormal)), shine);
}

void main() {
  // Vertex in clip coordinates
  gl_Position = transformMatrix * position;
  
  // Normal vector in eye coordinates
  vec3 ecNormal = normalize(normalMatrix * normal);
  
  // Light calculations
  vec3 totalAmbient = vec3(0, 0, 0);
  
  vec3 totalFrontDiffuse = vec3(0, 0, 0);

  totalAmbient += lightAmbient[0];

  vec3 lightDir;
  lightDir = -one_float * lightNormal[1];
  totalFrontDiffuse  += lightDiffuse[1];

  vertLight = vec4(totalAmbient, 0) + vec4(totalFrontDiffuse, 1);
  vertColor = vertLight * color;

  fragPosition = position * modelviewInv;
}