extends Control

# 🔹 พาธไปยังฉากเกมจริง
@export var next_scene_path: String = "res://lessons_reference/video_16/testmap40.tscn"
@onready var video: VideoStreamPlayer = %Video

func _ready() -> void:
	# ให้เล่นอัตโนมัติถ้ายังไม่ได้ตั้ง autoplay
	if not video.autoplay:
		video.play()
	video.finished.connect(_on_video_finished)

func _unhandled_input(event: InputEvent) -> void:
	# ให้กด Esc หรือคลิกเพื่อข้ามวิดีโอ
	if event.is_action_pressed("ui_cancel") or (event is InputEventMouseButton and event.pressed):
		_on_video_finished()

func _on_video_finished() -> void:
	get_tree().change_scene_to_file(next_scene_path)
