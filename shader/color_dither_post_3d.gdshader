shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// The color palette
const vec3 PALETTE[4] = vec3[4](
    vec3(0.059, 0.059, 0.106), // #0f0f1b
    vec3(0.337, 0.353, 0.459), // #565a75
    vec3(0.776, 0.718, 0.745), // #c6b7be
    vec3(0.980, 0.984, 0.965)  // #fafbf6
);

// 8x8 Bayer dithering matrix
const float BAYER_MATRIX[64] = float[64](
    0.0/64.0, 32.0/64.0, 8.0/64.0, 40.0/64.0, 2.0/64.0, 34.0/64.0, 10.0/64.0, 42.0/64.0,
    48.0/64.0, 16.0/64.0, 56.0/64.0, 24.0/64.0, 50.0/64.0, 18.0/64.0, 58.0/64.0, 26.0/64.0,
    12.0/64.0, 44.0/64.0, 4.0/64.0, 36.0/64.0, 14.0/64.0, 46.0/64.0, 6.0/64.0, 38.0/64.0,
    60.0/64.0, 28.0/64.0, 52.0/64.0, 20.0/64.0, 62.0/64.0, 30.0/64.0, 54.0/64.0, 22.0/64.0,
    3.0/64.0, 35.0/64.0, 11.0/64.0, 43.0/64.0, 1.0/64.0, 33.0/64.0, 9.0/64.0, 41.0/64.0,
    51.0/64.0, 19.0/64.0, 59.0/64.0, 27.0/64.0, 49.0/64.0, 17.0/64.0, 57.0/64.0, 25.0/64.0,
    15.0/64.0, 47.0/64.0, 7.0/64.0, 39.0/64.0, 13.0/64.0, 45.0/64.0, 5.0/64.0, 37.0/64.0,
    63.0/64.0, 31.0/64.0, 55.0/64.0, 23.0/64.0, 61.0/64.0, 29.0/64.0, 53.0/64.0, 21.0/64.0
);

// Get the threshold value from the Bayer matrix
float get_threshold(vec2 pixel_pos) {
    int x = int(mod(pixel_pos.x, 8.0));
    int y = int(mod(pixel_pos.y, 8.0));
    return BAYER_MATRIX[y * 8 + x];
}

// Find the closest color in the palette
vec3 find_closest_color(vec3 color, float threshold) {
    // Calculate luminance
    float lum = dot(color, vec3(0.299, 0.587, 0.114));
    
    // Map luminance to appropriate color index
    // We have 4 colors, so we need to map to indices 0-3
    float scaled_lum = lum * 3.0;
    
    // Apply dithering
    int lower_idx = int(floor(scaled_lum));
    int upper_idx = min(lower_idx + 1, 3);
    
    // Add threshold to determine whether to use upper or lower color
    float frac_part = fract(scaled_lum);
    
    // Use the threshold to determine the color
    if (frac_part < threshold) {
        return PALETTE[lower_idx];
    } else {
        return PALETTE[upper_idx];
    }
}

void fragment() {
    // Get screen texture color
    vec3 screen_color = texture(screen_texture, SCREEN_UV).rgb;
    
    // Get the threshold value from the Bayer matrix
    float threshold = get_threshold(FRAGCOORD.xy);
    
    // Find the closest color in the palette using dithering
    vec3 dithered_color = find_closest_color(screen_color, threshold);
    
    // Output the dithered color
    COLOR.rgb = dithered_color;
    COLOR.a = 1.0;  // Ensure full opacity
}