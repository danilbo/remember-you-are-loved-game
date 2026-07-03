extends Control

class_name HudWidget

const DEFAULT_MAX_VALUE := 100.0

@export_category("Values")
@export var hourglass_value := 0.0
@export var mana_value := 0.0
@export var soul_value := 0.0
@export var hp_value := 0.0
@export var energy_value := 0.0
@export_range(0.0, 100.0) var control_value := 0.0

@export_category("Max Values")
@export var hourglass_max_value := DEFAULT_MAX_VALUE
@export var mana_max_value := DEFAULT_MAX_VALUE
@export var soul_max_value := DEFAULT_MAX_VALUE
@export var hp_max_value := DEFAULT_MAX_VALUE
@export var energy_max_value := DEFAULT_MAX_VALUE

@onready var hourglass_value_label: Label = %HourglassValue
@onready var soul_value_label: Label = %SoulValue
@onready var mana_fill: ColorRect = %ManaFill
@onready var hp_fill: ColorRect = %HpFill
@onready var energy_fill: ColorRect = %EnergyFill
@onready var control_fill: ColorRect = %ControlFill

var _bar_fills: Dictionary = {}
var _value_labels: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_fills = {
		&"mana": mana_fill,
		&"hp": hp_fill,
		&"energy": energy_fill,
		&"control": control_fill,
	}
	_value_labels = {
		&"hourglass": hourglass_value_label,
		&"soul": soul_value_label,
	}
	update_values()

func update_values() -> void:
	set_hourglass_value(hourglass_value)
	set_mana_value(mana_value)
	set_soul_value(soul_value)
	set_hp_value(hp_value)
	set_energy_value(energy_value)
	set_control_value(control_value)

func set_hourglass_value(value: float) -> void:
	hourglass_value = clampf(value, 0.0, _safe_max(hourglass_max_value))
	_update_value_label(&"hourglass", hourglass_value)

func set_mana_value(value: float) -> void:
	mana_value = clampf(value, 0.0, _safe_max(mana_max_value))
	_update_bar(&"mana", mana_value, mana_max_value)

func set_soul_value(value: float) -> void:
	soul_value = clampf(value, 0.0, _safe_max(soul_max_value))
	_update_value_label(&"soul", soul_value)

func set_hp_value(value: float) -> void:
	hp_value = clampf(value, 0.0, _safe_max(hp_max_value))
	_update_bar(&"hp", hp_value, hp_max_value)

func set_energy_value(value: float) -> void:
	energy_value = clampf(value, 0.0, _safe_max(energy_max_value))
	_update_bar(&"energy", energy_value, energy_max_value)

func set_control_value(value: float) -> void:
	control_value = clampf(value, 0.0, DEFAULT_MAX_VALUE)
	_update_bar(&"control", control_value, DEFAULT_MAX_VALUE)

func set_hourglass_max_value(value: float) -> void:
	hourglass_max_value = _safe_max(value)
	set_hourglass_value(hourglass_value)

func set_mana_max_value(value: float) -> void:
	mana_max_value = _safe_max(value)
	set_mana_value(mana_value)

func set_soul_max_value(value: float) -> void:
	soul_max_value = _safe_max(value)
	set_soul_value(soul_value)

func set_hp_max_value(value: float) -> void:
	hp_max_value = _safe_max(value)
	set_hp_value(hp_value)

func set_energy_max_value(value: float) -> void:
	energy_max_value = _safe_max(value)
	set_energy_value(energy_value)

func set_value(stat_name: StringName, value: float) -> void:
	match stat_name:
		&"hourglass":
			set_hourglass_value(value)
		&"mana":
			set_mana_value(value)
		&"soul":
			set_soul_value(value)
		&"hp":
			set_hp_value(value)
		&"energy":
			set_energy_value(value)
		&"control":
			set_control_value(value)

func set_max_value(stat_name: StringName, value: float) -> void:
	match stat_name:
		&"hourglass":
			set_hourglass_max_value(value)
		&"mana":
			set_mana_max_value(value)
		&"soul":
			set_soul_max_value(value)
		&"hp":
			set_hp_max_value(value)
		&"energy":
			set_energy_max_value(value)

func _update_value_label(stat_name: StringName, value: float) -> void:
	var label := _value_labels.get(stat_name) as Label
	if label:
		label.text = str(roundi(value))

func _update_bar(stat_name: StringName, value: float, max_value: float) -> void:
	var fill := _bar_fills.get(stat_name) as ColorRect
	if not fill:
		return

	var parent_size := fill.get_parent_control().size
	var ratio := clampf(value / _safe_max(max_value), 0.0, 1.0)
	fill.size = Vector2(parent_size.x * ratio, parent_size.y)

func _safe_max(value: float) -> float:
	return maxf(value, 1.0)
