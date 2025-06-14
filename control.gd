extends Control

@onready var canvas_item_shader_view: ColorRect = %CanvasItemShaderView
@onready var text_edit: TextEdit = $HBoxContainer/Control3/TextEdit
@onready var shader_material := canvas_item_shader_view.material as ShaderMaterial
@onready var shader := shader_material.shader
@onready var check_box_auto_compile: CheckBox = $HBoxContainer/Control3/MarginContainer/HBoxContainer/CheckBoxAutoCompile

func _ready() -> void:
	text_edit.text = shader.code

func compile():
	shader = Shader.new()
	shader.code = text_edit.text
	shader_material.shader = shader
	print("Finished Compiling")
	
func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("compile"):
		compile()

func _on_button_pressed() -> void:
	compile()
	
func _on_text_edit_text_changed() -> void:
	if check_box_auto_compile.button_pressed:
		compile()
		
