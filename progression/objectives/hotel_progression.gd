class_name HotelProgression
extends RefCounted
## Session-owned, latched milestones. Only evaluate() awards new completions.

const OBJECTIVES: Array[ObjectiveDefinition] = [preload("res://data/progression/first_stays.tres"), preload("res://data/progression/steady_service.tres"), preload("res://data/progression/trusted_hotel.tres")]
const METRIC_LABELS: Dictionary = {"bookings": "Reservas", "meals": "Refeições", "cleaned": "Limpezas", "completed": "Visitas concluídas", "reputation": "Reputação"}
const LEGACY_UNLOCKS: Array[StringName] = [&"bedroom_3", &"reception_3", &"restaurant_3", &"elevator_3"]
var completed: Array[StringName] = []
var legacy_access: bool = false

func evaluate(metrics: Dictionary) -> void:
	for objective in OBJECTIVES:
		if completed.has(objective.id) or (not objective.prerequisite.is_empty() and not completed.has(objective.prerequisite)):
			continue
		var ready: bool = true
		for metric: String in objective.requirements:
			if float(metrics.get(metric, 0)) < float(objective.requirements[metric]):
				ready = false
		if ready:
			completed.append(objective.id)

func upgrade_error(room: RoomState) -> String:
	if room.level < 2:
		return ""
	var unlock := StringName("%s_%d" % [room.definition_id, room.level + 1])
	if legacy_access and LEGACY_UNLOCKS.has(unlock):
		return ""
	for objective in OBJECTIVES:
		if objective.unlocks.has(unlock) and not completed.has(objective.id):
			return "Conclua o objetivo: %s." % objective.display_name
	return ""

func next_objective() -> ObjectiveDefinition:
	for objective in OBJECTIVES:
		if not completed.has(objective.id):
			return objective
	return null

func summary() -> String:
	var next := next_objective()
	return "Hotel de referência • %d/%d objetivos" % [completed.size(), OBJECTIVES.size()] if next == null else "Objetivos %d/%d • %s" % [completed.size(), OBJECTIVES.size(), next.display_name]

func snapshot() -> Dictionary:
	return {"completed": completed.duplicate(), "legacy_access": legacy_access}

func restore(data: Variant) -> bool:
	if not data is Dictionary or not data.get("completed") is Array or not data.get("legacy_access") is bool:
		return false
	var validated: Array[StringName] = []
	# Objectives form an ordered chain. Reject unknown, duplicate or skipped IDs.
	if data.completed.size() > OBJECTIVES.size():
		return false
	for index in data.completed.size():
		var value: Variant = data.completed[index]
		if not (value is String or value is StringName) or StringName(value) != OBJECTIVES[index].id:
			return false
		validated.append(StringName(value))
	completed = validated
	legacy_access = data.legacy_access
	return true
