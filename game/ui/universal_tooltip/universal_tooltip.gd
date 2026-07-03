extends PanelContainer
class_name UniversalTooltip

@export var widget_data : MapNodeData


@onready var icon: TextureRect = $MarginContainer/VBoxContainer/TextureRect
@onready var title: RichTextLabel = $MarginContainer/VBoxContainer/Title
@onready var description: RichTextLabel = $MarginContainer/VBoxContainer/Description



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_data(widget_data)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_data(data: MapNodeData):
	if data == null:
		return
	widget_data = data
	icon.texture = data.icon
	title.text = data.title
	description.text = data.description
