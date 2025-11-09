extends CharacterBody2D

@export var speed: float = 95 # can also just use := like var speed := 130
@onready var anim := $AnimatedSprite2D
@onready var interact_area: Area2D = $InteractionArea
@onready var rod_sprite: Sprite2D = $FishingRodSprite

func show_rod() -> void:
	if rod_sprite == null:
		return
	rod_sprite.visible = true
	_update_rod_position()

func hide_rod() -> void:
	if rod_sprite == null:
		return
	rod_sprite.visible = false

func _update_rod_position() -> void:
	print("hello")
	if rod_sprite == null:
		return
	# FOR POSITIONING, TWEAK HERE:
	rod_sprite.position = Vector2(12, 0)
	

# Items stored in dictionary to store unique item IDs and count
var inventory: Dictionary = {} 

var direction := Vector2.ZERO # null direction by default
var last_facing := "down" # facing down by default

# _ means engine function basically, not one manually called

# Inventory Setup 
func add_item(id: String, amount: int = 1) -> void:
	
	# Looks up item in dictionary 
	inventory[id] = inventory.get(id, 0) + amount
	print("Picked up %s x%d (total: %d)" % [id, amount, inventory[id]])
	print(inventory)

func has_item(id: String, min_amount: int = 1) -> bool:
	return inventory.get(id, 0) >= min_amount

# This PROBABLY wont be used unless shop is implemented
func remove_item(id: String, amount: int = 1) -> void:
	if !inventory.has(id):
		return
	inventory[id] -= amount
	if inventory[id] <= 0:
		inventory.erase(id)
		
	
	
# Built in function
# Runs every frame that's tied to physics with respect to movement
func _physics_process(_delta):
	# Get movement input
	direction = Vector2(
		Input.get_action_strength("move_right") - 
		Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		).normalized() # normalized makes vector length 1 to prevent op diagonal movement
		
	if Input.is_action_pressed("sprint"):
		speed = 200 # bro do NOT do speed *= 2 190 speed LOL
		
	# This can probably be done better
	if !Input.is_action_pressed("sprint"):
		speed = 95
		
		# Apply velocity
	velocity = direction * speed
	move_and_slide()
		
	# Update animation
	_update_anim()

	
func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		_try_interaction()
		print("interact key pressed") # test
		
	_handle_inventory_selection()

# Inventory hotbar setup
var selected_slot: int = -1
var select_item_id: String = ""

func _select_inventory_index(index: int) -> void:
	var keys: Array = inventory.keys() # Array of item keys/names (FUNCLE)
	

	if index >= keys.size():
		print("Nothing in slot %d" %(index + 1))
		selected_slot = -1
		select_item_id = ""
		return
	
	selected_slot = index
	select_item_id = keys[index]
	
	print("Selected item: %s x(%d)" %[select_item_id, inventory[select_item_id]])
		
func _handle_inventory_selection():
	if Input.is_action_just_pressed("slot_1"):
		_select_inventory_index(0)
	elif Input.is_action_just_pressed("slot_2"):
		_select_inventory_index(1)
	
	
func _try_interaction():
	var areas := interact_area.get_overlapping_areas()
	
	for object in areas:
		if object.is_in_group("interactable"):
			if object.has_method("on_interact"):
				object.on_interact(self) # Pass player if needed
			return # only interact with single object

func _update_anim():
	if direction.length() > 0:
		# Decide facing direction
		if abs(direction.x) > abs(direction.y):
			last_facing = "right" if direction.x > 0 else "left"
		else:
			last_facing = "down" if direction.y > 0 else "up"
		anim.play("walk_%s" % last_facing)
	else:
		anim.play("idle_%s" % last_facing)
		_update_rod_position()
