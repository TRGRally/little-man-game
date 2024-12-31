shader_type canvas_item;
render_mode unshaded;

uniform vec3 color_to_replace = vec3(95.0, 204.0, 228.0);
uniform vec3 masque = vec3(500.0,500.0,500.0);
uniform float threshold = 0.31;

void fragment() {
    COLOR = texture(TEXTURE, UV);
    //if (distance(COLOR.rgb, normalize(color_to_replace)) < threshold) {
        // Replace the color
        //COLOR.rgb = normalize(masque);
    //}
	COLOR.rgb = normalize(masque);
}