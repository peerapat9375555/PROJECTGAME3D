extends Control

@export var main_menu_path: String = "res://lessons_reference/video_16/MainMenu.tscn"

@onready var btn_restart: Button = %BtnRestart
@onready var btn_main: Button = %BtnMainMenu
@onready var lbl_reason: Label = %LblReason

func _ready() -> void:
	visible = false
	# ให้เมนูทำงานตอน paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	btn_restart.pressed.connect(_on_restart)
	btn_main.pressed.connect(_on_main_menu)

func show_menu(reason: String = "") -> void:
	if lbl_reason:
		lbl_reason.text = reason
	visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_menu() -> void:
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu() -> void:
	get_tree().paused = false
	if ResourceLoader.exists(main_menu_path):
		get_tree().change_scene_to_file(main_menu_path)
