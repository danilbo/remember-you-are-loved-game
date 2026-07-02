extends CanvasLayer
@onready var music_slider = $CenterContainer/MenuPanel/VBoxContainer/HSliderMusic
@onready var sfx_slider = $CenterContainer/MenuPanel/VBoxContainer/HSliderSFX
@onready var continue_btn = $CenterContainer/MenuPanel/VBoxContainer/ButtonContinue
@onready var exit_btn = $CenterContainer/MenuPanel/VBoxContainer/ButtonExit

func _ready():
	visible = false
	
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color.BLACK
	btn_normal.border_width_left = 1
	btn_normal.border_width_right = 1
	btn_normal.border_width_top = 1
	btn_normal.border_width_bottom = 1
	btn_normal.border_color = Color.WHITE
	btn_normal.corner_radius_top_left = 4
	btn_normal.corner_radius_top_right = 4
	btn_normal.corner_radius_bottom_left = 4
	btn_normal.corner_radius_bottom_right = 4
	
	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = Color(0.2, 0.2, 0.2)   
	
	_apply_button_style(continue_btn, btn_normal, btn_hover)
	_apply_button_style(exit_btn, btn_normal, btn_hover)
	
	var slider_track = StyleBoxFlat.new()
	slider_track.bg_color = Color.WHITE
	
	slider_track.content_margin_top = 2
	slider_track.content_margin_bottom = 2
	slider_track.corner_radius_top_left = 2
	slider_track.corner_radius_top_right = 2
	slider_track.corner_radius_bottom_left = 2
	slider_track.corner_radius_bottom_right = 2
	
	music_slider.add_theme_stylebox_override("slider", slider_track)
	sfx_slider.add_theme_stylebox_override("slider", slider_track)
	
	var grabber_tex = _make_white_circle(16)
	music_slider.add_theme_icon_override("grabber", grabber_tex)
	music_slider.add_theme_icon_override("grabber_highlight", grabber_tex)
	sfx_slider.add_theme_icon_override("grabber", grabber_tex)
	sfx_slider.add_theme_icon_override("grabber_highlight", grabber_tex)
	
	
	continue_btn.pressed.connect(_on_continue_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	
	

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		_on_continue_pressed()
		get_viewport().set_input_as_handled()

func _apply_button_style(button: Button, normal: StyleBox, hover: StyleBox):
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", normal)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_outline_color", Color.WHITE)
	button.add_theme_constant_override("outline_size", 1)

func _make_white_circle(size: int) -> ImageTexture:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0,0,0,0))
	var center = Vector2(size/2.0, size/2.0)
	var r = size/2.0 - 1
	for y in size:
		for x in size:
			if Vector2(x,y).distance_to(center) <= r:
				img.set_pixel(x, y, Color.WHITE)
	return ImageTexture.create_from_image(img)

func _on_continue_pressed():
	GlobalVariables.toggle_pause()

func _on_exit_pressed():
	get_tree().quit()

func _on_music_changed(value: float):
	GlobalVariables.music_volume = value

func _on_sfx_changed(value: float):
	GlobalVariables.sfx_volume = value

func sync_sliders():
	if not is_inside_tree() or not music_slider or not sfx_slider:
		return
	music_slider.set_value_no_signal(GlobalVariables.music_volume)
	sfx_slider.set_value_no_signal(GlobalVariables.sfx_volume)
