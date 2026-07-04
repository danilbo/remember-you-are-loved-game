extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_data(citizens : int, current_panic : float, 
farmers : int, food : int, buildings : int, buildings_size : int):
	$TextureRect/HBoxContainer/VBoxContainer/Sitezens.text = "Жители: %s" % citizens
	$TextureRect/HBoxContainer/VBoxContainer/Panic.text = "Паника: %s" % clamp(int(current_panic), 0, 100)
	$TextureRect/HBoxContainer/VBoxContainer/BuildindSize.text = "Размер: %s" % buildings_size
	$TextureRect/HBoxContainer/VBoxContainer/Buildings.text = "Дома: %s" % buildings
	$TextureRect/HBoxContainer/VBoxContainer/Farmers.text = "Фермеры: %s" % farmers
	$TextureRect/HBoxContainer/VBoxContainer/Food.text = "Еда: %s" % food
