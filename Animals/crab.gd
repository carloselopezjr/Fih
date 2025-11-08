extends Node2D

@onready var sprite = $AnimatedSprite2D

var speed := 40
var direction := 1
var distance := 50
var start_x := 0.0

func _ready():
	await get_tree().process_frame  # wait one frame for transforms to apply
	start_x = position.x
	sprite.play("default")


func _process(delta):
	position.x += direction * speed * delta

	if position.x > start_x + distance:
		direction = -1
		sprite.flip_h = true  # face left
	elif position.x < start_x - distance:
		direction = 1
		sprite.flip_h = false # face right
