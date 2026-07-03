shader_type canvas_item;

uniform bool cull_backface = true;
uniform bool use_front = true;
uniform float fov : hint_range(1, 179) = 90.0;
uniform float rot_y_deg : hint_range(-360, 360) = 0.0;
uniform float rot_x_deg : hint_range(-360, 360) = 0.0;
uniform float inset : hint_range(0, 1) = 0.0;
uniform sampler2D text : hint_normal;

// --- new blur uniforms ---
uniform float corner_blur_strength : hint_range(0.0, 2.0) = 0.4; // max blur radius in UV units
uniform float corner_blur_size : hint_range(0.0, 1.0) = 0.25;    // how far from corners the blur extends
uniform int blur_samples : hint_range(1, 16) = 8;                // number of blur taps (higher = smoother)
uniform float edge_softness : hint_range(0.0, 0.5) = 0.02;       // soft border for the whole quad

varying vec2 offset;
varying vec3 world_pos_3d;

void vertex() {
	float rot_y_rad = radians(rot_y_deg);
	float rot_x_rad = radians(rot_x_deg);

	float sin_y = sin(rot_y_rad), cos_y = cos(rot_y_rad);
	float sin_x = sin(rot_x_rad), cos_x = cos(rot_x_rad);

	mat3 rotation_matrix;
	rotation_matrix[0] = vec3(cos_y, 0.0, -sin_y);
	rotation_matrix[1] = vec3(sin_y * sin_x, cos_x, cos_y * sin_x);
	rotation_matrix[2] = vec3(sin_y * cos_x, -sin_x, cos_y * cos_x);

	float perspective_scale = tan(radians(fov) * 0.5);
	world_pos_3d = rotation_matrix * vec3(UV - 0.5, 0.5 / perspective_scale);

	float depth_scale = (0.5 / perspective_scale) + 0.5;
	world_pos_3d.xy *= depth_scale * rotation_matrix[2].z;
	offset = depth_scale * rotation_matrix[2].xy;

	VERTEX += (UV - 0.5) / TEXTURE_PIXEL_SIZE * perspective_scale * (1.0 - inset);
}

void fragment() {
	if (cull_backface && world_pos_3d.z <= 0.0) discard;

	vec2 projected_uv = (world_pos_3d.xy / world_pos_3d.z) - offset + 0.5;

	// --- compute corner distance (0..~0.7) ---
	float corner_dist = min(
		min(distance(projected_uv, vec2(0.0, 0.0)), distance(projected_uv, vec2(1.0, 0.0))),
		min(distance(projected_uv, vec2(0.0, 1.0)), distance(projected_uv, vec2(1.0, 1.0)))
	);

	// blur radius: full strength at the corners, zero outside corner_blur_size
	float blur_radius = corner_blur_strength * (1.0 - smoothstep(0.0, corner_blur_size, corner_dist));

	// soft alpha border for the whole quad (avoids hard clipping)
	float alpha_border = smoothstep(0.0, edge_softness, projected_uv.x)
	                   * smoothstep(0.0, edge_softness, 1.0 - projected_uv.x)
	                   * smoothstep(0.0, edge_softness, projected_uv.y)
	                   * smoothstep(0.0, edge_softness, 1.0 - projected_uv.y);

	// --- blur sampling ---
	vec4 blurred = vec4(0.0);
	int samples = max(1, blur_samples);
	float total_weight = 0.0;

	for (int i = 0; i < samples; i++) {
		float angle = 6.2831853 * float(i) / float(samples); // even angular spread
		vec2 offset_dir = vec2(cos(angle), sin(angle));
		// sample two points along the radius (inner + outer) for a soft disc
		for (int j = 0; j < 2; j++) {
			float r = blur_radius * (float(j) + 0.5) / 2.0;
			vec2 sample_uv = projected_uv + offset_dir * r;
			// clamp to avoid sampling garbage outside the texture
			sample_uv = clamp(sample_uv, vec2(0.0), vec2(1.0));
			float w = 1.0;
			blurred += texture(TEXTURE, sample_uv) * w;
			total_weight += w;
		}
	}
	blurred /= total_weight;

	// sample the original (sharp) texture
	vec2 sample_uv = clamp(projected_uv, vec2(0.0), vec2(1.0));
	vec4 sharp = texture(TEXTURE, sample_uv);

	// mix between sharp and blurred based on the same corner distance
	float mix_factor = smoothstep(0.0, corner_blur_size * 0.7, corner_dist); // sharpens quickly when away from corner
	vec4 color = mix(blurred, sharp, mix_factor);

	// apply face‑flip if needed
	if (!use_front)
		color = texture(TEXTURE, vec2(1.0 - sample_uv.x, sample_uv.y));
		// Note: flipping is applied to the sharp texture here; you may also blur the flipped version if desired.
		// For simplicity the blur is always done on the original orientation.

	color.a *= alpha_border;
	COLOR = color;
	COLOR.a *= 0.5;
}