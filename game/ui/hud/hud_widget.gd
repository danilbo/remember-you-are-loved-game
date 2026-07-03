extends Control

class_name HudWidget

const DEFAULT_MAX_VALUE := 100.0
const BAR_TWEEN_TIME := 0.28
const BAR_PULSE_SCALE := Vector2(1.06, 1.18)
const BAR_PULSE_UP_TIME := 0.08
const BAR_PULSE_DOWN_TIME := 0.16

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
@onready var mana_fill: Control = %ManaFill
@onready var hp_fill: Control = %HpFill
@onready var energy_fill: Control = %EnergyFill
@onready var control_fill: Control = %ControlFill
@onready var mana_bar: Control = %ManaBar
@onready var hp_bar: Control = %HpBar
@onready var energy_bar: Control = %EnergyBar
@onready var control_bar: Control = %ControlBar

var _bars: Dictionary = {}
var _bar_fills: Dictionary = {}
var _value_labels: Dictionary = {}
var _bar_fill_tweens: Dictionary = {}
var _bar_pulse_tweens: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bars = {
		&"mana": mana_bar,
		&"hp": hp_bar,
		&"energy": energy_bar,
		&"control": control_bar,
	}
	_bar_fills = {
		&"mana": mana_fill,
		&"hp": hp_fill,
		&"energy": energy_fill,
		&"control": control_fill,
	}
	for bar in _bars.values():
		_set_bar_pivot_to_center(bar)
	_value_labels = {
		&"hourglass": hourglass_value_label,
		&"soul": soul_value_label,
	}
	update_values(false)

func update_values(animate_bars := true) -> void:
	set_hourglass_value(hourglass_value)
	set_mana_value(mana_value, animate_bars)
	set_soul_value(soul_value)
	set_hp_value(hp_value, animate_bars)
	set_energy_value(energy_value, animate_bars)
	set_control_value(control_value, animate_bars)

func set_hourglass_value(value: float) -> void:
	hourglass_value = clampf(value, 0.0, _safe_max(hourglass_max_value))
	_update_value_label(&"hourglass", hourglass_value)

func set_mana_value(value: float, animate := true) -> void:
	mana_value = clampf(value, 0.0, _safe_max(mana_max_value))
	_update_bar(&"mana", mana_value, mana_max_value, animate)

func set_soul_value(value: float) -> void:
	soul_value = clampf(value, 0.0, _safe_max(soul_max_value))
	_update_value_label(&"soul", soul_value)

func set_hp_value(value: float, animate := true) -> void:
	hp_value = clampf(value, 0.0, _safe_max(hp_max_value))
	_update_bar(&"hp", hp_value, hp_max_value, animate)

func set_energy_value(value: float, animate := true) -> void:
	energy_value = clampf(value, 0.0, _safe_max(energy_max_value))
	_update_bar(&"energy", energy_value, energy_max_value, animate)

func set_control_value(value: float, animate := true) -> void:
	control_value = clampf(value, 0.0, DEFAULT_MAX_VALUE)
	_update_bar(&"control", control_value, DEFAULT_MAX_VALUE, animate)

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

func _update_bar(stat_name: StringName, value: float, max_value: float, animate := true) -> void:
	var fill := _bar_fills.get(stat_name) as Control
	if not fill:
		return

	var parent_size := fill.get_parent_control().size
	var ratio := clampf(value / _safe_max(max_value), 0.0, 1.0)
	var target_size := Vector2(parent_size.x * ratio, parent_size.y)
	if not animate:
		fill.size = target_size
		return

	_animate_bar_fill(stat_name, fill, target_size)
	_pulse_bar(stat_name)

func _animate_bar_fill(stat_name: StringName, fill: Control, target_size: Vector2) -> void:
	var active_tween := _bar_fill_tweens.get(stat_name) as Tween
	if active_tween:
		active_tween.kill()

	var tween := create_tween()
	_bar_fill_tweens[stat_name] = tween
	tween.tween_property(fill, "size", target_size, BAR_TWEEN_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func():
		if _bar_fill_tweens.get(stat_name) == tween:
			_bar_fill_tweens.erase(stat_name)
	)

func _pulse_bar(stat_name: StringName) -> void:
	var bar := _bars.get(stat_name) as Control
	if not bar:
		return

	var active_tween := _bar_pulse_tweens.get(stat_name) as Tween
	if active_tween:
		active_tween.kill()

	bar.scale = Vector2.ONE
	var tween := create_tween()
	_bar_pulse_tweens[stat_name] = tween
	tween.tween_property(bar, "scale", BAR_PULSE_SCALE, BAR_PULSE_UP_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(bar, "scale", Vector2.ONE, BAR_PULSE_DOWN_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func():
		if _bar_pulse_tweens.get(stat_name) == tween:
			_bar_pulse_tweens.erase(stat_name)
	)

func _set_bar_pivot_to_center(bar: Control) -> void:
	if not bar:
		return
	bar.pivot_offset = bar.size * 0.5

func _safe_max(value: float) -> float:
	return maxf(value, 1.0)
