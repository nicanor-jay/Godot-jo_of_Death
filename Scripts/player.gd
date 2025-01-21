extends CharacterBody2D
class_name Player

var dash_direction: Vector2

const DEFAULT_SPEED = 300.0
const DASH_SPEED = 1500
const DEFAULT_ATTACK_COOLDOWN = 2.0
const DEFAULT_RECOVERY_COOLDOWN = 0.2
const DEFAULT_ATTACK_DURATION = 0.15
const MULTI_KILL_MODIFIER = 1.5

var can_move = true
var can_attack = true
var is_attacking = false
var is_recovering = false
var is_dead = false
var enemies_killed_in_dash = 0

func _ready() -> void:
	$Hitbox.add_to_group("player")
	$AttackCooldown.wait_time = DEFAULT_ATTACK_DURATION
	$AttackCooldown.wait_time = DEFAULT_ATTACK_COOLDOWN
	$AttackRecovery.wait_time = DEFAULT_RECOVERY_COOLDOWN

func _physics_process(delta: float) -> void:

	if is_dead:
		# play death animation
		pass
		
	if is_recovering:
		return
	
	if is_attacking:
		velocity = dash_direction* DASH_SPEED
		move_and_slide()

	# Handle jump.
	if Input.is_action_just_pressed("attack") && can_attack:
		print("dashing")
		var mouse_pos = (get_global_mouse_position())
		var direction = global_position.direction_to(mouse_pos)
		dash_direction = direction
		
		$ArrowRotationPoint/Arrow.modulate = Color(.5,.5,.5,1)
		is_attacking = true
		can_attack = false
		$AttackDuration.start()
		
		return

	var mouse_pos = (get_global_mouse_position())
	$ArrowRotationPoint.look_at(mouse_pos)
	if can_move:
		var direction = global_position.direction_to(mouse_pos)
		velocity = direction* DEFAULT_SPEED
		move_and_slide()


func _on_attack_duration_timeout() -> void:
	print("attack finished")
	is_attacking = false
	is_recovering = true
	
	if enemies_killed_in_dash > 0:
		Events.add_to_score.emit(10 * enemies_killed_in_dash  * enemies_killed_in_dash)
		Events.add_to_combo.emit(enemies_killed_in_dash)
		$AttackCooldown.wait_time = DEFAULT_ATTACK_COOLDOWN / 4
	else:
		$AttackCooldown.wait_time = DEFAULT_ATTACK_COOLDOWN
	
	enemies_killed_in_dash = 0
	$AttackCooldown.start()	
	$AttackRecovery.start()


func _on_attack_cooldown_timeout() -> void:
	print("can_attack")
	$ArrowRotationPoint/Arrow.modulate = Color(1,1,1,1)
	can_attack = true
	
func _on_mouse_dead_zone_mouse_entered() -> void:
	can_move = false


func _on_mouse_dead_zone_mouse_exited() -> void:
		can_move = true


func _on_hitbox_body_entered(body: Node2D) -> void:
	print("Body detected")
	if body is Enemy and is_attacking:
		print("enemy detected")
		
		body.queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	print("Area detected")
	if area is not EnemyHitbox:
		return
		
	var enemy = area.get_parent()
	print(enemy)
	
	print("enemy detected")
	if is_attacking:
		# Player always kills enemy if attacking
		enemies_killed_in_dash+=1
		
		# Add enemy as dead sprite before freeing
		var dead_sprite = Sprite2D.new()
		dead_sprite.texture = %DeadSpriteTemplate.texture
		dead_sprite.scale = %DeadSpriteTemplate.scale
		dead_sprite.global_position = area.global_position
		dead_sprite.modulate = Color(1,.9,.9,1)
		dead_sprite.z_index = -5
		get_parent().add_child(dead_sprite)
		add_to_group("dead_enemies")
		
		enemy.queue_free()
		pass
	elif enemy.has_method("get_is_attacking"):
		if enemy.get_is_attacking():
			#print("DEATH")
			get_tree().paused = true
			queue_free()
			


func _on_attack_recovery_timeout() -> void:
	is_recovering = false
