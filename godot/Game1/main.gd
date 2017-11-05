extends Node

onready var gem = preload("res://gem.tscn")
onready var gem_container = get_node("gem_container")
onready var score_label = get_node("HUD/score")
onready var time_label = get_node("HUD/time")
onready var game_over_label = get_node("HUD/game_over")
onready var game_timer = get_node("game_timer")

var score = 0
var level = 1
var screensize

func _ready():
	randomize()
	screensize = get_viewport().get_rect().size
	set_process(true)
	spawn_gems(10)

func _process(delta):
	time_label.set_text(str(int(game_timer.get_time_left())))
	if gem_container.get_child_count() == 0:
		level += 1
		spawn_gems(10 * level)

func spawn_gems(n):
	for i in range(n):
		var g = gem.instance()
		gem_container.add_child(g)
		g.connect("gem_grabbed", self, "_on_gem_grabbed")
		g.set_pos(Vector2(
			rand_range(0, screensize.width),
			rand_range(0, screensize.height)))

func _on_gem_grabbed():
	score += 1
	score_label.set_text(str(score))

func _on_game_timer_timeout():
	get_node("player").set_fixed_process(false)
	game_over_label.set_opacity(1)

