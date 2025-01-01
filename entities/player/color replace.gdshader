shader_type canvas_item;

// Uniforms for color replacement
uniform vec3 masque = vec3(0.1, 0.85, 1.0);

// Hard-coded values for outline
const int width = 1; // Outline width
const vec4 outline_color = vec4(0.0, 0.6, 1.0, 1.0);
const float flickering_speed = 20.0; // Flickering speed
const float minimal_flickering_alpha = 0.6; // Minimal alpha for flickering


void fragment() {
    vec4 base_color = texture(TEXTURE, UV);

    // Apply color replacement
    base_color.rgb = normalize(masque);

    float pixel_size_x = 1.0 / float(textureSize(TEXTURE, 0).x);
    float pixel_size_y = 1.0 / float(textureSize(TEXTURE, 0).y);
    vec2 pixel_size = vec2(pixel_size_x, pixel_size_y);

    // Outline logic
    bool is_outline = false;
    vec4 resulting_color = outline_color;

    if (base_color.a == 0.0) {
        // Check only cardinal directions for pixel-perfect outline
        vec2 offsets[4] = vec2[](vec2(-1.0, 0.0), vec2(1.0, 0.0), vec2(0.0, -1.0), vec2(0.0, 1.0));
        for (int i = 0; i < 4; i++) {
            vec4 neighbor_color = texture(TEXTURE, UV + offsets[i] * pixel_size);
            if (neighbor_color.a > 0.0) {
                is_outline = true;
                float alpha_norm = (sin(TIME * flickering_speed) + 1.2) * 0.5;
                alpha_norm = (1.0 - minimal_flickering_alpha) * alpha_norm + minimal_flickering_alpha;
                resulting_color.a = outline_color.a * alpha_norm; // Adjust alpha with flickering
                break;
            }
        }
    }

    // Set the final color
    if (is_outline) {
        COLOR = resulting_color;
    } else {
        COLOR = base_color;
    }
}
