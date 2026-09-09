shader_type sky;
render_mode disable_fog;
// Direct background shading avoids relying on an unused ambient radiance cubemap.
// Sky built-ins: https://docs.godotengine.org/en/4.5/tutorials/shaders/shader_reference/sky_shader.html
uniform sampler2D cloud_noise : filter_linear, repeat_enable;
void sky(){
 float height=max(EYEDIR.y,0.0);
 vec3 background=mix(vec3(.62,.66,.59),vec3(.12,.30,.46),pow(height,.42));
 vec2 p=EYEDIR.xz/(height+.32)*.26+vec2(.43,.71);
 float billow=texture(cloud_noise,p).r;
 float cloud=smoothstep(.49,.68,billow)*smoothstep(.015,.18,height);
 vec3 cloud_color=mix(vec3(.61,.67,.64),vec3(.95,.86,.66),smoothstep(.49,.75,billow));
 COLOR=mix(background,cloud_color,cloud*.88);
 if(LIGHT0_ENABLED){
  float sun=max(dot(EYEDIR,LIGHT0_DIRECTION),0.0);
  COLOR+=vec3(.35,.25,.13)*pow(sun,32.0)+vec3(1.0,.81,.5)*smoothstep(.9995,.9998,sun);
 }
}
