extends Node2D


@onready var player = get_node("/root/Main/Player")

var score = 0
var combo = 1
const SAVE_ZONE_DISTANCE = 150.0
const DEFAULT_COMBO_DURATION = 1.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.add_to_score.connect(_on_event_add_to_score)
	Events.add_to_combo.connect(_on_event_add_to_combo)
	$UI/ScoreLabel.text = "Score: 0"
	$UI/ComboLabel.text = "x1"
	$ComboTimer.wait_time = DEFAULT_COMBO_DURATION


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_enemy_spawn_timer_timeout() -> void:
	print("Spawning Enemy")
	spawn_enemy()

func spawn_enemy() -> void:
	var new_enemy = preload("res://Scenes/melee_enemy.tscn").instantiate()
	$Path2D/PathFollow2D.progress_ratio = randf()
	
	while $Path2D/PathFollow2D.global_position.distance_to(player.global_position) < SAVE_ZONE_DISTANCE:
		print("GETTING NEW SPAWN")
		$Path2D/PathFollow2D.progress_ratio = randf()
		
	new_enemy.global_position = $Path2D/PathFollow2D.global_position
	add_child(new_enemy)
	
#func _draw() -> void:
	#draw_circle($Player.global_position, SAVE_ZONE_DISTANCE, Color(1, 0, 0, 0.5))
	
func _on_event_add_to_score(points: int):
	score = score+points
	$UI/ScoreLabel.text = "Score: " + str(score)

func _on_event_add_to_combo(points: int):
	combo += points
	$UI/ComboLabel.text = "x" + str(combo)
	$ComboTimer.start()

func _on_combo_timer_timeout() -> void:
	print("Combo timer ran out")
	reset_combo_timer()
	pass
	

func reset_combo_timer():
	combo = 1
	$UI/ComboLabel.text = "x" + str(combo)
	#$ComboTimer.stop()
	#$ComboTimer.wait_time = DEFAULT_COMBO_DURATION
	#$ComboTimer.start()
	pass
