extends CharacterBody2D
class_name Enemy

@onready var player = get_node("/root/Main/Player")

const DEFAULT_SPEED = 150.0
const DASH_SPEED = 900

var dash_direction: Vector2
var in_range = false

var can_attack = true
var is_attacking = false
var is_charging = false
var is_cooling_down = false

func get_is_attacking() -> bool:
	return is_attacking

func _ready() -> void:
	$Hitbox.add_to_group("enemy")

func _physics_process(delta: float) -> void:

	if is_charging or is_cooling_down:
		# Stay still until charging over
		return
	elif is_attacking:
		# Move toward player
		velocity = dash_direction * DASH_SPEED
		move_and_slide()
		return
	
	if not in_range:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * DEFAULT_SPEED
		move_and_slide()
	elif can_attack and in_range:
		print("charging")
		is_charging = true
		$AttackChargeUp.start()
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		in_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		in_range = false


func _on_attack_charge_up_timeout() -> void:
	print("attacking")
	dash_direction = global_position.direction_to(player.global_position)
	is_charging = false
	is_attacking = true
	$AttackDuration.start()


func _on_attack_duration_timeout() -> void:
	print("cooling down\n")
	is_attacking = false
	can_attack = false
	is_cooling_down = true
	$AttackCooldown.start()


func _on_attack_cooldown_timeout() -> void:
	can_attack = true
	is_cooling_down = false
	
