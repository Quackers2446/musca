shader_type canvas_item;

uniform float hex_size : hint_range(0.01, 0.2) = 0.08;
uniform float hex_opacity : hint_range(0.0, 1.0) = 0.3;

// Create hexagonal grid pattern
vec2 hex_coord(vec2 uv) {
    vec2 h = vec2(hex_size, hex_size * 0.8660254);
    vec2 a = mod(uv, h) - h * 0.5;
    vec2 b = mod(uv - h * 0.5, h) - h * 0.5;
    return dot(a, a) < dot(b, b) ? a : b;
}

void fragment() {
    vec2 uv = UV;
    vec2 hex = hex_coord(uv);
    
    // Create hexagonal grid by checking distance to edges
    float dist_to_edge = length(hex) / hex_size;
    
    // Create hexagonal borders - only at the edges
    float hex_border = smoothstep(0.0, 0.02, dist_to_edge) - smoothstep(0.02, 0.04, dist_to_edge);
    
    // Start with transparent
    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
    
    // Add hexagonal border lines
    if (hex_border > 0.0) {
        color = vec4(0.0, 0.0, 0.0, hex_border * hex_opacity);
    }
    
    COLOR = color;
}
