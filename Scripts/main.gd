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
@export var chaA : AnimatedSprite2D
@export var chaB : AnimatedSprite2D
@export var chaAage : AnimatedSprite2D
@export var chaBage : AnimatedSprite2D

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
var clockTween : Tween

@onready var chaApos = chaA.position
@onready var chaBpos = chaB.position

# character mouths
@onready var Asrimouth: AnimatedSprite2D = $Clock/NamePanel/CharacterB/Mouth
@onready var Wesmouth: AnimatedSprite2D = $Clock/DatePanel/CharacterA/Mouth

# character eyes
@onready var Asrieyes: AnimatedSprite2D = $Clock/NamePanel/CharacterB/Eyes
@onready var Weseyes: AnimatedSprite2D = $Clock/DatePanel/CharacterA/Eyes

var AsriNum : int = 30
var WesNum : int = 35
var dialogueNum 
#@onready var textA = $Clock/DatePanel/CharacterA.position - Vector2(310,40)
#@onready var textB = $Clock/NamePanel/CharacterB.position - Vector2(-280, 30)

# boolean for opening of the game, will result in false after pressed for the first time
var opening : bool = true
var normal_idle : bool = true

var character_fades

# SIGNALS


func _ready() -> void:
	DialogueManager.readJSON("res://Dialogue/ITID_dialogue.json")
	# THE OVERALL DIRECTOR SCRIPT IS PLAYED HERE 
	
	# bring the clock into focus
	title_tween()
	clock_tween()
	
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
	character_talking()
	DialogueManager.dialogue_started.connect(dialogue_go)
	
	# enabling the buttons to be pressed after the dialogue
	DialogueManager.buttons_enabled.connect(buttons_enable)


func _process(delta: float) -> void:
	days.speed_scale = 2/length_s
	dates.speed_scale = 2/length_s


func title_tween():
	# For the opening of the game
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($Clock,"position",Vector2(0,0),3)
	tween.tween_property($Clock,"scale",Vector2(1,1),3)

func clock():
	# sets the clock animation
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
	clockTween.kill()


func ramp_up_time():
	# kills the tweens and sets the buttons to disabled
	leftbutton.disabled = true
	midbutton.disabled = true
	rightbutton.disabled = true
	tween_kill()
	# start the animation
	length_s = 0.1
	clock()
	clock_tween()
	$Background.play()
	if opening == true:
		fade_tween()
		panel_moves()
		chaAage.play(str(WesNum))
		chaA.play(str(WesNum))
		Weseyes.play(str(WesNum))
		Wesmouth.animation = str(WesNum)
		chaBage.play(str(AsriNum))
		chaB.play(str(AsriNum))
		Asrieyes.play(str(AsriNum))
		Asrimouth.animation = str(AsriNum)
		await get_tree().create_timer(11).timeout
		tween_kill()
		$Background.stop()
		length_s = 1.0
		clock()
		panel_moves()
		await get_tree().create_timer(3).timeout
		opening = false
		DialogueManager.dialogue_started.emit()
	else:
		fade_tween_back()
		await get_tree().create_timer(10).timeout
		fade_tween()
		await get_tree().create_timer(9).timeout
		tween_kill()
		$Background.stop()
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
	fadetween = get_tree().create_tween()
	fadetween.parallel().tween_property(days,"modulate:a",0,3)
	fadetween.parallel().tween_property(dates,"modulate:a",0,3)
	fadetween.parallel().tween_property(chaAage,"modulate:a",1,3)
	fadetween.parallel().tween_property(chaBage,"modulate:a",1,3)
	fadetween.tween_interval(1)
	fadetween.parallel().tween_property(chaAage,"modulate:a",0,2)
	fadetween.parallel().tween_property(chaBage,"modulate:a",0,2)
	fadetween.parallel().tween_property(chaA,"modulate:a",1,2)
	fadetween.parallel().tween_property(chaB,"modulate:a",1,2)

func fade_tween_back():
	# a fade tween fades the character away 
	await get_tree().create_timer(4.0).timeout
	fadetween = get_tree().create_tween().set_parallel()
	fadetween.tween_property(days,"modulate:a",1,4)
	fadetween.tween_property(dates,"modulate:a",1,4)
	fadetween.tween_property(chaA,"modulate:a",0,4)
	fadetween.tween_property(chaB,"modulate:a",0,4)

func clock_tween():
	# A tween animation that constantly moves the clock for dynamic effect
	clockTween = get_tree().create_tween().set_loops()
	clockTween.tween_property($Clock, "position:x", -2, 0.5)
	clockTween.tween_property($Clock, "position:x", 2, 0.5)
	pass
# BUTTON CODE

func buttons_enable():
	if WesNum >= 50:
		end_sequence()
	if AsriNum >= 50: 
		end_sequence()
	else:
		leftbutton.disabled = false
		midbutton.disabled = false
		rightbutton.disabled = false

func left_pressed():
	# animation for when the left button gets pressed 
	$HandTestLeft.play()
	var handtween = get_tree().create_tween() 
	handtween.tween_property($HandTestLeft,"position",Vector2(0,-60),2.5).set_trans(Tween.TRANS_CUBIC)
	handtween.tween_callback(ramp_up_time)
	handtween.tween_property($HandTestLeft,"position",Vector2(-639,-211),2.0).set_trans(Tween.TRANS_CUBIC)
	
	if opening == false: 
		await get_tree().create_timer(1.1).timeout
		panel_moves()
		await get_tree().create_timer(9.0).timeout
		WesNum += 5
		chaAage.play(str(WesNum))
		chaA.play(str(WesNum))
		Weseyes.play(str(WesNum))
		Wesmouth.animation = str(WesNum)
		AsriNum += 5
		chaBage.play(str(AsriNum))
		chaB.play(str(AsriNum))
		Asrieyes.play(str(AsriNum))
		Asrimouth.animation = str(AsriNum)
	# add the necessary variables for when I want to fade in the new character animation and call the new dialogue array

func middle_pressed():
	# animation for when the middle button gets pressed 
	var handtween = get_tree().create_tween()
	handtween.tween_property($HandTestMid,"position",Vector2(0,0),2.5).set_trans(Tween.TRANS_CUBIC)
	handtween.tween_callback(ramp_up_time)
	handtween.tween_property($HandTestMid,"position",Vector2(-613,-384),2.0).set_trans(Tween.TRANS_CUBIC)
	
	if opening == false: 
		await get_tree().create_timer(1.1).timeout
		panel_moves()
		#date_tween()
		await get_tree().create_timer(9.0).timeout
		WesNum += 5
		chaAage.play(str(WesNum))
		chaA.play(str(WesNum))
		Weseyes.play(str(WesNum))
		Wesmouth.animation = str(WesNum)
		
	# add the necessary variables for when I want to fade in the new character animation and call the new dialogue array

func right_pressed():
	$HandTestRight.play()
	var handtween = get_tree().create_tween()
	handtween.tween_property($HandTestRight,"position",Vector2(0,-40),2.5).set_trans(Tween.TRANS_CUBIC)
	handtween.tween_callback(ramp_up_time)
	handtween.tween_property($HandTestRight,"position",Vector2(630,-268),2.0).set_trans(Tween.TRANS_CUBIC)
	
	if opening == false: 
		await get_tree().create_timer(1.1).timeout
		panel_moves()
		#name_tween()
		await get_tree().create_timer(9.0).timeout
		AsriNum += 5
		chaB.play(str(AsriNum))
		chaBage.play(str(AsriNum))
		Asrieyes.play(str(AsriNum))
		Asrimouth.animation = str(AsriNum)
		# add the necessary variables for when I want to fade in the new character animation and call the new dialogue array


func character_talking():
	DialogueManager.wes_talking.connect(Wes_mouth_moving)
	DialogueManager.asri_talking.connect(Asri_mouth_moving)
	DialogueManager.stop_talking.connect(stop_mouth_moving)
func Wes_mouth_moving():
	Wesmouth.play(str(WesNum))
func Asri_mouth_moving():
	Asrimouth.play(str(AsriNum))
func stop_mouth_moving():
	Wesmouth.stop()
	Asrimouth.stop()


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
	character_movement()


func dialogue_go():
	dialogueNum = "A" + str(AsriNum) + "W" + str(WesNum)
	#DialogueManager.start_dialogue(lines)
	DialogueManager.dialogue_player(dialogueNum)

func end_sequence():
	# this will be used the next time the buttons are suppose to be available, but a character has reached 50
	pass
