shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	//original_color.rgb = vec3(original_color.r + original_color.g + original_color.b) / 3.0;
	original_color.rgb = (original_color.rgb + vec3(0.9,0,0)) / 1.5;
	COLOR = original_color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
