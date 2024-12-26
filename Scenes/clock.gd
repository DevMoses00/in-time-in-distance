extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(4).timeout
	clock_tween()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func clock_tween():
	# A tween animation that constantly moves the clock for dynamic effect
	var clockTween = get_tree().create_tween().set_loops()
	clockTween.tween_property(self, "position:x", -5, 0.5)
	clockTween.tween_property(self, "position:x", 5, 0.5)
	pass
