extends Line2D
class_name DashTrail

const LIFETIME: float = 2.0
const LINE_COLOR: Color = Color(1,1,1,1)
const LINE_WIDTH: float = 4.0
var timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = LIFETIME
	timer.one_shot = true
	timer.connect("timeout", _on_timeout)
	add_child(timer)
	timer.start()	

func _process(delta: float) -> void:
	modulate.a -=1.5	 * delta

func init_line(position: Vector2, color: Color = LINE_COLOR, width:float = LINE_WIDTH):
	self.begin_cap_mode = Line2D.LINE_CAP_ROUND
	self.end_cap_mode =Line2D.LINE_CAP_ROUND
	self.default_color = color
	self.width = width
	self.add_point(position)

func _on_timeout() -> void:
	print("trail cleared")
	queue_free()
