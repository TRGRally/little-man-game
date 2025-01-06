shader_type canvas_item;

//uniforms for color replacement
uniform vec4 masque = vec4(0.1, 0.85, 1.0, 0.1);
uniform vec4 outline_color = vec4(0.1, 0.85, 1.0, 0.1);
//hard-coded value for outline
const int width = 0; //this can be made float if we dont care about pixel perfect



void fragment() {
    vec4 base_color = texture(TEXTURE, UV);

    // Apply color replacement
    base_color.rgb = normalize(masque.rgb);

	if (base_color.a != 0.0) {
		base_color.a = masque.a;
	}

    float pixel_size_x = 1.0 / float(textureSize(TEXTURE, 0).x);
    float pixel_size_y = 1.0 / float(textureSize(TEXTURE, 0).y);
    vec2 pixel_size = vec2(pixel_size_x, pixel_size_y);

    // Inside outline logic
    vec4 resulting_color = outline_color;


	COLOR = base_color;

}
