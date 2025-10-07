shader_type canvas_item;

uniform float hex_size : hint_range(0.01, 0.2) = 0.08;
uniform float hex_opacity : hint_range(0.0, 1.0) = 0.3;

// Simple hexagonal pattern
vec2 hex_coord(vec2 uv) {
    vec2 h = vec2(hex_size, hex_size * 0.8660254);
    vec2 a = mod(uv, h) - h * 0.5;
    vec2 b = mod(uv - h * 0.5, h) - h * 0.5;
    return dot(a, a) < dot(b, b) ? a : b;
}

void fragment() {
    vec2 uv = UV;
    vec2 hex = hex_coord(uv);
    
    // Create hexagonal grid - only show borders, not fill
    float hex_mask = smoothstep(0.0, 0.05, length(hex) / hex_size);
    
    // Start with transparent
    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
    
    // Only add subtle hexagonal border effect
    if (hex_mask > 0.0) {
        color = vec4(0.0, 0.0, 0.0, hex_mask * hex_opacity * 0.3);
    }
    
    // Add very subtle color variation to simulate compound eye
    color.r += sin(uv.x * 20.0) * 0.01;
    color.g += cos(uv.y * 20.0) * 0.01;
    
    COLOR = color;
}
