class_name HotelSession
extends RefCounted
## Owns a run. UI sends commands here; systems mutate only their assigned state.

const EMPLOYEES: Array[EmployeeDefinition] = [preload("res://data/employees/receptionist.tres"), preload("res://data/employees/cleaner.tres")]
var rules: SimulationRules = preload("res://data/simulation.tres")
var economy := HotelEconomy.new()
var hotel := HotelModel.new(economy)
var transport := TransportSystem.new(rules)
var guests := GuestSystem.new(rules)
var employees := EmployeeSystem.new(rules)
var actors: Dictionary = {}
var rng := RandomNumberGenerator.new()
var next_actor_id: int = 1
var time: float = 0.0
var arrival_timer: float = 0.0
var day: int = 0
var opened: bool = false
var speed: int = 1

func _init(seed_value: int = 123456) -> void:
	rng.seed = seed_value

func tick(delta: float) -> void:
	time += delta
	transport.sync(hotel)
	employees.step(actors, hotel, transport, delta)
	transport.step(actors, delta)
	guests.step(actors, hotel, transport, delta, time)
	if opened:
		arrival_timer -= delta
		if arrival_timer <= 0:
			arrival_timer = rules.arrival_interval * rng.randf_range(0.8, 1.2) * (1.4 - guests.reputation / 100.0)
			if guest_count() < rules.max_guests:
				spawn_guest()
	var current_day: int = floori(time / rules.day_seconds)
	if current_day > day:
		day = current_day
		_pay_daily_expenses()

func hire(definition: EmployeeDefinition) -> String:
	if not economy.purchase(definition.hire_cost, "Contratação: " + definition.display_name, time):
		return "Caixa insuficiente para contratar."
	var actor := ActorState.new()
	actor.id = next_actor_id
	next_actor_id += 1
	actor.role = definition.id
	actor.display_name = definition.display_name + " " + str(actor.id)
	actor.state = &"idle"
	actor.speed = definition.speed
	actor.skill = definition.skill
	actors[actor.id] = actor
	return ""

func spawn_guest() -> ActorState:
	var actor := ActorState.new()
	actor.id = next_actor_id
	next_actor_id += 1
	actor.display_name = "Visitante %03d" % actor.id
	actor.money = rules.starting_budget
	actor.speed = rules.walk_speed * rng.randf_range(0.85, 1.15)
	actor.needs.hunger = rng.randf_range(30, 55)
	actors[actor.id] = actor
	return actor

func guest_count() -> int:
	var result: int = 0
	for actor: ActorState in actors.values():
		if actor.role == &"guest":
			result += 1
	return result

func demolish(id: int) -> String:
	var room := hotel.by_id(id)
	if room == null:
		return "Selecione uma sala."
	for actor: ActorState in actors.values():
		if actor.target_room == id and actor.state != &"exit":
			return "Há alguém usando ou indo para esta sala."
		if room.definition().category == &"transport" and (actor.floor_index > 0 or actor.in_transit()):
			return "Aguarde todos descerem antes de remover o elevador."
	var result := hotel.demolish(id)
	transport.sync(hotel)
	return result

func alerts() -> String:
	var dirty: int = 0
	var queued: int = 0
	for room in hotel.rooms:
		if room.dirty:
			dirty += 1
		queued += room.queue.members.size()
	var lift_queue: int = 0
	for lift in transport.lifts:
		lift_queue += lift.queue.members.size()
	if lift_queue >= 4:
		return "Elevadores: %d esperando. Considere outro poço." % lift_queue
	if dirty > 0:
		return "%d quarto(s) aguardando limpeza. Contrate camareiros se a fila crescer." % dirty
	if queued > 2:
		return "%d aguardando atendimento. Confira quartos livres e recepcionistas." % queued
	return "Operação estável. Observe a ocupação antes de expandir." if opened else "Hotel fechado para novas chegadas. Construa, contrate e abra as portas."

func _pay_daily_expenses() -> void:
	var maintenance: int = 0
	for room in hotel.rooms:
		maintenance += room.definition().maintenance
	if maintenance > 0:
		economy.transact(-maintenance, "Manutenção diária", time)
	var salaries: int = 0
	for actor: ActorState in actors.values():
		for definition in EMPLOYEES:
			if actor.role == definition.id:
				salaries += definition.salary
	if salaries > 0:
		economy.transact(-salaries, "Salários diários", time)
