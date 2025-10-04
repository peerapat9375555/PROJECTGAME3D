extends CharacterBody3D

@onready var animation: AnimationPlayer = $gobot/AnimationPlayer2
var _is_jumping: bool = false

# ===== กระสุน =====
@export var primary_bullet_scene: PackedScene
@export var alt_bullet_scene: PackedScene

# ===== คูลดาวน์ (แยกกัน) =====
@export var primary_cooldown: float = 0.2
@export var alt_cooldown: float = 0.5

@onready var muzzle: Marker3D = %Marker3D
@onready var timer_primary: Timer = %TimerPrimary
@onready var timer_alt: Timer = %TimerAlt
@onready var sfx_primary: AudioStreamPlayer = %AudioStreamPlayer
@onready var sfx_alt: AudioStreamPlayer = %AudioStreamPlayerAlt

# ===== การเคลื่อนไหว / กระโดด =====
@export var move_speed: float = 5.5
@export var gravity: float = 20.0
@export var jump_force: float = 10.0
@export var max_jumps: int = 2     # กระโดดได้สูงสุดกี่ครั้ง (2 = ดับเบิลจัมพ์)
var _jump_count: int = 0           # ตัวนับจำนวนครั้งที่กระโดดไปแล้ว

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	%Marker3D.rotation_degrees.y += 2.0

	if animation and animation.has_animation("shoot"):
		animation.play("shoot")

	timer_primary.one_shot = true
	timer_primary.wait_time = primary_cooldown
	timer_alt.one_shot = true
	timer_alt.wait_time = alt_cooldown

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		%Camera3D.rotation_degrees.x -= event.relative.y * 0.2
		%Camera3D.rotation_degrees.x = clamp(%Camera3D.rotation_degrees.x, -60.0, 60.0)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# ===== เดิน/วิ่ง =====
	var input_dir2d = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_dir3d = Vector3(input_dir2d.x, 0, input_dir2d.y)
	var direction = transform.basis * input_dir3d
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	# ===== แรงโน้มถ่วง =====
	velocity.y -= gravity * delta

	# ===== กระโดด (Double Jump) =====
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			_jump_count = 1
			_do_jump(_jump_count)
		elif _jump_count < max_jumps:
			_jump_count += 1
			_do_jump(_jump_count)

	if Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0

	move_and_slide()

	# แตะพื้น => รีเซ็ตจำนวนกระโดด
	if is_on_floor():
		_jump_count = 0

	# ===== อัปเดตอนิเมชันยืน/วิ่ง =====
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
					if animation.current_animation != "shoot" and animation.has_animation("shoot"):
						animation.play("shoot", 0.5)
				else:
					if animation.current_animation != "Locomotion-Library/idle1" and animation.has_animation("Locomotion-Library/idle1"):
						animation.play("Locomotion-Library/idle1", 0.5)
		else:
			_is_jumping = true

	# ===== ยิงกระสุน (ใช้ Timer แยก) =====
	if Input.is_action_pressed("shoot_alt") and timer_alt.is_stopped():
		_play_shoot_anim_if_needed()
		_shoot(true)
	elif Input.is_action_pressed("shoot") and timer_primary.is_stopped():
		_play_shoot_anim_if_needed()
		_shoot(false)

# ---------- Helpers ----------
func _do_jump(jump_idx: int):
	velocity.y = jump_force
	_is_jumping = true

	if animation:
		var clip = ""
		if jump_idx == 1:
			clip = "Locomotion-Library/Jump"
		else:
			clip = "Locomotion-Library/DoubleJump"
			if not animation.has_animation(clip):
				clip = "Locomotion-Library/Jump"

		animation.play(clip, 0.1)
		animation.seek(0.0, true)  # รีเซ็ตเฟรมให้เล่นตั้งแต่ต้นทุกครั้ง

func _play_shoot_anim_if_needed():
	# ไม่ให้ยิงตอนลอยกลางอากาศ (ถ้าอยากให้ยิงได้ ลบเงื่อนไขนี้)
	if not is_on_floor():
		return
	if animation and animation.has_animation("shoot") and animation.current_animation != "shoot":
		animation.play("shoot", 0.5)

func _shoot(alt: bool):
	var scene = alt_bullet_scene if alt else primary_bullet_scene
	if scene == null:
		push_warning(( "alt_bullet_scene" if alt else "primary_bullet_scene") + " ยังไม่ได้เซ็ตใน Inspector")
		return

	var bullet: Node3D = scene.instantiate()
	muzzle.add_child(bullet)
	bullet.global_transform = muzzle.global_transform

	if alt:
		timer_alt.start()
		if is_instance_valid(sfx_alt):
			sfx_alt.play()
	else:
		timer_primary.start()
		if is_instance_valid(sfx_primary):
			sfx_primary.play()
