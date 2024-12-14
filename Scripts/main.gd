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

# TWEENS
var tween_sec : Tween
var tween_min : Tween
var tween_hour : Tween
var PanelLtween : Tween
var PanelRtween : Tween
var fadetween : Tween

@onready var chaApos = chaA.position
@onready var chaBpos = chaB.position

#@onready var textA = $Clock/DatePanel/CharacterA.position - Vector2(310,40)
#@onready var textB = $Clock/NamePanel/CharacterB.position - Vector2(-280, 30)

# boolean for opening of the game, will result in false after pressed for the first time
var opening : bool = true
var normal_idle : bool = true

# SIGNALS


func _ready() -> void:
	DialogueManager.readJSON("res://Dialogue/ITID_dialogue.json")
	# THE OVERALL DIRECTOR SCRIPT IS PLAYED HERE 
	
	# bring the clock into focus
	title_tween()
	
	# standard clock rotation
	length_s = 1.0
	clock()
	panel_moves()
	await get_tree().create_timer(5).timeout
	
	# activate buttons
	buttons_enable()
	
	# activated when player first gets the button
	leftbutton.pressed.connect(left_pressed)
	midbutton.pressed.connect(middle_pressed)
	rightbutton.pressed.connect(right_pressed)
	
	
	# starting the dialogue
	DialogueManager.dialogue_started.connect(dialogue_go)
	
	# enabling the buttons to be pressed after the dialogue
	DialogueManager.buttons_enabled.connect(buttons_enable)


func _process(delta: float) -> void:
	days.speed_scale = 2/length_s
	dates.speed_scale = 2/length_s


func title_tween():
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($Clock,"position",Vector2(0,0),3)
	tween.tween_property($Clock,"scale",Vector2(1,1),3)

func clock():
	tween_sec = get_tree().create_tween().set_parallel().set_loops()
	tween_sec.tween_property(second,"rotation",TAU,length_s).from(0)
	tween_min = get_tree().create_tween().set_parallel().set_loops()
	tween_min.tween_property(minute,"rotation",TAU,length_s * 60).from(0)
	tween_hour = get_tree().create_tween().set_parallel().set_loops()
	tween_hour.tween_property(hour,"rotation",TAU,length_s * 3600).from(0)

func panel_moves():
	name_tween()
	date_tween()

func tween_kill():
	tween_sec.kill()
	tween_min.kill()
	tween_hour.kill()
	PanelLtween.kill()
	PanelRtween.kill()


func ramp_up_time():
	# kills the tweens and sets the buttons to disabled
	leftbutton.disabled = true
	midbutton.disabled = true
	rightbutton.disabled = true
	tween_kill()
	# start the animation
	length_s = 0.1
	clock()
	if opening == true:
		fade_tween()
		panel_moves()
		await get_tree().create_timer(11).timeout
		tween_kill()
		length_s = 1.0
		clock()
		panel_moves()
		await get_tree().create_timer(3).timeout
		opening = false
		DialogueManager.dialogue_started.emit()
	else:
		await get_tree().create_timer(11).timeout
		tween_kill()
		length_s = 1.0
		clock()
		panel_moves()
		await get_tree().create_timer(3).timeout
		DialogueManager.dialogue_started.emit()


func name_tween():
	print("I'm the name panel and I'm working")
	# for when the right button is pressed and the name panel must tween rapidly
	PanelRtween = get_tree().create_tween().set_loops()
	PanelRtween.tween_property(namePanel, "position:y",2,length_s * 3).set_ease(Tween.EASE_IN_OUT)
	PanelRtween.tween_property(namePanel, "position:y",-2,length_s * 1).set_ease(Tween.EASE_IN_OUT)

func date_tween():
	print("I'm the date panel and I'm working ")
	# for when the mid button is pressed and the name panel must tween rapidly
	PanelLtween = get_tree().create_tween().set_loops()
	PanelLtween.tween_property(datePanel, "position:y",2,length_s * 3).set_ease(Tween.EASE_IN_OUT)
	PanelLtween.tween_property(datePanel, "position:y",-2,length_s * 1).set_ease(Tween.EASE_IN_OUT)


func fade_tween():
	# the speedy clock's day and date fades away and is replaced by the two characters
	# a fade tween between that blurs removes the date and time and replaces it with the character
	await get_tree().create_timer(4.0).timeout
	fadetween = get_tree().create_tween().set_parallel()
	fadetween.tween_property(days,"modulate:a",0,4)
	fadetween.tween_property(dates,"modulate:a",0,4)
	fadetween.tween_property(chaA,"modulate:a",1,4)
	fadetween.tween_property(chaB,"modulate:a",1,4)


# BUTTON CODE

func buttons_enable():
	leftbutton.disabled = false
	midbutton.disabled = false
	rightbutton.disabled = false

func left_pressed():
	# animation for when the left button gets pressed 
	var handtween = get_tree().create_tween()
	handtween.tween_property($HandTestLeft,"position",Vector2(0,0),1)
	handtween.tween_callback(ramp_up_time)
	handtween.tween_property($HandTestLeft,"position",Vector2(-639,-211),1)
	
	if opening == false: 
		await get_tree().create_timer(1.1).timeout
		panel_moves()
	# add the necessary variables for when I want to fade in the new character animation and call the new dialogue array

func middle_pressed():
	# animation for when the middle button gets pressed 
	var handtween = get_tree().create_tween()
	handtween.tween_property($HandTestMid,"position",Vector2(0,0),1)
	handtween.tween_callback(ramp_up_time)
	handtween.tween_property($HandTestMid,"position",Vector2(-613,-384),1)
	
	if opening == false: 
		await get_tree().create_timer(1.1).timeout
		date_tween()
	# add the necessary variables for when I want to fade in the new character animation and call the new dialogue array

func right_pressed():
	var handtween = get_tree().create_tween()
	handtween.tween_property($HandTestRight,"position",Vector2(0,0),1)
	handtween.tween_callback(ramp_up_time)
	handtween.tween_property($HandTestRight,"position",Vector2(630,-268),1)
	
	if opening == false: 
		await get_tree().create_timer(1.1).timeout
		name_tween()
		# add the necessary variables for when I want to fade in the new character animation and call the new dialogue array

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

func _on_timer_timeout() -> void:
	pass
	#character_movement()


func dialogue_go():
	#DialogueManager.start_dialogue(lines)
	DialogueManager.dialogue_player("Teaser")
