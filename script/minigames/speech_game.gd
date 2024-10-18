extends VBoxContainer

signal player_has_win
signal player_has_lose
var key_start_speech = KEY_W
var window = JavaScriptBridge.get_interface("window")
var navigator = JavaScriptBridge.get_interface("navigator")
var speechRecognition 
var speechGrammarList
var speechRecognitionEvent

var console = JavaScriptBridge.get_interface("console")

var win_counter = 0
var win_count_max = 3

@onready var question_text  = $question_text
@onready var show_answer = $show_answer
@onready var win_show = $win_show
@onready var show_button = $show_buttton
@onready var mistake_bar = $mistake_bar

var quest_text
var choices_default_color = Color(1,1,1)
var choices_correct_color = Color(0,1,0,1)
var choices_incorrect_color = Color(1,0,0,1)

var random_text_list = [
	"ตะเกียบคีบเนื้อ",
	"กัมมันตภาพรังสี",
	"ได้ยังไง",
	"ฮัลโหล",
	"ทดสอบ"
]
var random_text_list_dup = random_text_list.duplicate()

var onresult = JavaScriptBridge.create_callback(func(args):
	if args and args.size():
		var t = args[0].results[0][0].transcript
		show_answer.text = t
		checker(t)
	)
var onerror = JavaScriptBridge.create_callback(func(args):
	if args and args.size():
		var err = args[0].error
		if err == "no-speech":
			return;
	switch_to_quick_game()
	)
var onspeechend = JavaScriptBridge.create_callback(func(_args):
	speechRecognition.stop()
	)
var js_start = JavaScriptBridge.create_callback(func(_args):
	start()
	)

func run():
	if not window:
		switch_to_quick_game()
	else:
		window.js_start = js_start
		window.onerror = onerror
		JavaScriptBridge.eval("
		navigator.mediaDevices
		.getUserMedia({
		  audio: true,
		})
		.then((stream) => {
			let recorder = new MediaRecorder(stream);
			recorder.stream.getAudioTracks().forEach(function(track){track.stop();});
			js_start()
		})
		.catch((err) => {
			onerror()
		});")

func start():
	show_button.get_node("button_to_start").text = OS.get_keycode_string(key_start_speech)
	reset_mistake_bar()
	reset_win_counter()
	reset_text_list()
	set_question_text()

func _ready():
	if window:
		speechRecognition = choose_obj("SpeechRecognition", "webkitSpeechRecognition")
		speechRecognition.continuous = false; 
		speechRecognition.lang = 'th'; 
		speechRecognition.interimResults = false; 
		speechRecognition.maxAlternatives = 1;
		
		speechRecognition.onresult = onresult
		speechRecognition.onerror = onerror
		speechRecognition.onspeechend = onspeechend

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.physical_keycode == key_start_speech:
			if window and speechRecognition:
				speechRecognition.start()

func checker(text):
	if quest_text == text:
		set_question_text()
		win_counter = win_counter + 1
		show_win_count()
		reset_mistake_bar()
		var w_c = win_show.get_node("win_count")
		set_obj_font_color(w_c, choices_correct_color)
		if is_inside_tree():
			get_timer_to_default_color(w_c).start()
	else:
		mistake_bar.value = mistake_bar.value - (mistake_bar.max_value / 4.0)
		set_obj_font_color(show_answer, choices_incorrect_color)
		if is_inside_tree():
			get_timer_to_default_color(show_answer).start()
	win_checker()

func win_checker():
	if win_counter >= win_count_max:
		player_has_win.emit()
	elif mistake_bar.value <= 0:
		player_has_lose.emit()
	JavaScriptBridge.eval("
	navigator.mediaDevices
		.getUserMedia({
		  audio: false,
		})")

func switch_to_quick_game():
	get_parent().switch_to_other_game(get_parent().game_type.QUICK_TYPE)

func choose_obj(obj1, obj2):
	var obj
	if window[obj1]:
		obj = JavaScriptBridge.create_object(obj1)
	elif window[obj2]:
		obj = JavaScriptBridge.create_object(obj2)
	return obj

func reset_mistake_bar():
	mistake_bar.value = mistake_bar.max_value

func reset_win_counter():
	win_counter = 0
	show_win_count()

func show_win_count():
	var w_c = win_show.get_node("win_count")
	var w_m = win_show.get_node("win_max")
	w_c.text = str(win_counter)
	w_m.text = str(win_count_max)

func reset_text_list():
	random_text_list_dup = random_text_list.duplicate()

func get_random_text():
	if random_text_list_dup.size() <= 0:
		reset_text_list()
	random_text_list_dup.shuffle()
	return random_text_list_dup.pop_front()

func set_question_text():
	var t = get_random_text()
	quest_text = t
	question_text.text = t 

func set_obj_font_color(obj, color):
	obj.set("theme_override_colors/font_color", color)

func get_timer_to_default_color(obj):
	var children = obj.get_children()
	for child in children:
		if child is Timer:
			return child
	var to_default_color_timer = Timer.new()
	to_default_color_timer.wait_time = 0.25
	to_default_color_timer.one_shot = true
	to_default_color_timer.timeout.connect(func():
		set_obj_font_color(obj ,choices_default_color)
		)
	obj.add_child(to_default_color_timer)
	return to_default_color_timer
