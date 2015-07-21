#define PROCESSING_LIGHT_SHADER

uniform float waterLevel;

uniform mat4 modelviewMatrix;
uniform mat4 transformMatrix;
uniform mat3 normalMatrix;

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

//flat varying vec4 vertColor;
varying vec4 vertLight;
varying vec4 fragPosition;
//varying vec4 backVertColor;

const float zero_float = 0.0;
const float one_float = 1.0;
const vec3 zero_vec3 = vec3(0);

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float noise(vec2 v)
{
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
    + i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 65.0 * dot(m, g) + 0.5;
}

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
  totalFrontDiffuse += lightDiffuse[1] * lambertFactor(lightDir, ecNormal);
  
  lightDir = -one_float * lightNormal[2];
  totalFrontDiffuse += lightDiffuse[2] * lambertFactor(lightDir, ecNormal);

  vertLight = vec4(totalAmbient, 0)/* * ambient*/ + vec4(totalFrontDiffuse, 1);
  //vertColor = /*vertLight * */color;

  fragPosition = position;
  fragPosition.y += (noise(fragPosition.xz * 0.02) - 0.5) * (fragPosition.y - waterLevel);
//  vertColor = vec4(totalFrontDiffuse, 1) * color;
}

/*void main() {
  // Vertex in clip coordinates
  gl_Position = transformMatrix * position;
    
  // Vertex in eye coordinates
  vec3 ecVertex = vec3(modelviewMatrix * position);
  
  // Normal vector in eye coordinates
  vec3 ecNormal = normalize(normalMatrix * normal);
  vec3 ecNormalInv = ecNormal * -one_float;
  
  // Light calculations
  vec3 totalAmbient = vec3(0, 0, 0);
  
  vec3 totalFrontDiffuse = vec3(0, 0, 0);
  vec3 totalFrontSpecular = vec3(0, 0, 0);
  
  vec3 totalBackDiffuse = vec3(0, 0, 0);
  vec3 totalBackSpecular = vec3(0, 0, 0);
  
  for (int i = 0; i < 8; i++) {
    if (lightCount == i) break;
    
    vec3 lightPos = lightPosition[i].xyz;
    bool isDir = zero_float < lightPosition[i].w;
    float spotCos = lightSpot[i].x;
    float spotExp = lightSpot[i].y;
    
    vec3 lightDir;
    float falloff;    
    float spotf;
      
    if (isDir) {
      falloff = one_float;
      lightDir = -one_float * lightNormal[i];
    } else {
      falloff = falloffFactor(lightPos, ecVertex, lightFalloff[i]);  
      lightDir = normalize(lightPos - ecVertex);
    }
  
    spotf = spotExp > zero_float ? spotFactor(lightPos, ecVertex, lightNormal[i], 
                                              spotCos, spotExp) 
                                 : one_float;
    
    if (any(greaterThan(lightAmbient[i], zero_vec3))) {
      totalAmbient       += lightAmbient[i] * falloff;
    }
    
    if (any(greaterThan(lightDiffuse[i], zero_vec3))) {
      totalFrontDiffuse  += lightDiffuse[i] * falloff * spotf *
                            lambertFactor(lightDir, ecNormal);
      totalBackDiffuse   += lightDiffuse[i] * falloff * spotf * 
                            lambertFactor(lightDir, ecNormalInv);
    }
    
    if (any(greaterThan(lightSpecular[i], zero_vec3))) {
      totalFrontSpecular += lightSpecular[i] * falloff * spotf * 
                            blinnPhongFactor(lightDir, ecVertex, ecNormal, shininess);
      totalBackSpecular  += lightSpecular[i] * falloff * spotf * 
                            blinnPhongFactor(lightDir, ecVertex, ecNormalInv, shininess);
    }     
  }    

  // Calculating final color as result of all lights (plus emissive term).
  // Transparency is determined exclusively by the diffuse component.
  vertColor =     vec4(totalAmbient, 0) * ambient + 
                  vec4(totalFrontDiffuse, 1) * color + 
                  vec4(totalFrontSpecular, 0) * specular + 
                  vec4(emissive.rgb, 0);
              
  backVertColor = vec4(totalAmbient, 0) * ambient + 
                  vec4(totalBackDiffuse, 1) * color + 
                  vec4(totalBackSpecular, 0) * specular + 
                  vec4(emissive.rgb, 0);
}*/