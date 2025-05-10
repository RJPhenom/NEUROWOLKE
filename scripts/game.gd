extends Control

# VARS
# Preload keystroke sfx assets
var keystrokes = [
	preload("res://assets/sfx/beep.wav")
]

# Audio stream player
var keystroke_player: AudioStreamPlayer

# Dialoge controls
var dialogue_history: Label
var dialogue_scrollbox: ScrollContainer
var dialogue_options: VBoxContainer
var dialogue_theme = load("res://styles/tros_theme.tres")
var dialogue_scroll_speed = 0.04 # in seconds

# Subject controls
var subject_details: Label
var subject_tracker: int = 1

# Boolean state trackers
var is_text_scrolling = false
var win: bool = false

# Begin play
func _ready():
	# Audio stream player ref
	keystroke_player = get_node("AudioStreamPlayer")
	
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
			return ["SUBJECT", "So detective, want to tell me why I’m here?", 002]
		001002:
			return ["SUBJECT", "No, care to enlighten me?", 002]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 003]
		002000:
			return ["SUBJECT", "Wait, you can’t be serious. I didn’t know I was breaking the law, "
			+ "I thought everything was on the up and up. Hans told me we were investigating a mole. "
			+ "You got to believe me.", 004]
		002001:
			return ["SYSTEM", "CHOOSE A SUBJECT TO INQUIRE ABOUT", 004]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		001003:
			return ["SUBJECT", "You think I’m one of those damn robots?", 000]
		_:
			return ["SYS", "Unknown option: The void stares back.", 000]

# Fetches options by switch ID
func get_dialogue_options(id: int) -> Array:
	match id:
		000:
			return ["END"]
		001:
			return [
				["Hello, I am detective Richter. I will be overseeing your examination today, Herr Anderson.", 001001], 
				["Greetings, Mr Anderson, do you know why you are here?", 001002],
				["Kunstgeist", 001003]
			]
		002:
			return [
				["If what you’re saying is true then you’d certainly be exonerated. If you can prove it.", 002001]
			]
		003:
			return [
				["Yes and once I prove it, I’m going to enjoy frying that tin can you call a skull. We know you were involved in the attack.", 002001]
			]
		004:
			return [
				["[INQUIRE ABOUT HIS PAST]", 002001],
				["[INQUIRE ABOUT HIS CONSPIRATORS]", 002001],
				["[INQUIRE IF HE'S A KUNSTGEIST]", 002001],
			]
		005:
			return [
				["[INQUIRE ABOUT HIS PAST]", 002001],
				["[INQUIRE ABOUT HIS CONSPIRATORS]", 002001],
				["[INQUIRE IF HE'S A KUNSTGEIST]", 002001],
				["[RENDER JUDGEMENT]", 002001]
			]
		006:
			return [
				["If what you’re saying is true then you’d certainly be exonerated. If you can prove it.", 002001]
			]
		007:
			return [
				["If what you’re saying is true then you’d certainly be exonerated. If you can prove it.", 002001]
			]

		_:
			return []

# Wrties to the history label/scrollbox
func write_to_dialogue_history(speaker: String, text: String, scrolling: bool, options: Array = []):
	var win_states = [
		"END_WIN_HUMAN",
		"END_WIN_KUNST",
	]
	
	var lose_states = [
		"END_LOSE_HUMAN",
		"END_LOSE_KUNST"
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
	var speaker_prefix = "\n\n\n//" + speaker + ":   "
	var appendage_text = text
	
	if !scrolling:
		dialogue_history.text = history + speaker_prefix + appendage_text
		return
	
	# Handles text scrolling animation
	var scrolled_text = history + speaker_prefix
	
	is_text_scrolling = true
	while is_text_scrolling:
		# Avoids null appendage in end states
		if appendage_text.length() > 0: scrolled_text += appendage_text[0]
		else: 
			is_text_scrolling = false
			break
		
		# Writes the scrolled char
		dialogue_history.text = scrolled_text
		play_random_keystroke()
		
		# Avoids overflow on array
		if appendage_text.length() == 1:
			is_text_scrolling = false
		else:
			appendage_text = appendage_text.substr(1)
			dialogue_scrollbox.scroll_vertical = dialogue_scrollbox.get_v_scroll_bar().max_value
			await get_tree().create_timer(dialogue_scroll_speed).timeout
	
	if !options.is_empty(): write_to_dialogue_options(options)

# Clears the dialogue options vbox of children
func clear_dialogue_options():
	for child in dialogue_options.get_children():
		child.queue_free()

# Writes options to the vbox as buttons for dialogue interaction
func write_to_dialogue_options(options: Array):
	while is_text_scrolling:
		await get_tree().create_timer(0.1).timeout
		
	if options == ["END"]:
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
	var response_options = get_dialogue_options(option_response[2])
	
	write_to_dialogue_history("YOU", option_text, false)
	write_to_dialogue_history(option_response[0], option_response[1], true, response_options)

# Sets subject details
func set_subject_details(subject: Array):
	subject_details.text = subject[0] + "\n" + subject[1] + "\n" + subject[2]

# Fetches and sets subject details
func get_subject(subject_id: int) -> Array:
	match subject_id:
		1:
			return ["CLIVE ANDERSON", "ACADIAN COLONIES", "DATA THEFT", 001, 
				"//:   Your first subject is brought to you. He sits in a chair and a Shinka-seishi Deck is placed on his head."
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
	write_to_dialogue_history("NARRATOR", subject[4], true)
	
	# Init dialogue options
	var opening_options = get_dialogue_options(subject[3])
	if !opening_options.is_empty(): write_to_dialogue_options(opening_options)

# Plays a random keystroke sfx
func play_random_keystroke():
	var random_keystroke = randi() % keystrokes.size()
	var keystroke = keystrokes[random_keystroke]
	
	keystroke_player.stream = keystroke
	keystroke_player.play()
