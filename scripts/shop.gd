extends Node2D

@export var main_gameplay_node : RootNode
@export var shop_container : UltimateBoxContainer

@export var god_card_texture : Texture2D
@export var hero_card_texture : Texture2D

@onready var card_node = preload("res://scenes/card_ex.tscn")

var cards_list : Array[Logical_card] = [preload("res://resourses/amnezia.tres").duplicate(), preload("res://resourses/bandages.tres").duplicate(),
preload("res://resourses/beg_for_food.tres").duplicate(), preload("res://resourses/camoflage.tres").duplicate(), preload("res://resourses/campfire.tres").duplicate(),
preload("res://resourses/clear_weather.tres").duplicate(), preload("res://resourses/communicate.tres").duplicate(), preload("res://resourses/confusion.tres").duplicate(),
preload("res://resourses/control_plus.tres").duplicate(), preload("res://resourses/destroy_barn.tres").duplicate(), preload("res://resourses/energy_conversion.tres").duplicate(),
preload("res://resourses/godfist_save.tres").duplicate(), preload("res://resourses/godlike_healing.tres").duplicate(), preload("res://resourses/help_locals.tres").duplicate(),
preload("res://resourses/kill.tres").duplicate(), preload("res://resourses/knife.tres").duplicate(), preload("res://resourses/lie_to_locals.tres").duplicate(),
preload("res://resourses/lightning_bolt.tres").duplicate(), preload("res://resourses/master_the_panic.tres").duplicate(), preload("res://resourses/meditate.tres").duplicate(),
preload("res://resourses/memory_wipe.tres").duplicate(), preload("res://resourses/mulligan.tres").duplicate(), preload("res://resourses/panic_reduce.tres").duplicate(),
preload("res://resourses/planned_kill.tres").duplicate(), preload("res://resourses/preach.tres").duplicate(), preload("res://resourses/rituallistic_kill.tres").duplicate(),
preload("res://resourses/rituallistic_knife.tres").duplicate(), preload("res://resourses/shelter.tres").duplicate(), preload("res://resourses/sleeping_bag.tres").duplicate(),
preload("res://resourses/steal_the_food.tres").duplicate(), preload("res://resourses/stimulant.tres"), preload("res://resourses/storm.tres").duplicate(), preload("res://resourses/tornado.tres").duplicate(),
preload("res://resourses/unscheduled_dayoff.tres").duplicate(), preload("res://resourses/weird_potion.tres").duplicate()]


signal on_card_hovered(icon : Texture2D, res_name : String, desc : String)
signal on_card_unhovered()
signal on_shop_closing()

var shop_close_in_progress = false

var card_array : Array[Card] = []

func _ready() -> void:
	pass
	#create_shop(24)


func spawn_random_card() -> void:
	var new_card : Card = card_node.instantiate().duplicate()
	self.add_child(new_card)
	card_array.append(new_card)
	shop_container.add_element(new_card)
	new_card.position = $Card_graph_content.position
	
	new_card.on_hovered.connect(_handle_on_hovered)
	new_card.on_unhovered.connect(_handle_on_unhovered)
	
	var new_scale = 0.55
	new_card.scale.x = new_scale
	new_card.scale.y = new_scale
	new_card.def_scale.x = new_scale
	new_card.def_scale.y = new_scale
	
	new_card.logical_res = cards_list.pick_random().duplicate()
	
	new_card.in_shop = true
	
	match new_card.logical_res.type:
		new_card.logical_res.TYPES.GOD:
			new_card.front_art = god_card_texture.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
			
		new_card.logical_res.TYPES.HERO:
			new_card.front_art = hero_card_texture.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
			
		new_card.logical_res.TYPES.ITEM:
			new_card.front_art = hero_card_texture.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	new_card.player_node = main_gameplay_node.player_node_ext
	
	new_card.generate_from_resource()

func create_shop(value : int) -> void:
	for i in range(0, value):
		spawn_random_card()

func _handle_on_hovered(icon : Texture2D, res_name : String, desc : String):
	on_card_hovered.emit(icon, res_name, desc)
	
func _handle_on_unhovered():
	on_card_unhovered.emit()

func close_shop():
	if not shop_close_in_progress:
		shop_close_in_progress = true
		on_shop_closing.emit()
		shop_container.clear()
		for i : Card in card_array:
			i.disable_logic = true
			i.termination_seq = true
			i.termination_ticks = 50

func _on_button_pressed() -> void:
	close_shop()
