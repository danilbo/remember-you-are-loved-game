extends Node2D

class_name RootNode

@onready var card_node = preload("res://scenes/card_ex.tscn")
@onready var res_test = preload("res://resourses/godlike_healing.tres")
@onready var ultimate_box_container = $Utimate_box_container
@onready var player_node_ext : Player = %Player

@export var shop_node : Node2D

@export var god_card_texture : Texture2D
@export var hero_card_texture : Texture2D

@export var village_sprite1 : Sprite2D
@export var village_sprite2 : Sprite2D
@export var village_sprite3 : Sprite2D

@export var main_node : Node2D

@export_subgroup("Camp textures")
@export var camp_texture1 : Texture2D
@export var camp_texture2 : Texture2D
@export var camp_texture3 : Texture2D

@export_subgroup("Village textures")
@export var village_texture1 : Texture2D
@export var village_texture2 : Texture2D
@export var village_texture3 : Texture2D

var animation_aplpha_speed : float = 0.01
var current_village_state : int = 1

signal on_level_end()

signal on_card_hovered(icon : Texture2D, res_name : String, desc : String)
signal on_card_unhovered()

var card_array : Array[Card] = []

signal on_village_stats_change(citizens : int, current_panic : float, farmers : int, food : int, buildings : int, buildings_size : int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_node_ext.village.on_stat_change.connect(on_village_stat_change)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if visible:
		if current_village_state == 2:
			village_sprite1.material.set_shader_parameter("alpha_channel", move_toward(village_sprite1.material.get_shader_parameter("alpha_channel"), 0., animation_aplpha_speed))
			village_sprite2.material.set_shader_parameter("alpha_channel", move_toward(village_sprite2.material.get_shader_parameter("alpha_channel"), 1., animation_aplpha_speed))
		
		elif current_village_state == 3:
			village_sprite1.material.set_shader_parameter("alpha_channel", move_toward(village_sprite1.material.get_shader_parameter("alpha_channel"), 0., animation_aplpha_speed))
			village_sprite2.material.set_shader_parameter("alpha_channel", move_toward(village_sprite2.material.get_shader_parameter("alpha_channel"), 0., animation_aplpha_speed))
			village_sprite3.material.set_shader_parameter("alpha_channel", move_toward(village_sprite3.material.get_shader_parameter("alpha_channel"), 1., animation_aplpha_speed))
		
		
	if Input.is_action_just_pressed("ui_left"):
		%Player.draw_random_card()
		#ultimate_box_container.remove_element_at_index(1)
		
	if Input.is_action_just_pressed("ui_right"):
		end_level()


func spawn_card(card_logic_res, container) -> void:
	var new_card : Card = card_node.instantiate().duplicate()
	self.add_child(new_card)
	card_array.append(new_card)
	container.add_element(new_card)
	new_card.position = $Card_graph_content.position
	
	new_card.on_hovered.connect(_handle_on_hovered)
	new_card.on_unhovered.connect(_handle_on_unhovered)
	
	var new_scale = 0.55
	new_card.scale.x = new_scale
	new_card.scale.y = new_scale
	new_card.def_scale.x = new_scale
	new_card.def_scale.y = new_scale
	
	new_card.logical_res = card_logic_res#.duplicate()
	
	#new_card.logical_res.position = card_logic_res.position
	
	match card_logic_res.type:
		card_logic_res.TYPES.GOD:
			new_card.front_art = god_card_texture.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
			
		card_logic_res.TYPES.HERO:
			new_card.front_art = hero_card_texture.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
			
		card_logic_res.TYPES.ITEM:
			new_card.front_art = hero_card_texture.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	new_card.logical_res.generate(%Player)
	new_card.player_node = %Player
	
	new_card.generate_from_resource()


func spawn_temp_card(card_logic_res : Logical_card) -> void:
	var new_card : Card = card_node.instantiate().duplicate()
	self.add_child(new_card)
	new_card.position = Vector2.ZERO
	#new_card.position = $Card_graph_content.position
	
	var new_scale = 0.55
	new_card.scale.x = new_scale
	new_card.scale.y = new_scale
	new_card.def_scale.x = new_scale
	new_card.def_scale.y = new_scale
	new_card.rotation_y = 0.
	new_card.animation_move_speed /= 2.
	
	new_card.logical_res = card_logic_res.duplicate()
	
	
	new_card.non_playable = true
	#new_card.logical_res.position = card_logic_res.position
	
	match card_logic_res.type:
		card_logic_res.TYPES.GOD:
			new_card.front_art = god_card_texture.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
			
		card_logic_res.TYPES.HERO:
			new_card.front_art = hero_card_texture.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
			
		card_logic_res.TYPES.ITEM:
			new_card.front_art = hero_card_texture.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	new_card.logical_res.generate(%Player)
	new_card.player_node = %Player
	
	new_card.generate_from_resource()
	
	new_card.new_pos = $Card_graph_content.position
	new_card.termination_seq = true
	new_card.termination_ticks = 50


func _handle_on_hovered(icon : Texture2D, res_name : String, desc : String):
	on_card_hovered.emit(icon, res_name, desc)
	
func _handle_on_unhovered():
	on_card_unhovered.emit()


func end_level() -> void:
	on_level_end.emit()
	player_node_ext.hand_box_container.clear()
	player_node_ext.buff_card_place1.clear()
	
	for i in card_array:
		i.termination_seq = true
		i.termination_ticks = 60
		i.logical_res.position = i.logical_res.POSITIONS.DECK
		i.logical_res.time_on_table = 0
	
	card_array.clear()
	
	
	GlobalVariables.current_level += 1
	await get_tree().create_timer(0.6).timeout
	current_village_state = 1
	village_sprite1.material.set_shader_parameter("alpha_channel", 1.)
	village_sprite2.material.set_shader_parameter("alpha_channel", 0.)
	village_sprite3.material.set_shader_parameter("alpha_channel", 0.)


func check_animations() -> bool:
	for i in card_array:
		if i.pulse_loops > 0:
			return 0
	
	return 1


func reassign_for_village_type():
	match player_node_ext.village.type:
		player_node_ext.village.VILLAGE_TYPE.CAMP:
			village_sprite1.texture = camp_texture1
			village_sprite2.texture = camp_texture2
			village_sprite3.texture = camp_texture3
			
		player_node_ext.village.VILLAGE_TYPE.VILLAGE:
			village_sprite1.texture = village_texture1
			village_sprite2.texture = village_texture2
			village_sprite3.texture = village_texture3



func on_village_stat_change(citizens : int, current_panic : float, farmers : int, food : int, buildings : int, buildings_size : int):
	on_village_stats_change.emit(citizens, current_panic, farmers, food, buildings, buildings_size)
