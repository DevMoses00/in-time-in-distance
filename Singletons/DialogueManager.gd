extends Node

# I might not to load this like such?
@onready var text_box_scene = preload("res://Scenes/text_box.tscn")

var dialogue_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2
var text_box_tween : Tween

var is_dialogue_active = false
var can_advance_line = false

#var textA : Vector2 = Vector2(-870,200)
#
#const lines: Array[String] = [
	#"Hey I'm testing this clock thing out",
	#"Well I'm doing it for the second time wowza",
	#"This is going to be a pain in the neck that's for sure",
#]

signal dialogue_started

# maybe I replace the position parameter with which dialogue text box I want to call
func start_dialogue(position: Vector2, lines: Array[String]):
	if is_dialogue_active:
		return
	
	dialogue_lines = lines
	
	# maybe remove
	text_box_position = position
	
	_show_text_box()
	
	is_dialogue_active = true

func _show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	text_box.global_position = text_box_position
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
			return
		
		_show_text_box()
