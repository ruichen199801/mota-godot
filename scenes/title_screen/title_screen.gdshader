shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.7;
uniform float softness : hint_range(0.0, 1.0) = 0.8;
uniform vec4 dark_color : source_color = vec4(0.0, 0.0, 0.0, 0.85);

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float vignette = smoothstep(radius - softness, radius, dist);
	COLOR = vec4(dark_color.rgb, dark_color.a * vignette);
}
