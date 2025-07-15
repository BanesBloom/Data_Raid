extends Control

const MAIN = preload("res://scenes/main.tscn")
const SCORE_ENTRY = preload("res://scenes/score_entry.tscn")

const BEEP_CUT = preload("res://audio/effects/ui-beep.wav")

@onready var score_v_box: VBoxContainer = %ScoreVBox
@onready var settings_v_box: VBoxContainer = %SettingsVBox
@onready var tutorial_v_box: VBoxContainer = %TutorialVBox
@onready var credits_v_box: VBoxContainer = %CreditsVBox

@onready var resolution_option = %ResolutionOption

@onready var master_label = %MasterLabel
@onready var master_slider = %MasterSlider
@onready var music_label = %MusicLabel
@onready var music_slider = %MusicSlider
@onready var effects_label = %EffectsLabel
@onready var effects_slider = %EffectsSlider

@onready var move_left_keybind = %MoveLeftKeybind
@onready var move_right_keybind = %MoveRightKeybind
@onready var speed_up_keybind = %SpeedUpKeybind
@onready var slow_down_keybind = %SlowDownKeybind
@onready var fire_keybind = %FireKeybind

@onready var key_selector = %KeySelector

@onready var scores_list = %ScoresList

var game : Node
var scores : Array[Dictionary] = []

func _ready():
	SignalBus.connect("end_game", cleanup)
	
	if not OS.has_feature("web"):
		%FileNotification.text = "Settings and scores are stored at:\n%s"%OS.get_user_data_dir()
		%QuitButton.visible = true
		if FileAccess.file_exists("user://scores.txt"):
			load_scores()
		if FileAccess.file_exists("user://settings.txt"):
			load_settings()
	
	move_left_keybind.pressed.connect(update_keybind.bind("left"))
	move_right_keybind.pressed.connect(update_keybind.bind("right"))
	speed_up_keybind.pressed.connect(update_keybind.bind("forward"))
	slow_down_keybind.pressed.connect(update_keybind.bind("backward"))
	fire_keybind.pressed.connect(update_keybind.bind("fire"))
	
	update_keybind_buttons()
	
	AudioController.play_bgm(AudioController.MUSIC["Main Menu"])

func cleanup(result : Dictionary):
	##print_debug(result)
	if result.has("name"):
		scores.append(result)
		update_scores()
	
	AudioController.play_bgm(AudioController.MUSIC["Main Menu"])
	game.queue_free()
	score_v_box.visible = true
	tutorial_v_box.visible = false
	settings_v_box.visible = false
	credits_v_box.visible = false
	visible = true

#region MAIN BUTTONS
#------------------------------------------------------------------------------#

func _on_play_button_pressed():
	game = MAIN.instantiate()
	get_parent().add_child(game)
	visible = false
	AudioController.play_bgm(AudioController.MUSIC["Game"])
	

func _on_scores_button_pressed():
	score_v_box.visible = true
	settings_v_box.visible = false
	tutorial_v_box.visible = false
	credits_v_box.visible = false

func _on_tutorial_button_pressed():
	score_v_box.visible = false
	settings_v_box.visible = false
	tutorial_v_box.visible = true
	credits_v_box.visible = false

func _on_credits_button_pressed() -> void:
	score_v_box.visible = false
	settings_v_box.visible = false
	tutorial_v_box.visible = false
	credits_v_box.visible = true

func _on_settings_button_pressed():
	score_v_box.visible = false
	settings_v_box.visible = true
	tutorial_v_box.visible = false
	credits_v_box.visible = false

func _on_quit_button_pressed():
	AudioController.pause_bgm()
	
	if not OS.has_feature("web"):
		save_scores()
		save_settings()
	
	get_tree().quit()

#endregion
#------------------------------------------------------------------------------#

#region AUDIO SLIDERS
#------------------------------------------------------------------------------#

func _on_master_slider_value_changed(value):
	master_label.text = "%s"%ceili(value * 100)
	AudioController.adjust_audio_level("Master", value)

func _on_music_slider_value_changed(value):
	music_label.text = "%s"%ceili(value * 100)
	AudioController.adjust_audio_level("Music", value)

func _on_effects_slider_value_changed(value):
	effects_label.text = "%s"%ceili(value * 100)
	AudioController.adjust_audio_level("Effects", value)

#endregion
#------------------------------------------------------------------------------#

func update_keybind(action : StringName):
	if action == null: return
	
	set_process_input(false)
	
	key_selector.open()
	var newKeycode = await key_selector.keySelected
	var newEvent = InputEventKey.new()
	newEvent.keycode = newKeycode
	
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, newEvent)
	
	update_keybind_buttons()
	
	set_process_input(true)

func update_keybind_buttons():
	move_left_keybind.text = InputMap.action_get_events("left")[0].as_text()
	move_right_keybind.text = InputMap.action_get_events("right")[0].as_text()
	speed_up_keybind.text = InputMap.action_get_events("forward")[0].as_text()
	slow_down_keybind.text = InputMap.action_get_events("backward")[0].as_text()
	fire_keybind.text = InputMap.action_get_events("fire")[0].as_text()

func update_scores():
	scores.sort_custom(func(a, b):
		if a["score"] > b["score"]: return true
		else: return false
	)
	
	for node in scores_list.get_children():
		node.queue_free()
	
	for score in scores:
		var entry : ScoreEntry = SCORE_ENTRY.instantiate()
		entry.initialize(score["name"], score["level"], score["score"])
		scores_list.add_child(entry)

func load_scores():
	var scoresFile : FileAccess = FileAccess.open("user://scores.txt", FileAccess.READ)
	while not scoresFile.eof_reached():
		var entry = JSON.parse_string(scoresFile.get_line())
		if entry == null: continue
		elif entry.has("name") and entry.has("level") and entry.has("score"):
			scores.append(entry)
	scoresFile.close()
	
	update_scores()

func load_settings():
	var settingsFile : FileAccess = FileAccess.open("user://settings.txt", FileAccess.READ)
	var settings : Dictionary = JSON.parse_string(settingsFile.get_line())
	master_slider.value = settings["masterVol"]
	music_slider.value = settings["musicVol"]
	effects_slider.value = settings["effectsVol"]
	
	InputMap.action_get_events("left")[0].keycode = settings["left"]
	
	settingsFile.close()

func save_scores():
	if scores.is_empty(): return
	
	var scoresFile : FileAccess = FileAccess.open("user://scores.txt", FileAccess.WRITE)
	for score in scores:
		scoresFile.store_line(JSON.stringify(score))
	scoresFile.close()

func save_settings():
	var settingsFile : FileAccess = FileAccess.open("user://settings.txt", FileAccess.WRITE)
	
	var settings : Dictionary = {
		"masterVol" : master_slider.value,
		"musicVol" : music_slider.value,
		"effectsVol" : effects_slider.value,
		"left" : InputMap.action_get_events("left")[0].get_keycode_with_modifiers(),
		"right" : InputMap.action_get_events("right")[0].get_keycode_with_modifiers(),
		"forward" : InputMap.action_get_events("forward")[0].get_keycode_with_modifiers(),
		"backward" : InputMap.action_get_events("backward")[0].get_keycode_with_modifiers(),
		"fire" : InputMap.action_get_events("fire")[0].get_keycode_with_modifiers(),
	}
	settingsFile.store_string(JSON.stringify(settings))
	
	settingsFile.close()


func _on_menu_button_mouse_entered() -> void:
	AudioController.play_effect(BEEP_CUT, 0.0, 0.5)
