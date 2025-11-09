extends Node2D

@onready var key_container = $KeyContainer
@onready var round_timer = $RoundTimer

# preload all key scenes
var key_scenes := {
	"F": preload("res://ui/qte/keys/Fkey.tscn"),
	"G": preload("res://ui/qte/keys/Gkey.tscn"),
	"H": preload("res://ui/qte/keys/Hkey.tscn"),
	"J": preload("res://ui/qte/keys/Jkey.tscn"),
	"K": preload("res://ui/qte/keys/Kkey.tscn"),
	"L": preload("res://ui/qte/keys/Lkey.tscn")
}

# round / game data
var combo := []
var current_index := 0
var fails := 0              # failed rounds counter
var current_round := 0
const TOTAL_ROUNDS := 4     # rounds required for success
const MAX_FAILED_ROUNDS := 2  # total allowed failures

signal qte_success
signal qte_fail


func _ready():
	start_round()


func start_round():
	# clear previous round
	for c in key_container.get_children():
		c.queue_free()
	combo.clear()
	current_index = 0

	# create 4 random keys
	var all_keys = ["F", "G", "H", "J", "K", "L"]
	all_keys.shuffle()
	combo = all_keys.slice(0, 4)

	# position keys
	var start_x = 60
	var spacing = 40
	for i in range(combo.size()):
		var letter = combo[i]
		var key_instance = key_scenes[letter].instantiate()
		key_instance.position = Vector2(start_x + i * spacing, 100)
		key_container.add_child(key_instance)

	print("New combo:", combo)
	round_timer.start()


func _process(_delta):
	# skip input if sequence already done
	if current_index >= combo.size():
		_round_success()
		return

	var target_letter = combo[current_index]
	var action_name = "qte_" + target_letter.to_lower()

	# ✅ correct key
	if Input.is_action_just_pressed(action_name):
		current_index += 1
		print("Correct:", target_letter)

	# ❌ wrong key pressed — fail this round immediately
	else:
		for key in ["f", "g", "h", "j", "k", "l"]:
			if key != target_letter.to_lower() and Input.is_action_just_pressed("qte_" + key):
				print("Wrong key:", key)
				_round_fail()
				return


func _on_RoundTimer_timeout():
	_round_fail()


func _round_success():
	current_round += 1
	round_timer.stop()

	if current_round >= TOTAL_ROUNDS:
		print("✅ Fish caught after %d rounds!" % TOTAL_ROUNDS)
		emit_signal("qte_success")
		queue_free()
	else:
		print("✅ Round complete! Moving to round %d..." % (current_round + 1))
		start_round()


func _round_fail():
	round_timer.stop()
	fails += 1
	print("❌ Round failed! Total failed rounds: %d" % fails)

	if fails >= MAX_FAILED_ROUNDS:
		print("Fish escaped after %d failed rounds!" % fails)
		emit_signal("qte_fail")
		queue_free()
	else:
		print("Retrying round %d..." % (current_round + 1))
		start_round()
