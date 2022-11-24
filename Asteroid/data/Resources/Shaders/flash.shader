shader_type canvas_item;

uniform float progress : hint_range(0,1);

uniform vec4 flash_color : hint_color = vec4(1.0);

void fragment(){
	vec4 color = texture(TEXTURE,UV);	
	
	color.rgb = mix(color.rgb, flash_color.rgb,progress);
	COLOR = color;
}