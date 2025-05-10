extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var end_audio_player: AudioStreamPlayer = get_node("AudioStreamPlayer")
	end_audio_player.play()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
