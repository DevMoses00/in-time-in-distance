extends Node2D

@export_group("Hands")
@export var second : Sprite2D
@export var minute : Sprite2D
@export var hour : Sprite2D

@export_group("Panels")
@export var datePanel : Sprite2D
@export var namePanel : Sprite2D
@export var days : AnimatedSprite2D
@export var dates : AnimatedSprite2D

@export_group("Buttons")
@export var leftbutton : Button
@export var midbutton : Button
@export var rightbutton : Button

@export_group("Time")
@export var length_s : float

@export_group("Dialogue")
@export var resource : DialogueResource
@export var title : String

# TWEENS
var tween_sec : Tween
var tween_min : Tween
var tween_hour : Tween
var datetween : Tween
var nametween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title_tween()
	length_s = 1.0
	standard_clock()
	panel_moves()
	await get_tree().create_timer(5).timeout
	buttons_toggle()
	midbutton.pressed.connect(ramp_up_time)
	DialogueManager.show_dialogue_balloon(resource, title)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	days.speed_scale = 2/length_s
	dates.speed_scale = 2/length_s

func title_tween():
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($Clock,"position",Vector2(0,0),3)
	tween.tween_property($Clock,"scale",Vector2(1,1),3)

func standard_clock():
	tween_sec = get_tree().create_tween().set_parallel().set_loops()
	tween_sec.tween_property(second,"rotation",TAU,length_s).from(0)
	tween_min = get_tree().create_tween().set_parallel().set_loops()
	tween_min.tween_property(minute,"rotation",TAU,length_s * 60).from(0)
	tween_hour = get_tree().create_tween().set_parallel().set_loops()
	tween_hour.tween_property(hour,"rotation",TAU,length_s * 3600).from(0)

func panel_moves():
	datetween = get_tree().create_tween().set_loops()
	datetween.tween_property(datePanel, "position:y",2,length_s * 3).set_ease(Tween.EASE_IN_OUT)
	datetween.tween_property(datePanel, "position:y",-2,length_s * 1).set_ease(Tween.EASE_IN_OUT)
	nametween = get_tree().create_tween().set_loops()
	nametween.tween_property(namePanel, "position:y",2,length_s * 3).set_ease(Tween.EASE_IN_OUT)
	nametween.tween_property(namePanel, "position:y",-2,length_s * 1).set_ease(Tween.EASE_IN_OUT)

func tween_kill():
	tween_sec.kill()
	tween_min.kill()
	tween_hour.kill()
	datetween.kill()
	nametween.kill()

func ramp_up_time():
	tween_kill()
	buttons_toggle()
	length_s = 0.1
	standard_clock()
	panel_moves()

func buttons_toggle():
	if leftbutton.disabled == false: 
		leftbutton.disabled = true
		midbutton.disabled = true
		rightbutton.disabled = true
	else: 
		leftbutton.disabled = false
		midbutton.disabled = false
		rightbutton.disabled = false
