extends CharacterBody3D

<<<<<<< Updated upstream
@onready var animation: AnimationPlayer = $gobot/AnimationPlayer2
var _is_jumping: bool = false
=======
# ลาก .tscn ของกระสุนมาใส่ใน Inspector ช่องนี้
@export var bullet_scene: PackedScene
>>>>>>> Stashed changes

# ---------- Config ----------
@export var MAX_HP: int = 100
@export var CONTACT_DAMAGE: int = 10
@export var INVINCIBLE_TIME: float = 0.6
@export var SPEED: float = 5.5
@export var GRAVITY: float = 20.0
@export var JUMP_FORCE: float = 10.0

var hp: int = MAX_HP
var _invincible: bool = false

# ---------- Node refs (null-safe) ----------
@onready var cam: Camera3D = get_node_or_null("Camera3D")
@onready var marker: Node3D = get_node_or_null("Marker3D")
@onready var shoot_timer: Timer = get_node_or_null("Timer")               # คูลดาวน์ยิง (ถ้ามี)
@onready var hurt_timer: Timer = get_node_or_null("HurtTimer")            # กันโดนซ้ำ (จะสร้างให้อัตโนมัติถ้าไม่มี)
@onready var health_bar: ProgressBar = get_node_or_null("HealthBar")
@onready var shoot_sfx: AudioStreamPlayer = get_node_or_null("AudioStreamPlayer")  # มี/ไม่มีได้

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if marker:
		marker.rotation_degrees.y += 2.0

<<<<<<< Updated upstream
	# เล่น Idle ตอนเริ่ม
	if animation and animation.has_animation("shoot"):
		animation.play("shoot")
=======
	if health_bar:
		health_bar.max_value = MAX_HP
		health_bar.value = hp
>>>>>>> Stashed changes

	# ถ้าไม่มี HurtTimer ให้สร้างให้เลย
	if hurt_timer == null:
		hurt_timer = Timer.new()
		hurt_timer.name = "HurtTimer"
		add_child(hurt_timer)
	hurt_timer.one_shot = true
	hurt_timer.wait_time = INVINCIBLE_TIME
	if not hurt_timer.timeout.is_connected(_on_hurt_timer_timeout):
		hurt_timer.timeout.connect(_on_hurt_timer_timeout)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		if cam:
			cam.rotation_degrees.x -= event.relative.y * 0.2
			cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -60.0, 60.0)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

<<<<<<< Updated upstream
func _physics_process(delta):
	const SPEED = 5.5
=======
func _physics_process(delta: float) -> void:
	# movement
	var input_2d: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_3d: Vector3 = Vector3(input_2d.x, 0.0, input_2d.y)
	var dir: Vector3 = transform.basis * input_3d

	velocity.x = dir.x * SPEED
	velocity.z = dir.z * SPEED
	velocity.y -= GRAVITY * delta
>>>>>>> Stashed changes

	if Input.is_action_just_pressed("jump") and is_on_floor():
<<<<<<< Updated upstream
		velocity.y = 10.0
		_is_jumping = true
		if animation and animation.has_animation("Locomotion-Library/Jump"):
			animation.play("Locomotion-Library/Jump")
=======
		velocity.y = JUMP_FORCE
>>>>>>> Stashed changes
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0

	move_and_slide()

<<<<<<< Updated upstream
	# อัปเดตอนิเมชันวิ่ง/ยืน
	if animation:
		var planar_speed := Vector2(velocity.x, velocity.z).length()

		if is_on_floor():
			if _is_jumping:
				_is_jumping = false
				if planar_speed > 0.1 and animation.has_animation("shoot"):
					animation.play("shoot", 0.5)
				elif animation.has_animation("Locomotion-Library/idle1"):
					animation.play("Locomotion-Library/idle1", 0.5)
			else:
				if planar_speed > 0.1:
					if animation.current_animation != "shoot" \
					and animation.has_animation("shoot"):
						animation.play("shoot", 0.5)
				else:
					if animation.current_animation != "Locomotion-Library/idle1" \
					and animation.has_animation("Locomotion-Library/idle1"):
						animation.play("Locomotion-Library/idle1", 0.5)
		else:
			_is_jumping = true



	if Input.is_action_pressed("shoot") and %Timer.is_stopped():
		# เล่นแอนิเมชันยิง (ถ้ามีคลิปชื่อ "shoot")
		if animation and animation.has_animation("shoot") and animation.current_animation != "shoot":
			animation.play("shoot", 0.5)  # 0.1 = blend time เล็กน้อย
=======
	# shoot (กดครั้งเดียว)
	if Input.is_action_just_pressed("shoot"):
>>>>>>> Stashed changes
		shoot_bullet()

	# contact damage (ต้องเรียกหลัง move_and_slide)
	_check_mob_contact_damage()

func shoot_bullet() -> void:
	# เคารพคูลดาวน์ถ้ามี
	if shoot_timer and not shoot_timer.is_stopped():
		return

	if bullet_scene == null:
		push_warning("Assign 'bullet_scene' on Player in the Inspector.")
		return

	# 1) สร้างกระสุนก่อน
	var bullet := bullet_scene.instantiate() as Node3D
	if bullet == null:
		push_error("bullet_scene instantiate failed")
		return

	# 2) ใส่เข้า scene root (ไม่ผูกกับ Marker เพื่อลดปัญหา transform)
	get_tree().current_scene.add_child(bullet)

	# 3) ตั้งผู้ยิง (ถ้าสคริปต์กระสุนรองรับ)
	if bullet.has_method("set_shooter"):
		bullet.set_shooter(self)

	# 4) ตั้งตำแหน่ง/ทิศยิงจาก muzzle (Marker3D ถ้ามี ไม่งั้นใช้กล้อง/ตัวเรา)
	var muzzle: Transform3D = _get_muzzle_transform()
	bullet.global_transform = muzzle
	bullet.global_position += -muzzle.basis.z * 0.75  # ดันออกจากปากปืนเล็กน้อย
	var forward: Vector3 = -muzzle.basis.z

	# 5) ให้กระสุนวิ่งไปข้างหน้า
	if bullet is RigidBody3D:
		(bullet as RigidBody3D).linear_velocity = forward * 30.0
	elif bullet is CharacterBody3D:
		(bullet as CharacterBody3D).velocity = forward * 30.0
		(bullet as CharacterBody3D).move_and_slide()
	elif bullet.has_method("fire"):
		bullet.fire(forward)

	# 6) เริ่มคูลดาวน์/เสียง (ถ้ามี)
	if shoot_timer:
		shoot_timer.start()
	if shoot_sfx:
		shoot_sfx.play()

func _get_muzzle_transform() -> Transform3D:
	if marker:
		return marker.global_transform
	elif cam:
		return cam.global_transform
	else:
		return global_transform

# ---------- HP / Damage ----------
func _check_mob_contact_damage() -> void:
	if _invincible:
		return

	var count: int = get_slide_collision_count()
	if count <= 0:
		return

	for i in range(count):
		var col := get_slide_collision(i)
		if col == null:
			continue
		var other: Node = col.get_collider() as Node
		if other == null:
			continue

		var mob: Node = _find_mob_node(other)
		if mob == null:
			continue

		var dmg: int = CONTACT_DAMAGE
		if "damage" in mob:
			dmg = int(mob.damage)

		take_damage(dmg)
		return

func _find_mob_node(start: Node) -> Node:
	var cur := start
	var hops := 0
	while cur and hops < 3:
		if cur.is_in_group("Mob"):
			return cur
		cur = cur.get_parent()
		hops += 1
	return null

func take_damage(amount: int) -> void:
	if _invincible:
		return
	hp = clamp(hp - amount, 0, MAX_HP)
	if health_bar:
		health_bar.value = hp

	_invincible = true
	if hurt_timer:
		hurt_timer.start()
	else:
		await get_tree().create_timer(INVINCIBLE_TIME).timeout
		_invincible = false

	if hp <= 0:
		die()

func _on_hurt_timer_timeout() -> void:
	_invincible = false

func die() -> void:
	get_tree().reload_current_scene()
