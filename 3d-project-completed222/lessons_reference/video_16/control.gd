extends Control

@export_file("*.tscn")
var main_menu_path: String = "res://lessons_reference/video_16/MainMenu.tscn"

@onready var btn_restart: Button = $CenterContainer/VBoxContainer/BtnRestart
@onready var btn_main: Button    = $CenterContainer/VBoxContainer/BtnMainMenu
@onready var lbl_reason: Label   = $CenterContainer/VBoxContainer/LblReason

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_restart.pressed.connect(_on_restart)
	btn_main.pressed.connect(_on_main_menu)

func show_menu(reason: String = "") -> void:
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
	# ✅ ปลด pause ก่อน
	get_tree().paused = false

	# ✅ เช็ก path เมนูหลัก
	if main_menu_path == "" or not ResourceLoader.exists(main_menu_path):
		push_error("DeathMenu: main_menu_path not valid: " + main_menu_path)
		return

	# ✅ โหลดฉากใหม่อย่างปลอดภัย
	var scene := load(main_menu_path)
	if scene is PackedScene:
		get_tree().change_scene_to_packed(scene)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		push_error("DeathMenu: cannot load PackedScene: " + main_menu_path)
