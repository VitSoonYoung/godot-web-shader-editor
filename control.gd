extends Control

const GODOT_LOG_PATH := "user://logs/godot.log"
const MESSAGE_FINISHED_COMPILING := "Compile sucessfully!"
const MESSAGE_SHADER_ERROR := "SHADER ERROR: "
const MESSAGE_LINE_HEIGHT := 23.0 # 1 message line height
const MESSAGE_MAX_LINE := 10 # Show message up to X lines

enum MessageType {
	INFO,
	SUCCESS,
	WARNING,
	DANGER,
}

const messageTypeToColor: Dictionary[MessageType, String] = { # BBCode Color name
	MessageType.INFO: "gray",
	MessageType.SUCCESS: "green",
	MessageType.WARNING: "yellow",
	MessageType.DANGER: "red",
}

@onready var canvas_item_shader_view: ColorRect = %CanvasItemShaderView
@onready var check_box_auto_compile: CheckBox = %CheckBoxAutoCompile
@onready var code_edit: CodeEdit = %CodeEdit
@onready var label_message: RichTextLabel = %LabelMessage
@onready var shader_material := canvas_item_shader_view.material as ShaderMaterial
@onready var shader := shader_material.shader

@export var typing_color: Color
@export var symbol_color: Color
@export var function_color: Color
@export var member_variable_color: Color
@export var number_color: Color

var timer_log: Timer = Timer.new()
var syntax_highlighter := CodeHighlighter.new()
var log_file: FileAccess
var regex_find_shader_error_line := RegEx.new()
var current_error_line: int = 0

func _ready() -> void:
	highlight_shader_code()
	code_edit.text = shader.code
	regex_find_shader_error_line.compile("E\\s+(\\d+)->")
	check_compile_error()
	

func compile():
	shader = Shader.new()
	shader.code = code_edit.text
	shader_material.shader = shader
	check_compile_error()
	print(MESSAGE_FINISHED_COMPILING) # Use as a marker in Godot Logs to check compilation error

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("compile"):
		compile()

func _on_button_pressed() -> void:
	compile()

func _on_code_edit_text_changed() -> void:
	if check_box_auto_compile.button_pressed:
		compile()

func highlight_shader_code():
	syntax_highlighter.symbol_color = symbol_color
	syntax_highlighter.function_color = function_color
	syntax_highlighter.member_variable_color = member_variable_color
	syntax_highlighter.number_color = number_color
	
	var control_keywords = ["if", "else", "for", "while", "do", "return", "break", "continue", "discard"]
	var type_keywords = ["void", "bool", "int", "float", "vec2", "vec3", "vec4", "mat2", "mat3", "mat4", "sampler2D", "samplerCube"]
	var shader_keywords = ["shader_type", "uniform", "varying", "attribute", "const", "in", "out", "inout"]
	var builtin_functions = ["texture", "mix", "dot", "cross", "normalize", "length", "distance", "reflect", "sin", "cos", "tan", "abs", "min", "max", "clamp", "step", "smoothstep"]

	for keyword in control_keywords:
		syntax_highlighter.add_keyword_color(keyword, function_color) 
	
	for keyword in type_keywords:
		syntax_highlighter.add_keyword_color(keyword, typing_color) 
			
	for keyword in shader_keywords:
		syntax_highlighter.add_keyword_color(keyword, function_color)
			
	for keyword in builtin_functions:
		syntax_highlighter.add_keyword_color(keyword, function_color)
		
	code_edit.syntax_highlighter = syntax_highlighter
	
	
func get_shader_logs() -> PackedStringArray:
	if not log_file:
		log_file = FileAccess.open(GODOT_LOG_PATH, FileAccess.READ)
		
		if log_file == null:
			print("get_shader_logs() ", GODOT_LOG_PATH, " is not readable")
			return []
	
	
	var lines: PackedStringArray = log_file.get_as_text().split("\n")
	
	#var max_line_count: int = code_edit.text.count("\n") + 10
	#lines = lines.slice(max(lines.size() - max_line_count, 0), lines.size() - 1)
	return lines
	
func set_message(message: String, message_type: MessageType = MessageType.INFO):
	label_message.text = "[color=%s]%s[/color]" % [messageTypeToColor[message_type], message]
	
	# Auto scroll to bottom and sizing
	var lines: PackedStringArray = message.split("\n")
	label_message.scroll_to_line(lines.size() - 1)
	label_message.custom_minimum_size.y = MESSAGE_LINE_HEIGHT * clamp(lines.size(), 2, MESSAGE_MAX_LINE)
	
	
func check_compile_error():
	# Reset error
	if current_error_line != null:
		print("current_error_line", current_error_line)
		code_edit.set_line_background_color(current_error_line, Color(0, 0, 0, 0))
		current_error_line = -1
		
	# Find error line number and compilation error message
	var lines: PackedStringArray = get_shader_logs()

	for line_i: int in range(lines.size() -1, 0, -1):
		var line: String = lines[line_i]
		print(line_i, " ", line)
		
		if line == MESSAGE_FINISHED_COMPILING:
			print("No compilation error")
			break
			
		if line.contains(MESSAGE_SHADER_ERROR):
			set_message(line.replace(MESSAGE_SHADER_ERROR, ""), MessageType.DANGER)
			
		var result = regex_find_shader_error_line.search(line)
		
		if result:
			current_error_line = result.get_string(1).to_int() - 1
			code_edit.set_line_background_color(current_error_line, Color(1, 0.5, 0.5, 0.5))  # light red
			#print("Found error line ", current_error_line)
			break
			
	if current_error_line == -1:
		set_message(MESSAGE_FINISHED_COMPILING, MessageType.SUCCESS)
		
	print("check_compile_error() Finished checking")
