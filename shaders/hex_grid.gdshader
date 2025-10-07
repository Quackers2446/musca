shader_type canvas_item;

uniform float hex_size : hint_range(0.01, 0.2) = 0.08;
uniform float hex_opacity : hint_range(0.0, 1.0) = 0.6;

// Create honeycomb hexagonal grid with taller hexagons
vec2 hex_coord(vec2 uv) {
    vec2 h = vec2(hex_size, hex_size * 0.8660254 * 1.5); // Make them 1.5x taller
    vec2 a = mod(uv, h) - h * 0.5;
    vec2 b = mod(uv - h * 0.5, h) - h * 0.5;
    return dot(a, a) < dot(b, b) ? a : b;
}

void fragment() {
    vec2 uv = UV;
    vec2 hex = hex_coord(uv);
    
    // Create honeycomb pattern - darker borders, lighter centers
    float dist_to_edge = length(hex) / hex_size;
    
    // Create hexagonal cell effect
    float hex_cell = smoothstep(0.0, 0.8, dist_to_edge);
    
    // Start with transparent
    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
    
    // Create honeycomb effect with rounded/curved appearance
    if (hex_cell > 0.0) {
        // Add rounded effect using distance from center
        float rounded_effect = pow(hex_cell, 2.0) * hex_opacity * 0.5;
        
        // Add slight curvature to simulate compound eye depth
        float curvature = sin(uv.x * 15.0) * cos(uv.y * 15.0) * 0.2;
        rounded_effect += curvature;
        
        color = vec4(0.0, 0.0, 0.0, rounded_effect);
    }
    
    // Subtle variation in each cell - just a tiny bit different
    float cell_id = floor(uv.x / hex_size) + floor(uv.y / (hex_size * 0.8660254 * 1.5)) * 100.0;
    float cell_variation = sin(cell_id * 0.1) * 0.05 + 0.95; // Very subtle variation
    
    // Apply subtle variation to the cell
    color.rgb *= cell_variation;
    
    // Add slight color variation to simulate compound eye
    color.r += sin(uv.x * 20.0) * 0.08;
    color.g += cos(uv.y * 20.0) * 0.08;
    color.b += sin((uv.x + uv.y) * 15.0) * 0.03;
    
    COLOR = color;
}
