shader_type canvas_item;

uniform float hex_size : hint_range(0.01, 0.1) = 0.02;
uniform float distortion_strength : hint_range(0.0, 1.0) = 0.3;
uniform float color_shift : hint_range(0.0, 1.0) = 0.2;
uniform bool enable_hex_filter = true;

// Hexagonal grid function
vec2 hex_coord(vec2 uv) {
    vec2 h = vec2(hex_size, hex_size * 0.8660254); // sqrt(3)/2
    vec2 a = mod(uv, h) - h * 0.5;
    vec2 b = mod(uv - h * 0.5, h) - h * 0.5;
    return dot(a, a) < dot(b, b) ? a : b;
}

// Create hexagonal pattern
float hex_pattern(vec2 uv) {
    vec2 hex = hex_coord(uv);
    return smoothstep(0.0, 0.1, length(hex) / hex_size);
}

// Compound eye effect
vec4 compound_eye_effect(vec4 color, vec2 uv) {
    if (!enable_hex_filter) return color;
    
    // Create hexagonal grid
    float hex_mask = hex_pattern(uv);
    
    // Add slight distortion to simulate compound eye structure
    vec2 distortion = vec2(
        sin(uv.x * 50.0) * 0.01,
        cos(uv.y * 50.0) * 0.01
    ) * distortion_strength;
    
    // Sample with distortion
    vec2 distorted_uv = uv + distortion;
    vec4 distorted_color = texture(TEXTURE, distorted_uv);
    
    // Apply hexagonal mask
    vec4 hex_color = mix(color, distorted_color, hex_mask);
    
    // Add color shift to simulate different photoreceptor types
    hex_color.r += color_shift * 0.1;
    hex_color.g += color_shift * 0.05;
    hex_color.b -= color_shift * 0.1;
    
    return hex_color;
}

void fragment() {
    vec2 uv = UV;
    vec4 color = texture(TEXTURE, uv);
    
    // Apply compound eye effect
    color = compound_eye_effect(color, uv);
    
    COLOR = color;
}
