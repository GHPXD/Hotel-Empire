class_name UILabels
extends RefCounted

const STATES: Dictionary = {&"arriving": "Chegando", &"walking": "Caminhando", &"lift_queue": "Esperando elevador", &"riding": "No elevador", &"checkin": "Na recepção", &"deciding": "Escolhendo atividade", &"service_queue": "Esperando serviço", &"using": "Em atendimento", &"exit": "Saindo", &"idle": "Disponível", &"working": "Atendendo", &"cleaning": "Limpando"}
const ROLES: Dictionary = {&"guest": "Hóspede", &"receptionist": "Recepcionista", &"cleaner": "Camareiro(a)"}

static func state(value: StringName) -> String:
	return STATES.get(value, "Estado desconhecido")

static func role(value: StringName) -> String:
	return ROLES.get(value, "Equipe")

static func search_key(value: String) -> String:
	var result := value.strip_edges().to_lower()
	for replacement in [["á", "a"], ["à", "a"], ["â", "a"], ["ã", "a"], ["é", "e"], ["ê", "e"], ["í", "i"], ["ó", "o"], ["ô", "o"], ["õ", "o"], ["ú", "u"], ["ç", "c"]]:
		result = result.replace(replacement[0], replacement[1])
	return result
