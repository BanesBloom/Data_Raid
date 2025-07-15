extends Node

const MUSIC = {
	"Main Menu" : preload("res://audio/music/A Worthy Challenge (LOOP).wav"),
	"Game" : preload("res://audio/music/BGM_03.wav")
}

const EFFECTS = {
	"Explosion":[
		preload("res://audio/effects/explode/explode-1.wav"),
		preload("res://audio/effects/explode/explode-2.wav"),
		preload("res://audio/effects/explode/explode-5.wav"),
	],
	"Collect":[
		preload("res://audio/effects/refuel.wav")
	],
	"Shoot" : [
		preload("res://audio/effects/shoot.wav")
	],
	"Die" : [
		preload("res://audio/effects/lose-life.wav")
	],
	"Complete Level" : [
		preload("res://audio/effects/bridge-break.wav")
	]
}

@onready var bgm = $BGM

var master_vol
var music_vol
var effects_vol

## ----- Background Music ----- ##

func pause_bgm():
	bgm.stream_paused = true

func play_bgm(stream : AudioStream = null, position : float = 0.0):
	if bgm.stream_paused == true:
		bgm.stream_paused = false
	
	if bgm.stream != stream and stream != null:
		bgm.stream = stream
		bgm.play(position)

## ----- Positional Audio ----- ##

func play_effect_at_2D(type : String = "", pos : Vector2 = Vector2.ZERO):
	if not EFFECTS.has(type): 
		push_error("Effect \"" + type + "\" not found.")
		return
	var player : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	player.bus = "Effects"
	player.stream = EFFECTS[type].pick_random()
	player.autoplay = true
	player.position = pos
	player.connect("finished", func(): player.queue_free())
	add_child(player)

## ----- Universal Audio ----- ##

func play_effect(aud : AudioStream = null, pos : float = 0.0, vol : float = 1.0):
	var player : AudioStreamPlayer = AudioStreamPlayer.new()
	player.bus = "Effects"
	player.stream = aud
	player.volume_db = linear_to_db(vol)
	player.autoplay = true
	player.connect("finished", func(): player.queue_free())
	add_child(player)

## ----- Audio Adjustment ----- ##

func adjust_audio_level(bus : String, level : float):
	if bus == null || level == null: return
	var bus_index = AudioServer.get_bus_index(bus)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(level))
