extends CharacterBody2D
class_name Player

var dash_direction: Vector2

@export var speedCurve: Curve

const DEFAULT_SPEED = 300.0
const DASH_SPEED = 1600
const DEFAULT_ATTACK_COOLDOWN = 1.5
const DEFAULT_ATTACK_DURATION = 0.3
const MULTI_KILL_MODIFIER = 1.5

var can_move = true
var can_attack = true
var is_attacking = false
var is_dead = false
var enemies_killed_in_dash = 0

const dash_trail_scene = preload("res://Scenes/dash_trail.tscn")
var dash_trail: Line2D

func _ready() -> void:
	$Hitbox.add_to_group("player")
	$AttackDuration.wait_time = DEFAULT_ATTACK_DURATION
	$AttackCooldown.wait_time = DEFAULT_ATTACK_COOLDOWN
	
	#$Sprite2D.modulate = Color(5,5,5,1)

func _physics_process(delta: float) -> void:
	if is_dead:
		# play death animation
		pass
	
	if is_attacking:
		dash_trail.add_point(position)
		
		var time_ratio = ($AttackDuration.wait_time - $AttackDuration.time_left) / $AttackDuration.wait_time
		var finalSpeed: float = DASH_SPEED * speedCurve.sample(time_ratio)
		velocity = dash_direction * finalSpeed
		
		move_and_slide()
		return
		
	if Input.is_action_just_pressed("attack") && can_attack:
		var mouse_pos = (get_global_mouse_position())
		var direction = global_position.direction_to(mouse_pos)
		dash_direction = direction
		
		start_dash()
		
		$ArrowRotationPoint/Arrow.modulate = Color(.5,.5,.5,1)
		is_attacking = true
		can_attack = false
		$AttackDuration.start()
		return

	var mouse_pos = (get_global_mouse_position())
	$ArrowRotationPoint.look_at(mouse_pos)
	var direction = global_position.direction_to(mouse_pos)
	
	if direction.x < 0:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false
	
	if can_move:
		velocity = direction* DEFAULT_SPEED
		move_and_slide()

func start_dash():
	dash_trail = dash_trail_scene.instantiate()
	dash_trail.init_line(global_position, Color(1,1,1,1), 10.0)
	get_parent().add_child(dash_trail)
	

func _on_attack_duration_timeout() -> void:
	print("attack finished")
	is_attacking = false
	
	if enemies_killed_in_dash > 0:
		Events.add_to_score.emit(10 * enemies_killed_in_dash  * enemies_killed_in_dash)
		Events.add_to_combo.emit(enemies_killed_in_dash)
		$AttackCooldown.wait_time = DEFAULT_ATTACK_COOLDOWN / 4
	else:
		$AttackCooldown.wait_time = DEFAULT_ATTACK_COOLDOWN
	
	enemies_killed_in_dash = 0
	$AttackCooldown.start()	


func _on_attack_cooldown_timeout() -> void:
	print("can_attack")
	$ArrowRotationPoint/Arrow.modulate = Color(1,1,1,1)
	can_attack = true
	
func _on_mouse_dead_zone_mouse_entered() -> void:
	print("Mouse enterd DEADSZONE")
	can_move = false

func _on_mouse_dead_zone_mouse_exited() -> void:
		can_move = true


func _on_hitbox_area_entered_exited(area: Area2D) -> void:
	if not area.is_in_group("enemy"):
		return
		
	if area is Projectile:
		if is_attacking and area.has_method("break_apart"):
			area.break_apart()
			enemies_killed_in_dash+=1
			
		else:
			print("Projectile detected")
			get_tree().paused = true
			queue_free()
		return
	## Area is a EnemyHitbox
	var enemy = area.get_parent()
	if is_attacking:
		# Player always kills enemy if attacking
		enemies_killed_in_dash+=1
		
		# Add enemy as dead sprite before freeing
		var dead_sprite = Sprite2D.new()
		dead_sprite.texture = %DeadSpriteTemplate.texture
		dead_sprite.scale = %DeadSpriteTemplate.scale
		dead_sprite.global_position = area.global_position
		dead_sprite.modulate = Color(1,.5,.5,1)
		dead_sprite.z_index = -5
		get_parent().add_child.call_deferred(dead_sprite)
		add_to_group("dead_enemies")
		
		enemy.queue_free()
		pass
	elif enemy.has_method("get_is_attacking"):
		if enemy.get_is_attacking():
			#print("DEATH")
			get_tree().paused = true
			queue_free()			
