extends Node

class_name Player

@export_subgroup("Characteristics")
@export var hp : float = 100.
@export var energy : float = 100.
@export var control : float = 100.
@export var mana : float = 100.
@export var hand_size : int = 8 #max = 8
@export var souls : int = 0
@export var turns_to_die : int = 100

@export_subgroup("Node Links")
@export var hand_box_container : Node2D
@export var buff_card_place1 : Node2D
@export var village : Node
@export var graveyard : Vector2
@export var deck_card_node : Card
@export var main_node : RootNode

signal on_player_stats_change(hp : float, energy : float, control : float, mana : float, souls : int)
signal on_player_death
#var deck : Array[Logical_card] = [preload("res://resourses/steal_the_food.tres"), preload("res://resourses/food.tres").duplicate(),preload("res://resourses/beg_for_food.tres").duplicate(), preload("res://resourses/destroy_barn.tres").duplicate(), preload("res://resourses/master_the_panic.tres").duplicate(), preload("res://resourses/mulligan.tres"), preload("res://resourses/tornado.tres"), preload("res://resourses/amnezia.tres"), preload("res://resourses/memory_wipe.tres"), preload("res://resourses/confusion.tres"), preload("res://resourses/communicate.tres"), preload("res://resourses/rituallistic_kill.tres"), preload("res://resourses/kill.tres").duplicate(), preload("res://resourses/knife.tres").duplicate(), preload("res://resourses/campfire.tres").duplicate(), preload("res://resourses/shelter.tres").duplicate(), preload("res://resourses/godfist_save.tres").duplicate(), preload("res://resourses/panic_reduce.tres").duplicate(), preload("res://resourses/unscheduled_dayoff.tres").duplicate(), preload("res://resourses/clear_weather.tres").duplicate(), preload("res://resourses/lightning_bolt.tres").duplicate(), preload("res://resourses/storm.tres").duplicate()]#, preload("res://resourses/godlike_healing.tres").duplicate(), preload("res://resourses/godlike_healing.tres").duplicate()]
var deck : Array[Logical_card] = []
var current_deck_delta : int = 0
var can_play_cards = true

var current_card_playing : Card

var deck_node_show_ticks : int = 0
var deck_node_show_seq : bool = false

var need_to_draw_cards : bool = true
var need_to_draw_ticks_const : int = 45
var need_to_draw_ticks : int = need_to_draw_ticks_const

var need_to_draw_one_ticks_const : int = 5
var need_to_draw_one_ticks : int = need_to_draw_one_ticks_const

var new_turn_cooldown_const : int = 90
var new_turn_cooldown : int = new_turn_cooldown_const

var dead : bool = false
var forever_end : bool = false

func _ready() -> void:
	on_player_stats_change.emit(hp, energy, control, mana, souls)
	
	if true:
		for i in range(0,16):
			#deck.append(preload("res://resourses/destroy_barn.tres").duplicate())
			#deck.append(preload("res://resourses/kill.tres").duplicate())
			deck.append(main_node.shop_node.cards_list.pick_random().duplicate())

func _process(delta: float) -> void:
	if dead and not forever_end:
		if main_node.check_animations():
			main_node.end_level()
			forever_end = true
		
	if new_turn_cooldown > 0:
		new_turn_cooldown -= 1
	
	if main_node.visible and not dead:
		if need_to_draw_cards and main_node.check_animations():
			need_to_draw_ticks -= 1
			if need_to_draw_ticks <= 0:
				#need_to_draw_cards = false
				for i in range(0, hand_size):
					await get_tree().create_timer(0.03).timeout
					draw_random_card() 
					
				need_to_draw_cards = false
	
	if not deck_card_node.visible:
		if deck_node_show_seq:
			deck_node_show_ticks -= 1
			if deck_node_show_ticks <= 0:
				deck_card_node.show()
				deck_node_show_seq = false


func change_characteristics(energy_delta : float = 0., mana_delta : float = 0., control_delta : float = 0., panic_delta : float = 0., hp_delta : float = 0.) -> void:
	if dead:
		return
	
	if panic_delta != 0.:
		interact_with_village(0, 0, 0, panic_delta)
	
	if energy_delta > 0. and item_trigger("Костёр", false):
		energy_delta *= 2.
	
	elif energy_delta < 0. and item_trigger("Стимулятор", false):
		energy_delta /= 2.
	
	energy += energy_delta
	mana += mana_delta
	
	if control_delta != 0. and not item_trigger("Странное зелье", false):
		control += control_delta
		
	hp += hp_delta
	
	energy = clampf(energy, 0., 100.)
	mana = clampf(mana, 0., 100.)
	control = clampf(control, 0., 100.)
	hp = clampf(hp, 0., 100.)
	
	on_player_stats_change.emit(hp, energy, control, mana, souls)
	
	if hp <= 0:
		die(0)
		
	elif control <= 0:
		die(1)
	


func do_special_trigger(args : Array) -> void:
	if dead:
		return
	
	if "selfharm" in args:
		change_characteristics(randf_range(-25, -5), 0, randf_range(-5, 8), 0, randf_range(-25, -5))
	
	if "steal_food" in args:
		var chance : int = randi_range(0, 100)
		print(chance,"%")
		if chance < 70:
			main_node.spawn_temp_card(preload("res://resourses/food.tres").duplicate())
			deck.append(preload("res://resourses/food.tres").duplicate())
		
	
	if "beg_for_food" in args:
		var chance : int = randi_range(0, 100)
		print(chance,"%")
		if chance < 50:
			change_characteristics(0,0,0,0, [-10, -5].pick_random())
			
		else:
			main_node.spawn_temp_card(preload("res://resourses/food.tres").duplicate())
			deck.append(preload("res://resourses/food.tres").duplicate())
	
	if "burn_the_barn" in args:
		village.food -= village.food / 5.
	
	if "hp_random" in args:
		change_characteristics(0,0,0,0, [-10, -5, 0].pick_random())
	
	if "mulligan" in args:
		var cards_in_hand : int = len(hand_box_container.linked_nodes) - 1
		for i : Card in main_node.card_array:
			if i.logical_res.position == i.logical_res.POSITIONS.HAND:
				for j in hand_box_container.linked_nodes:
					if j[0] == i:
						hand_box_container.remove_element_at_index(j[1])
						break
						
				i.send_to_grave()
					

		for i in range(0, cards_in_hand):
			draw_random_card()
	
	if "tornado" in args:
		trigger_on_bad_weather()
		var chance : int = randi_range(0, 100) 
		print(chance,"%")
		if chance < 50:
			if not item_trigger("Самодельное убежище"):
				change_characteristics(0, 0, 0, 0, -60)
				
			interact_with_village(0, randi_range(1, village.buildings / 2), Village.KILL_TYPE.ENVIRONMENT)
	
	if "confusion" in args:
		village.confused = true
	
	if "comm1" in args:
		change_characteristics(0., 0., [-5., 10].pick_random())
		
	if "comm2" in args:
		interact_with_village(0, 0, 0, [-5., 0, 5].pick_random())
	
	if "unscheduled_dayoff" in args:
		village.unscheduled_dayoff = true
	
	if "good_weather" in args:
		trigger_on_good_weather()
	
	if "bad_weather" in args:
		trigger_on_bad_weather()
	
	if "bolt" in args:
		var chance : int = randi_range(0, 100)
		trigger_on_bad_weather()
		if chance <= 5:
			if not item_trigger("Самодельное убежище"):
				change_characteristics(0, 0, 0, 0, -60)
			
		elif chance <= 25:
			interact_with_village(0, 1, 1)
			
		else:
			interact_with_village(1, 0, 1)

func draw_random_card() -> void:
	if len(hand_box_container.linked_nodes) < hand_size:
		for i in deck:
			match i.position:
				i.POSITIONS.DECK:
					i.position = i.POSITIONS.HAND
					main_node.spawn_card(i, hand_box_container)
					current_deck_delta += 1
					break
					
		if len(deck) - current_deck_delta <= 0:
			deck_card_node.hide()


func interact_with_village(kills : int, demolish_houses : int, kill_type, panic_delta : float = 0.):
	if dead:
		return
	
	if panic_delta != 0.:
		if not village.confused:
			village.current_panic += panic_delta
			
		else:
			village.current_panic += panic_delta
		village.current_panic = clampf(village.current_panic, 0, 100)
	
	if kills > 0:
		if kill_type == village.KILL_TYPE.SILENT_KILL or kill_type == village.KILL_TYPE.KNOWN_KILL or kill_type == village.KILL_TYPE.RITUALISTIC_KILL:
			if item_trigger("Нож"):
				change_characteristics(10)
				
			if item_trigger("Ритуальный нож"):
				change_characteristics(0, 6)
				
		if item_trigger("Точечная амнезия"):
			kill_type = Village.KILL_TYPE.IGNORE
			
		elif item_trigger("Маскировка"):
			kill_type = Village.KILL_TYPE.ACCIDENT
	
	
	if kill_type != Village.KILL_TYPE.IGNORE:
		if item_trigger("Стирание памяти", false):
			kill_type = Village.KILL_TYPE.IGNORE
	
	
	for i in range(0, kills):
		village.kill_citizen(kill_type, -1)
		
	for i in range(0, demolish_houses):
		village.demolish_building(kill_type)
	
	
	village.on_stat_change.emit(village.citizens, village.current_panic, village.farmers, village.food, village.buildings, village.buildings_size)


func new_turn() -> void:
	if not main_node.check_animations() or need_to_draw_cards or new_turn_cooldown > 0 or dead:
		return
	
	if turns_to_die <= GlobalVariables.current_turn:
		die(3)
	
	GlobalVariables.current_turn += 1
	
	new_turn_cooldown = new_turn_cooldown_const
	
	current_deck_delta = 0
	
	need_to_draw_cards = true
	need_to_draw_ticks = need_to_draw_ticks_const
	
	var c : int = 0
	var res_ticks : int = 0
	var only_passive_deleted : bool = true
	var deletion_indexes : Array[int] = []
	
	village.tick()
	
	change_characteristics(15, 10, 4)
	
	for i : Card in main_node.card_array:
		#print(i.logical_res.position, i.logical_res.POSITIONS.HAND)
		match i.logical_res.position:
			i.logical_res.POSITIONS.HAND:
				deletion_indexes.append(main_node.card_array.find(i))
				for j in hand_box_container.linked_nodes:
					if j[0] == i:
						hand_box_container.remove_element_at_index(j[1])
						break
						
				i.new_pos = deck_card_node.position
				i.logical_res.position = i.logical_res.POSITIONS.DECK
				i.rotation_def.y = 180.
				i.termination_seq = true
				i.termination_ticks = 25
				if only_passive_deleted:
					only_passive_deleted = false
			
			i.logical_res.POSITIONS.GRAVE:
				deletion_indexes.append(main_node.card_array.find(i))
				
				if i.logical_res.name != "Еда":
					i.new_pos = deck_card_node.position
				
				i.logical_res.position = i.logical_res.POSITIONS.DECK
				i.rotation_def.y = 180.
				i.termination_seq = true
				i.termination_ticks = 25
				if only_passive_deleted:
					only_passive_deleted = false
			
			i.logical_res.POSITIONS.PASSSIVE:
				i.logical_res.time_on_table += 1
				if not i.logical_res.has_special_trigger:
					i.use_bigger_card = true
					i.trigger_pulse_animation(c * i.pulse_ticks_const * len(i.logical_res.animation_loop))
					if res_ticks == 0:
						res_ticks += c * i.pulse_ticks_const * len(i.logical_res.animation_loop)
					c += 1
				
				if i.logical_res.time_on_table >= i.logical_res.duration:
					deletion_indexes.append(main_node.card_array.find(i))
					
					if i.logical_res.has_special_trigger:
						for j in buff_card_place1.linked_nodes:
							if j[0] == i:
								buff_card_place1.remove_element_at_index(j[1])
								break
								
						i.new_pos = deck_card_node.position
						i.logical_res.position = i.logical_res.POSITIONS.DECK
						i.rotation_def.y = 180.
						i.termination_seq = true
						i.termination_ticks = 25
						i.logical_res.time_on_table = 0
				
				else:
					current_deck_delta -= 1
			
	if not deck_card_node.visible and not deck_node_show_seq and len(deletion_indexes) > 0:
		if not only_passive_deleted:
			deck_node_show_ticks = 15
			
		else:
			deck_node_show_ticks = (res_ticks * 2) - 4
			
		deck_node_show_seq = true
		
	deletion_indexes.sort()
	deletion_indexes.reverse()
	current_deck_delta -= len(deletion_indexes)
	
	for i in deletion_indexes:
		main_node.card_array.remove_at(i)
	
	deletion_indexes.clear()
	
	for i in deck:
		if i.name == "Еда" and i.if_food_termination:
			deletion_indexes.append(deck.find(i))
			
			
	deletion_indexes.sort()
	deletion_indexes.reverse()
		
	for i in deletion_indexes:
		deck.remove_at(i)
		
	
	deck.shuffle()

func trigger_on_bad_weather() -> void:
	for i : Card in main_node.card_array:
		if i.logical_res.name == "Хорошая погода" and i.logical_res.position == i.logical_res.POSITIONS.PASSSIVE:
			for j in buff_card_place1.linked_nodes:
				if j[0] == i:
					buff_card_place1.remove_element_at_index(j[1])
					break
					
			i.send_to_grave()


func trigger_on_good_weather() -> void:
	for i : Card in main_node.card_array:
		if i.logical_res.name == "Гроза" and i.logical_res.position == i.logical_res.POSITIONS.PASSSIVE:
			for j in buff_card_place1.linked_nodes:
				if j[0] == i:
					buff_card_place1.remove_element_at_index(j[1])
					break
					
			i.send_to_grave()


func die(ending : int):
	for i : Card in main_node.card_array:
		if i.logical_res.name == "Спасение" and i.logical_res.position == i.logical_res.POSITIONS.PASSSIVE:
			for j in buff_card_place1.linked_nodes:
				if j[0] == i:
					buff_card_place1.remove_element_at_index(j[1])
					break
					
			i.send_to_grave()
			change_characteristics(0, 0, 100, -35, 10)
			return
	
	dead = true
	on_player_death.emit()


func item_trigger(item_name : String, delete_item : bool = true) -> bool:
	for i : Card in main_node.card_array:
		if i.logical_res.name == item_name and i.logical_res.position == i.logical_res.POSITIONS.PASSSIVE:
			if delete_item:
				for j in buff_card_place1.linked_nodes:
					if j[0] == i:
						buff_card_place1.remove_element_at_index(j[1])
						break
						
				i.send_to_grave()
			return true
			
	return false
	

func obtain_soul() -> void:
	souls += 1
	on_player_stats_change.emit(hp, energy, control, mana, souls)


func _on_button_pressed() -> void:
	new_turn()
