extends Node2D

var tween_sec : Tween
var tween_min : Tween
var tween_hour : Tween

@export_group("Hands")
@export var second : Sprite2D
@export var minute : Sprite2D
@export var hour : Sprite2D
@export_group("Buttons")
@export var leftbutton : Button
@export var midbutton : Button
@export var rightbutton : Button

@export_group("Panels")
@export var days : AnimatedSprite2D
@export var dates : AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clock()
	SoundManager.fade_in_bgs("Ticking",2.0)
	await get_tree().create_timer(3).timeout
	fade_tween_in($Thanks)
	await get_tree().create_timer(1).timeout
	fade_tween_in($Thanks2)
	await get_tree().create_timer(2).timeout
	fade_tween_in($Clock)
	fade_tween_in($VineMossLogo)
	await get_tree().create_timer(2).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fade_tween_in(image) -> void:
	var fadeTween = get_tree().create_tween()
	fadeTween.tween_property(image,"modulate",Color(1.0, 1.0, 1.0, 1.0), 2)

func clock():
	# sets the clock animation
	tween_sec = get_tree().create_tween().set_parallel().set_loops()
	tween_sec.tween_property(second,"rotation",TAU,1.0).from(0)
	tween_min = get_tree().create_tween().set_parallel().set_loops()
	tween_min.tween_property(minute,"rotation",TAU,1.0 * 60).from(0)
	tween_hour = get_tree().create_tween().set_parallel().set_loops()
	tween_hour.tween_property(hour,"rotation",TAU,1.0 * 3600).from(0)

func tween_kill():
	tween_sec.kill()
	tween_min.kill()
	tween_hour.kill()

func _on_right_button_2_pressed() -> void:
	SoundManager.play_sfx("LeftButton")
	tween_kill()
	days.pause()
	dates.pause()
	SoundManager.stop("Ticking")
	await get_tree().create_timer(3).timeout
	get_tree().quit()

func _on_restart_button_pressed() -> void:
	SoundManager.play_sfx("LeftButton")
	tween_kill()
	days.pause()
	dates.pause()
	SoundManager.stop("Ticking")
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://Scenes/title.tscn")



func _on_game_button_pressed() -> void:
	SoundManager.play_sfx("LeftButton")
	tween_kill()
	days.pause()
	dates.pause()
	SoundManager.stop("Ticking")
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
