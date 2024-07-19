extends Line2D

@export var ANIMATION_DURATION = 0.5
var elapsed_time = 0.0

func _process(delta):
	if elapsed_time < ANIMATION_DURATION:
		elapsed_time += delta
		
		var alpha = 1.0 - (elapsed_time / ANIMATION_DURATION)
		
		self.default_color.a = alpha
		if elapsed_time >= ANIMATION_DURATION:
			self.default_color.a = 0.0
			queue_free()
