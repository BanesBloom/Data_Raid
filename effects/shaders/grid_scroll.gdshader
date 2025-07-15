shader_type canvas_item;

uniform float columns = 16.0;
uniform float rows = 16.0;
uniform float grid_width = 0.05;
uniform vec4 grid_color : source_color = vec4(1, 1, 1, 1) ;
uniform vec4 base_color : source_color = vec4(0, 0, 0, 1);

uniform vec2 tiling = vec2(1.0, 1.0);
uniform vec2 offset;

void vertex(){
	UV = UV * tiling + offset * TIME;
}

void fragment() {
    vec2 grid = fract(vec2(UV.x * columns, UV.y * rows));
	vec2 bottom_left = step(vec2(grid_width), grid);
	vec2 top_right = step(vec2(grid_width), 1.0 - grid);
	COLOR = grid_color - (bottom_left.x * bottom_left.y * top_right.x * top_right.y);
	if (COLOR != grid_color){
		COLOR = base_color;
	}
}
