#TODO: idle event handling with alternates and blinking; make physics depend on hitbox

extends AnimatedSprite2D
var state
var idle_activities = ["idle", "reading", "thinking", "walking"]
#var idle_activities = ["idle_default", "idle_notcool", "reading_file", "reading_yaoi", "thinking_default", "thinking_tweaked", "walking"]

#physics variables
var velocity = Vector2(0,0)
var gravity = 3780
var bounce = .3
var friction = 0.99
var ground_friction = 0.5
var rotation_velocity = 0.0
var rotation_damping = 0.6

#drag variables
var is_dragging = false
var drag_offset = Vector2(0,0)
var last_mouse_pos = Vector2(0,0)

func _ready():	
	state = "idle"
	animation = "idle_default"
	frame = 0

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		is_dragging = false

#event pt 2
func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_offset = Vector2(DisplayServer.mouse_get_position()) - Vector2(DisplayServer.window_get_position())
			last_mouse_pos = DisplayServer.mouse_get_position()
			velocity = Vector2(0,0)

func _process(delta):
	var window_pos = DisplayServer.window_get_position()
	var window_size = DisplayServer.window_get_size()
	var screen_size = DisplayServer.screen_get_size()
	
	if is_dragging:
		var global_mouse_pos = DisplayServer.mouse_get_position()
		DisplayServer.window_set_position(Vector2i(Vector2(global_mouse_pos) - drag_offset))
		velocity = (global_mouse_pos - last_mouse_pos) / delta
		last_mouse_pos = global_mouse_pos
	else:
		#physics
		velocity.y += gravity * delta
		velocity *= friction
		var new_pos = Vector2(window_pos) + (velocity * delta)
		
		#collisions
		if new_pos.x < 0:
			new_pos.x = 0
			velocity.x = -velocity.x * bounce
		elif new_pos.x + window_size.x > screen_size.x:
			new_pos.x = screen_size.x - window_size.x
			velocity.x = -velocity.x * bounce
			
		if new_pos.y < 0:
			new_pos.y = 0
			velocity.y = -velocity.y * bounce
		elif new_pos.y + window_size.y > screen_size.y:
			new_pos.y = screen_size.y - window_size.y
			velocity.x = velocity.x * ground_friction
			velocity.y = -velocity.y * bounce
			
		DisplayServer.window_set_position(Vector2i(new_pos))
	
	if is_dragging:
		state = "dragging"
	elif Vector2(window_pos).y + window_size.y < screen_size.y - 5:
		state = "falling"
	else:
		state = "idle"
	update_animations()

func update_animations():
	#flipping
	if not is_dragging:
			if velocity.x > 10:
				flip_h = false
			elif velocity.x < -10:
				flip_h = true
	
	#rotating
	if state == "dragging" or state == "falling":
		var target_rotation = velocity.x * 0.0005
		var force = (target_rotation - rotation) * 0.2
		rotation_velocity += force
		rotation_velocity *= rotation_damping
		rotation = lerp(rotation, rotation + rotation_velocity, 0.2)
	elif state == "idle":
		rotation = 0
	
	#state handling
	if state == "dragging" and abs(velocity.length()) > 500:
		pass # animation = "dragging_violent"
	elif state == "dragging":
		pass # animation = "dragging_default"
	elif state == "falling":
		pass # animation = "falling"
	
	#idle handling
	
	
	
