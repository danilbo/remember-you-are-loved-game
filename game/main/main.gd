extends Node2D

const MAP_MANAGER_SCENE = preload("res://game/map/map_manager/map_manager.tscn")
const TOOLTIP_SCENE = preload("res://game/ui/universal_tooltip/universal_tooltip.tscn")
var temp_node_list : Array[MapNode] = []

var universal_tooltip : UniversalTooltip

var map_manager : MapManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_universal_tooltip()
	spawn_map_manager()
	map_manager.spawn_next_nodes(3)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if universal_tooltip and universal_tooltip.visible:
		update_tooltip_position()
		
func spawn_map_manager():
	if map_manager:
		return
	map_manager = MAP_MANAGER_SCENE.instantiate()
	add_child(map_manager)
	
	map_manager.on_any_node_hovered.connect(_handle_node_hovered)
	map_manager.on_any_node_unhovered.connect(_handle_node_unhovered)
	


func spawn_universal_tooltip():
	universal_tooltip = TOOLTIP_SCENE.instantiate()
	add_child(universal_tooltip)

func _handle_node_hovered(data : MapNodeData):
	if !data:
		return 
	universal_tooltip.set_data(data)
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
