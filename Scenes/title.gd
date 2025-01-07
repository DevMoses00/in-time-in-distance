extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	fade_tween_in($Clock)
	SoundManager.fade_in_bgs("Ticking",2.0)
	await get_tree().create_timer(4).timeout
	fade_tween_out($Clock)
	await get_tree().create_timer(2).timeout
	fade_tween($VineMossLogo)
	await get_tree().create_timer(9).timeout
	fade_tween_in($Container/VBoxContainer/Label)
	await get_tree().create_timer(8).timeout
	fade_tween_in($Container/VBoxContainer/Label2)
	await get_tree().create_timer(9).timeout
	fade_tween_in($Container/VBoxContainer/Label3)
	await get_tree().create_timer(12).timeout
	fade_tween_out($Container/VBoxContainer/Label)
	fade_tween_out($Container/VBoxContainer/Label2)
	fade_tween_out($Container/VBoxContainer/Label3)
	await get_tree().create_timer(1).timeout
	$TitleAnim.play()
	fade_tween_in($TitleAnim)
	shrink()
	SoundManager.fade_out("Ticking",5.0)
	SoundManager.fade_in_mfx("SynthA",1.0)
	await get_tree().create_timer(2).timeout
	SoundManager.fade_in_mfx("SynthC",1.0)
	await get_tree().create_timer(2).timeout
	SoundManager.fade_in_mfx("SynthB",1.0)
	await get_tree().create_timer(4).timeout
	$Play.disabled = false
	fade_tween_in($Play)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fade_tween(image) -> void:
	var fadeTween = get_tree().create_tween()
	fadeTween.tween_property(image,"modulate",Color(1.0, 1.0, 1.0, 1.0), 2)
	fadeTween.tween_interval(5)
	fadeTween.tween_property(image,"modulate",Color(1.0, 1.0, 1.0, 0.0), 2)

func fade_tween_in(image) -> void:
	var fadeTween = get_tree().create_tween()
	fadeTween.tween_property(image,"modulate",Color(1.0, 1.0, 1.0, 1.0), 2)

func fade_tween_out(image) -> void:
	var fadeTween = get_tree().create_tween()
	fadeTween.tween_property(image,"modulate",Color(1.0, 1.0, 1.0, 0.0), 2)

func shrink():
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($TitleAnim, "scale",Vector2(0.7,0.7),6)
	tween.tween_property($TitleAnim, "position:y",-50,6)


func _on_play_pressed() -> void:
	$Play.hide()
	SoundManager.stop_all()
	$Background.stop()
	fade_tween_out($TitleAnim)
	await get_tree().create_timer(2).timeout
	fade_tween_in($Clock)
	await get_tree().create_timer(2).timeout
	fade_tween_out($Clock)
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
