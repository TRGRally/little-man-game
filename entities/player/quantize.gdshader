shader_type canvas_item;
render_mode unshaded;

uniform sampler2D TextureMap;
uniform int NumDivisions = 1;

void fragment()
{
    // quantize the UV value to a stepped value
    // based on number of divisions.
    // the 0.5 added ensures we sample from
    // the centre of the "pixel"
    vec2 st = (vec2(ivec2( UV * float(NumDivisions) ))+0.5)/float(NumDivisions);
    // read the texture using the highest LOD to avoid
    // filtering problems on discontinuities
    vec4 tex_col = textureLod( TextureMap, st, 0 );
    // set the output
    COLOR = tex_col;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
