extends Node

class_name Player

@export_subgroup("Characteristics")
@export var hp : float = 100.
@export var energy : float = 100.
@export var control : float = 100.
@export var mana : float = 100.
@export var hand_size : int = 1 #max = 8

@export_subgroup("Node Links")
@export var hand_box_container : Node2D
@export var buff_card_place1 : Node2D
@export var village : Node
@export var graveyard : Vector2
@export var deck_card_node : Card
@export var main_node : Node2D

signal on_player_stats_change(hp : float, energy : float, control : float, mana : float)

var deck : Array[Logical_card] = [preload("res://resourses/shelter.tres").duplicate(), preload("res://resourses/godfist_save.tres").duplicate(), preload("res://resourses/panic_reduce.tres").duplicate(), preload("res://resourses/unscheduled_dayoff.tres").duplicate(), preload("res://resourses/clear_weather.tres").duplicate(), preload("res://resourses/lightning_bolt.tres").duplicate(), preload("res://resourses/storm.tres").duplicate()]#, preload("res://resourses/godlike_healing.tres").duplicate(), preload("res://resourses/godlike_healing.tres").duplicate()]
var current_deck_delta : int = 0
var can_play_cards = true

var current_card_playing : Card

var deck_node_show_ticks : int = 0
var deck_node_show_seq : bool = false

func _ready() -> void:
	on_player_stats_change.emit(hp, energy, control, mana)
	#print(deck)

func _process(delta: float) -> void:
	if not deck_card_node.visible:
		if deck_node_show_seq:
			deck_node_show_ticks -= 1
			if deck_node_show_ticks <= 0:
				deck_card_node.show()
				deck_node_show_seq = false

func change_characteristics(energy_delta : float = 0., mana_delta : float = 0., control_delta : float = 0., panic_delta : float = 0., hp_delta : float = 0.) -> void:
	if panic_delta != 0.:
		interact_with_village(0, 0, 0, panic_delta)
	
	energy += energy_delta
	mana += mana_delta
	control += control_delta
	hp += hp_delta
	
	energy = clampf(energy, 0., 100.)
	mana = clampf(mana, 0., 100.)
	control = clampf(control, 0., 100.)
	hp = clampf(hp, 0., 100.)
	
	on_player_stats_change.emit(hp, energy, control, mana)
	
	if hp == 0:
		die()
	
	print("energy = ", energy)
	print("mana = ", mana)
	print("control = ", control)
	print("hp = ", hp)
	print()


func do_special_trigger(args : Array) -> void:
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
	if panic_delta != 0.:
		village.current_panic += panic_delta
		village.current_panic = clampf(village.current_panic, 0, 100)
	
	for i in range(0, kills):
		village.kill_citizen(kill_type, -1)
		
	for i in range(0, demolish_houses):
		village.demolish_building(kill_type)
	


func new_turn() -> void:
	var c : int = 0
	var res_ticks : int = 0
	var only_passive_deleted : bool = true
	var deletion_indexes : Array[int] = []
	
	village.tick()
	
	change_characteristics(20, 12)
	
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


func die():
	for i : Card in main_node.card_array:
		if i.logical_res.name == "Спасение" and i.logical_res.position == i.logical_res.POSITIONS.PASSSIVE:
			for j in buff_card_place1.linked_nodes:
				if j[0] == i:
					buff_card_place1.remove_element_at_index(j[1])
					break
					
			i.send_to_grave()
			change_characteristics(0, 0, 100, -25, 10)
			break
	
	if hp <= 0.:
		pass


func item_trigger(item_name : String) -> bool:
	for i : Card in main_node.card_array:
		if i.logical_res.name == item_name and i.logical_res.position == i.logical_res.POSITIONS.PASSSIVE:
			for j in buff_card_place1.linked_nodes:
				if j[0] == i:
					buff_card_place1.remove_element_at_index(j[1])
					break
					
			i.send_to_grave()
			return true
			
	return false
	


func _on_button_pressed() -> void:
	new_turn()
