extends AnimatedSprite2D

@export var key_letter: String = "K"  # set this per key scene (F, G, H, J, K, L)
@export var press_duration := 0.15  # seconds to stay pressed

var press_timer := 0.0
var pressed := false

func _ready():
	frame = 0  # start normal
	pressed = false

func _process(delta):
	var action_name = "qte_" + key_letter.to_lower()

	# detect press
	if Input.is_action_just_pressed(action_name):
		_press()

	# handle release animation timer (optional)
	if pressed:
		press_timer -= delta
		if press_timer <= 0.0:
			_reset()

func _press():
	frame = 1  # show pressed frame
	pressed = true
	press_timer = press_duration

func _reset():
	frame = 0  # back to normal frame
	pressed = false
