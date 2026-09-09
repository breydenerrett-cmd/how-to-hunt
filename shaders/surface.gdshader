shader_type spatial;
uniform vec4 base_color : source_color = vec4(0.5,0.5,0.5,1.0);
uniform bool wood = false;
varying vec3 world;
float hash21(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise2(vec2 p) {
	vec2 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);
	return mix(mix(hash21(i),hash21(i+vec2(1.0,0.0)),f.x),mix(hash21(i+vec2(0.0,1.0)),hash21(i+vec2(1.0)),f.x),f.y);
}
void vertex() { world=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment() {
	float variation=noise2(world.xz*0.45)*0.22+noise2(world.xz*5.0)*0.09+noise2(world.xz*55.0)*0.05;
	if(wood) {
		float plank=hash21(vec2(floor(world.z),0.0));
		float grain=noise2(vec2(world.x*1.8,world.z*45.0));
		variation=plank*0.11+grain*0.085;
	}
	ALBEDO=base_color.rgb*(0.76+variation);
	ROUGHNESS=wood?0.78:0.95;
}
