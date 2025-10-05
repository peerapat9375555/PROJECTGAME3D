extends Node3D

var player_score: int = 0
@export var target_score: int = 10
@export var next_level_path: String = "res://scene/end.tscn"
@export var main_menu_path: String = "res://lessons_reference/video_16/MainMenu.tscn"

@onready var label: Label = $Label
@onready var death_menu: Control = $CanvasLayer/DeathMenu

func _ready() -> void:
	if death_menu:
		death_menu.main_menu_path = main_menu_path

	# ต่อสัญญาณ KillPlane อัตโนมัติ
	var kill_plane := get_node_or_null("KillPlane")
	if kill_plane and kill_plane is Area3D:
		(kill_plane as Area3D).body_entered.connect(_on_kill_plane_body_entered)

func increase_score() -> void:
	player_score += 1
	if label:
		label.text = "Score: %d" % player_score
	if player_score >= target_score:
		change_to_next_level()

func _on_kill_plane_body_entered(body: Node) -> void:
	# debug
	print("KillPlane hit: ", body.name)
	_show_death_menu("")

func _on_mob_spawner_3d_mob_spawned(mob: Node) -> void:
	if mob and mob.has_signal("died"):
		mob.died.connect(func():
			increase_score()
			if "global_position" in mob:
				do_poof(mob.global_position)
		)
	if "global_position" in mob:
		do_poof(mob.global_position)

func do_poof(mob_position: Vector3) -> void:
	const SMOKE_PUFF := preload("res://mob/smoke_puff/smoke_puff.tscn")
	var poof := SMOKE_PUFF.instantiate()
	add_child(poof)
	poof.global_position = mob_position

func change_to_next_level() -> void:
	if ResourceLoader.exists(next_level_path):
		get_tree().change_scene_to_file(next_level_path)
	else:
		push_error("Scene not found: %s" % next_level_path)

func _show_death_menu(reason: String = "") -> void:
	if death_menu and death_menu.has_method("show_menu"):
		death_menu.call("show_menu", reason)
	else:
		push_error("DeathMenu not found; fallback reload.")
		get_tree().reload_current_scene()
