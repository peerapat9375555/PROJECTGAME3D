extends Control

# 🔹 พาธซีนที่มีวีดีโอ (Cutscene Scene)
@export var cutscene_path: String = "res://lessons_reference/video_16/cutscene.tscn"

@onready var btn_start: Button = $BtnStart

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	process_mode = Node.PROCESS_MODE_ALWAYS
	btn_start.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	# 🔸 เมื่อกดปุ่ม Start จะไปที่ฉากวีดีโอก่อน
	get_tree().change_scene_to_file(cutscene_path)
