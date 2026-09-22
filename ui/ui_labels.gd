class_name UILabels
extends RefCounted

const STATES: Dictionary = {&"arriving": "Chegando", &"walking": "Caminhando", &"lift_queue": "Esperando elevador", &"riding": "No elevador", &"checkin": "Na recepção", &"deciding": "Escolhendo atividade", &"service_queue": "Esperando serviço", &"using": "Em atendimento", &"exit": "Saindo", &"idle": "Disponível", &"working": "Atendendo", &"cleaning": "Limpando"}
const ROLES: Dictionary = {&"guest": "Hóspede", &"receptionist": "Recepcionista", &"cleaner": "Camareiro(a)"}

static func state(value: StringName) -> String:
	return STATES.get(value, "Estado desconhecido")

static func role(value: StringName) -> String:
	return ROLES.get(value, "Equipe")

const CHECKIN: Dictionary = {
	"empty": "Sem fila de check-in.",
	"head_travelling": "O primeiro hóspede está chegando à recepção.\nAguarde sua chegada para iniciar o atendimento.",
	"unstaffed": "Recepção sem funcionário atendendo.\nConfira a contratação e a atribuição de um recepcionista em Equipe.",
	"processing": "Atendimento em andamento.\nAguarde ou melhore a recepção para reduzir o tempo de check-in.",
	"ready": "Há um quarto disponível para o primeiro hóspede.\nO próximo atendimento pode concluir a reserva.",
	"cleaning": "Aguardando quarto limpo.\nConfira a equipe de limpeza e o acesso dos camareiros aos quartos.",
	"occupied": "Os quartos disponíveis para este hóspede estão ocupados.\nAguarde uma saída ou amplie a hospedagem.",
	"unaffordable": "Quartos fora do orçamento do primeiro hóspede.\nConfira as tarifas; quartos sem melhorias oferecem preço menor.",
	"no_accessible_bedroom": "Nenhum quarto com acesso para o primeiro hóspede.\nConstrua quartos e conecte os andares superiores por elevador.",
}

static func checkin(reason: String) -> String:
	return CHECKIN.get(reason, "Não foi possível avaliar esta fila.")

static func search_key(value: String) -> String:
	var result := value.strip_edges().to_lower()
	for replacement in [["á", "a"], ["à", "a"], ["â", "a"], ["ã", "a"], ["é", "e"], ["ê", "e"], ["í", "i"], ["ó", "o"], ["ô", "o"], ["õ", "o"], ["ú", "u"], ["ç", "c"]]:
		result = result.replace(replacement[0], replacement[1])
	return result
