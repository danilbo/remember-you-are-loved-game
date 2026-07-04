extends Node

class_name Village

enum VILLAGE_TYPE{CAMP, VILLAGE, CASTLE}
enum KILL_TYPE{ENVIRONMENT = 1, ACCIDENT = 3, SILENT_KILL = 10, KNOWN_KILL = 20, RITUALISTIC_KILL = 50, IGNORE = 0}

@export var type : VILLAGE_TYPE
@export var current_level : int

@export_subgroup("Citizens and their stats")
@export var citizens : int
var current_panic : float = 0 #from 0 to 100

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
var ending_level : bool = false

func _ready() -> void:
	generate(1)

func load_from_res(resource : Village_resourse):
	type = int(resource.type)
	citizens = resource.citizens
	farmers = resource.farmers
	food = resource.food
	food_gain_eff = resource.food_gain_eff
	buildings = resource.buildings
	buildings_size = resource.buildings_size
	citizens_const = citizens
	current_panic = 0
	kill_on_that_turn = false
	unscheduled_dayoff = false
	confused = false
	ending_level = false

func generate(level : int):
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
	
	
func tick():
	if current_panic >= 75 and citizens > 2:
		var chance1 : int = randi_range(0,100)
		if chance1 <= (current_panic - 75) * 4:
			%Player.die(2)
			return
	
	food -= citizens
	
	if confused:
		confused = false
	
	if food < -1:
		for i in range(0, abs(food / 2)):
			kill_citizen(KILL_TYPE.ACCIDENT, 0)
			
			
	print("food left before harvest = ", food)
	
	if not unscheduled_dayoff:
		food += float(farmers) * food_gain_eff
		
	else:
		unscheduled_dayoff = false
	
	print("food left after harvest = ", food)
	
	current_panic -= randf_range(0.5, 3.)
	current_panic = clampf(current_panic, 0., 100.)
	
	print("panic redused, current panic = ", current_panic)
	
	print()


func kill_citizen(kill_type : KILL_TYPE, citizen_type = -1):
	match citizen_type:
		-1:
			if randi_range(0, 1) == 0 and farmers != citizens or farmers == 0:
				citizens -= 1
				print("citizen killed")
				
			else:
				citizens -= 1
				farmers -= 1
				print("farmer killed")
				
		0:
			if citizens != farmers:
				citizens -= 1
				print("citizen killed")
			
			else:
				citizens -= 1
				farmers -= 1
				print("farmer killed")
			
		1:
			if farmers == 0:
				citizens -= 1
				print("citizen killed")
				
			else:
				citizens -= 1
				farmers -= 1
				print("farmer killed")
	
	#print(float(kill_type) * (float(citizens_const) / float(citizens)))
	%Player.change_characteristics(0, 3.5)
	%Player.obtain_soul()
	
	if citizens != 0:
		if not confused:
			current_panic += ( float(kill_type) * clampf( (float(citizens_const) / float(citizens) ), 0., 2.5) ) / clampf(float(current_level) / 5., 1., 9999999.)
		
		else:
			current_panic -= ( float(kill_type) * clampf( (float(citizens_const) / float(citizens) ), 0., 2.5) ) / clampf(float(current_level) / 5., 1., 9999999.)
		
	print(citizens, " || ", int(citizens_const / 3), " || ", int(citizens - (citizens_const / 3)))
	if citizens <= clampi(int(citizens_const / 3), 1, 99999):
		%Player.main_node.current_village_state = 3
	
	elif citizens <= int(citizens_const - (citizens_const / 3)):
		%Player.main_node.current_village_state = 2
	
	
	print("current panic = ", current_panic)
	print("citizens left = ", citizens, "; farmers of them = ", farmers)
	
	
	if citizens <= 0 and not ending_level:
		ending_level = true
		await get_tree().create_timer(0.5).timeout
		%Player.main_node.end_level()

func demolish_building(kill_type : KILL_TYPE):
	for i in range(0, buildings_size):
		kill_citizen(kill_type, -1)
		if citizens <= 0:
			break
