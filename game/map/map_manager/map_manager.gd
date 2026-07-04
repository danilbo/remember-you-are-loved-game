extends Node2D

class_name MapManager

const MAP_NODE_SCENE = preload("res://game/map/map_node/map_node.tscn")

signal on_any_node_hovered(data : MapNodeData)
signal on_any_node_unhovered()
signal screen_change_requested(show: bool, request_id: int)
signal screen_change_finished(request_id: int)
signal gameplay_node_selected(node : MapNode)
signal on_screen_overflow

var data_paths: Array[String] = [
	"res://game/resources/default_map_node.tres",
    "res://game/resources/another_default_map_node.tres"
]

@export_category("Map node positining values")
@export var current_pos : Vector2 = Vector2(-50,500)
@export var y_step := 200
@export var x_step := 600
@export var x_random_offset := 20

@export_category("draw line params")
@export var dash_length := 12.0
@export var gap_length := 8.0
@export var draw_line_time := 0.5
@export var line_color := Color.WHITE
@export var line_width := 4.0
@export var targe_center_offset:= 55.0
@export var _active_part := .6
var passed_nodes : Array[MapNode] = []
var possible_nodes : Array[MapNode] = []
var _drawn_lines: Array[PackedVector2Array] = []
var _active_line := PackedVector2Array()
var _active_line_progress := 0.0
var _active_line_tween: Tween
var _is_transitioning := false
var _screen_change_request_id := 0
@export var map_offset_x:= 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_current_pos() -> Vector2:
	if passed_nodes.size() <= 0:
		return current_pos
	return passed_nodes[passed_nodes.size()-1].position

func get_current_global_pos() -> Vector2:
	if passed_nodes.size() <= 0:
		return current_pos
	return passed_nodes[passed_nodes.size()-1].global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw() -> void:
	for line in _drawn_lines:
		_draw_dashed_line(line[0], line[1], 1.0)

	if _active_line.size() == 2:
		_draw_dashed_line(_active_line[0], _active_line[1], _active_line_progress)

func _check_screen():
	if get_viewport_rect().size.x * _active_part <= get_current_pos().x - map_offset_x:
		
		global_position.x -=  get_viewport_rect().size.x / 2;
		map_offset_x +=  get_viewport_rect().size.x / 2;
		on_screen_overflow.emit()
	
	
	
func spawn_next_nodes(amount : int) -> Array[MapNode]:
	_check_screen()
		
	var target_points := get_points(current_pos, amount)
	possible_nodes.clear()
	for point in target_points:
		var node :=spawn_map_node(point, MapNodeData.new())
		possible_nodes.append(node)
		
	
	return possible_nodes
	
	
func get_points(start: Vector2, count: int) -> Array[Vector2]:
	var points: Array[Vector2] = []

	if count <= 0:
		return points

	var first_y := start.y - (count - 1) * y_step * 0.5

	for i in range(count):
		var x := start.x + x_step + randf_range(-x_random_offset, x_random_offset)
		var y := first_y + i * y_step
		if y < 200 or y > 800:
			continue
		points.append(Vector2(x, y))

	return points	
	
func _has_passed_nodes() -> bool:
	return !passed_nodes.is_empty()
	
func _update_current_position():
	current_pos = passed_nodes[passed_nodes.size()].position

func _on_node_hover_handle(data : MapNodeData):
	on_any_node_hovered.emit(data)
func _on_node_unhover_handle():
	on_any_node_unhovered.emit()

func spawn_map_node(position: Vector2, new_data : MapNodeData) -> MapNode:
	var node : MapNode = MAP_NODE_SCENE.instantiate()
	node.position = position
	add_child(node)
	node.set_data(new_data)
	node.hovered.connect(_on_node_hover_handle)
	node.unhovered.connect(_on_node_unhover_handle)
	node.clicked.connect(_handle_node_click)
	return node

func _handle_node_click(node: MapNode):
	gameplay_node_selected.emit(node)
	
	if _is_transitioning:
		return
	_is_transitioning = true

	var previous_node_pos := current_pos
	if passed_nodes.size() > 0:
		var previous_node:= passed_nodes[passed_nodes.size()-1]
		previous_node.clear_outline()
	for mp in possible_nodes:
		if mp != node:
			mp.delete()
	possible_nodes.clear()
	passed_nodes.append(node)
	
# временно
	current_pos = node.position
	await _draw_line_over_time(previous_node_pos + 
	Vector2 (targe_center_offset, targe_center_offset), 
		current_pos +
		Vector2 (targe_center_offset, targe_center_offset)
	)
	await node.play_outline_animation()
	await _do_screen_change(false)
	_is_transitioning = false
	_start_screen_change(true)
				

func _draw_line_over_time(from: Vector2, to: Vector2) -> void:
	if _active_line_tween:
		_active_line_tween.kill()

	if _active_line.size() == 2:
		_drawn_lines.append(_active_line.duplicate())

	_active_line = PackedVector2Array([from, to])
	_active_line_progress = 0.0
	queue_redraw()

	_active_line_tween = create_tween()
	_active_line_tween.tween_method(_set_active_line_progress, 0.0, 1.0, draw_line_time)
	_active_line_tween.finished.connect(_commit_active_line)
	await _active_line_tween.finished

func _do_screen_change(show: bool) -> void:
	var request_id := _next_screen_change_request_id()
	screen_change_requested.emit(show, request_id)
	while true:
		var finished_request_id: int = await screen_change_finished
		if finished_request_id == request_id:
			return

func _start_screen_change(show: bool) -> void:
	screen_change_requested.emit(show, _next_screen_change_request_id())

func _next_screen_change_request_id() -> int:
	_screen_change_request_id += 1
	return _screen_change_request_id

func _set_active_line_progress(value: float) -> void:
	_active_line_progress = value
	queue_redraw()

func _commit_active_line() -> void:
	if _active_line.size() == 2:
		_drawn_lines.append(_active_line.duplicate())
	_active_line.clear()
	_active_line_progress = 0.0
	queue_redraw()

func _draw_dashed_line(from: Vector2, to: Vector2, progress: float) -> void:
	var line_vector := to - from
	var line_length := line_vector.length()
	if line_length <= 0.0:
		return

	var visible_length := line_length * clampf(progress, 0.0, 1.0)
	var direction := line_vector / line_length
	var safe_dash_length := maxf(dash_length, 1.0)
	var safe_gap_length := maxf(gap_length, 0.0)
	var pattern_length := safe_dash_length + safe_gap_length
	var distance := 0.0

	while distance < visible_length:
		var dash_start := distance
		var dash_end := minf(distance + safe_dash_length, visible_length)
		draw_line(from + direction * dash_start, from + direction * dash_end, line_color, line_width, true)
		distance += pattern_length

	
