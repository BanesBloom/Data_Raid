extends StaticBody2D
class_name Fuel

const SCORE = 100

func _ready():
	$GPUParticles2D.connect("finished", func(): queue_free())

func destroy():
	SignalBus.emit_signal("score_increased", SCORE)
	$CollisionShape2D.disabled = true
	$Sprite2D.visible = false
	$GPUParticles2D.emitting = true
	AudioController.play_effect_at_2D("Explosion", global_position)

func refuel():
	SignalBus.emit_signal("refueled", 25)
	AudioController.play_effect_at_2D("Collect", global_position)
	queue_free()
