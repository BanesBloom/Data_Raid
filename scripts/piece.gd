extends StaticBody2D
class_name Piece


signal end_reached


func _ready():
	$"Trigger Area".connect("body_entered", _on_trigger_area_entered)


func _on_trigger_area_entered(body):
	if body is Player:
		emit_signal("end_reached")
		$"Trigger Area".queue_free()


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		SignalBus.emit_signal("life_lost")
	elif body.is_in_group("bullet"):
		$BridgeExplosion.emitting = true
		AudioController.play_effect_at_2D("Complete Level", global_position)
		
		## TODO: Change this to swapping to a broken bridge sprite.
		$Bridge.queue_free()
		
		body.queue_free()
		SignalBus.emit_signal("level_cleared", global_position)
