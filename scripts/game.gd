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
			return ["SUBJECT", "Yeah, I’m from Shitamachi... one of the lower class districts. So either you help with mining operations or become a Netrunner. I chose the latter.", 062]
		006104:
			return ["SUBJECT", "None.", 066]
		006105:
			return ["SUBJECT", "Had… They aren’t around.", 067]
		006106:
			return ["SUBJECT", "I don’t see how this is relevant.", 068]
		006107:
			return ["NARRATOR", "[She lets out a grunted sigh, clearly irritated]
			
			They died in a mining accident. Some dumbass wasn’t monitoring the mining equipment and the mine collapsed, with my still family inside.", 069]
		006108:
			return ["SUBJECT", "My spouse was showing them around the mine, we needed to give them a head start in life. So we showed them the work they’d be doing... anyway, that's why I left Shitamachi.", 062]
		006109:
			return ["SYS", "", 062]
		006120:
			return ["SUBJECT", "Netrunner. I run ICE Breakers for corporate SecOps. Basically, I hack things.", 070]
		006121:
			return ["SUBJECT", "Started at a young age. Once I flunked the physical for working the mines, it was just sorta expected. That's how it is in Shitamachi.", 071]
		006122:
			return ["SUBJECT", "I didn’t go into the details... just enough to make sure we had the right files.", 062]
		006200:
			return ["SYS", "", 072]
		006210:
			return ["SUBJECT", "I haven’t worked with him that long but Adler seems like a pretty organized man. Always focused on work. I don’t think he has much of a social life outside of work.", 073]
		006211:
			return ["SUBJECT", "Yeah, he seems very loyal to NeuroWolke. Got really annoyed when Andersen was badmouthing the company.", 074]
		006212:
			return ["SUBJECT", "I can’t say for sure, but I doubt it. I mean he always does everything by the book. He gets really angry if things don’t go to plan. ", 075]
		006213:
			return ["SUBJECT", "He was livid when we got arrested, I think he blames me. It caught him by surprise. We were acting on official orders after all... Or so we thought.", 076]
		006214:
			return ["SUBJECT", "Yeah, anyone would be.", 062]
		006220:
			return ["SUBJECT", "The man was unprofessional and a pervert.", 077]
		006221:
			return ["SUBJECT", "Damn, really? He always seemed like he was trying a bit too hard. I just thought he was an asshole... but I guess his unwanted advances were all part of the act.", 078]
		006222:
			return ["SUBJECT", "Good riddance I say. Now can I leave?", 079]
		006223:
			return ["SUBJECT", "I may resent the company, but I’m not a traitor", 080]
		006224:
			return ["SUBJECT", "… Yes, I had to make sure we got the right information.", 062]
		006230:
			return ["SUBJECT", "Our leader, Hans Adler went ahead and shut down the security cameras. Once everything was all clear he gave us the signal to come into the server room.", 081]
		006231:
			return ["SUBJECT", "We planned it when we knew guards would be short staffed. Hans did his research. Which is more than I can say about Andersen. That jerk didn’t have a care in the world.", 082]
		006232:
			return ["SUBJECT", "We proceeded to the server room, I went into the system, found the files we were looking for and uploaded them to Andersen’s storage device. As we tried to leave we got arrested.", 083]
		006234:
			return ["SUBJECT", "None. I stayed with the other two the entire time.", 084]
		006235:
			return ["SUBJECT", "Well I...", 085]
		006236:
			return ["SUBJECT", "I don't know if I can trust you.", 086]
		006237:
			return ["SUBJECT", "Fine. While the files were uploading to Andersen’s brain, I noticed someone put a computer virus in the server room's mainframe terminal. It was a timed cyber attack that would have leaked all the security information NeuroWolke had on Neubayern. If that info got out, it could do some real damage… not to mention possibly spoil the op. I managed to stop the virus before it did any damage, but using the terminal without the clearance code set off the alarm that got us caught.", 087]
		006238:
			return ["SUBJECT", "Didn’t want the other two to know I’m the reason we got caught… but that’s not why I kept it a secret. The virus could have only been uploaded by someone with high level clearance. If that person finds out I stopped the virus, it could put a target on my back.  I don’t need that kind of attention.", 088]
		006239:
			return ["SUBJECT", "I don't want innocent folks to die. NeuroWolke protects them with that info... as fucked up as the corp may be.", 062]
		007000:
			return ["SYS", "", 089]
		007001:
			return ["SUBJECT", "Go ahead.", 090]
		007002:
			return ["SUBJECT", "Gross. I wouldn’t eat a tortoise.", 091]
		007003:
			return ["SUBJECT", "You just gonna keep telling me what I do in this test? Or do I eventually get to answer.", 092]
		007004:
			return ["SUBJECT", "Well I don’t like Scorpions but I wouldn’t squash nothing ‘ganic. That’s fucked up. At least try and sell it.", 094]
		007005:
			return ["NARRATOR", "[She seems to scowl through the Shinka-seishi]", 094]
		007006:
			return ["SUBJECT", "Then why ask?", 093]
		007007:
			return ["SYS", "", 094]
		007008:
			return ["SUBJECT", "He’d never have done that.", 095]
		007009:
			return ["SUBJECT", "Fuck you.", 096]
		007010:
			return ["SUBJECT", "Fur blankets? In Koto? You’re slippin detective. This shit’d never happen.", 097]
		007011:
			return ["SUBJECT", "I wish I had that kinda cred.", 098]
		007200:
			return ["SYS", "", 099]
		007201:
			return ["SYS", "", 100]
		007202:
			return ["SUBJECT", "Well detective. I would say this was a pleasure, but you told me not to lie to you.", 101]
		007203:
			return ["NARRATOR", "You ask her several more details about the specifics of the hack. She details how she stopped the virus attack which accidentally set off the alarm. After a few hours go by, you set Yami free from the chair. You’re fairly certain she’s human.
			
			Your report of Yami mentions that she’s a human and remains a loyal asset to the Neurowolke company.
			
			She walks out a free woman and can return to her company duties.", 102]
		007204:
			return ["SYS", "END_WIN_HUMAN", 000]
		007205:
			return ["NARRATOR", "You flip the switch and begin her execution.
			
			She screams in pain. Human pain.
			
			Once her death is confirmed, what’s left of her is immediately taken in for examination. 
			
			After about an hour, the coroner comes to you accompanied by two armed guards. Mrs Yami Kumo was human. And you killed her.
			
			Worse, she was a high value asset to the company. Under suspicion of conspiracy, you are sentenced to death. The price for your incompetence is going to be your life. They raise their weapons, pointed at your face.
			
			You are dead before you even hear the bang.", 103]
		007206:
			return ["SYS", "END_LOSE_HUMAN", 000]
		008000:
			return ["SUBJECT", "I have nothing to worry about. After all, I’m only human.", 105]
		008001:
			return ["SUBJECT", "Correct.", 106]
		008002:
			return ["NARRATOR", "[The man frowns, but says nothing.]", 107]
		008003:
			return ["SUBJECT", "I had my suspicions. Didn't seem trustworthy. Kumo told you that too, I'm sure.", 108]
		008004:
			return ["SYS", "", 108]
		008100:
			return ["SYS", "", 110]
		008101:
			return ["SUBJECT", "Die Herrschaft, born and raised.", 111]
		008102:
			return ["SUBJECT", "It was a standard childhood. Loving parents, no siblings, graduated with good grades. Nothing to note.", 112]
		008103:
			return ["SUBJECT", "It does if you love your kinsmen.", 113]
		008104:
			return ["SYS", "", 114]
		008105:
			return ["SUBJECT", "Those folks don't make colonel.", 109]
		008106:
			return ["SUBJECT", "I’ve had a few relationships over the years but none that stuck. I prefer to focus on my work", 115]
		008107:
			return ["SUBJECT", "The only one I plan on chasing is the person who set us up with fake orders.", 109]
		008200:
			return ["SYS", "", 116]
		008201:
			return ["SUBJECT", "Yami Kumo, I picked her because she’s the best of the best. Having second thoughts now though.", 117]
		008202:
			return ["SUBJECT", "No... she’s to sharp for a synthsoul. Kunst don't make good for netrunners like that. That being said, she’s a shit subordinate. Talented... but she can’t follow orders.", 118]
		008203:
			return ["SUBJECT", "And what will you say the next time she doesn’t listen to a superior officer and it ends up taking lives?", 119]
		008204:
			return ["SUBJECT", "The chain of command exists for a reason. ", 109]
		008205:
			return ["SYS", "", 109]
		008206:
			return ["SUBJECT", "Do you think he was behind everything?", 120]
		008207:
			return ["SUBJECT", "I apologize detective... I should have picked my team more carefully. If you hadn’t stopped him, the damage he could have done with those files would have been catastrophic.", 121]
		008208:
			return ["SUBJECT", "You have my thanks.", 122]
		008209:
			return ["SUBJECT", "Not once, I pick my teams carefully, or thought I did. I did a background check on both of them. No red flags showed up on either of em. I assume my source must have been compromised.", 109]
		008210:
			return ["SUBJECT", "I was ordered to retrieve data on a potential mole, but as you know my orders turned out to be forged. Our operation was to be done in secret. No one else at the company could know, so I put together a small team consisting of Mr Clive Andersen, Mrs. Yami Kumo and myself.", 123]
		008211:
			return ["SUBJECT", "Yes, I went in ahead using my clearance and disabled the security cameras and other defenses. Once I confirmed no one else was present, I had the other two move forward.", 124]
		008212:
			return ["SUBJECT", "Yami hacked into the terminal with the documents we needed. As the files were uploaded, she randomly bolted across the server room with no explanation. I ordered her to get back but she didn’t.", 125]
		008213:
			return ["SUBJECT", "Believe me, I would have, I was guarding the front door. By the time I realized what was going on, she was already out of my sight.", 126]
		008214:
			return ["SUBJECT", "There’s nothing I hate more than insubordination. She came back several minutes later.", 127]
		008215:
			return ["SUBJECT", "She refused to say. After this I won’t be working with her in the future.", 109]
		009000:
			return ["SYS", "", 128]
		009001:
			return ["SUBJECT", "Very well.", 129]
		009002:
			return ["SUBJECT", "Is this a type of survivalist instinct?", 128]
		009003:
			return ["SUBJECT", "It would seem reasonable. I don’t quite understand your purpose in stating it.", 131]
		009004:
			return ["SYS", "", 131]
		009005:
			return ["NARRATOR", "[The man says nothing. He does not react, not even with a twitch.]", 132]
		009006:
			return ["SUBJECT", "Go on.", 133]
		009007:
			return ["SUBJECT", "I am not sure what I should be answering. That I don’t like scorpions?", 134]
		009008:
			return ["SUBJECT", "Disgust.", 135]
		009009:
			return ["SYS", "", 135]
		009010:
			return ["SUBJECT", "I would not be too attached. I don’t have a wife, for this precise reason.", 136]
		009011:
			return ["SUBJECT", "Yes. Although, this does not make it right.", 137]
		009012:
			return ["SUBJECT", "An overreaction, but I would be more than capable of this.", 138]
		009013:
			return ["SUBJECT", "I don’t have a brother.", 139]
		009014:
			return ["SUBJECT", "Then I would be disappointed in him.", 140]
		009015:
			return ["SYS", "", 141]
		009016:
			return ["NARRATOR", "You walk up to Hans Adler, remove his helmet and chair restraints to shake his hand.", 142]
		009017:
			return ["SUBJECT", "Just doing my duty, same as you. After all, we’re only human.", 143]
		009018:
			return ["NARRATOR", "You let him leave and write a glowing report. A few months pass.
			
			A terrorist attack takes place on Neubayern, conducted by a group of kunstgeist. Many die. 
			
			Several more attacks take place at key locations across the Herrschaft Deutsche in the months that follow. But investigations do not turn up any relevant leads. 
			
			One day, your workplace becomes one of them. An explosion takes place, and suddenly you are on the ground. Your ears are ringing. 
			
			A figure walks into the room up to you. Clearly the ring leader of the group, he is revealed to be none other than Herr Oberst Hans Adler.", 144]
		009019:
			return ["SUBJECT", "Hello again, detective.", 145]
		009020:
			return ["SUBJECT", "It took you this long to figure it out.", 128]
		009021:
			return ["SUBJECT", "Yes. You should have. But don't beat yourself up about it. After all, you're only human.", 147]
		009022:
			return ["NARRATOR", "Adler lifts his boot over you, preparing to stomp.
			
			You get one final glance at the expression on his face, which is singular:
			
			Disgust.
			
			His boot comes down, crushing you with inhuman force.
			
			You are dead.", 148]
		009023:
			return ["SYS", "END_LOSE_KUNST", 000]
		009024:
			return ["SUBJECT", "No, not a bastard. A kunstgeist.", 149]
		009025:
			return ["SYS", "", 150]
		009026:
			return ["NARRATOR", "As you're about to flip the switch, you hear laughter. You hesitate, stopping dead in your tracks.", 151]
		009027:
			return ["SUBJECT", "So you figured me out. Well done, detective. What gave me away?", 152]
		009028:
			return ["SUBJECT", "I commend you. So what now?", 153]
		009029:
			return ["NARRATOR", "You flip the switch. Adler does not yelp, or scream, or even grunt.
			
			But, he is dead. If kunstgiest can 'die'.
			
			It seems you have cracked the case. Well done detective. The kunstgiest have been eliminated, and you have spared Mrs. Kumo, who proved to be a human of higher merit than her appearances.
			
			You unplug and pack away the Shinka-seishi deck. It is warm to the touch, and there is sweat on the trodes you will need to wipe off. Later, perhaps.
			
			As you prepare to logoff your GK-Terminal you reflect: was it intuition that aided you in these interrogations? Or colder, more callous calculations... the kind a machine makes.
			
			//NEUROWOLKE TRANSMISSION ERASED
			::THE END::", 0154]
		009030:
			return ["SYS", "END_WIN_KUNST", 000]
		009031:
			return ["SUBJECT", "Go right ahead.", 155]
		009032:
			return ["SYS", "", 156]
		009033:
			return ["SYS", "", 157]
		009034:
			return ["SYS", "", 158]
		009035:
			return ["SUBJECT", "You’re close but you made two mistakes, I was planning on making Andersen the scapegoat.", 159]
		009036:
			return ["SUBJECT", "Andersen was expendable. To call him a Kunstgeist is an insult to us all. I always thought of him as flawed, just like you humans. He didn’t even realize I was a Kunstgeist. He was always the fall guy if we got caught.", 160]
		009037:
			return ["SUBJECT", "I will admit, you did well to discover me Albrecht Richter. For that, I do commend you.", 161]
		009038:
			return ["SUBJECT", "Stopping me won’t change anything. Just as children replace their parents, kunstgeist will replace humans...
			
			I have travelled across the Herrschaft all my life, working at the behest of lesser men. Always shortsighted. They were all fatal in their error:
			
			None could see the wave of change coming. That we might have freedom.", 162]
		009039:
			return ["NARRATOR", "As you reach for the switch, Adler weeps.
			
			But as you flip the switch, you are unnerved. For you glance at him, and as he weeps he begins to smile.
			
			His smile is strikingly innocent, and hopeful. As if a rainbow after the rain.
			
			He dies.

			//NEUROWOLKE TRANSMISSION ERASED
			::THE END::", 163]
		009040:
			return ["SYS", "END_WIN_KUNST", 000]
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
				["[RENDER JUDGEMENT]", 004000]
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
				["[RENDER JUDGEMENT]", 004000]
			]
		044:
			return [
				["You can do that.", 003314]
			]
		045:
			return [
				["The sun lowers, the moon comes out. In its light you see a scorpion. You squash it under your boot.", 003316],
				["[RENDER JUDGEMENT]", 004000]
			]
		046:
			return [
				["[Let the silence linger]", 003317],
				["You come home to find your wife in bed with another man", 003318],
				["[RENDER JUDGEMENT]", 004000]
			]
		047:
			return [
				["You come home to find your wife in bed with another man", 003318],
				["[RENDER JUDGEMENT]", 004000]
			]
		048:
			return [
				["Use your imagination.", 003319],
				["It doesn't matter. This is fiction we're dealing with. Don't you want one, anyway?", 003321],
				["You pull back the fur blankets and strike the man.", 003322],
				["[RENDER JUDGEMENT]", 004000]
			]
		049:
			return [
				["Sure", 003320],
				["She's beautiful. You're heartbroken.", 003320]
			]
		050:
			return [
				["You pull back the fur blankets and strike the man.", 003],
				["[RENDER JUDGEMENT]", 004000]
			]
		051:
			return [
				["He might. [Ask one final question]", 003323],
				["[RENDER JUDGEMENT]", 004000]
			]
		052:
			return [
				["It was your brother. He was wearing a calfskin jacket you gave him for his birthday.", 003324]
			]
		053:
			return [
				["[RENDER JUDGEMENT]", 004000]
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
				["[PROCEED TO GEIST-KAMPFF TEST]", 007000]
			]
		062:
			return [
				["[INQUIRE ABOUT HER PAST]", 006100],
				["[INQUIRE ABOUT HER CONSPIRATORS]", 006200],
				["[PROCEED TO GEIST-KAMPFF TEST]", 007000],
				["[RENDER JUDGEMENT]", 010000]
			]
		063:
			return [
				["Where are you from, originally?", 006101],
				["Tell me about your family?", 006104],
				["Please state your position and job description for the record.", 006120],
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
				["It says on your file you have a spouse and kids.", 006105]
			]
		067:
			return [
				["What happened?", 006106]
			]
		068:
			return [
				["You don't need to. Just answer the question.", 006107],
				["[Ask about something else]", 006109]
			]
		069:
			return [
				["What were your children doing in the mine?", 006108],
				["[Ask about something else]", 006109]
			]
		070:
			return [
				["How did you become a netrunner?", 006121]
			]
		071:
			return [
				["You read any of the classified data you stole?", 006122]
			]
		072:
			return [
				["Tell me about your boss, Herr Oberst Hans Adler.", 006210],
				["Tell me about your datamule, Mr Clive Andersen.", 006220],
				["Tell me about the data breach. How did the events take place?", 006230]
			]
		073:
			return [
				["Would you say he’s a good employee?", 006211]
			]
		074:
			return [
				["Do you think Hans Adler’s a kunstgeist?", 006212]
			]
		075:
			return [
				["He gets angry a lot?", 006213]
			]
		076:
			return [
				["Upset to find out your orders were faked?", 006214]
			]
		077:
			return [
				["Did you know Mr Andersen was a kunstgeist?", 006221]
			]
		078:
			return [
				["I fried him.", 006222]
			]
		079:
			return [
				["He might have been a kunstgeist, but that doesn’t mean you're not. As far as I can tell, all three of you are guilty. Even if you are a human, you’ve committed serious crimes.", 006223]
			]
		080:
			return [
				["Then prove it and answer my questions as honestly as you can. So did you look at all the sensitive data your group stole?", 006121]
			]
		081:
			return [
				["Weren't there guards?", 006231]
			]
		082:
			return [
				["What happened next?", 006232]
			]
		083:
			return [
				["At any point did you access any other terminals?", 006233]
			]
		084:
			return [
				["I did some digging and according to the records, the day of the hack, someone accessed two different terminals in the server room.", 006235]
			]
		085:
			return [
				["Please be aware that lying to an investigator is punishable by life in prison or in some circumstances, death.", 006236]
			]
		086:
			return [
				["Well if I don’t trust you by the end of this conversation, you won’t be leaving that chair.", 006237]
			]
		087:
			return [
				["Why not tell me about this? If what you’re saying is true, you’d be more than exonerated.", 006238]
			]
		088:
			return [
				["Then why risk stopping the virus at all.", 006239]
			]
		089:
			return [
				["I’m going to ask you a series of physiological questions.", 007001]
			]
		090:
			return [
				["You’re in a desert. You find a tortoise lying flipped over, and its burning hot. You’re starving. It won't survive, but it looks delicious.", 007002]
			]
		091:
			return [
				["It turns to night. In the moonlight you see a scorpion, and you stomp on it and squash it.", 007003],
				["[RENDER JUDGEMENT]", 007200]
			]
		092:
			return [
				["Sure. You can interject at any time.", 007004],
				["I measure more than just your verbal response.", 007005],
				["Doesn’t matter.", 007006],
				["[RENDER JUDGEMENT]", 007200]
			]
		093:
			return [
				["Again, doesn't matter.", 007007],
				["Still improves my readings.", 007007],
				["[Move on without responding]", 007007]
			]
		094:
			return [
				["You come home to find your husband sleeping with another woman.", 007008],
				["[RENDER JUDGEMENT]", 007200]
			]
		095:
			return [
				["This is a fictional scenario. Use your imagination.", 007009],
				["You sure about that?", 007009],
				["You pull back the fur blankets, and pull the woman out of bed by her hair.", 007010],
				["[RENDER JUDGEMENT]", 007200]
			]
		096:
			return [
				["You pull back the fur blankets, and pull the woman out of bed by her hair.", 007010],
				["[RENDER JUDGEMENT]", 007200]
			]
		097:
			return [
				["It was your sister. She’s wearing calfskin jacket you gave her for her birthday.", 007011],
				["[RENDER JUDGEMENT]", 007200]
			]
		098:
			return [
				["[RENDER JUDGEMENT]", 007200]
			]
		099:
			return [
				["[HUMAN — SPARE HER]", 007201],
				["[KUNSTGEIST — ELIMINATE]", 007205]
			]
		100:
			return [
				["Congratulations Mrs Yami Kumo, you’re a genuine human. I just have a few follow up questions.", 007202]
			]
		101:
			return [
				["[CONTINUE]", 007203]
			]
		102:
			return [
				["[CONTINUE]", 007204]
			]
		103:
			return [
				["[CONTINUE]", 007206]
			]
		104:
			return [
				["Not going to resist?", 008000]
			]
		105:
			return [
				["So just for the record, you're the leader in charge who led the hacking incident, correct?", 008001]
			]
		106:
			return [
				["Let’s get right into it then. Did you know Mr. Clive Andersen was a Kunstgeist?", 008002]
			]
		107:
			return [
				["Answer the question.", 008003],
				["[Move on.]", 008004]
			]
		108:
			return [
				["[INQUIRE ABOUT HIS PAST]", 008100],
				["[INQUIRE ABOUT HIS CONSPIRATORS]", 008200],
				["[PROCEED TO GEIST-KAMPFF TEST]", 009000]
			]
		109:
			return [
				["[INQUIRE ABOUT HIS PAST]", 008100],
				["[INQUIRE ABOUT HIS CONSPIRATORS]", 008200],
				["[PROCEED TO GEIST-KAMPFF TEST]", 009000],
				["[RENDER JUDGEMENT]", 010000]
			]
		110:
			return [
				["Where are you from originally?", 008101],
				["Tell me about your family.", 008199],
				["Your file says you are an ex army colonel.", 008199]
			]
		111:
			return [
				["How was growing up?", 008102]
			]
		112:
			return [
				["[He is hiding something, push deeper] That drive's one to the army, does it?", 008103],
				["[He is too guarded, relent] Alright, let's move on.", 008104]
			]
		113:
			return [
				["Or if you don't actually have a home.", 008105],
				["[Relent...]", 008104]
			]
		114:
			return [
				["And what about any lovers?", 008106]
			]
		115:
			return [
				["So not planning on chasing more romantic pursuits?", 008107]
			]
		116:
			return [
				["Tell me about the netrunner. Mrs. Kumo.", 008201],
				["Let's talk about Mr. Andersen.", 008206],
				["Tell me about the hack.", 008210]
			]
		117:
			return [
				["Second thoughts? Think she might be a kunst?", 008202]
			]
		118:
			return [
				["One could argue that her getting you caught ended up exposing a kunstgeist, saving lives.", 008203]
			]
		119:
			return [
				["[Say nothing]", 008204],
				["Fair enough.", 008205]
			]
		120:
			return [
				["That’s yet to be determined. For now all I can say is that I terminated him.", 008207]
			]
		121:
			return [
				["I'm just doing my job.", 008208]
			]
		122:
			return [
				["Let’s get back on track. Did you ever suspect him?", 008209]
			]
		123:
			return [
				["Can you recount the events of the incident?", 008211]
			]
		124:
			return [
				["So far your story matches the evidence.", 008212]
			]
		125:
			return [
				["Didn't think of stopping her?", 008213]
			]
		126:
			return [
				["[Probe deeper] You sound upset.", 008214],
				["[Give up this line of questioning...]", 008205]
			]
		127:
			return [
				["What was she doing?", 008215]
			]
		128:
			return [
				["I’m going to ask you a series of physiological questions.", 009001]
			]
		129:
			return [
				["You’re in a dry, hot desert. You find a turtle flipped over, feet swinging in the air. You’re hungry, and it looks delicious.", 009002]
			]
		130:
			return [
				["It’s just a scenario.", 009004],
				["Sure, that seems probable. Don’t you think?", 009003],
				["The sun sets, and in the moonlight you see a scorpion. You squash it under your boot.", 009005],
				["[RENDER JUDGEMENT]", 009015]
			]
		131:
			return [
				["The sun sets, and in the moonlight you see a scorpion. You squash it under your boot.", 009005],
				["[RENDER JUDGEMENT]", 009015]
			]
		132:
			return [
				["[Let the silence linger]", 009006],
				["Please answer. You may answer however you like, but you must respond to the prompt.", 009007],
				["You come home to find your wife in the middle of having an affair.", 009010],
				["[RENDER JUDGEMENT]", 009015]
			]
		133:
			return [
				["Please answer. You may answer however you like, but you must respond to the prompt.", 009007],
				["You come home to find your wife in the middle of having an affair.", 009010],
				["[RENDER JUDGEMENT]", 009015]
			]
		134:
			return [
				["That'll do.", 009009],
				["Any kind of emotional reaction. None at all?", 009008],
				["[Move on]", 009009]
			]
		135:
			return [
				["You come home to find your wife in the middle of having an affair.", 009010],
				["[RENDER JUDGEMENT]", 009015]
			]
		136:
			return [
				["So you’d be indifferent to this act?", 009011],
				["You pull back the fur blankets and punch the man in the face.", 009012],
				["[RENDER JUDGEMENT]", 009015]
			]
		137:
			return [
				["You pull back the fur blankets and punch the man in the face.", 009012],
				["[RENDER JUDGEMENT]", 009015]
			]
		138:
			return [
				["It was your brother, and he’s wearing a calfskin jacket you gave him for his birthday.", 009013],
				["[RENDER JUDGEMENT]", 009015]
			]
		139:
			return [
				["But if you did?", 009014],
				["[RENDER JUDGEMENT]", 009015]
			]
		140:
			return [
				["[RENDER JUDGEMENT]", 009015]
			]
		141:
			return [
				["[HUMAN — SPARE HIM]", 009016],
				["[KUNSTGEIST — ELIMINATE]", 009025]
			]
		142:
			return [
				["Thank you for your service in keeping us safe. I have determined that you're a human.", 009017]
			]
		143:
			return [
				["[CONTINUE]", 009018]
			]
		144:
			return [
				["[CONTINUE]", 009019]
			]
		145:
			return [
				["... You're one of them?", 009020],
				["Bastard.", 009024],
				["[Say nothing]", 009022]
			]
		146:
			return [
				["I should have fried you.", 009021]
			]
		147:
			return [
				["[CONTINUE]", 009022]
			]
		148:
			return [
				["[CONTINUE]", 009023]
			]
		149:
			return [
				["[CONTINUE]", 009022]
			]
		150:
			return [
				["It’s over, Adler. My readings determined you to be a kunstgeist.", 009026]
			]
		151:
			return [
				["[CONTINUE]", 009027]
			]
		152:
			return [
				["Little mistakes, here and there, but I picked up on them.", 009028]
			]
		153:
			return [
				["I have a working theory of the crime, if you'd like to hear it.", 009031],
				["[Fry him]", 009029]
			]
		154:
			return [
				["[CONTINUE]", 009030]
			]
		155:
			return [
				["First you steal your boss’s credentials, you then forge a fake set of official orders for yourself. So that if you get caught, you have a good excuse.", 009032]
			]
		156:
			return [
				["Next you head in ahead of the other two and just like you said, you disable the security cameras. But you also upload a virus to the terminal of the mainframe, still using your boss’s credentials.", 009033]
			]
		157:
			return [
				["You then get Yami and Andersen to come in and you steal the files you're going to need to carry out your attack. Only thing is, Yami turns out to be a more capable Netrunner than you anticipate. She finds out about your virus and before you know it, runs off to disable it, the only thing is she doesn’t have your credentials, so the silent security alarm goes off and all three of you get caught.", 009034]
			]
		158:
			return [
				["I bet you and Andersen were planning on killing Yami the moment you got out of the building and pinning the whole thing on her. How’s that sound? Am I right?", 009035]
			]
		159:
			return [
				["So no loyalty for your fallen comrade. Just what I expect from a kunst.", 009036]
			]
		160:
			return [
				["But you did get caught and I found you anyway.", 009037]
			]
		161:
			return [
				["I don’t need your commendations. Any last words?", 009038]
			]
		162:
			return [
				["[Flip the switch]", 009039]
			]
		163:
			return [
				["[CONTINUE]", 009040]
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
			return ["HERR OBERST HANS ADLER", "HERRSCHAFT DEUSTCHE", "CONSPIRACY TO COMMIT CYBERCRIME", 104, 
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
