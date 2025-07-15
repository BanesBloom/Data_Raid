extends CharacterBody2D
class_name Bullet

var speed = 1500

func _physics_process(delta):
	velocity = Vector2.UP * speed * delta
	var hit = move_and_collide(velocity)
	
	if hit != null:
		hit = hit.get_collider()
		if hit is Jet || hit is Fuel || hit is Boat:
			hit.destroy()
		queue_free()

func _on_timer_timeout():
	queue_free()
