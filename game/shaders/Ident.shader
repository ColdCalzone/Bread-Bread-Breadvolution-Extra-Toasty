// Good enough, I can make it better in future projects

shader_type canvas_item;

uniform float point = 0.5;
uniform float time = -1.0;
uniform float speed = 1.5;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	// after mid-point
	if (UV.x > point + sin(time * speed)) {
		COLOR.a = 
		// Make it fade towards the right
		((1.0 - UV.x)  + 
		// Move it by the SIN of time * speed
		(sin(time * speed) * 2.0) + point) + 
		// Shear
		(0.5 - UV.y * point);
	} 
	// before
	else {
		COLOR.a = 
		
		((UV.x) - 
		
		(sin(time * speed) * 2.0)) + 
		// Shear
		(0.5 + UV.y * point);
	}
}