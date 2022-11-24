shader_type canvas_item;

uniform float speed : hint_range(1,10);

uniform vec2 distortion = vec2(0,2);

void vertex(){
	vec2 vertex = VERTEX;
	
	vec2 final_vertex = vertex + distortion * cos(TIME * speed);
	
	VERTEX = final_vertex;
}