extends AnimatedSprite2D

@export var max_charge_time := 2.5
@export var input_action := "cast"

var charging := false
var charge := 0.0

func _ready():
	animation = "default"  # change if your animation has another name
	frame = 0

func _process(delta):
	if Input.is_action_pressed(input_action):
		# start or continue charging
		charging = true
		if charge < max_charge_time:
			charge += delta
			_update_bar()
	elif charging:
		# released — decide zone, then reset
		print("Charge time:", charge)
		var zone = _zone_from_charge(charge)
		print("Cast released → Zone", zone)
		perform_cast(zone)
		charge = 0.0
		charging = false
		frame = 0

func _update_bar():
	var total_frames := sprite_frames.get_frame_count(animation)
	var ratio := charge / max_charge_time
	var frame_index := int(ratio * (total_frames - 1))
	frame = frame_index

func _zone_from_charge(t: float) -> int:
	if t < max_charge_time * 0.33:
		return 1
	elif t < max_charge_time * 0.66:
		return 2
	else:
		return 3

func perform_cast(zone: int):
	match zone:
		1:
			print("🎣 Cast landed close to shore!")
		2:
			print("🎣 Cast landed mid-ocean!")
		3:
			print("🎣 Cast landed far out!")
