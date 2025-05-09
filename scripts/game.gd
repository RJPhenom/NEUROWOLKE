extends Control

# VARS
# Dialoge controls
var dialogue_history: Label
var dialogue_scrollbox: ScrollContainer
var dialogue_options: VBoxContainer
var dialogue_theme = load("res://styles/tros_theme.tres")

# Subject controls
var subject_details: Label
var subject_tracker: int = 1

var win: bool = false

# Begin play
func _ready():
	# Control references
	dialogue_history = get_node("DialogueMargin/DialogueVbox/DialogueHistoryScrollbox/DialogueHistoryVbox/DialogueHistoryLabel")
	dialogue_scrollbox = get_node("DialogueMargin/DialogueVbox/DialogueHistoryScrollbox")
	dialogue_options = get_node("DialogueMargin/DialogueVbox/DialogueOptionsVbox")
	
	subject_details = get_node("DialogueMargin/DialogueVbox/SubjectHbox/SubjectDetails")
	
	# Initializes the first subject conversation
	init_new_subject(subject_tracker)

# Fetchs dialogue by switch ID
func get_dialogue_response(id: int) -> Array:
	match id:
		001001:
			return ["Response one.", 001]
		001002:
			return ["Response two.", 001]
		001003:
			return ["END_WIN_HUMAN", 000]
		_:
			return ["Unknown option: The void stares back.", 000]

# Fetches options by switch ID
func get_dialogue_options(id: int) -> Array:
	match id:
		001:
			return [
				["Hello, I am detective Richter. I will be overseeing your examination today, Herr Anderson.", 001001], 
				["Greetings, Mr Anderson, do you know why you are here?", 001002],
				["Kunstgeist", 001003]
			]
		_:
			return []

# Wrties to the history label/scrollbox
func write_to_dialogue_history(text: String):
	var win_states = [
		"//SUBJECT:   END_WIN_HUMAN",
		"//SUBJECT:   END_WIN_KUNST",
	]
	
	var lose_states = [
		"//SUBJECT:   END_LOSE_HUMAN",
		"//SUBJECT:   END_LOSE_KUNST"
	]
	
	if text in win_states:
		# Debug
		print("Conversation End state reached. Player is currently winning.")
		
		win = true
		clear_dialogue_options()
		
		# TODO: Add convo end anim
		subject_tracker += 1	
		init_new_subject(subject_tracker)
		
		return
	
	elif text in lose_states:
		# Debug
		print("Conversation End state reached. Player has lost.")
		
		win = false
		clear_dialogue_options()
		
		# TODO: Add convo end anim
		init_new_subject(0)
		
		return
	
	var history = dialogue_history.text
	history += "\n\n\n" + text
	
	dialogue_history.text = history
	
	await get_tree().create_timer(0.2).timeout
	dialogue_scrollbox.scroll_vertical = dialogue_scrollbox.get_v_scroll_bar().max_value

# Clears the dialogue options vbox of children
func clear_dialogue_options():
	for child in dialogue_options.get_children():
		child.queue_free()

# Writes options to the vbox as buttons for dialogue interaction
func write_to_dialogue_options(options: Array):
	if options.is_empty():
		# Debug
		print("Game End state reached.")
		
		if win: get_tree().call_deferred("change_scene_to_file", "res://scenes/win_screen.tscn")
		else: get_tree().call_deferred("change_scene_to_file", "res://scenes/lose_screen.tscn")
		
		return
	
	clear_dialogue_options()
	for i in options.size():
		var option = options[i]
		var option_button = Button.new()
		option_button.theme = dialogue_theme
		option_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		option_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		option_button.text = "//" + str(i + 1) + ".   " + option[0]
		option_button.pressed.connect(exec_dialogue_option.bind(option))

		dialogue_options.add_child(option_button)

# Dialogue option button press handler
func exec_dialogue_option(option: Array):
	var option_text = option[0]
	var option_response = get_dialogue_response(option[1])
	var response_options = get_dialogue_options(option_response[1])
	
	write_to_dialogue_history("//YOU:   " + option_text)
	write_to_dialogue_history("//SUBJECT:   " + option_response[0])
	write_to_dialogue_options(response_options)

# Sets subject details
func set_subject_details(subject: Array):
	subject_details.text = subject[0] + "\n" + subject[1] + "\n" + subject[2]

# Fetches and sets subject details
func get_subject(subject_id: int) -> Array:
	match subject_id:
		1:
			return ["CLIVE ANDERSON", "ACADIAN COLONIES", "DATA THEFT", 001, 
				"//:   Your first subject is brought to you. He sits in a chair and a Shinka-seishi Cyberdeck is placed on his head."
				+ "It’s purpose is to help monitor the subjects responses."
				+ "\n\n\n"
				+ "It’s second function is to allow you to eliminate."]
		_:
			return ["[SUBJECT]", "[ORIGIN]", "[CRIME]", 000, ""]

# Initializes a new subject and conversation
func init_new_subject(subject_id: int):
	# Fetch subject
	var subject = get_subject(subject_id)
	
	# Write details and opening
	set_subject_details(subject)
	write_to_dialogue_history(subject[4])
	
	# Init dialogue options
	var opening_options = get_dialogue_options(subject[3])
	if !opening_options.is_empty(): write_to_dialogue_options(opening_options)
