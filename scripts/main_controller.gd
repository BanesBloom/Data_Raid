extends Node2D

const JET = preload("res://scenes/jet.tscn")
const BRIDGE_PIECE = preload("res://scenes/pieces/_bridge.tscn")
const PIECES = [
	preload("res://scenes/pieces/normal_1.tscn"),
	preload("res://scenes/pieces/normal_2.tscn"),
	preload("res://scenes/pieces/odd_1.tscn"),
	preload("res://scenes/pieces/odd_2.tscn"),
	preload("res://scenes/pieces/split_1.tscn"),
	preload("res://scenes/pieces/split_2.tscn"),
]


@onready var life_bulbs : Array[TextureRect] = [
	%BottomBulb,
	%MiddleBulb,
	%TopBulb
]


@onready var username_text_edit : LineEdit = %UsernameTextEdit
@onready var submit_button : Button = %SubmitButton


@onready var player : Player = $Player
@onready var jet_timer : Timer = $JetTimer


var used_pieces : Array[PackedScene] = []
var current_level : Array = []
var pieces_left = 5
var spawn_point = -1200


var lives : int = 3
var fuel : float = 100


var level : int = 0
var score : int = 0


func _ready():
	SignalBus.connect("refueled", refuel)
	SignalBus.connect("score_increased", increase_score)
	SignalBus.connect("life_lost", take_damage)
	SignalBus.connect("level_cleared", level_cleared)
	
	for node in $Level.get_children():
		node.connect("end_reached", spawn_piece)
	
	spawn_piece()


func _process(_delta):
	%FuelBar.value = fuel
	%Speedometer.rotation_degrees = move_toward(%Speedometer.rotation_degrees, -45 + (40 * ((player.speed - player.BASE_SPEED) / player.SPEED_CHANGE)) + randf_range(-2, 2), 1)


func _physics_process(_delta):
	fuel -= 1 * _delta
	if fuel <= 0: lose_game()


func spawn_piece():
	spawn_point -= 2400
	
	var piece = null
	if pieces_left <= 0:
		piece = BRIDGE_PIECE.instantiate()
		used_pieces.clear()
		pieces_left = 5
	else:
		while piece == null or used_pieces.has(piece):
			piece = PIECES.pick_random()
		
		used_pieces.append(piece)
		piece = piece.instantiate()
		pieces_left -= 1
	
	current_level.append(piece)
	
	$Level.call_deferred("add_child", piece)
	piece.global_position = Vector2(0, spawn_point)
	piece.connect("end_reached", spawn_piece)


func spawn_jet():
	var jet = JET.instantiate()
	
	var h_pos = get_viewport().get_visible_rect().size.x
	if randi_range(0, 1) == 1:
		h_pos = -h_pos
		jet.swap_direction()
	var pos = player.position + Vector2(-h_pos, randf_range(-500, -1500))
	
	jet.global_position = pos
	add_child(jet)
	jet_timer.start(randf_range(0.5, 10.0))


func refuel(value):
	fuel += value
	if fuel > 100: fuel = 100


func take_damage():
	for child in get_children():
		if child is Bullet: child.queue_free()
	
	life_bulbs[lives - 1].visible = false
	lives -= 1
	
	if lives <= 0:
		lose_game()


func level_cleared(_pos):
	level += 1
	
	if level > 1:
		increase_score(500)
		if level % 2 == 1 and lives < 3:
			lives += 1
			life_bulbs[lives - 1].visible = true
	
	for i in current_level.size() - 1:
		current_level.pop_back()


func increase_score(value):
	score += value
	%ScoreDisplay.text = "%s"%score


func lose_game():
	AudioController.pause_bgm()
	%FinalLevelLabel.text = "%s"%level
	%FinalScoreLabel.text = "%s"%score
	$LoseScreen.visible = true
	process_mode = Node.PROCESS_MODE_DISABLED


func _on_submit_button_pressed():
	if username_text_edit.text == "":
		if %SaveWarning.visible == true:
			SignalBus.emit_signal("end_game", {})
		else:
			%SaveWarning.visible = true
	else:
		SignalBus.emit_signal("end_game", {
			"name":username_text_edit.text,
			"level":level,
			"score":score
		})
