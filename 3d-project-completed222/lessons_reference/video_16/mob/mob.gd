extends RigidBody3D
signal died

@export var damage: int = 10
@export var speed_min: float = 2.0
@export var speed_max: float = 4.0
@export var CONTACT_DAMAGE_INTERVAL: float = 0.8

var speed: float
var health: int = 3

@onready var bat_model: Node3D = get_node_or_null("bat_model")
@onready var timer: Timer = get_node_or_null("Timer")
@onready var player: Node3D = get_node("/root/Game/Player")
@onready var damage_area: Area3D = get_node_or_null("DamageArea")

var _player_inside: bool = false
var _damage_tick: Timer

func _ready() -> void:
	add_to_group("Mob")
	speed = randf_range(speed_min, speed_max)

	if damage_area:
		damage_area.body_entered.connect(_on_damage_area_body_entered)
		damage_area.body_exited.connect(_on_damage_area_body_exited)
	else:
		push_warning("Add Area3D named 'DamageArea' + CollisionShape3D under Mob.")

	_damage_tick = Timer.new()
	_damage_tick.name = "DamageTick"
	_damage_tick.one_shot = false
	_damage_tick.wait_time = CONTACT_DAMAGE_INTERVAL
	add_child(_damage_tick)
	_damage_tick.timeout.connect(_on_damage_tick_timeout)

func _physics_process(_delta: float) -> void:
	var direction: Vector3 = global_position.direction_to(player.global_position)
	direction.y = 0.0
	linear_velocity = direction * speed
	if bat_model:
		bat_model.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI

func _on_damage_area_body_entered(body: Node) -> void:
	# 1) ชนผู้เล่น → ทำดาเมจ และเริ่มติ๊กซ้ำ
	if body == player:
		_player_inside = true
		if player.has_method("take_damage"):
			player.take_damage(damage)
		if _damage_tick.is_stopped():
			_damage_tick.start()
		return

	# 2) ชนกระสุน → โดนยิง
	if body.is_in_group("Bullet"):
		take_damage()
		if not body.is_queued_for_deletion():
			body.queue_free()

func _on_damage_area_body_exited(body: Node) -> void:
	if body == player:
		_player_inside = false
		_damage_tick.stop()

func _on_damage_tick_timeout() -> void:
	if _player_inside and player and player.has_method("take_damage"):
		player.take_damage(damage)

func take_damage() -> void:
	if health <= 0:
		return
	if bat_model and bat_model.has_method("hurt"):
		bat_model.hurt()
	health -= 1

	if health == 0:
		set_physics_process(false)
		gravity_scale = 1.0
		var direction := player.global_position.direction_to(global_position)
		var random_upward_force := Vector3.UP * randf() * 5.0
		apply_central_impulse(direction.rotated(Vector3.UP, randf_range(-0.2, 0.2)) * 10.0 + random_upward_force)
		if timer:
			timer.start()
		_damage_tick.stop()

func _on_timer_timeout() -> void:
	queue_free()
	died.emit()
