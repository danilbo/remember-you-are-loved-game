extends Node2D

const MAP_MANAGER_SCENE = preload("res://game/map/map_manager/map_manager.tscn")
const TOOLTIP_SCENE = preload("res://game/ui/universal_tooltip/universal_tooltip.tscn")

@export var camp_icon : Texture
@export var village_icon : Texture
@export var shop_icon : Texture

@export var main_gameplay_node : RootNode
@export var shop_node : Node2D

@onready var hud_widget: HudWidget = $CanvasLayer/HudWidget
@onready var camera : Camera2D = $Camera2D

var shop_chance : int = 100
var selected_dot_type : MapNode.DOT_TYPES
var selected_village_resource : Village_resourse
var temp_node_list : Array[MapNode] = []
var universal_tooltip : UniversalTooltip
var map_manager : MapManager
var _screen_change_tween: Tween

func _ready() -> void:
	#hud_widget.set_visible(false)
	
	spawn_universal_tooltip()
	spawn_map_manager()
	_subscribe_gameplay()
	_subscribe_shop()
	game_start()

	
func game_start():
	player_stats_updated(100., 100., 100., 100., 0)
	var new_node = map_manager.spawn_next_nodes(1)
	map_manager.gameplay_node_selected.connect(_handle_gameplay_select)	
	new_node[0].data.icon = camp_icon
	new_node[0].village_resource.generate(GlobalVariables.current_level)
	new_node[0].data.description = new_node[0].village_resource.get_desc()
	new_node[0].data.title = new_node[0].village_resource.get_village_name()	

func _subscribe_gameplay():
	main_gameplay_node.player_node_ext.on_player_stats_change.connect(player_stats_updated)
	main_gameplay_node.on_level_end.connect(on_level_end)
	main_gameplay_node.on_card_hovered.connect(_handler_on_card_hover)
	main_gameplay_node.on_card_unhovered.connect(_handler_on_card_unhover)	

func _subscribe_shop():
	shop_node.on_card_hovered.connect(_handler_on_card_hover)
	shop_node.on_card_unhovered.connect(_handler_on_card_unhover)
	shop_node.on_shop_closing.connect(_handle_on_shop_close)

func do_test():
	map_manager.global_position.x -= 100

func _process(delta: float) -> void:
	if universal_tooltip and universal_tooltip.visible:
		update_tooltip_position()
	if Input.is_action_just_pressed("DebugAction"):
		hud_widget.set_value(&"mana", hud_widget.mana_value + 10)
		do_test()

func spawn_map_manager():
	if map_manager:
		return
	map_manager = MAP_MANAGER_SCENE.instantiate()
	add_child(map_manager)

	map_manager.on_any_node_hovered.connect(_handle_node_hovered)
	map_manager.on_any_node_unhovered.connect(_handle_node_unhovered)
	map_manager.screen_change_requested.connect(_handle_screen_change_requested)
	map_manager.on_screen_overflow.connect(_handle_screen_overflow)

func spawn_universal_tooltip():
	universal_tooltip = TOOLTIP_SCENE.instantiate()
	add_child(universal_tooltip)

func set_hud_value(stat_name: StringName, value: float) -> void:
	hud_widget.set_value(stat_name, value)

func set_hud_max_value(stat_name: StringName, value: float) -> void:
	hud_widget.set_max_value(stat_name, value)

func _handle_node_hovered(data : MapNodeData):
	if !data:
		return
	universal_tooltip.set_data(data.get_tooltip_data())
	universal_tooltip.visible = true

func _handle_node_unhovered():
	universal_tooltip.visible = false

func update_tooltip_position():
	var mouse_pos := get_viewport().get_mouse_position()
	var viewport_size := get_viewport_rect().size
	var tooltip_size := universal_tooltip.size
	var offset := 16

	var pos := mouse_pos + Vector2(offset, -tooltip_size.y * 0.5)

	if pos.x + tooltip_size.x > viewport_size.x:
		pos.x = mouse_pos.x - tooltip_size.x - offset

	pos.y = mouse_pos.y - tooltip_size.y * 0.5

	if pos.y < 0:
		pos.y = 0

	if pos.y + tooltip_size.y > viewport_size.y:
		pos.y = viewport_size.y - tooltip_size.y

	universal_tooltip.global_position = pos

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		GlobalVariables.toggle_pause()

func do_change_screen_logic(show : bool):
	if _screen_change_tween:
		_screen_change_tween.kill()

	var material := $CanvasLayer/ColorRect.material as ShaderMaterial
	var tween_duration := 0.6
	var start_value: float = float(material.get_shader_parameter("progress"))
	var end_value: float = 1

	if !show:
		end_value = 0
		

	_screen_change_tween = create_tween()
	var tween := _screen_change_tween
	tween.tween_method(
		func(v):
			material.set_shader_parameter("progress", v),
		start_value,
		end_value,
		tween_duration
	)
	await get_tree().create_timer(tween_duration).timeout
	if _screen_change_tween == tween:
		_screen_change_tween = null

func _handle_screen_change_requested(show: bool, request_id: int) -> void:
	await do_change_screen_logic(show)
	map_manager.screen_change_finished.emit(request_id)
	on_fade_change(show, request_id)


func on_fade_change(show : bool, request_id : int):
	if not show:
		if selected_dot_type == MapNode.DOT_TYPES.LEVEL:
			main_gameplay_node.show()
			map_manager.hide()
			main_gameplay_node.player_node_ext.new_turn()
			
		else:
			map_manager.hide()
			shop_node.show()
			shop_node.create_shop(24)
			shop_node.shop_close_in_progress = false
			


func player_stats_updated(hp : float, energy : float, control : float, mana : float, souls : int):
	if mana != hud_widget.mana_value:
		hud_widget.set_mana_value(mana)
		
	if hp != hud_widget.hp_value:
		hud_widget.set_hp_value(hp)
		
	if energy != hud_widget.energy_value:
		hud_widget.set_energy_value(energy)
		
	if control != hud_widget.control_value:
		hud_widget.set_control_value(control)
		
	hud_widget.set_soul_value(souls)
	hud_widget.set_hourglass_value(GlobalVariables.current_turn)


func _handle_on_shop_close() -> void:
	await do_change_screen_logic(false)
	shop_node.hide()
	map_manager.show()
	do_change_screen_logic(true)
	generate_new_nodes(true)

func _handle_screen_overflow():
	pass
	

func on_level_end() -> void:
	await do_change_screen_logic(false)
	main_gameplay_node.hide()
	map_manager.show()
	do_change_screen_logic(true)
	generate_new_nodes()
	
	
func _handler_on_card_hover(icon : Texture2D, res_name : String, desc : String):
	var data : TooltipData = TooltipData.new()
	
	data.description = desc
	data.icon = icon
	data.title = res_name
	
	if !data:
		return
	universal_tooltip.set_data(data)
	universal_tooltip.visible = true
	
func _handler_on_card_unhover():
	universal_tooltip.visible = false


func _handle_gameplay_select(node : MapNode):
	selected_dot_type = node.dot_type
	if node.dot_type == node.DOT_TYPES.LEVEL:
		main_gameplay_node.player_node_ext.village.load_from_res(node.village_resource)
		main_gameplay_node.reassign_for_village_type()


func generate_new_nodes(no_shop : bool = false) -> void:
	var new_nodes : Array[MapNode] = map_manager.spawn_next_nodes(3)
	
	
	if GlobalVariables.current_level > 2:
		if not no_shop:
			var chance : int = randi_range(0, 100)
			print(chance,"%")
			if chance <= shop_chance:
				new_nodes.pick_random().dot_type = MapNode.DOT_TYPES.SHOP
				shop_chance = 50
				
			else:
				shop_chance += 25
			
	for i in new_nodes:
		if i.dot_type != MapNode.DOT_TYPES.SHOP:
			if GlobalVariables.current_level > 7:
				i.village_resource.type = Village_resourse.VILLAGE_TYPE.VILLAGE
				i.data.icon = village_icon
			
			else:
				i.data.icon = camp_icon
			
			i.village_resource.generate(GlobalVariables.current_level)
			i.data.description = i.village_resource.get_desc()
			i.data.title = i.village_resource.get_village_name()
			
		
		else:
			i.data.icon = shop_icon
			i.data.description = "Тут можно навсегда получить карты за души!"
			i.data.title = "Магазин"
