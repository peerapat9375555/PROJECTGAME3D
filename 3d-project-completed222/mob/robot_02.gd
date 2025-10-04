# mob/robot01.gd

extends RigidBody3D

signal died

var speed = randf_range(2.0, 4.0)
var health = 3

@onready var robot_02 = %robot02

@onready var timer = %Timer

@onready var hurt_sound: AudioStreamPlayer3D = %HurtSound
@onready var ko_sound: AudioStreamPlayer3D = %KOSound

@onready var player = get_node("/root/Game/Player")


func _ready():
	# 🔒 ล็อกการหมุน X และ Z ตอนยังมีชีวิต
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true


func _physics_process(delta):
	if health <= 0:
		return
	
	# เคลื่อนที่เข้าหาผู้เล่น
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0.0
	linear_velocity = direction * speed
	
	# หมุนหันหน้าเข้าผู้เล่น (เฉพาะแกน Y)
	var target_rotation_y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI
	robot_02.rotation.y = target_rotation_y


func take_damage():
	if health == 0:
		return
		
	robot_02.hurt()
	health -= 1
	
	hurt_sound.pitch_scale = randfn(1.0, 0.1)
	hurt_sound.play()
	
	if health == 0:
		# 🔊 เล่นเสียง KO
		ko_sound.play()
		
		# หยุดการเคลื่อนไหว
		set_physics_process(false)
		
		# ✅ ปลดล็อกการหมุนให้ฟิสิกส์หมุนได้ตอนตาย
		axis_lock_angular_x = false
		axis_lock_angular_y = false
		axis_lock_angular_z = false
		
		# ✅ เปิดแรงโน้มถ่วง
		gravity_scale = 1.0
		
		# ✅ ให้แรงกระเด็นตอนตาย
		var direction = player.global_position.direction_to(global_position)
		var random_upward_force = Vector3.UP * randf() * 5.0
		apply_central_impulse(
			direction.rotated(Vector3.UP, randf_range(-0.2, 0.2)) * 10.0 + random_upward_force
		)

		# ตั้งเวลาให้หายไปหลังตาย
		timer.start()


func _on_timer_timeout():
	queue_free()
	died.emit()
