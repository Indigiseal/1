shader_type canvas_item;

uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D noise_texture;
uniform float dissolve_edge_size : hint_range(0.0, 0.1) = 0.02;
uniform vec4 dissolve_edge_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Sample noise for dissolve pattern
    float noise = texture(noise_texture, UV).r;
    
    // Create dissolve effect
    float dissolve_alpha = step(dissolve_amount, noise);
    
    // Create edge effect
    float edge_factor = smoothstep(dissolve_amount - dissolve_edge_size, dissolve_amount, noise);
    vec4 edge_color = mix(tex_color, dissolve_edge_color, edge_factor);
    
    // Final color
    COLOR = mix(edge_color, tex_color, dissolve_alpha);
    COLOR.a *= dissolve_alpha;
}