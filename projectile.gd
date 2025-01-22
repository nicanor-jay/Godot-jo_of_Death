extends Area2D
class_name Projectile

var travelled_distance = 0
const SPEED = 400.0
const RANGE = 1200.0
var snapped = false

func _ready() -> void:
	add_to_group("enemy")

func _physics_process(delta: float) -> void:
	if not snapped:
		var direction = Vector2.RIGHT.rotated(rotation)
		position += direction * SPEED * delta
		travelled_distance += SPEED * delta
		
		if travelled_distance > RANGE:
			queue_free()


func _on_body_entered(body: Node2D) -> void:
	queue_free()

func break_apart():
	if snapped == false:
		print("Snapped Arrow")
		snapped = true
		$Sprite2D.queue_free()
		$CollisionShape2D.queue_free()
		
		$CPUParticles2D.emitting = true
		Events.add_to_combo.emit(1)


func _on_cpu_particles_2d_finished() -> void:
	queue_free()
