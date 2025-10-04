extends Control

@export var game_scene_path: String = "res://lessons_reference/video_16/game.tscn"
@onready var btn_start: Button = %BtnStart

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	btn_start.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(game_scene_path)
