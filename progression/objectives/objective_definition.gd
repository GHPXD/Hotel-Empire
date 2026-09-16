class_name ObjectiveDefinition
extends Resource
## Authored requirements and permanent unlocks; never stores run state.

@export var id: StringName
@export var display_name: String
@export var description: String
@export var prerequisite: StringName
@export var requirements: Dictionary = {}
@export var unlocks: Array[StringName] = []
@export var reward_text: String
