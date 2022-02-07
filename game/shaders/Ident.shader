// Good enough, I can make it better in future projects

shader_type canvas_item;

uniform float time = 0.0;
uniform float speed = 3.0;
uniform float delay = 3.0;
uniform float base_alpha = 0.3;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if(UV.x + UV.y > 1.0 + (cos(time + delay) * speed)) {
		COLOR.a = (2.0 + (cos(time + delay) * speed)) - (UV.x + UV.y) + base_alpha;
	}
	if(UV.x + UV.y < 1.0 + (cos(time + delay) * speed)) {
		COLOR.a = -(cos(time + delay) * speed) + (UV.x + UV.y) + base_alpha;
	}
}
