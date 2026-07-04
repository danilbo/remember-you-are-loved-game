extends Resource

class_name Logical_card

enum RISK_LEVEL{LOW, MEDIUM, HIGH}
enum TYPES{GOD,HERO,ITEM}
enum CASTING_TYPES{INSTANT, BUFF}
enum POSITIONS{DECK, HAND, GRAVE, PASSSIVE}

@export_subgroup("Card type")
@export var dumb_card : bool = true
@export var risk_level : RISK_LEVEL
@export var type : TYPES
@export var casting_type : CASTING_TYPES
@export var name : String
@export var desctiption : String

@export_subgroup("Buff and debuff")
@export var duration : int
@export var has_special_trigger : bool

@export_subgroup("Stats affection")
@export var hp : float
@export var energy : float
@export var control : float
@export var mana : float
@export var panic : float
@export var kills : int
@export var demolish_buildings : int
@export var kill_type : Village.KILL_TYPE #{ENVIRONMENT = 1, ACCIDENT = 3, SILENT_KILL = 10, KNOWN_KILL = 20, RITUALISTIC_KILL = 50, IGNORE = 0}
@export var special_triggers : Array

@export_subgroup("Buff stats affection")
@export var hp_buff : float
@export var energy_buff : float
@export var control_buff : float
@export var mana_buff : float
@export var panic_buff : float
@export var special_triggers_buff : Array

@export_subgroup("Visuals")
@export var icon : Texture2D

@export_subgroup("Shop")
@export var base_cost : int = 1

var position = POSITIONS.DECK
var animation_loop : Array = [] #func, args
var time_on_table : int = 0 #for buffs only
var if_food_termination : bool = false


func anim_trigger(current_loop : int, player_node : Player) -> void:
	if name == "Еда" and not if_food_termination:
		if_food_termination = true
		
	var new_event = animation_loop[current_loop]
	if new_event[0] == player_node.change_characteristics:
		player_node.change_characteristics(new_event[1][0], new_event[1][1], new_event[1][2], new_event[1][3], new_event[1][4])
	
	if new_event[0] == player_node.do_special_trigger:
		player_node.do_special_trigger(new_event[1])
	
	if new_event[0] == player_node.interact_with_village:
		player_node.interact_with_village(new_event[1][0],new_event[1][1],new_event[1][2],new_event[1][3])

func generate(player_node : Player) -> void:
	animation_loop.clear()
	
	
	if dumb_card:
		if energy != 0.:
			animation_loop.append([player_node.change_characteristics, [energy, 0., 0., 0., 0.]])
			
		if mana != 0:
			animation_loop.append([player_node.change_characteristics, [0., mana, 0., 0., 0.]])
			
		if control != 0.:
			animation_loop.append([player_node.change_characteristics, [0., 0., control, 0., 0.]])
			
			
		if hp != 0.:
			animation_loop.append([player_node.change_characteristics, [0., 0., 0., 0., hp]])
			
				
		if kills != 0:
			animation_loop.append([player_node.interact_with_village, [kills, 0, kill_type, 0.]])
			
		if demolish_buildings != 0:
			animation_loop.append([player_node.interact_with_village,  [0, demolish_buildings, kill_type, 0.]])
			
		if panic != 0:
			animation_loop.append([player_node.interact_with_village, [0, 0, 0, panic]])
			
		if len(special_triggers) > 0:
			for i in range(0, len(special_triggers)):
				animation_loop.append([player_node.do_special_trigger, [special_triggers[i]]])
			

func regenerate_buff(player_node : Player) -> void:
	animation_loop.clear()
	
	if dumb_card:
		if energy_buff != 0.:
			animation_loop.append([player_node.change_characteristics, [energy_buff, 0., 0., 0., 0.]])
			
		if mana_buff != 0:
			animation_loop.append([player_node.change_characteristics, [0., mana_buff, 0., 0., 0.]])
			
		if control_buff != 0.:
			animation_loop.append([player_node.change_characteristics, [0., 0., control_buff, 0., 0.]])
			
			
		if hp_buff != 0.:
			animation_loop.append([player_node.change_characteristics, [0., 0., 0., 0., hp_buff]])
			
			
		if panic_buff != 0:
			animation_loop.append([player_node.interact_with_village, [0, 0, 0, panic]])
			
		if len(special_triggers_buff) > 0:
			for i in range(0, len(special_triggers_buff)):
				animation_loop.append([player_node.do_special_trigger, [special_triggers_buff[i]]])
