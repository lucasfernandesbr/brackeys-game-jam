shader_type canvas_item;
render_mode blend_mix;

uniform vec2  light_pos = vec2(0.5, -0.05);
uniform vec4  light_color : source_color = vec4(1.0, 0.95, 0.8, 1.0);
uniform float light_intensity : hint_range(0.0, 1.0) = 0.35;
uniform float cone_spread     : hint_range(0.1, 1.5) = 0.65;
uniform float top_softness    : hint_range(0.1, 1.5) = 0.45;
uniform vec4  shadow_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float shadow_strength : hint_range(0.0, 1.0) = 0.55;
uniform float shadow_start    : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	float half_width = cone_spread * (0.4 + UV.y);
	float horiz = 1.0 - smoothstep(0.0, half_width, abs(UV.x - light_pos.x));
	float vert  = 1.0 - smoothstep(0.0, top_softness, UV.y - light_pos.y);
	float light_mask = clamp(horiz * vert, 0.0, 1.0) * light_intensity;

	float shade = smoothstep(shadow_start, 1.0, UV.y) * shadow_strength;
	shade *= (1.0 - clamp(horiz, 0.0, 1.0) * 0.6);

	vec4 col = vec4(shadow_color.rgb, shade);
	col.rgb  = mix(col.rgb, light_color.rgb, light_mask);
	col.a    = clamp(col.a + light_mask, 0.0, 1.0);
	COLOR = col;
}
