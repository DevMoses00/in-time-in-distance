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
@export var chaA : Sprite2D
@export var chaB : Sprite2D

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
var fadetween : Tween

@onready var chaApos = chaA.position
@onready var chaBpos = chaB.position

@onready var textA = $Clock/DatePanel/CharacterA.position - Vector2(310,40)
@onready var textB = $Clock/NamePanel/CharacterB.position - Vector2(-280, 30)

const lines: Array[String] = [
	"Hey I'm testing this clock thing out",
	"Well I'm doing it for the second time wowza",
	"This is going to be a pain in the neck that's for sure.",
]

func _ready() -> void:
	# THE OVERALL DIRECTOR SCRIPT IS PLAYED HERE 
	
	# bring the clock into focus
	title_tween()
	
	# standard clock rotation
	length_s = 1.0
	standard_clock()
	panel_moves()
	await get_tree().create_timer(5).timeout
	
	# activate buttons
	buttons_toggle()
	
	# activated when player selects the middle button
	midbutton.pressed.connect(middle_pressed)
	# the speedy clock's day and date fades away and is replaced by the two characters
	midbutton.pressed.connect(fade_tween)
	
	DialogueManager.dialogue_started.connect(dialogue_go)
	#DialogueManager.show_dialogue_balloon(resource, title)


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
	# kills the tweens and sets the buttons to disabled
	tween_kill()
	buttons_toggle()
	length_s = 0.1
	standard_clock()
	panel_moves()

func fade_tween():
	# a fade tween between that blurs removes the date and time and replaces it with the character
	await get_tree().create_timer(4.0).timeout
	fadetween = get_tree().create_tween().set_parallel()
	fadetween.tween_property(days,"modulate:a",0,4)
	fadetween.tween_property(dates,"modulate:a",0,4)
	fadetween.tween_property(chaA,"modulate:a",1,4)
	fadetween.tween_property(chaB,"modulate:a",1,4)
	fadetween.tween_interval(7)
	fadetween.finished.connect(standard_clock)
	fadetween.finished.connect(panel_moves)
	await get_tree().create_timer(6).timeout
	length_s = 1.0
	await get_tree().create_timer(3).timeout
	DialogueManager.dialogue_started.emit()
	

func buttons_toggle():
	if leftbutton.disabled == false: 
		leftbutton.disabled = true
		midbutton.disabled = true
		rightbutton.disabled = true
	else: 
		leftbutton.disabled = false
		midbutton.disabled = false
		rightbutton.disabled = false

func middle_pressed():
	# animation for when the middle button gets pressed 
	var handtween = get_tree().create_tween()
	handtween.tween_property($HandTestMid,"position",Vector2(0,0),1)
	handtween.tween_callback(ramp_up_time)
	handtween.tween_property($HandTestMid,"position",Vector2(-613,-384),1)

func character_movement():
	$Timer.wait_time = length_s
	var posArray = [chaApos - Vector2 (-3,0), chaApos + Vector2(-1,0), chaApos, chaApos + Vector2 (3,0)]
	for i in posArray:
		chaA.position = i
		await get_tree().create_timer(length_s/5).timeout

	var posBrray = [chaBpos - Vector2 (-3,0), chaBpos, chaBpos + Vector2(1,0), chaBpos + Vector2 (3,0)]
	for i in posBrray:
		chaB.position = i
		await get_tree().create_timer(length_s/5).timeout
	#if chaA.position == chaApos:
		#chaA.position += Vector2 (3,0)
	#else:
		#chaA.position = chaApos

func _on_timer_timeout() -> void:
	character_movement()

func dialogue_go():
	DialogueManager.start_dialogue(textA, lines)
	DialogueManager.start_dialogue(textB, lines)
