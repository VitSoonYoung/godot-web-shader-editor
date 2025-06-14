extends Control

@onready var canvas_item_shader_view: ColorRect = %CanvasItemShaderView
@onready var check_box_auto_compile: CheckBox = %CheckBoxAutoCompile
@onready var code_edit: CodeEdit = %CodeEdit
@onready var shader_material := canvas_item_shader_view.material as ShaderMaterial
@onready var shader := shader_material.shader

var syntax_highlighter := CodeHighlighter.new()

func _ready() -> void:
	highlight_shader_code()
	code_edit.text = shader.code

func compile():
	shader = Shader.new()
	shader.code = code_edit.text
	shader_material.shader = shader
	print("Finished Compiling")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("compile"):
		compile()

func _on_button_pressed() -> void:
	compile()

func _on_code_edit_text_changed() -> void:
	if check_box_auto_compile.button_pressed:
		compile()

func highlight_shader_code():
	syntax_highlighter.symbol_color = Color(0.851, 0.851, 0.851) 
	syntax_highlighter.function_color = Color(0.863, 0.863, 0.549) 
	syntax_highlighter.member_variable_color = Color(0.376, 0.749, 0.871)
	syntax_highlighter.number_color = Color(0.710, 0.867, 0.678)
	
	var control_keywords = ["if", "else", "for", "while", "do", "return", "break", "continue", "discard"]
	var type_keywords = ["void", "bool", "int", "float", "vec2", "vec3", "vec4", "mat2", "mat3", "mat4", "sampler2D", "samplerCube"]
	var shader_keywords = ["shader_type", "uniform", "varying", "attribute", "const", "in", "out", "inout"]
	var builtin_functions = ["texture", "mix", "dot", "cross", "normalize", "length", "distance", "reflect", "sin", "cos", "tan", "abs", "min", "max", "clamp", "step", "smoothstep"]

	for keyword in control_keywords:
		syntax_highlighter.add_keyword_color(keyword, Color(0.302, 0.678, 0.678)) 
	
	for keyword in type_keywords:
		syntax_highlighter.add_keyword_color(keyword, Color(0.863, 0.863, 0.549)) 
			
	for keyword in shader_keywords:
		syntax_highlighter.add_keyword_color(keyword, Color(0.863, 0.863, 0.549))
			
	for keyword in builtin_functions:
		syntax_highlighter.add_keyword_color(keyword, Color(0.863, 0.863, 0.549))
		
	code_edit.syntax_highlighter = syntax_highlighter
	
