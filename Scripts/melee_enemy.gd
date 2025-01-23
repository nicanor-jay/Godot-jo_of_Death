extends CharacterBody2D
class_name Enemy

@onready var player = get_node("/root/Main/Player")
@onready var deadSpriteTemp = get_node("/root/Main/DeadMeleeSprite")
const DEFAULT_SPEED = 150.0
const DASH_SPEED = 900

var dash_direction: Vector2

var in_range = false
var can_attack = true
var is_attacking = false
var is_charging = false
var is_cooling_down = false
var is_dead = false
var is_player_dead = false

func get_is_attacking() -> bool:
	return is_attacking

func _ready() -> void:
	add_to_group("enemy")
	$SmokeAppear.emitting = true
	Events.player_death.connect(_on_event_player_death)

func _physics_process(delta: float) -> void:
	if player == null:
		#$AnimatedSprite2D.play("idle")
		return
		
	if is_charging or is_cooling_down or is_dead:
		return
	elif is_attacking:
		# Move toward player
		velocity = dash_direction * DASH_SPEED
		$AnimatedSprite2D.play("attack")
		move_and_slide()
		return
		
	var direction = global_position.direction_to(player.global_position)
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	
	if not in_range:
		velocity = direction * DEFAULT_SPEED
		$AnimatedSprite2D.play("run")
		move_and_slide()
	elif can_attack and in_range:
		is_charging = true
		$AttackChargeUp.start()
		$AnimatedSprite2D.play("charge")
	else:
		$AnimatedSprite2D.play("idle")
		

func die():
	if is_dead == false:
		is_dead = true
		$DeathParticles.emitting = true
		$AnimatedSprite2D.play("death")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		in_range = false

func _on_attack_charge_up_timeout() -> void:
	if not is_dead && player !=null:
		print("attacking")
		dash_direction = global_position.direction_to(player.global_position)
		if dash_direction.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		
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
	
func _on_animated_sprite_2d_animation_finished() -> void:
	print("Enemy died")
	var dead_sprite = Sprite2D.new()
	dead_sprite.texture = deadSpriteTemp.texture
	dead_sprite.scale = deadSpriteTemp.scale
	dead_sprite.global_position = $AnimatedSprite2D.global_position
	dead_sprite.z_index = -5
	dead_sprite.region_enabled = true
	dead_sprite.region_rect = Rect2(Vector2(20, 48), Vector2(16,16))
	dead_sprite.add_to_group("dead_enemies")
	dead_sprite.set_process(false)
	get_parent().add_child.call_deferred(dead_sprite)
	queue_free()
	
func _on_event_player_death():
	is_player_dead = true
	$AttackChargeUp.stop()
	$AttackCooldown.stop()
	$AttackDuration.stop()
