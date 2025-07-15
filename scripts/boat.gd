extends CharacterBody2D
class_name Boat

const SPEED = 150
const SCORE = 25

var dir = Vector2.LEFT

func _ready():
	$GPUParticles2D.connect("finished", func(): queue_free())
	dir = dir * randi_range(-1, 1)

func _physics_process(delta):
	velocity = dir * SPEED
	var hit = move_and_collide(velocity * delta)
	if hit != null:
		dir *= -1

func destroy():
	SignalBus.emit_signal("score_increased", SCORE)
	$CollisionShape2D.disabled = true
	$Sprite2D.visible = false
	$GPUParticles2D.emitting = true
	AudioController.play_effect_at_2D("Explosion", global_position)

func _on_movement_timer_timeout():
	dir = Vector2.LEFT * randi_range(-1, 1)
	$MovementTimer.wait_time = randf_range(0.25, 1.5)
