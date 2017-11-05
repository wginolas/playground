extends Area2D

onready var appear_effect = get_node("appear_effect")
onready var collect_effect = get_node("collect_effect")
onready var appear_delay = get_node("appear_delay")
onready var sprite = get_node("sprite")
signal gem_grabbed

func _ready():
	appear_effect.interpolate_property(
		sprite,
		"transform/pos",
		sprite.get_pos(),
		Vector2(0, 0),
		3,
		Tween.TRANS_BOUNCE,
		Tween.EASE_OUT)

	collect_effect.interpolate_property(
		sprite,
		"transform/scale",
		sprite.get_scale(),
		sprite.get_scale() * 3,
		0.3,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT)

	collect_effect.interpolate_property(
		sprite,
		"visibility/opacity",
		1,
		0,
		0.3,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT)

	appear_delay.set_wait_time(rand_range(0, 0.5))
	appear_delay.start()

func _on_gem_area_enter( area ):
	if area.get_name() == "player":
		emit_signal("gem_grabbed")
		clear_shapes()
		collect_effect.start()

func _on_appear_delay_timeout():
	appear_effect.start()

func _on_collect_effect_tween_complete( object, key ):
	queue_free()
