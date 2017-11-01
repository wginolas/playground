extends Node

onready var gem = preload("res://gem.tscn")
onready var gem_container = get_node("gem_container")

var score = 0
var level = 1
var screensize

func _ready():
	screensize = get_viewport().get_rect().size
	set_process(true)
	spawn_gems(10)

func _process(delta):
	if gem_container.get_child_count() == 0:
		level += 1
		spawn_gems(10 * level)

func spawn_gems(n):
	for i in range(n):
		var g = gem.instance()
		gem_container.add_child(g)
		g.set_pos(Vector2(
			rand_range(0, screensize.width),
			rand_range(0, screensize.height)))
