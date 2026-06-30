extends Node2D

const MAP_NODE_SCENE = preload("res://game/map/map_node/map_node.tscn")
const TOOLTIP_SCENE = preload("res://game/ui/universal_tooltip/universal_tooltip.tscn")
var temp_node_list : Array[MapNode] = []

var universal_tooltip : UniversalTooltip

var data_paths: Array[String] = [
	"res://game/resources/default_map_node.tres",
    "res://game/resources/another_default_map_node.tres"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_temp_test_logic()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if universal_tooltip and universal_tooltip.visible:
		update_tooltip_position()
		
func _temp_test_logic():
	
	spawn_universal_tooltip()
	
	temp_node_list.append(spawn_map_node(Vector2(-50, 100)))
	temp_node_list.append(spawn_map_node(Vector2(0, 500)))
	temp_node_list.append(spawn_map_node(Vector2(1100, 600)))
	temp_node_list.append(spawn_map_node(Vector2(1100, 0)))
	temp_node_list.append(spawn_map_node(Vector2(500, 300)))
	temp_node_list[0].set_data(load(data_paths[0]))
	temp_node_list[1].set_data(load(data_paths[1]))
	temp_node_list[2].set_data(load(data_paths[0]))
	temp_node_list[3].set_data(load(data_paths[1]))
	
	
func spawn_map_node(position: Vector2) -> MapNode:
	var node : MapNode = MAP_NODE_SCENE.instantiate()
	node.position = position
	add_child(node)
	node.hovered.connect(_handle_node_hovered)
	node.unhovered.connect(_handle_node_unhovered)
	return node

func spawn_universal_tooltip():
	universal_tooltip = TOOLTIP_SCENE.instantiate()
	add_child(universal_tooltip)

func _handle_node_hovered(data : MapNodeData):
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
