extends Node2D

@onready var card_node = preload("res://scenes/card_ex.tscn")
@onready var res_test = preload("res://resourses/godlike_healing.tres")
@onready var ultimate_box_container = $Utimate_box_container


@export var god_card_texture : Texture2D
@export var hero_card_texture : Texture2D

var card_array : Array[Card] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		%Player.die()
		#%Player.draw_random_card()
		
	if Input.is_action_just_pressed("ui_cancel"):
		%Player.draw_random_card()
		#ultimate_box_container.remove_element_at_index(1)


func spawn_card(card_logic_res, container) -> void:
	var new_card : Card = card_node.instantiate().duplicate()
	self.add_child(new_card)
	card_array.append(new_card)
	container.add_element(new_card)
	new_card.position = $Card_graph_content.position
	
	
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
