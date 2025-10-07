extends Control

var stamina_bar: ProgressBar
var stamina_label: Label

var max_stamina: float = 100.0
var current_stamina: float = 100.0

func _ready():
	# Create stamina bar
	stamina_bar = ProgressBar.new()
	stamina_bar.name = "StaminaBar"
	stamina_bar.min_value = 0
	stamina_bar.max_value = 100
	stamina_bar.value = 100
	stamina_bar.size = Vector2(200, 20)
	stamina_bar.position = Vector2(20, 20)
	stamina_bar.show_percentage = false
	add_child(stamina_bar)
	
	# Create stamina label
	stamina_label = Label.new()
	stamina_label.name = "StaminaLabel"
	stamina_label.text = "Stamina: 100%"
	stamina_label.position = Vector2(20, 45)
	stamina_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(stamina_label)

func update_stamina(stamina: float, max_stamina: float):
	current_stamina = stamina
	self.max_stamina = max_stamina
	
	# Safety check - make sure UI elements exist
	if not stamina_bar or not stamina_label:
		return
	
	# Update progress bar
	stamina_bar.value = (stamina / max_stamina) * 100
	
	# Update label
	var percentage = int((stamina / max_stamina) * 100)
	stamina_label.text = "Stamina: " + str(percentage) + "%"
	
	# Change color based on stamina level
	if stamina < 20:
		stamina_bar.modulate = Color.RED
	elif stamina < 50:
		stamina_bar.modulate = Color.YELLOW
	else:
		stamina_bar.modulate = Color.GREEN
