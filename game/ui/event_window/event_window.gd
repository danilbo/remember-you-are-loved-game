extends Control

# 1. Exported variables (These will appear in the Inspector for easy setup!)
@export var title_text: String = "СОБЫТИЕ" : set = set_title
@export var description_text: String = "Описание..." : set = set_description
@export var image_texture: Texture2D : set = set_image

# 2. Get references to the UI nodes
@onready var title_label: Label = $EventPanel/EventContent/TextContent/Title
@onready var description_label: Label = $EventPanel/EventContent/TextContent/CenterContainer2/Description
@onready var image_node: TextureRect = $EventPanel/EventContent/Image
@onready var btn: Button = $EventPanel/EventContent/TextContent/CenterContainer/ButtonContinue

# 3. The Setter Functions (Updates the UI when the variables change)
func set_title(new_text: String) -> void:
	title_text = new_text
	if title_label:
		title_label.text = new_text

func set_description(new_text: String) -> void:
	description_text = new_text
	if description_label:
		description_label.text = new_text

func set_image(new_texture: Texture2D) -> void:
	image_texture = new_texture
	if image_node:
		image_node.texture = new_texture

# 4. Initialize with inspector values when the scene loads
func _ready():
	# Force the UI to update with whatever is set in the Inspector
	set_title(title_text)
	set_description(description_text)
	set_image(image_texture)
	
	# Optional: connect the button signal here
	btn.pressed.connect(_on_continue_pressed)

func _on_continue_pressed():
	if GlobalVariables.ending != -1:
		get_tree().quit()
		
	queue_free() # Destroy the window if you don't need it anymore
