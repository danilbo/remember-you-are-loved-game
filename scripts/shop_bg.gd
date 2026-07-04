extends Sprite2D

var time : float = 0.
const def_speed : float = 0.025
var speed : float = def_speed

var transition_speed : float = 0.1
var transition_shader_scaling = 0.04
var tunnel_blackness_transition_speed = 0.002
var transition_seq = false

@onready var start_scale = scale
@onready var start_tunnel_blackness = 0.88
@onready var tunnel_blackness = start_tunnel_blackness

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.set_shader_parameter("tunnel_blackness", 1.)
	tunnel_blackness = 1.
	speed = transition_speed
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += speed
	material.set_shader_parameter("iTime", time)
	
	if Input.is_action_just_pressed("ui_accept"):
		if not transition_seq:
			transition_seq = true
		
		else:
			transition_seq = false
		
	if transition_seq:
		speed = lerpf(speed, transition_speed, transition_shader_scaling)
		tunnel_blackness = move_toward(tunnel_blackness, 1., tunnel_blackness_transition_speed)
		material.set_shader_parameter("tunnel_blackness", tunnel_blackness)
		#print(material.get_shader_parameter("tunnel_blackness"))
		
	
	else:
		speed = lerpf(speed, def_speed, transition_shader_scaling)
		tunnel_blackness = move_toward(tunnel_blackness, start_tunnel_blackness, tunnel_blackness_transition_speed)
		material.set_shader_parameter("tunnel_blackness", tunnel_blackness)
