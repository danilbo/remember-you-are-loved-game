extends Node2D
class_name MapNode 

@export var data: MapNodeData



signal hovered(data: MapNodeData)
signal unhovered()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_data(data: MapNodeData):
	self.data = data

func  get_data() -> MapNodeData:
	return self.data
	

func _on_area_2d_mouse_entered() -> void:
	print("enter")
	hovered.emit(data)


func _on_area_2d_mouse_exited() -> void:
	print("exit")
	unhovered.emit()
