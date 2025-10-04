extends CharacterBody3D

@onready var animation: AnimationPlayer = $gobot/AnimationPlayer2
var _is_jumping: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	%Marker3D.rotation_degrees.y += 2.0

	# เล่น Idle ตอนเริ่ม
	if animation and animation.has_animation("shoot"):
		animation.play("shoot")

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		%Camera3D.rotation_degrees.x -= event.relative.y * 0.2
		%Camera3D.rotation_degrees.x = clamp(
			%Camera3D.rotation_degrees.x, -60.0, 60.0
		)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	const SPEED = 5.5

	var input_direction_2D = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	var input_direction_3D = Vector3(
		input_direction_2D.x, 0, input_direction_2D.y
	)
	var direction = transform.basis * input_direction_3D

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	velocity.y -= 20.0 * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10.0
		_is_jumping = true
		if animation and animation.has_animation("Locomotion-Library/Jump"):
			animation.play("Locomotion-Library/Jump")
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0

	move_and_slide()

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
		shoot_bullet()


func shoot_bullet():
	const BULLET_3D = preload("bullet_3d.tscn")
	var new_bullet = BULLET_3D.instantiate()
	%Marker3D.add_child(new_bullet)

	new_bullet.global_transform = %Marker3D.global_transform

	%Timer.start()
	%AudioStreamPlayer.play()
