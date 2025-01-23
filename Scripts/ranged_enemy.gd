extends CharacterBody2D

@onready var player = get_node("/root/Main/Player")
const PROJECTILE = preload("res://Scenes/projectile.tscn")
@onready var deadSpriteTemp = get_node("/root/Main/DeadRangedSprite")

const DEFAULT_SPEED = 150.0

var attack_dir: Vector2

var is_dead = false
var in_range = false
var can_attack = true
var is_attacking = false
var is_charging = false
var is_cooling_down = false
var is_player_dead = false

func _ready() -> void:
	add_to_group("enemy")
	$SmokeAppear.emitting = true
	Events.player_death.connect(_on_event_player_death)


func _physics_process(delta: float) -> void:
	if player == null:
		return
	if is_cooling_down:
		$AnimatedSprite2D.play("attack")
		return
	
	if is_charging or is_attacking:
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
		print("charging")
		is_charging = true
		can_attack = false
		$AttackChargeUp.start()
		$AnimatedSprite2D.play("charge")
	else:
		$AnimatedSprite2D.play("idle")
		
func die():
	if is_dead == false:
		is_dead = true
		$DeathParticles.emitting = true
		$AnimatedSprite2D.play("death")
		$AttackChargeUp.stop()
		$AttackCooldown.stop()


func shoot():
	var new_bullet = PROJECTILE.instantiate()
	new_bullet.global_position = $ArrowOrignMarker.global_position
	new_bullet.look_at(player.global_position)
	new_bullet.z_index = 5
	get_parent().add_child(new_bullet)
	$AttackCooldown.start()
	
func _on_attack_detection_range_body_entered(body: Node2D) -> void:
	if body is Player:
		in_range = true

func _on_attack_detection_range_body_exited(body: Node2D) -> void:
	if body is Player:
		in_range = false


func _on_attack_charge_up_timeout() -> void:
	print("attacking")
	if player == null:
		return
	attack_dir = global_position.direction_to(player.global_position)
	is_charging = false
	is_attacking = true
	$AnimatedSprite2D.play("attack")
	shoot()

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
	is_cooling_down = false
	is_attacking = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "death":
		var dead_sprite = Sprite2D.new()
		dead_sprite.texture = deadSpriteTemp.texture
		dead_sprite.scale = deadSpriteTemp.scale
		dead_sprite.global_position = $AnimatedSprite2D.global_position
		dead_sprite.z_index = -5
		dead_sprite.region_enabled = true
		dead_sprite.region_rect = Rect2(Vector2(32, 48), Vector2(16,16))
		dead_sprite.add_to_group("dead_enemies")
		get_parent().add_child.call_deferred(dead_sprite)
		queue_free()

func _on_event_player_death():
	is_player_dead = true
	$AttackChargeUp.stop()
	$AttackCooldown.stop()
