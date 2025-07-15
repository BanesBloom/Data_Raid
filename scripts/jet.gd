extends CharacterBody2D
class_name Jet

const SPEED = 1000
const SCORE = 50

var dir = Vector2.RIGHT

func _ready():
	$GPUParticles2D.connect("finished", func(): queue_free())

func _physics_process(_delta):
	velocity = dir * SPEED
	move_and_slide()

func destroy():
	SignalBus.emit_signal("score_increased", SCORE)
	$CollisionShape2D.disabled = true
	$Sprite2D.visible = false
	$Trail.emitting = false
	$GPUParticles2D.emitting = true
	AudioController.play_effect_at_2D("Explosion", global_position)

func swap_direction():
	dir = -dir
	$Trail.position *= -1 
	$Sprite2D.flip_h = true
