shader_type spatial;
uniform sampler2D albedo_texture;
uniform float shadow_threshold : hint_range(0.0, 1.0, 0.01) = 0.5;

void vertex() {
    // Called for every vertex the material is visible on.
}


void light() {
    vec3 light_dir;

    // The rest of your toon shading logic remains the same
    float n_dot_l = dot(NORMAL, light_dir);

    vec3 final_light;
    if (n_dot_l > shadow_threshold) { // Using your uniform for flexibility
        final_light = LIGHT_COLOR;
    } else {
        final_light = LIGHT_COLOR * 0.5;
    }

    DIFFUSE_LIGHT = final_light;
}

void fragment() {
    // Use the imported albedo texture for the base color
    vec4 base_color = texture(albedo_texture, UV);
    ALBEDO = base_color.rgb;
}