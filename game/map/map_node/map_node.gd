extends Node2D
class_name MapNode 

enum DOT_TYPES{LEVEL, SHOP}

@export var data: MapNodeData
@export var title: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var location_data: Resource
@export var is_interactive: bool = true
@export var normal_scale: float = 1.0
@export var hover_scale: float = 1.15
@export var scale_lerp_speed: float = 10.0
@export var outline_color: Color = Color(1.0, 0.86, 0.42, 1.0)
@export var outline_width: float = 4.0
@export var outline_padding: float = 16.0
@export var outline_draw_time: float = 0.45
@export var outline_wobble: float = 4.0
@export var dot_type : DOT_TYPES
@export var village_resource : Village_resourse = Village_resourse.new()

@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite_2d: Sprite2D = $Area2D/CollisionShape2D/Sprite2D


signal hovered(data: MapNodeData)
signal unhovered()
signal clicked(map_node: MapNode)

var _target_scale: float = normal_scale
var _outline_progress: float = 0.0
var _outline_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if icon == null and sprite_2d.texture != null:
		icon = sprite_2d.texture
	scale = Vector2.ONE * normal_scale
	_target_scale = normal_scale
	set_interactive(is_interactive)
	if not area_2d.input_event.is_connected(_on_area_2d_input_event):
		area_2d.input_event.connect(_on_area_2d_input_event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var lerp_weight := clampf(delta * scale_lerp_speed, 0.0, 1.0)
	var next_scale := lerpf(scale.x, _target_scale, lerp_weight)
	scale = Vector2.ONE * next_scale

func _draw() -> void:
	if _outline_progress <= 0.0:
		return
	_draw_hand_drawn_outline()

func set_data(data: MapNodeData):
	self.data = data


func set_interactive(value: bool) -> void:
	is_interactive = value
	if area_2d:
		area_2d.input_pickable = value
	if collision_shape_2d:
		collision_shape_2d.disabled = not value
	if not value:
		_target_scale = normal_scale
	

func _on_area_2d_mouse_entered() -> void:
	if not is_interactive:
		return
	_do_hover()


func _on_area_2d_mouse_exited() -> void:
	if not is_interactive:
		return
	_do_unhover()

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not is_interactive:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_interactive = false
		_do_unhover()
		sprite_2d.modulate = Color.DARK_GRAY
		clicked.emit(self)

func _do_unhover():
		_target_scale = normal_scale
		unhovered.emit()
		
func _do_hover():
	_target_scale = hover_scale
	hovered.emit(data)

func play_outline_animation() -> void:
	if _outline_tween:
		_outline_tween.kill()
	_outline_progress = 0.0
	queue_redraw()
	_outline_tween = create_tween()
	_outline_tween.tween_method(_set_outline_progress, 0.0, 1.0, outline_draw_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await _outline_tween.finished

func clear_outline() -> void:
	if _outline_tween:
		_outline_tween.kill()
	_outline_progress = 0.0
	queue_redraw()

func _set_outline_progress(value: float) -> void:
	_outline_progress = value
	queue_redraw()

func _draw_hand_drawn_outline() -> void:
	var center := _get_outline_center()
	var radius := _get_outline_radius()
	var start_angle := -PI * 0.58
	var max_angle := TAU * _outline_progress
	var segment_count := 96
	var stroke_count := 2

	for stroke_index in range(stroke_count):
		var previous_point := Vector2.ZERO
		var has_previous_point := false
		var stroke_offset := float(stroke_index) * 0.8

		for segment_index in range(segment_count + 1):
			var segment_progress := float(segment_index) / float(segment_count)
			if segment_progress > _outline_progress:
				break

			var angle := start_angle + max_angle * segment_progress
			var wobble := sin(segment_progress * TAU * 5.0 + stroke_offset) * outline_wobble
			wobble += sin(segment_progress * TAU * 11.0 + stroke_offset * 2.0) * outline_wobble * 0.35
			var point := center + Vector2(cos(angle), sin(angle)) * (radius + wobble)

			if has_previous_point:
				draw_line(previous_point, point, outline_color, outline_width - float(stroke_index), true)

			previous_point = point
			has_previous_point = true

func _get_outline_center() -> Vector2:
	if collision_shape_2d:
		return collision_shape_2d.position
	return Vector2.ZERO

func _get_outline_radius() -> float:
	if collision_shape_2d and collision_shape_2d.shape:
		if collision_shape_2d.shape is CircleShape2D:
			return collision_shape_2d.shape.radius + outline_padding
		if collision_shape_2d.shape is RectangleShape2D:
			var rect_shape := collision_shape_2d.shape as RectangleShape2D
			return maxf(rect_shape.size.x, rect_shape.size.y) * 0.5 + outline_padding
	return 64.0 + outline_padding

func delete():
	visible = false
	queue_free()
