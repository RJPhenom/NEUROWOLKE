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
	dialogue_history = get_node("MarginContainer2/HBoxContainer/DialogueMargin/DialogueVbox/DialogueHistoryScrollbox/DialogueHistoryVbox/DialogueHistoryLabel")
	dialogue_scrollbox = get_node("MarginContainer2/HBoxContainer/DialogueMargin/DialogueVbox/DialogueHistoryScrollbox")
	dialogue_options = get_node("MarginContainer2/HBoxContainer/DialogueMargin/DialogueVbox/DialogueOptionsVbox")
	dialogue_options.add_spacer(true)
	
	subject_details = get_node("MarginContainer2/HBoxContainer/DialogueMargin/DialogueVbox/SubjectHbox/SubjectDetails")
	
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
		002001:
			return ["SUBJECT", "Wait, you can’t be serious. I didn’t know I was breaking the law, I thought everything was on the up and up. Hans told me we were investigating a mole. You got to believe me.", 004]
		002002:
			return ["SYSTEM", "CHOOSE A SUBJECT TO INQUIRE ABOUT", 005]
		003100:
			return ["SYS", "", 007]
		003200:
			return ["SYS", "", 023]
		003300:
			return ["SYS", "", 040]
		003110:
			return ["SUBJECT", "Yeah, rough times lately. Not that I ever knew how it was during the golden age.", 008]
		003111:
			return ["SUBJECT", "You kidding? We were basically the most important place in the entire quadrant. Trade, manufacturing starships, everything. Not that it ever did me any good.", 009]
		003112:
			return ["SUBJECT", "Guys like me struggle to get by. I do all the grunt work while my bosses drink cocktails. All the work with none of the credit. But I managed.", 006]
		003120:
			return ["SUBJECT", "Don’t have one. Born an orphan.", 010]
		003121:
			return ["SUBJECT", "It sucked! Going from group home to group home. People treat you like shit.", 011]
		003122:
			return ["SUBJECT", "It was. Growing up with no one having your back.", 012]
		003123:
			return ["SUBJECT", "I’m not exactly popular with the ladies. Tried to make a pass on our Hacker Yami. Lady nearly broke my arm off. Also punched me right in the face!", 013]
		003124:
			return ["SUBJECT", "I know, right? Makes no sense to me either.", 006]
		003125:
			return ["SUBJECT", "What do you know? You don’t know me.", 006]
		003126:
			return ["SUBJECT", "Screw you man, I should smack you for saying that.", 014]
		003127:
			return ["SUBJECT", "Pfft!", 006]
		003130:
			return ["SUBJECT", "Wasn’t by choice, let me tell you that. You think I like having my brain used as a storage device?", 015]
		003131:
			return ["SUBJECT", "Just trying to get by, like everyone else. You don’t know how hard it is to make a living. I need to do whatever pays the bills.", 016]
		003132:
			return ["SUBJECT", "Stop lumping me in with those damn machines. I don’t look at any of the files they put in my head. Probably wouldn’t understand them even if I did.", 017]
		003133:
			return ["SUBJECT", "None. That's above my pay grade.", 018]
		003134:
			return ["SUBJECT", "Not a soul, you arrested us before I could unload the files.", 006]
		003210:
			return ["SUBJECT", "She’s pretty good at her job, quickest hacker I’ve ever seen. Not bad on the eyes either.", 024]
		003211:
			return ["SUBJECT", "Have you seen her? Of course I am! Got a nasty temper on her though. My jaw’s still sore from her left hook.", 025]
		003212:
			return ["SUBJECT", "I have no idea what I could have done. I’ve been nothing but friendly to the lady.", 026]
		003213:
			return ["SUBJECT", "She did say the same thing, but I just assumed she was playing hard to get!", 027]
		003214:
			return ["SUBJECT", "Would be a shame if she was. But…", 028]
		003215:
			return ["SUBJECT", "It wouldn’t surprise me. If you ask me, someone who can hack that fast can’t possibly be human.", 006]
		003220:
			return ["SUBJECT", "He’s the one who made us do this job in the first place. Real piece of work that guy. ", 029]
		003221:
			return ["SUBJECT", "Of course not! He tells us to do a job then gets mad at us when we get arrested for listening to him...
			
			I also expected him to do his research and make sure we weren't going to be committing a crime that’ll cost us our lives.", 030]
		003222:
			return ["SUBJECT", "Probably! He seems too loyal if you get my meaning. Ain’t no one that honest. Wouldn’t surprise me if he’s a Kunstgeist.", 031]
		003223:
			return ["SUBJECT", "Yeah, I do. He follows any orders he gets without question.", 032]
		003224:
			return ["SUBJECT", "Or a Kunstgeist trying not to get caught. So why don’t you let me go and question him instead.", 033]
		003230:
			return ["SUBJECT", "Based on what our leader said, the company had a mole inside it. We were told to stealthily take information from the company, so we don’t tip off the mole.", 034]
		003231:
			return ["SUBJECT", "Heh, you can say that again. I knew this job was a bad idea. I had a feeling things would go downhill.", 035]
		003232:
			return ["SUBJECT", "I can’t afford to not work. Lot of jobs I gotta do, that I’d rather not.", 036]
		003233:
			return ["SUBJECT", "Well our leader broke into the facility and disabled the camera’s, we snuck into the server rooms and our hacker got the files and uploaded em in my head.", 037]
		003234:
			return ["SUBJECT", "Now that you mention it there was a moment when our hacker, Yami got separated from us...
			
			While the files were downloading to my brain, she just up and left without saying a word. Left me and the leader panicking. Though she sold us out for a second. Several minutes later she came back running. Old Hans was pissed.", 038]
		003235:
			return ["SUBJECT", "Hell if I know. Hans demanded to know where she went but she refused to say.", 039]
		003236:
			return ["SUBJECT", "I was too busy trying not to get caught. Which as you can see, didn’t go so well.", 006]
		003310:
			return ["SUBJECT", "What kind of test?", 041]
		003311:
			return ["SUBJECT", "Okay", 042]
		003312:
			return ["SUBJECT", "What? Is that a question?", 043]
		003313:
			return ["SUBJECT", "Well then I’d rather not respond at all.", 044]
		003314:
			return ["SUBJECT", "...", 045]
		003315:
			return ["SUBJECT", "I don’t know. Seems an odd thing to say to me. Why would I eat a turtle?", 045]
		003316:
			return ["SUBJECT", "Alright…", 046]
		003317:
			return ["SUBJECT", "... what? I don't know! Some test...", 047]
		003318:
			return ["SUBJECT", "Don’t got a wife.", 048]
		003319:
			return ["SUBJECT", "Can I imagine her pretty?", 049]
		003320:
			return ["SUBJECT", "Would be nice, now, wouldn't it?", 050]
		003321:
			return ["SUBJECT", "Fine.", 050]
		003322:
			return ["SUBJECT", "Well he’d deserve it, in that case, wouldn’t he?", 051]
		003323:
			return ["SUBJECT", "I'd say so.", 052]
		003324:
			return ["SUBJECT", "He must have been an ungrateful bastard.", 053]
		004000:
			return ["SYS", "", 054]
		004100:
			return ["SYS", "", 055]
		004101:
			return ["SUBJECT", "Yes, of course! Thank you so much sir.", 056]
		004102:
			return ["NARRATOR", "You spare him and continue your investigations of the other two members. After several hours of questioning, you yield little in terms of results. The three of them are set free. 

			Your life returns to mostly mundane paperwork for the next several months.

			One day, a terrorist attack takes place on the planet Neubayern, at the heart of the Herrschaft Deutsche… many die. 

			The attack is carried out by none other than Mr. Clive Andersen. He was a Kunstgeist the entire time. 

			For failing to identify him, you are held responsible for letting the attack take place. Your government sentences you to death for your incompetence. 

			Ironically, for your execution, you are placed in the same chair you questioned him in. 

			You feel a sudden jolt of pain as you're electrocuted. Your mind fades into darkness.

			You are dead.", 057]
		004103:
			return ["SYS", "END_LOSE_KUNST", 000]
		004200:
			return ["NARRATOR", "After questioning him, you believe him to be a Kunstgeist. An android rebel bent on throwing the dominion into chaos.

			You flip the switch and begin his execution.

			He lets out several yells in pain.

			After his death, his body is taken in for examination. The coroner does confirm that Mr. Clive Andersen was in fact a Kunstgeist.

			You have done your job adequately, detective.", 058]
		004201:
			return ["SYS", "END_WIN_KUNST", 000]
		005000:
			return ["SUBJECT","[Her attitude seems hostile]", 060]
		005001:
			return ["SUBJECT", "Is that supposed to help you figure out if I’m a Kunstgeist in some way?", 061]
		006000:
			return ["SYS", "", 061]
		006100:
			return ["SYS", "", 063]
		006101:
			return ["SUBJECT", "I’m from Koto...", 064]
		006102:
			return ["SUBJECT", "It’s mostly a Japanese controlled quadrant. The companies have a monopoly on rare metals there, mostly used for computing. They also have better performing AI.", 065]
		006103:
			return ["SUBJECT", "Yeah, I’m from Shitamachi... one of the lower class districts. So either you help with mining operations or become a Netrunner. I chose the latter.", 061]
		006100:
			return ["SUBJECT", "", 061]
		006100:
			return ["SUBJECT", "", 061]
		006100:
			return ["SUBJECT", "", 061]
		006100:
			return ["SUBJECT", "", 061]
		006100:
			return ["SUBJECT", "", 061]
		006100:
			return ["SUBJECT", "", 061]
		006100:
			return ["SUBJECT", "", 061]
		006100:
			return ["SUBJECT", "", 061]
		
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
				["We know you were involved in a large data theft incident. You attacked your employer, NeuroWolke. The punishment for such a crime is death.", 002001]			]
		003:
			return [
				["Yes and once I prove it, I’m going to enjoy frying that tin can you call a skull. We know you were involved in the attack.", 002001]
			]
		004:
			return [
				["If what you’re saying is true then you’d certainly be exonerated. If you can prove it.", 002002]
			]
		005:
			return [
				["[INQUIRE ABOUT HIS PAST]", 003100],
				["[INQUIRE ABOUT HIS CONSPIRATORS]", 003200],
				["[PROCEED TO GEIST-KAMPFF TEST]", 003300]
			]
		006:
			return [
				["[INQUIRE ABOUT HIS PAST]", 003100],
				["[INQUIRE ABOUT HIS CONSPIRATORS]", 003200],
				["[PROCEED TO GEIST-KAMPFF TEST]", 003300],
				["[RENDER JUDGMENT]", 004000]
			]
		007:
			return [
				["You're from the Acadian Colonies right?", 003110],
				["Tell me about your family", 003120],
				["How did you become a Datamule?", 003113],
			]
		008:
			return [
				["Golden age?", 003111]
			]
		009:
			return [
				["Didn’t share in the wealth?", 003112]
			]
		010:
			return [
				["Tell me about that?", 003121]
			]
		011:
			return [
				["Sounds rough. ", 003122]
			]
		012:
			return [
				["No family, children, lovers?", 003123]
			]
		013:
			return [
				["Geez I wonder why? You seem like such a pleasant fella. ", 003124],
				["Probably serves you right.", 003125],
				["You do have a very punchable face.", 003126]
			]
		014:
			return [
				["Striking an investigator is a crime punishable by death.", 003127]
			]
		015:
			return [
				["Then why be a datamule in the first place?", 003131]
			]
		016:
			return [
				["You must learn a whole lot of secrets? Would be really dangerous if you turned out to be a kunstgeist.", 003132]
			]
		017:
			return [
				["So you didn’t look at any of the stolen files?", 003133]
			]
		018:
			return [
				["That’s convenient if you’re telling the truth, you did take a lot of sensitive data. So you didn’t share the data with anyone?", 003134]
			]
		019:
			return [
				["Sounds rough. ", 003122]
			]
		020:
			return [
				["No family, children, lovers?", 003123]
			]
		021:
			return [
				["Geez I wonder why? You seem like such a pleasant fella. ", 003124],
				["Probably serves you right.", 003125],
				["You do have a very punchable face.", 003126]
			]
		022:
			return [
				["Striking an investigator is a crime punishable by death.", 003127]
			]
		023:
			return [
				["Tell me about your hacker, Mrs. Yami Kumo", 003210],
				["Tell me about your boss, Herr Oberst Hans Adler", 003220],
				["Why did your trio steal information from the company?", 003230]
			]
		024:
			return [
				["So you're attracted to her?", 003211]
			]
		025:
			return [
				["You must have made her pretty angry.", 003212]
			]
		026:
			return [
				["Her file does say she’s married.", 003213]
			]
		027:
			return [
				["I’ll cut to the chase. Do you think she’s a kunstgeist?", 003214]
			]
		028:
			return [
				["But what?", 003215]
			]
		029:
			return [
				["You don’t like him?", 003221]
			]
		030:
			return [
				["Do you think he willingly betrayed NeuroWolke?", 003222]
			]
		031:
			return [
				["You think he’s a kunstgeist?", 003223]
			]
		032:
			return [
				["Some people would say that’s loyalty to NeuroWolke.", 003224]
			]
		033:
			return [
				["I’ll get to him eventually, but right now I’m focusing on you.", 002002]
			]
		034:
			return [
				["Bet you didn’t think the mole would be on your team?", 003231]
			]
		035:
			return [
				["Then why take this job?", 003232]
			]
		036:
			return [
				["Tell me about the hacking, I want to hear how things went down.", 003233]
			]
		037:
			return [
				["Did anything about the actual theft seem off to you?", 003234]
			]
		038:
			return [
				["What do you think she was doing?", 003235]
			]
		039:
			return [
				["You didn't ask?", 003236]
			]
		040:
			return [
				["I am going to conduct a test. Please sit still and answer the questions.", 003310]
			]
		041:
			return [
				["This test measures emotional response. Please focus. ", 003311],
				["You’re in a desert, with dry heat. You find a tortoise lying flipped on its back. You’re starving. It looks delicious.", 003312]
			]
		042:
			return [
				["You’re in a desert, with dry heat. You find a tortoise lying flipped on its back. You’re starving. It looks delicious.", 003312]
			]
		043:
			return [
				["It’s meant to provoke a reaction. You can respond however you like.", 003313],
				["It is. What do you think about that?", 003315],
				["The sun lowers, the moon comes out. In its light you see a scorpion. You squash it under your boot.", 003316],
				["[RENDER JUDGMENT]", 004000]
			]
		044:
			return [
				["You can do that.", 003314]
			]
		045:
			return [
				["The sun lowers, the moon comes out. In its light you see a scorpion. You squash it under your boot.", 003316],
				["[RENDER JUDGMENT]", 004000]
			]
		046:
			return [
				["[Let the silence linger]", 003317],
				["You come home to find your wife in bed with another man", 003318],
				["[RENDER JUDGMENT]", 004000]
			]
		047:
			return [
				["You come home to find your wife in bed with another man", 003318],
				["[RENDER JUDGMENT]", 004000]
			]
		048:
			return [
				["Use your imagination.", 003319],
				["It doesn't matter. This is fiction we're dealing with. Don't you want one, anyway?", 003321],
				["You pull back the fur blankets and strike the man.", 003322],
				["[RENDER JUDGMENT]", 004000]
			]
		049:
			return [
				["Sure", 003320],
				["She's beautiful. You're heartbroken.", 003320]
			]
		050:
			return [
				["You pull back the fur blankets and strike the man.", 003],
				["[RENDER JUDGMENT]", 004000]
			]
		051:
			return [
				["He might. [Ask one final question]", 003323],
				["[RENDER JUDGMENT]", 004000]
			]
		052:
			return [
				["It was your brother. He was wearing a calfskin jacket you gave him for his birthday.", 003324]
			]
		053:
			return [
				["[RENDER JUDGMENT]", 004000]
			]
		054:
			return [
				["[HUMAN — SPARE HIM]", 004100],
				["[KUNSTGEIST — ELIMINATE]", 004200]
			]
		055:
			return [
				["Today’s your lucky day Mr. Andersen, you passed the test, once we can corroborate your story you’re free to go. We will still require your additional support in bringing the kunstgeist to justice.", 004101]
			]
		056:
			return [
				["Goodbye.", 004102]
			]
		057:
			return [
				["CONTINUE", 004103]
			]
		058:
			return [
				["CONTINUE", 004201]
			]
		059:
			return [
				["Hello Mrs. Kumo. I’m here to determine if you’re a kunstgeist.", 005000],
				["What’s with the cigarette burns? Are those self-inflicted?", 005001],
				["[PROCEED TO QUESTIONS]", 006000]
			]
		060:
			return [
				["I suppose not, let's begin.", 006000],
				["[Do not respond]", 006000]
			]
		061:
			return [
				["[INQUIRE ABOUT HER PAST]", 006100],
				["[INQUIRE ABOUT HER CONSPIRATORS]", 006200],
				["[PROCEED TO GEIST-KAMPFF TEST]", 006300]
			]
		062:
			return [
				["[INQUIRE ABOUT HER PAST]", 006100],
				["[INQUIRE ABOUT HER CONSPIRATORS]", 006200],
				["[PROCEED TO GEIST-KAMPFF TEST]", 006300],
				["[RENDER JUDGEMENT]", 010000]
			]
		063:
			return [
				["Where are you from, originally?", 006101],
				["Tell me about your family?", 003210],
				["Please state your position and job description for the record.", 003210],
			]
		064:
			return [
				["Tell me about that. ", 006102]
			]
		065:
			return [
				["That's why you became a Netrunner?", 006103]
			]
		066:
			return [
				["", 003210]
			]
		067:
			return [
				["", 003210]
			]
		068:
			return [
				["", 003210]
			]
		069:
			return [
				["", 003210]
			]
		070:
			return [
				["", 003210]
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
	
	is_text_scrolling = appendage_text.length() >0
	while is_text_scrolling:
		var appendage_char = appendage_text[0]
		scrolled_text += appendage_char
		appendage_text = appendage_text.substr(1)
		if appendage_text.is_empty(): is_text_scrolling = false
		
		dialogue_history.text = scrolled_text
		
		if appendage_char != "\n":
			play_random_keystroke()
			scroll_to_end()
			await get_tree().create_timer(0.004).timeout
		else:
			scroll_to_end()
			await get_tree().create_timer(0.4).timeout
	
	if !options.is_empty(): write_to_dialogue_options(options)

# Clears the dialogue options vbox of children
func clear_dialogue_options():
	for child in dialogue_options.get_children():
		child.queue_free()
	
	dialogue_options.add_spacer(true)

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
	
	# Clear previous subject dialogue
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
	
	scroll_to_end()

# Dialogue option button press handler
func exec_dialogue_option(option: Array):
	if !is_text_scrolling:
		var option_text = option[0]
		var option_response = get_dialogue_response(option[1])
		var response_options = get_dialogue_options(option_response[2])
		
		write_to_dialogue_history("YOU", option_text, false)
		write_to_dialogue_history(option_response[0], option_response[1], true, response_options)
		
		scroll_to_end()

# Sets subject details
func set_subject_details(subject: Array):
	subject_details.text = subject[0] + "\n" + subject[1] + "\n" + subject[2]

# Fetches and sets subject details
func get_subject(subject_id: int) -> Array:
	match subject_id:
		1:
			return ["CLIVE ANDERSON", "ACADIAN COLONIES", "DATA MULE", 001, 
				"Your first subject is brought to you. He sits in a chair and a Shinka-seishi Deck is placed on his head. It’s purpose is to help monitor the subjects responses.

				It’s second function is to eliminate."]
		2:
			return ["YAMI KUMO", "鉱東:下町 [KOTO: SHITAMACHI REGION]", "ICE BREAKER", 059, 
				"Your second subject is brought in. She is a slender Japanese woman, with several tattoos. You notice cigarette burns on her left wrist. Her name is Yami Kumo. A netrunner.

				Mrs. Kumo sits in the interrogation chair. She puts the Shinka-seishi on herself."]
		3:
			return ["HERR OBERST HANS ADLER", "HERRSCHAFT DEUSTCHE", "CONSPIRACY TO COMMIT CYBERCRIME", 001, 
				"Your final subject enters. He is tall. Broad. German. He has a stale face, grimacing as he moves to sit. He wears a leather jacket, worn from age. An antique.

				You place the Shinka-seishi on him. Somehow, it makes you nervous."]
		_:
			return ["[SUBJECT]", "[ORIGIN]", "[CRIME]", 000, ""]

# Initializes a new subject and conversation
func init_new_subject(subject_id: int):
	# Clear last subject 
	clear_dialogue_history()
	
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

func scroll_to_end():
	dialogue_scrollbox.scroll_vertical = dialogue_scrollbox.get_v_scroll_bar().max_value

func clear_dialogue_history():
	dialogue_history.text = ""
