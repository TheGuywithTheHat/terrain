#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform int fogDistance;
uniform float waterLevel;

uniform int horizonLine;
uniform int screenHeight;
uniform int zenithLine;
uniform float skylight;
uniform float b1;
uniform float a1;

varying vec4 vertLight;
varying vec4 fragPosition;

vec4 skyColor(float altitude) {
  vec3 zenith = vec3(0.4, 0.5, 1);
  vec3 horizon = mix(vec3(1, 0.6, 0.4), vec3(0.9, 1, 1), skylight);
  //return vec4(mix(zenith, horizon, (-5 * pow(altitude, 6) + 6 * pow(altitude, 5))) * skylight, 1);
  //return vec4(mix(zenith, horizon, 1.5 / (3 - 2 * altitude) - 0.5) * skylight, 1);
  return vec4(mix(zenith, horizon, b1 / (a1 + 1 - altitude) - a1) * skylight, 1);
}

float altitude() {
  float altitude = (screenHeight - gl_FragCoord.y - zenithLine) / (horizonLine - zenithLine);
  altitude = 1 - abs(1 - mod(altitude, 2));
  return altitude;
}

/*vec4 skyColor() {
  vec3 zenith = vec3(0.4, 0.5, 1);
  vec3 horizon = vec3(0.8, 0.9, 1);
  return vec4(mix(horizon, zenith, sqrt(abs((horizonLine + gl_FragCoord.y - screenHeight) / screenHeight))) * light, 1);
}*/

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

float rand(vec2 co){
  return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
}

vec4 applyNoiseTexture(vec4 rgba, float maxOffset) {
  return mix(vec4(rgba.rgb + (noise(fragPosition.xz * 16) * 2 + 1) * maxOffset    , rgba.a),
             //vec4(rgba.rgb + (noise(fragPosition.xz * 2 ) * 2 + 1) * maxOffset / 4, rgba.a),
             rgba,
             clamp((gl_FragCoord.z / gl_FragCoord.w) / (fogDistance / 4), 0, 1));
}

vec4 getColor() {
  float height = fragPosition.y + noise(fragPosition.xz) / 2 - 0.25;
  //height += (noise(fragPosition.xz * 0.02) - 0.5) * (fragPosition.y - waterLevel);
  
  vec3 color;

  float snowLevel = 24;
  float stoneLevel = 20;
  float grassLevel = waterLevel + 1;

  vec3 snow = vec3(0.95, 0.95, 0.95);
  vec3 stone = vec3(0.5, 0.5, 0.6);
  vec3 grass = vec3(0.5, 0.6, 0.3);
  vec3 sand = vec3(0.8, 0.7, 0.6);

  if(height > snowLevel + 0.5) {
    color =  snow;
  } else if(height > snowLevel - 0.5) {
    color = mix(stone, snow, (height - snowLevel + 0.5));
  } else if(height > stoneLevel + 1) {
    color = stone;
  } else if(height > stoneLevel - 1) {
    color = mix(grass, stone, (height - stoneLevel + 1) / 2);
  } else if(height > grassLevel + 0.5) {
    color = grass;
  } else if(height > grassLevel - 0.5) {
    color = mix(sand, grass, (height - grassLevel + 0.5));
  } else {
    color = sand;
  }

  return applyNoiseTexture(vec4(color, 1), 0.1);
}

vec4 applyLight(vec4 rgba) {
  if(fragPosition.y <= waterLevel) {
    rgba.rgb *= -1 / (fragPosition.y - waterLevel - 1);
  }
  return vertLight * rgba;
}

vec4 applyFog(vec4 rgba, float distance) {
  float fogAmount = min(distance / fogDistance, 1);
  vec4 fogColor = skyColor(altitude());
  return mix(rgba, fogColor, fogAmount);
}

void main() {
  float depth = gl_FragCoord.z / gl_FragCoord.w;
  gl_FragColor = applyFog(applyLight(getColor()), depth);
}