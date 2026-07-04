extends Resource

class_name Village_resourse

enum VILLAGE_TYPE{CAMP, VILLAGE, CASTLE}
enum KILL_TYPE{ENVIRONMENT = 1, ACCIDENT = 3, SILENT_KILL = 10, KNOWN_KILL = 20, RITUALISTIC_KILL = 50, IGNORE = 0}

var village_types_dict = {VILLAGE_TYPE.CAMP : "Палаточный лагерь", VILLAGE_TYPE.VILLAGE : "Деревня", VILLAGE_TYPE.CASTLE : "Ты правда поверил, что мы успеем замки?"}

@export var type : VILLAGE_TYPE
@export var current_level : int

@export_subgroup("Citizens and their stats")
@export var citizens : int
var current_panic : float #from 0 to 100

@export_subgroup("Food and mults")
@export var farmers : int #not an additional citizens but how many of them
@export var food : int
@export var food_gain_eff : float

@export_subgroup("Buildings and it's stats")
@export var buildings : int
@export var buildings_size : int #how much citizens can be stored inside one house


var citizens_const : int = citizens
var kill_on_that_turn : bool = false
var unscheduled_dayoff : bool = false
var confused : bool = false

func generate(level : int):
	if level < 7:
		type = VILLAGE_TYPE.CAMP
		
	else:
		type = VILLAGE_TYPE.VILLAGE
	
	current_panic = 0.
	match type:
		VILLAGE_TYPE.CAMP:
			citizens = randi_range(2.5 * level, (2.5 * level) + (level * 2))
			citizens_const = citizens
			buildings_size = randi_range(2, 6)
			buildings = (citizens / buildings_size) + randi_range(1,3)
			food = float(citizens) * randf_range(1.,3.)
			food_gain_eff = randf_range(2. * clampf((level) / 8., 1., 9999999.), 5. * clampf((level) / 8., 1., 9999999.))
			farmers = (float(citizens) / food_gain_eff) + randi_range(1, 3)
			
			if farmers > citizens:
				farmers = citizens
				
		VILLAGE_TYPE.VILLAGE:
			citizens = randi_range(3 * level, (3 * level) + (level * 2))
			citizens_const = citizens
			buildings_size = randi_range(4, 9)
			buildings = (citizens / buildings_size) + randi_range(1,3)
			food = float(citizens) * randf_range(1.,3.)
			food_gain_eff = randf_range(2. * clampf((level) / 8., 1., 9999999.), 5. * clampf((level) / 8., 1., 9999999.))
			farmers = (float(citizens) / food_gain_eff) + randi_range(1, 3)
			
			if farmers > citizens:
				farmers = citizens
		
	current_level = level
	print("citizens = ", citizens)
	print("farmers = ", farmers)
	print("buildings amount = ", buildings)
	print("buildings_size = ", buildings_size)
	print("food amount = ", food)
	print("food_gain_eff = ", food_gain_eff)
	print()


func get_desc() -> String:
	var send_str = ""
	
	send_str = send_str + "citizens = " + str(citizens) + "\n"
	send_str = send_str + "farmers = " + str(farmers) + "\n"
	send_str = send_str + "buildings amount = " + str(buildings) + "\n" 
	send_str = send_str + "food amount = " + str(food)
	
	return send_str


func get_village_name() -> String:
	print(type)
	return village_types_dict.get(type)
