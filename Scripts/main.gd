extends Node2D

var score = 0
var combo = 1
const SAVE_ZONE_DISTANCE = 150.0
const DEFAULT_COMBO_DURATION = 1.5

const playerScene = preload("res://Scenes/player.tscn")
var player : Player
enum gameStateValues {STARTMENU, PLAYING, DEAD}
var gameState: gameStateValues

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.add_to_score.connect(_on_event_add_to_score)
	Events.add_to_combo.connect(_on_event_add_to_combo)
	Events.player_death.connect(_on_event_player_death)
	gameState= gameStateValues.STARTMENU
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match gameState:
		gameStateValues.STARTMENU:
			if Input.is_action_just_pressed("attack"):
				start()
		gameStateValues.PLAYING:
			return
		gameStateValues.DEAD:
			if Input.is_action_just_pressed("attack"):
				#get_tree().paused = false
				start()

func start():
	$StartGameUI.visible = false
	$MidGameUI.visible = true
	gameState = gameStateValues.PLAYING
	clear_active_enemies()
	clear_inactive_enemies()
	score = 0
	$MidGameUI/ScoreLabel.text = "Score: 0"
	$MidGameUI/ComboLabel.text = "x1"
	
	$ComboTimer.wait_time = DEFAULT_COMBO_DURATION
	$EnemySpawnTimer.start()
	
	var newPlayer = playerScene.instantiate()
	newPlayer.global_position = $Level/PlayerSpawn.global_position
	player = newPlayer
	add_child.call_deferred(newPlayer)
	player.add_to_group("player")

func clear_active_enemies():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size()>0:
		for node in enemies:
			node.queue_free()
	
func clear_inactive_enemies():
	var enemies = get_tree().get_nodes_in_group("dead_enemies")
	if enemies.size()>0:
		for node in get_tree().get_nodes_in_group("dead_enemies"):
			node.queue_free()

func _on_enemy_spawn_timer_timeout() -> void:
	if player != null:
		print("Spawning Enemy")
		spawn_enemy()

func spawn_enemy() -> void:
	var new_enemy
	if randf() < 0.5:
		new_enemy = preload("res://Scenes/melee_enemy.tscn").instantiate()
	else:
		new_enemy = preload("res://Scenes/ranged_enemy.tscn").instantiate()
		
	#new_enemy = preload("res://Scenes/melee_enemy.tscn").instantiate()	
	#new_enemy = preload("res://Scenes/ranged_enemy.tscn").instantiate()	
	
		
	$Level/Path2D/PathFollow2D.progress_ratio = randf()
	while $Level/Path2D/PathFollow2D.global_position.distance_to(player.global_position) < SAVE_ZONE_DISTANCE:
		print("GETTING NEW SPAWN")
		$Level/Path2D/PathFollow2D.progress_ratio = randf()
		
	new_enemy.global_position = $Level/Path2D/PathFollow2D.global_position
	add_child(new_enemy)
	
func _on_event_add_to_score(points: int):
	score = score+points
	$MidGameUI/ScoreLabel.text = "Score: " + str(score)

func _on_event_add_to_combo(points: int):
	combo += points
	$MidGameUI/ComboLabel.text = "x" + str(combo)
	$ComboTimer.start()

func _on_combo_timer_timeout() -> void:
	print("Combo timer ran out")
	reset_combo_timer()
	pass
	
func reset_combo_timer():
	combo = 1
	$MidGameUI/ComboLabel.text = "x" + str(combo)
	pass

func _on_event_player_death():
	#get_tree().paused = true
	gameState = gameStateValues.DEAD
	$EnemySpawnTimer.stop()
	$MidGameUI.visible = false
