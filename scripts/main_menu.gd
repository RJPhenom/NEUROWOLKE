extends Control

# VARS
# Preload keystroke sfx assets
var keystrokes = [
	preload("res://assets/sfx/beep.wav")
]

# Audio stream player
var keystroke_player: AudioStreamPlayer

# Preamble text handling
var preamble_node: Label
var preamble = "//SYSTEM:   The year is 2871. 

Technology controls our lives.

Large corporations struggle for dominance.

You work in the HERRSCHAFT DEUTSCHE, a collection of star systems run by German Korporation Colonists.

You are Detective Albrecht Richter, tasked with finding and eliminating KUNSTGEIST: humanlike androids that have gone rogue.

To identify kunstgeist is difficult. you must perform a GEIST-KAMPFF TEST. 

Use it to draw out your suspect's humanity… or its absence.



::MISSION::

Recently there was a massive cyber attack on cloud data company NEUROWOLKE.  

A  rogue kunstgeist collective claimed responsibility. Three perpetrators were caught.

Normally they would receive summary execution. However, this attack seems to be an inside job: the perpetrators are all mid ranking members of NeuroWolke. 

You must perform an interrogation. 

Discover who are loyal members of the company and eliminate the perpetrators."
# *****************************************************************************

func _ready() -> void:
	BgmPlayer.play()
	
	keystroke_player = get_node("AudioStreamPlayer")
	preamble_node = get_node("MarginContainer2/HBoxContainer/MenuMargin/MenuVBox/Preamble")
	
	var appendage_text = preamble
	var printed_text = ""
	
	while appendage_text.length() > 0:
		var appendage_char = appendage_text[0]
		printed_text += appendage_char
		appendage_text = appendage_text.substr(1)
		
		preamble_node.text = printed_text
		if appendage_char != "\n": 
			play_random_keystroke()
			await get_tree().create_timer(0.04).timeout
		else:
			await get_tree().create_timer(0.4).timeout

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func play_random_keystroke():
	var random_keystroke = randi() % keystrokes.size()
	var keystroke = keystrokes[random_keystroke]
	
	keystroke_player.stream = keystroke
	keystroke_player.play()
