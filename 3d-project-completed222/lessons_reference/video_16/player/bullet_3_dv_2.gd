extends Area3D

@export var SPEED: float = 30
@export var RANGE: float = 40.0
@export var damage: int = 1           # เผื่อไว้ ถ้าศัตรูรองรับพารามิเตอร์

var start_pos: Vector3
var _armed := false
var shooter: Node = null              # ตั้งจากฝั่ง Player เพื่อกันยิงตัวเอง

func _ready():
	monitoring = true
	start_pos = global_position
	await get_tree().process_frame     # หน่วง 1 เฟรม กันชนปืน/ผู้ยิงเอง
	_armed = true

func _physics_process(delta):
	global_position += -global_transform.basis.z * SPEED * delta
	if start_pos.distance_to(global_position) > RANGE:
		queue_free()

func _on_body_entered(body):
	if not _armed:
		return
	if body == shooter:
		return

	if body and body.has_method("take_damage"):
		# ── เลือกอย่างใดอย่างหนึ่งด้านล่าง ──

		# (A) ถ้า mob.gd มี take_damage() ไม่รับพารามิเตอร์ → ใช้แบบนี้
		body.take_damage()

		# (B) ถ้าอยากส่งดาเมจเป็นตัวเลข ให้ไปแก้ mob.gd ให้เป็น:
		#     func take_damage(amount: int): ...
		# แล้วค่อยเปลี่ยนบรรทัดบนเป็น:
		# body.take_damage(damage)

	queue_free()
