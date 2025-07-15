extends Panel

signal keySelected

func _ready():
	close()

func _input(event):
	if not event is InputEventKey: return
	emit_signal("keySelected", event.keycode)
	close()

func open():
	show()
	set_process_input(true)

func close():
	hide()
	set_process_input(false)
