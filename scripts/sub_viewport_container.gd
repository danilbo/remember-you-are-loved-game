@tool
extends SubViewportContainer
class_name Card

@export_subgroup("Shader and textures")
@export var icon_texture_rect : TextureRect
@export var front_art: Texture2D:
	set(value):
		front_art = value
		_refresh()
@export var back_art: Texture2D:
	set(value):
		back_art = value
		_refresh()
@export var cull_backface: bool = false

@export var art_texture_rect: TextureRect
@export var card_contents: Control

@export_range(1, 120, 1) var simulated_camera_fov: float = 60:
	set(value):
		simulated_camera_fov = value
		_refresh()
@export_range(-360, 360, 1) var rotation_y: float = 0.0:
	set(value):
		rotation_y = value
		_refresh()
@export_range(-360, 360, 1) var rotation_x: float = 0.0:
	set(value):
		rotation_x = value
		_refresh()

@export_subgroup("Shadow")
@export var shadow_node : Sprite2D
@export var shadow_offset_mult : Vector2
@export var light_source_coords : Vector2

@export_subgroup("Animation")
@export_range(0., 1.) var animation_rotate_mult : float = 0.05
@export_range(0., 5.) var rotate_y_mult : float = 1.5
@export_range(0., 0.5) var animation_rotate_speed : float = 0.25

@export var animation_scale_mult : float = 1.3
@export var animation_scale_speed : float = 0.2

@export var animation_move_speed : float = 0.2


@export_subgroup("Play animation")
@export var scale_play_animation_mult = 1.3
@export var scale_play_animation_pulse_mult = 1.5
@export var scale_play_animation_pulse_speed = 0.2

@export var pulse_ticks_const : int

@export var use_bigger_card : bool

@export_subgroup("Logical")
@export var disable_logic : bool = false
@export var logical_res : Logical_card

var mouse_on : bool = false
var play_animation_playing : bool = false
var play_pulse_playing : bool = false
var pulse_ticks = 0
var pulse_loops = 0
var pulse_greating : bool = false
var player_node : Player
var non_playable : bool = false
var rotation_def : Vector2 = Vector2.ZERO
@onready var def_scale = scale
@onready var shadow_start_pos = shadow_node.global_position
@onready var new_pos = position

var termination_seq : bool = false
var termination_ticks : int = 0

var in_shop : bool = false

signal on_hovered(icon : Texture2D, res_name : String, desc : String)
signal on_unhovered()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not front_art:
		warnings.append("Front art texture is not assigned.")
	if cull_backface:
		if back_art:
			warnings.append(
				"Back art texture will not be visible because backface culling is enabled."
			)
	elif not back_art:
		warnings.append("Back art texture is not assigned.")
	if not (material is ShaderMaterial):
		warnings.append("CardArt requires a ShaderMaterial to function properly.")
	return warnings


func _ready():
	if not Engine.is_editor_hint():
		if disable_logic:
			rotation_def = Vector2(180., 0.)
		material = material.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		shadow_node.material = shadow_node.material.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		_refresh()


func _refresh():
	if not (material is ShaderMaterial):
		return
	if not card_contents or not art_texture_rect:
		return
	var shader_material := material as ShaderMaterial
	shader_material.set_shader_parameter("rot_y_deg", rotation_y)
	shader_material.set_shader_parameter("rot_x_deg", rotation_x)
	shader_material.set_shader_parameter("cull_backface", cull_backface)
	shader_material.set_shader_parameter("fov", simulated_camera_fov)
	
	shadow_node.material.set_shader_parameter("rot_y_deg", rotation_y)
	shadow_node.material.set_shader_parameter("rot_x_deg", rotation_x)
	shadow_node.material.set_shader_parameter("cull_backface", cull_backface)
	shadow_node.material.set_shader_parameter("fov", simulated_camera_fov)
	_refresh_texture()


func _refresh_texture():
	if not front_art or not back_art:
		return

	var rot_x_deg = wrapf(rotation_x, 0, 360)
	var rot_y_deg = wrapf(rotation_y, 0, 360)
	var front_facing_over_x = rot_x_deg < 90 or rot_x_deg > 270
	var front_facing_over_y = rot_y_deg < 90 or rot_y_deg > 270
	var use_front = front_facing_over_y == front_facing_over_x
	card_contents.visible = use_front
	art_texture_rect.texture = front_art if use_front else back_art
	material.set_shader_parameter("use_front", use_front)


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		if logical_res == null and mouse_on or logical_res != null and logical_res.position == logical_res.POSITIONS.GRAVE and mouse_on:
			if not in_shop:
				on_unhovered.emit()
		
		if termination_seq:
			termination_ticks -= 1
			
			if termination_ticks <= 0:
				#print(self, " TERMINATED!")
				queue_free()
				
		#if rotation_y > 45 and shadow_node.visible:
		#	shadow_node.hide()
			
		#elif rotation_y <= 45 and not shadow_node.visible:
		#	shadow_node.show()
		if new_pos != position:
			position.x = lerpf(position.x, new_pos.x, animation_move_speed)
			position.y = lerpf(position.y, new_pos.y, animation_move_speed)
		
		shadow_node.offset = (light_source_coords + position) * shadow_offset_mult
		
		if pulse_loops > 0:
			if pulse_ticks <= 0:
				pulse_ticks = pulse_ticks_const
				play_pulse_playing = true
				pulse_greating = true
				logical_res.anim_trigger(len(logical_res.animation_loop) - pulse_loops, player_node)
				
			pulse_ticks -= 1
			
		elif pulse_loops <= 0 and play_pulse_playing:
			play_pulse_playing = false
			pulse_greating = true
			
		if play_pulse_playing:
			if pulse_greating:
				scale.x = lerpf(scale.x, def_scale.x * scale_play_animation_pulse_mult, scale_play_animation_pulse_speed)
				scale.y = lerpf(scale.y, def_scale.y * scale_play_animation_pulse_mult, scale_play_animation_pulse_speed)
				
				if scale.x >= (def_scale.x * scale_play_animation_pulse_mult) - 0.05:
					pulse_greating = false
					
			else:
				if not use_bigger_card:
					scale.x = lerpf(scale.x, def_scale.x, scale_play_animation_pulse_speed)
					scale.y = lerpf(scale.y, def_scale.y, scale_play_animation_pulse_speed)
					
				else:
					scale.x = lerpf(scale.x, def_scale.x * scale_play_animation_mult, animation_scale_speed)
					scale.y = lerpf(scale.y, def_scale.y * scale_play_animation_mult, animation_scale_speed)
				
				
				if pulse_ticks <= 0:
					pulse_loops -= 1
					if pulse_loops <= 0:
						match logical_res.casting_type:
							logical_res.CASTING_TYPES.INSTANT:
								new_pos = player_node.graveyard
								if logical_res.name == "Еда":
									new_pos -= Vector2(400,-400)
									
								logical_res.position = logical_res.POSITIONS.GRAVE
								
							logical_res.CASTING_TYPES.BUFF:
								if logical_res.position != logical_res.POSITIONS.PASSSIVE and logical_res.position != logical_res.POSITIONS.GRAVE:
									logical_res.regenerate_buff(player_node)
									player_node.buff_card_place1.add_element(self)
									logical_res.position = logical_res.POSITIONS.PASSSIVE
									
								if logical_res.time_on_table >= logical_res.duration:
									for j in player_node.buff_card_place1.linked_nodes:
										if j[0] == self:
											player_node.buff_card_place1.remove_element_at_index(j[1])
											break
									
									new_pos = player_node.deck_card_node.position
									logical_res.position = logical_res.POSITIONS.DECK
									rotation_def.y = 180.
									termination_seq = true
									termination_ticks = 25
									logical_res.time_on_table = 0
								
								
						if not player_node.can_play_cards:
							player_node.can_play_cards = true
		
		if not play_animation_playing and pulse_loops <= 0 and not play_pulse_playing:
			if mouse_on:
				scale.x = lerpf(scale.x, def_scale.x * animation_scale_mult, animation_scale_speed)
				scale.y = lerpf(scale.y, def_scale.y * animation_scale_mult, animation_scale_speed)
				
				if disable_logic:
					rotation_x = lerpf(rotation_x, rotation_def.x + (0. - (get_correct_mouse_delta().y * animation_rotate_mult)),animation_rotate_speed)
					rotation_y = lerpf(rotation_y, (0. - (get_correct_mouse_delta().x * animation_rotate_mult * rotate_y_mult)),animation_rotate_speed)
					
				else:
					rotation_x = lerpf(rotation_x, 0. - (get_correct_mouse_delta().y * animation_rotate_mult),animation_rotate_speed)
					rotation_y = lerpf(rotation_y, rotation_def.y + (0. + (get_correct_mouse_delta().x * animation_rotate_mult * rotate_y_mult)),animation_rotate_speed)
					
				
				
			
			else:
				scale.x = lerpf(scale.x, def_scale.x, animation_scale_speed)
				scale.y = lerpf(scale.y, def_scale.y, animation_scale_speed)
				
				rotation_x = lerpf(rotation_x, rotation_def.x, animation_rotate_speed)
				rotation_y = lerpf(rotation_y, rotation_def.y, animation_rotate_speed)
				
			
		elif not pulse_greating:
			if not use_bigger_card:
				scale.x = lerpf(scale.x, def_scale.x, animation_scale_speed)
				scale.y = lerpf(scale.y, def_scale.y, animation_scale_speed)
				
			else:
				scale.x = lerpf(scale.x, def_scale.x * scale_play_animation_mult, animation_scale_speed)
				scale.y = lerpf(scale.y, def_scale.y * scale_play_animation_mult, animation_scale_speed)
			
			rotation_x = lerpf(rotation_x, rotation_def.x, animation_rotate_speed)
			rotation_y = lerpf(rotation_y, rotation_def.y, animation_rotate_speed)
		


func generate_from_resource() -> void:
	icon_texture_rect.texture = logical_res.icon.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)


func _on_mouse_entered() -> void:
	if not mouse_on:
		if logical_res != null and not logical_res.position == logical_res.POSITIONS.GRAVE:
			if not in_shop:
				on_hovered.emit(logical_res.icon, logical_res.name, logical_res.desctiption)
			
			else:
				on_hovered.emit(logical_res.icon, logical_res.name + " (" + str(logical_res.base_cost) + ")", logical_res.desctiption)
				
		mouse_on = true


func _on_mouse_exited() -> void:
	if mouse_on:
		if logical_res != null and not logical_res.position == logical_res.POSITIONS.GRAVE:
			on_unhovered.emit()
		mouse_on = false


func get_correct_mouse_delta() -> Vector2:
	if not in_shop:
		return get_viewport().get_mouse_position() - (get_viewport_rect().size / 2.) - position - ((size * scale) / 2.)
		
	else:
		return get_viewport().get_mouse_position()- position - ((size * scale) / 2.)


func _on_gui_input(event: InputEvent) -> void:
	if not disable_logic and not player_node.dead:
		if event.is_action_pressed("lmb") and in_shop and player_node.souls >= logical_res.base_cost:
			player_node.souls -= logical_res.base_cost
			player_node.change_characteristics()
			
			for i : Card in get_parent().card_array:
				for j in get_parent().shop_container.linked_nodes:
					if j[0] == self:
						get_parent().shop_container.remove_element_at_index(j[1])
						break
						
			
			#print(get_parent().shop_container.linked_nodes)
			player_node.deck.append(logical_res.duplicate())
			new_pos = Vector2(1800, 1100)
			get_parent().card_array.erase(self)
			termination_seq = true
			termination_ticks = 20
		
		if event.is_action_pressed("lmb") and not in_shop and not player_node.dead and player_node.village.citizens > 0 and player_node.main_node.check_animations() and not pulse_loops > 0 and not non_playable and player_node.mana + logical_res.mana >= 0. and player_node.energy + logical_res.energy >= 0. and player_node.can_play_cards:
			if logical_res.name == "Овладеть паникой" and player_node.village.current_panic < 50:
				return
				
			if logical_res.casting_type == logical_res.CASTING_TYPES.BUFF and len(player_node.buff_card_place1.linked_nodes) >= player_node.buff_card_place1.grid_limits.x * player_node.buff_card_place1.grid_limits.y:
				return
				
			if logical_res.type == logical_res.TYPES.HERO:
				var chance : int = randi_range(0, 100)
				print(chance, "%")
				
				if player_node.control <= 33:
					if logical_res.risk_level == logical_res.RISK_LEVEL.HIGH:
						if chance <= 90:
							logical_res.animation_loop.clear()
							logical_res.animation_loop.append([player_node.do_special_trigger, ["selfharm"]])
							
					if logical_res.risk_level == logical_res.RISK_LEVEL.MEDIUM:
						if chance <= 50:
							logical_res.animation_loop.clear()
							logical_res.animation_loop.append([player_node.do_special_trigger, ["selfharm"]])
				
				elif player_node.control <= 66:
					if logical_res.risk_level == logical_res.RISK_LEVEL.HIGH:
						if chance <= 50:
							logical_res.animation_loop.clear()
							logical_res.animation_loop.append([player_node.do_special_trigger, ["selfharm"]])
							
					if logical_res.risk_level == logical_res.RISK_LEVEL.MEDIUM:
						if chance <= 10:
							logical_res.animation_loop.clear()
							logical_res.animation_loop.append([player_node.do_special_trigger, ["selfharm"]])
			
			for i in player_node.hand_box_container.linked_nodes:
				if i[0] == self:
					player_node.hand_box_container.remove_element_at_index(i[1])
			
			non_playable = true
			
			if len(logical_res.animation_loop) > 0:
				player_node.current_card_playing = self
				player_node.can_play_cards = false
				pulse_loops = len(logical_res.animation_loop)
				pulse_ticks = pulse_ticks_const
				new_pos = Vector2.ZERO - (size / 2)
				
			else:
				match logical_res.casting_type:
					logical_res.CASTING_TYPES.BUFF:
						logical_res.regenerate_buff(player_node)
						player_node.buff_card_place1.add_element(self)
						logical_res.position = logical_res.POSITIONS.PASSSIVE


func trigger_pulse_animation(plus_ticks : int = 0) -> void:
	pulse_loops = len(logical_res.animation_loop)
	pulse_ticks = pulse_ticks_const + plus_ticks


func send_to_grave() -> void:
	non_playable = true
	new_pos = player_node.graveyard
	logical_res.position = logical_res.POSITIONS.GRAVE
