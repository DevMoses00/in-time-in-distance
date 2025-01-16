extends Node

# for the JSON file
var finish 

func readJSON(json_file_path):
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	finish = json.parse_string(content)
	return finish

@onready var text_box_scene = preload("res://Scenes/text_box.tscn")



var dialogue_lines
var current_line_index = 0

var text_box
var text_box_position: Vector2
var text_box_tween : Tween

var is_dialogue_active = false
var can_advance_line = false

signal buttons_enabled 
signal dialogue_started

# for the mouth movements
signal wes_talking
signal asri_talking
signal stop_talking
signal move_clock

# to skip a section of dialogue
signal skip_signaled

func _ready() -> void:
	skip_signaled.connect(skip_dialogue)

# Create a new dialogue start function that takes a specific set of dialogue lines
func dialogue_player(line_key):
	if is_dialogue_active:
		return
	
	dialogue_lines = finish[line_key]
	
	_show_text_box()
	
	is_dialogue_active = true

func _show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	
	if dialogue_lines[current_line_index].begins_with("R:"):
		print("ring")
		# play a ring sound
		SoundManager.stop_all()
		SoundManager.play_bgm("Alarm")
		await get_tree().create_timer(.01).timeout
		SoundManager.fade_out("Alarm",4.3)
		move_clock.emit()
		text_box.global_position = Vector2(200,-50)
	
	if dialogue_lines[current_line_index].begins_with("E:"):
		text_box.global_position = Vector2(200, 500)
	
	if dialogue_lines[current_line_index].begins_with("A:"):
		# Play an Asri sound
		tic_sound()
		text_box.global_position = Vector2(670, -10)
		asri_talking.emit()
	
	elif dialogue_lines[current_line_index].begins_with("W:"):
		# Play a Wes sound
		toc_sound()
		text_box.global_position = Vector2(-280, -10)
		wes_talking.emit()
	
	if dialogue_lines[current_line_index].begins_with("E:"):
		text_box.display_text(dialogue_lines[current_line_index])
		can_advance_line = false
		return
	
	text_box_tween = get_tree().create_tween().set_loops()
	# tween animation
	text_box_tween.tween_property(text_box, "scale",Vector2(1.01,1.01),.1)
	#text_box_tween.tween_callback(tic_sound)
	text_box_tween.tween_interval(1)
	text_box_tween.tween_property(text_box, "scale",Vector2(.98,.98),.1)
	#text_box_tween.tween_callback(toc_sound)
	text_box_tween.tween_interval(1)
	
	text_box.display_text(dialogue_lines[current_line_index])
	
	can_advance_line = false

func _on_text_box_finished_displaying():
	can_advance_line = true

func _unhandled_input(event: InputEvent) -> void:
	if (
		event.is_action_pressed("advance_dialogue") &&
		is_dialogue_active &&
		can_advance_line
	):
		text_box_tween.kill() # kill the tween loop
		text_box.queue_free()
		# have their mouths stop moving
		stop_talking.emit()
		
		current_line_index += 1
		if current_line_index >= dialogue_lines.size():
			is_dialogue_active = false
			current_line_index = 0
			# send a signal saying that this line is over and a new action must occur?
			buttons_enabled.emit()
			return
		
		_show_text_box()

func tic_sound():
	SoundManager.play_sfx("Tic")
func toc_sound():
	SoundManager.play_sfx("Toc")

func skip_dialogue():
	current_line_index = int(dialogue_lines.size())
	text_box.queue_free()
	# have their mouths stop moving
	stop_talking.emit()
	is_dialogue_active = false
	current_line_index = 0
	# send a signal saying that this line is over and a new action must occur?
	buttons_enabled.emit()
	return
