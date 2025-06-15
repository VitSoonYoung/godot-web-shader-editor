extends RichTextLabel

const UPDATE_INTERVAL: float = 0.1
const THRESHOLD_WARNING: float = 0.8 # Ratio of target FPS
const THRESHOLD_DANGER: float = 0.3

var time_passed: float = 0.0
var fps: float = 0.


func _process(delta: float) -> void:
	time_passed += delta

	if time_passed >= UPDATE_INTERVAL:
		fps = Engine.get_frames_per_second()
		text = "%d/%d[font_size=10]FPS[/font_size]" % [fps, DisplayServer.screen_get_refresh_rate()]

		if fps < THRESHOLD_DANGER * DisplayServer.screen_get_refresh_rate():
			self_modulate = Color.RED
		elif fps < THRESHOLD_WARNING * DisplayServer.screen_get_refresh_rate():
			self_modulate = Color.YELLOW
		else:
			self_modulate = Color.GREEN

		time_passed = 0.0
