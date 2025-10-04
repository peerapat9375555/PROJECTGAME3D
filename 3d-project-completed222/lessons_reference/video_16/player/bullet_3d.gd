extends RigidBody3D

@export var speed: float = 30.0
@export var lifetime: float = 3.0
@export var hit_groups: Array[StringName] = ["Mob"]   # ยิงใส่เฉพาะกลุ่มพวกนี้

var shooter: Node = null
var spent: bool = false

func set_shooter(owner: Node) -> void:
	shooter = owner

func _ready() -> void:
	add_to_group("Bullet")            # ให้ม็อบตรวจจับกระสุนได้ง่าย
	contact_monitor = true
	max_contacts_reported = 8
	sleeping = false

	var t := Timer.new()
	t.one_shot = true
	t.wait_time = lifetime
	add_child(t)
	t.timeout.connect(queue_free)
	t.start()

	body_entered.connect(_on_body_entered)

func fire(dir: Vector3) -> void:
	linear_velocity = dir.normalized() * speed

func _physics_process(_delta: float) -> void:
	if linear_velocity.length() < 0.01:
		linear_velocity = -global_transform.basis.z * speed

func _on_body_entered(body: Node) -> void:
	if spent:
		return
	if not _should_damage(body):
		return
	_damage(body)
	spent = true
	queue_free()

func _should_damage(target: Node) -> bool:
	if target == null:
		return false
	# กันยิงโดนตัวเราเอง/ลูกของเรา
	if shooter and (target == shooter or target.is_ancestor_of(shooter) or shooter.is_ancestor_of(target)):
		return false
	# ไต่ขึ้นหา parent เพื่อเช็คกลุ่ม
	var n := target
	var hops := 0
	while n and hops < 3:
		for g in hit_groups:
			if n.is_in_group(g):
				return true
		n = n.get_parent()
		hops += 1
	return false

func _damage(target: Node) -> void:
	# หาโนดที่มีเมธอด take_damage() (รองรับกรณีชนลูก เช่น CollisionShape)
	var n := target
	var hops := 0
	while n and hops < 3:
		if n.has_method("take_damage"):
			n.take_damage()  # ม็อบของคุณใช้แบบไม่รับพารามิเตอร์
			return
		n = n.get_parent()
		hops += 1
