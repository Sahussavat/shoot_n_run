extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.

##note
##ในส่วนของ add-on dialogue manager ได้ทำการ modified dialogue_line.gd ถ้าเกิด download ตัว add-on ใหม่ โปรด
##ก็อป code ในไฟล์ dialogue_line.gd ตัวเก่า ไปวางทับไฟล์ตัวใหม่ด้วย

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"ui_cancel"
@onready var character_pic = $Balloon/character/character_pic
@onready var character_box = $Balloon/character
@onready var background = $Balloon/background
## The dialogue resource
var resource: DialogueResource

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

var _locale: String = TranslationServer.get_locale()

var can_click_next = false

## The current line
var dialogue_line: DialogueLine:
	set(next_dialogue_line):
		var menu = get_tree().get_first_node_in_group(GroupsName.MENU)
		menu.process_mode = Node.PROCESS_MODE_DISABLED
		is_waiting_for_input = false
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()
		# The dialogue has finished so close the balloon
		if not next_dialogue_line:
			queue_free()
			return

		# If the node isn't ready yet then none of the labels will be ready yet either
		if not is_node_ready():
			await ready

		dialogue_line = next_dialogue_line

		character_label.visible = not dialogue_line.character.is_empty()
		character_label.text = "\n" + tr(dialogue_line.character, "dialogue")
		var pic_path = "res://img/visual_characters/%s.png" % (dialogue_line.character + "_" + dialogue_line.character_feel).to_lower()
		if ResourceLoader.exists(pic_path):
			character_pic.texture = ResourceLoader.load(pic_path)
			character_box.alignment = dialogue_line.character_align
		else:
			character_pic.texture = null

		dialogue_label.hide()
		dialogue_label.dialogue_line = dialogue_line

		responses_menu.hide()
		responses_menu.set_responses(dialogue_line.responses)

		# Show our balloon
		balloon.show()
		will_hide_balloon = false

		dialogue_label.show()
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
			await dialogue_label.finished_typing

		# Wait for input
		if dialogue_line.responses.size() > 0:
			balloon.focus_mode = Control.FOCUS_NONE
			responses_menu.show()
		elif dialogue_line.time != "":
			var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
			await get_tree().create_timer(time).timeout
			next(dialogue_line.next_id)
		else:
			is_waiting_for_input = true
			balloon.focus_mode = Control.FOCUS_ALL
			balloon.grab_focus()
		
		menu.process_mode = Node.PROCESS_MODE_ALWAYS
	get:
		return dialogue_line

## The base balloon anchor
@onready var balloon: Control = %Balloon

## The label showing the name of the currently speaking character
@onready var character_label: RichTextLabel = %CharacterLabel

## The label showing the currently spoken dialogue
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The menu of responses
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

@onready var skip_container = $Balloon/skip_container

func _ready() -> void:
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)
	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio = dialogue_label.visible_ratio
		self.dialogue_line = await resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue
func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	temporary_game_states =  [self] + extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)
	skip_container.enable_skip = true
	var blur = get_tree().get_first_node_in_group(GroupsName.BLUR_SCREEN_CONTROL)
	blur.get_parent().remove_child(blur)
	get_tree().get_first_node_in_group(GroupsName.SUB_MENU_POS).add_child(blur)
	var menu = get_tree().get_first_node_in_group(GroupsName.MENU_SET)
	menu.get_parent().remove_child(menu)
	get_tree().get_first_node_in_group(GroupsName.SUB_MENU_POS).add_child(menu)
	DialogueUtill.circle_out(func():
		can_click_next = true
		)
	skip_container.on_finished_skip.connect(func():
		menu = get_tree().get_first_node_in_group(GroupsName.MENU)
		menu.process_mode = Node.PROCESS_MODE_DISABLED
		ChangePage.change_to_target_page(menu)
		menu.do_resume()
		process_mode = Node.PROCESS_MODE_DISABLED
		DialogueUtill.circle_in(func():
			self.dialogue_line = await resource.get_next_dialogue_line(&"end")
			)
		)
	skip_container.set_skip_button()


## Go to the next line
func next(next_id: String) -> void:
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)


#region Signals


func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	will_hide_balloon = true
	get_tree().create_timer(0.1).timeout.connect(func():
		if will_hide_balloon:
			will_hide_balloon = false
			balloon.hide()
	)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing and can_click_next:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action) or KeyUtill.is_just_pressed(GameControlKeycode.get_current_key()[GameControlKeycode.KEY.MENU])
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if can_click_next:
		if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			next(dialogue_line.next_id)
		elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
			next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)


#endregion
