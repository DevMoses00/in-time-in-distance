extends Node

# JSON Variables
#var json = JSON.new()
#var dialogue_string = FileAccess.get_file_as_string("res://Dialogue/.ITID_dialogue.json")
#var dialogue_dict = JSON.parse_string(dialogue_string)
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


# maybe I replace the position parameter with which dialogue text box I want to call
func start_dialogue(lines: Array[String]):
	if is_dialogue_active:
		return
	
	dialogue_lines = lines
	
	
	_show_text_box()
	
	is_dialogue_active = true

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
	
	if dialogue_lines[current_line_index].begins_with("CATHY:"):
		text_box.global_position = Vector2(670, -10)
	
	elif dialogue_lines[current_line_index].begins_with("MAC:"):
		text_box.global_position = Vector2(-280, -10)
	
	text_box_tween = get_tree().create_tween().set_loops()
	# tween animation
	text_box_tween.tween_property(text_box, "scale",Vector2(1.01,1.01),.1)
	text_box_tween.tween_interval(1)
	text_box_tween.tween_property(text_box, "scale",Vector2(.98,.98),.1)
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
		
		current_line_index += 1
		if current_line_index >= dialogue_lines.size():
			is_dialogue_active = false
			current_line_index = 0
			# send a signal saying that this line is over and a new action must occur?
			buttons_enabled.emit()
			return
		
		_show_text_box()
