shader_type canvas_item;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (UV.x > 0.01 && UV.x < 0.99 && UV.y > 0.02 && UV.y < 0.98) {
		COLOR = vec4(vec3(-UV.y), 1.0);
		COLOR = vec4(0.149 * UV.y, 0.152* UV.y, 0.181* UV.y, 1.0);
		COLOR = max(COLOR, vec4(0.328 * UV.y - 0.3, 0.555 * UV.y - 0.3, 0.796 * UV.y - 0.3, 1.0));
	} else {
		COLOR = vec4(0.0, 0.127, 0.368, 1.0);
	}
}