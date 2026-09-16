class_name SaveStore
extends RefCounted

const DEFAULT_PATH: String = "user://hotel-v1.json"
const MAX_BYTES: int = 8 * 1024 * 1024

static func save_session(session: HotelSession, path: String = DEFAULT_PATH) -> String:
	var snapshot := SessionSnapshot.capture(session)
	var validated := SessionSnapshot.restore(snapshot)
	if not validated.error.is_empty():
		return "Não foi possível salvar: " + validated.error
	var temporary: String = path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return "Não foi possível gravar o save."
	file.store_string(JSON.stringify(snapshot))
	file.flush()
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK:
		return "Falha ao gravar os dados. Save anterior preservado."
	var full_path := ProjectSettings.globalize_path(path)
	var backup: String = full_path + ".bak"
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(backup) and DirAccess.remove_absolute(backup) != OK:
			return "Não foi possível atualizar o backup."
		if DirAccess.rename_absolute(full_path, backup) != OK:
			return "Não foi possível preservar o save anterior."
	if DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), full_path) != OK:
		if FileAccess.file_exists(backup):
			DirAccess.rename_absolute(backup, full_path)
		return "Falha ao finalizar o save."
	print("[SAVE] Gravado: ", path)
	return ""

static func load_session(path: String = DEFAULT_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"session": null, "error": "Nenhum save encontrado."}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > MAX_BYTES:
		return {"session": null, "error": "Save ilegível ou grande demais."}
	var parser := JSON.new()
	var error: Error = parser.parse(file.get_as_text())
	file.close()
	if error != OK:
		return {"session": null, "error": "Save incompleto ou corrompido. Partida atual preservada."}
	return SessionSnapshot.restore(parser.data)
