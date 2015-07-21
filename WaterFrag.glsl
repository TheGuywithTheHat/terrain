#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform int fogDistance;
uniform float waterLevel;
uniform int time;

uniform int horizonLine;
uniform int screenHeight;
uniform int zenithLine;
uniform float skylight;
uniform vec4 camPos;
uniform float b1;
uniform float a1;

varying vec4 vertLight;
varying vec4 fragPosition;
varying vec4 vertColor;

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

vec4 permute(vec4 x) {
  return mod289(((x * 34.0) + 1.0)  * x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float noise(vec3 v)
{ 
  const vec2  C = vec2(1.0 / 6.0, 1.0 / 3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy));
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min(g.xyz, l.zxy);
  vec3 i2 = max(g.xyz, l.zxy);

  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy;
  vec3 x3 = x0 - D.yyy;

// Permutations
  i = mod289(i); 
  vec4 p = permute(permute(permute(
      i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
    + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
    + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4(x.xy, y.xy);
  vec4 b1 = vec4(x.zw, y.zw);

  vec4 s0 = floor(b0) * 2.0 + 1.0;
  vec4 s1 = floor(b1) * 2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
  vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

  vec3 p0 = vec3(a0.xy, h.x);
  vec3 p1 = vec3(a0.zw, h.y);
  vec3 p2 = vec3(a1.xy, h.z);
  vec3 p3 = vec3(a1.zw, h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
  m = m * m;
  return 21.0 * dot(m*m, vec4(dot(p0, x0), dot(p1, x1), 
                              dot(p2, x2), dot(p3, x3))) + 0.5;
}

vec4 skyColor(float altitude) {
  vec3 zenith = vec3(0.4, 0.5, 1);
  vec3 horizon = mix(vec3(1, 0.6, 0.4), vec3(0.9, 1, 1), skylight);
  //altitude = (-5 * pow(altitude, 6) + 6 * pow(altitude, 5));
  altitude = 1 - abs(1 - mod(altitude, 2));
  //return vec4(mix(zenith, horizon, altitude) * skylight, 1);
  //return vec4(mix(zenith, horizon, 1.5 / (3 - 2 * altitude) - 0.5) * skylight, 1);
  return vec4(mix(zenith, horizon, b1 / (a1 + 1 - altitude) - a1) * skylight, 1);
}

float altitude() {
  float altitude = (screenHeight - gl_FragCoord.y - zenithLine) / (horizonLine - zenithLine);
  altitude = 1 - abs(1 - mod(altitude, 2));
  altitude += (noise(vec3(fragPosition.xz * 4, time * 0.025)) - altitude) / 4;
  return altitude;
}

vec4 applyLight(vec4 rgba) {
  vec4 color = skyColor(altitude());
  color.a *= (color.r + color.g + color.b) / 3;
  return color;
  //return mix(rgba, skyColor(altitude()), pow(noise(vec3(fragPosition.xz * 0.1, time * 0.01)) * 0.2 + noise(vec3(fragPosition.xz, time * 0.02)) * 0.6 + noise(vec3(fragPosition.xz * 2, time * 0.02)) * 0.1, 2));
  /*vec4 normal = normalize(vec4(pow(noise(vec3(fragPosition.xz, time * 0.02)) * 0.8, 2),
                               1,
                               pow(noise(vec3(fragPosition.xz + 11.378, time * 0.02)) * 0.8, 2),
                               1));

  vec4 camDir = normalize(vec4(camPos.x - fragPosition.x,
                               camPos.y,
                               camPos.z - fragPosition.z,
                               1));

  vec4 reflectDir = camDir - 2 * dot(camDir, normal) * normal;
  vec4 color = skyColor(acos(dot(reflectDir, vec4(0, 1, 0, 1))) / 6.2831853);

  return mix(vertColor, color, (pow(color.r, 2) + pow(color.g, 2) + pow(color.b, 2)) / 3);*/
}

vec4 applyFog(vec4 rgba, float distance) {
  float fogAmount = min(distance / fogDistance, 1);
  vec4 fogColor = skyColor(altitude());
  return mix(rgba, fogColor, fogAmount);
}

void main() {
  float depth = gl_FragCoord.z / gl_FragCoord.w;
  gl_FragColor = applyFog(applyLight(vertColor), depth);
}