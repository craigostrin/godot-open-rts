extends "res://source/match/units/actions/Action.gd"

var _target_unit = null
var _one_shot_timer = null

@onready var _unit = get_parent()


func _init(target_unit):
	_target_unit = target_unit


func _ready():
	if _teardown_if_out_of_range():
		return
	_one_shot_timer = Timer.new()
	_one_shot_timer.one_shot = true
	_one_shot_timer.timeout.connect(_hit_target)
	add_child(_one_shot_timer)
	_schedule_hit()


func _schedule_hit():
	var now = Time.get_ticks_msec()
	var next_attack_availability_time = _unit.get_meta("next_attack_availability_time", now)
	if next_attack_availability_time > now:
		var delay_millis = next_attack_availability_time - now
		_one_shot_timer.start(delay_millis / 1000.0)
	else:
		_hit_target()


func _hit_target():
	if _teardown_if_out_of_range():
		return
	_unit.set_meta(
		"next_attack_availability_time", Time.get_ticks_msec() + int(_unit.attack_interval * 1000.0)
	)
	_target_unit.hp -= _unit.attack_damage
	if _target_unit.hp > 0:
		_schedule_hit()
	else:
		queue_free()


func _teardown_if_out_of_range():
	var self_position_yless = _unit.global_position * Vector3(1, 0, 1)
	if (
		self_position_yless.distance_to(_target_unit.global_position * Vector3(1, 0, 1))
		> _unit.attack_range
	):
		queue_free()
		return true
	return false
