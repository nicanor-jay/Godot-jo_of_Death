extends Node2D


@onready var player = get_node("/root/Main/Player")

var score = 0
const SAVE_ZONE_DISTANCE = 150.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.add_to_score.connect(_on_event_add_to_score)
	$UI/ScoreLabel.text = "Score: 0"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_enemy_spawn_timer_timeout() -> void:
	print("Spawning Enemy")
	spawn_enemy()

func spawn_enemy() -> void:
	var new_enemy = preload("res://enemy.tscn").instantiate()
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
