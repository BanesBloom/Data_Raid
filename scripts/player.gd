extends CharacterBody2D
class_name Player

const PLAYER_BASE = preload("res://sprites/Player_Base.png")

const BULLET = preload("res://scenes/bullet.tscn")

const BASE_SPEED = 500
const SPEED_CHANGE = 250
const FIRE_RATE = 0.2

@onready var fire_position = $FirePosition
@onready var speed_trails : ParticleProcessMaterial = $SpeedTrails.process_material

var dead = false
var last_spawn : Vector2 = Vector2.ZERO

var speed = 500
var speed_target

func _ready():
	SignalBus.connect("level_cleared", set_spawn)
	SignalBus.connect("life_lost", die)
	
	$Camera2D.limit_left = -get_viewport().get_visible_rect().size.x
	$Camera2D.limit_right = get_viewport().get_visible_rect().size.x
	$Camera2D.position.y = -get_viewport().get_visible_rect().size.y / 1.5

func _physics_process(delta):
	if dead:
		velocity = (last_spawn - global_position) * 5
		move_and_slide()
		if (last_spawn - global_position).length() < 5:
			dead = false
			AudioController.play_bgm()
			$Sprite2D.visible = true
			$CollisionShape2D.disabled = false
		return
	
	speed_target = BASE_SPEED + (Input.get_axis("backward", "forward") * SPEED_CHANGE)
	speed = move_toward(speed, speed_target, 5)
	
	var h_dir = Input.get_axis("left", "right")
	velocity = Vector2(h_dir * BASE_SPEED, -speed)
	var hit = move_and_collide(velocity * delta)
	
	##speed_trails.gravity = Vector3(0, speed, 0)
	var trail_ratio = 0.5 + (0.5 * Input.get_axis("backward", "forward"))
	$SpeedTrails.amount_ratio = move_toward($SpeedTrails.amount_ratio, trail_ratio, 0.05)
	
	if hit != null:
		hit = hit.get_collider()
		if hit is Fuel:
			hit.refuel()
		else:
			SignalBus.emit_signal("life_lost")
	
	if Input.is_action_pressed("fire") && $FireRateTimer.is_stopped():
		fire()
		$FireRateTimer.start(FIRE_RATE)

func fire():
	var bullet = BULLET.instantiate()
	owner.add_child(bullet)
	bullet.global_position = fire_position.global_position
	
	AudioController.play_effect_at_2D("Shoot", global_position)

func set_spawn(spawn : Vector2):
	last_spawn = spawn

func die():
	process_mode = Node.PROCESS_MODE_DISABLED
	AudioController.pause_bgm()
	AudioController.play_effect_at_2D("Explosion", global_position)
	AudioController.play_effect_at_2D("Die", global_position)
	$Explosion.emitting = true
	$SpeedTrails.emitting = false
	$Sprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)

func _on_gpu_particles_2d_finished():
	process_mode = Node.PROCESS_MODE_INHERIT
	$SpeedTrails.emitting = true
	dead = true
