extends CharacterBody3D

signal Squashed

var Ponto_de_geracao: Vector3
var Alvo: Heroi = null
@onready var gerar_de_novo: Timer = get_node("Gerar_de_novo")
@onready var Agente_de_navegacao: NavigationAgent3D = get_node("NavigationAgent")

@export_category("Variáveis")
@export var distancia_limite: float = 2.0
@export var Velocidade_de_movimento: float = 4.0



func _physics_process(_delta):
	if is_instance_valid(Alvo):
		Agente_de_navegacao.set_target_position(Alvo.global_position)
	
	
	if Agente_de_navegacao.is_navigation_finished():
		velocity = Vector3.ZERO
		return

	var next_path_position: Vector3 = Agente_de_navegacao.get_next_path_position()
	var current_agent_position: Vector3 = global_position
	var new_velocity: Vector3 = current_agent_position.direction_to(next_path_position) * Velocidade_de_movimento
	
	if is_instance_valid(Alvo):
		var Nova_distancia: float = global_position.distance_to(Alvo.global_position)
		if not Nova_distancia > distancia_limite:
			return
	
	if Agente_de_navegacao.avoidance_enabled:
		Agente_de_navegacao.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()
	
func Squash():
	Squashed.emit()
	RoteiroGlobal.Pontuacao += 1
	queue_free()


func _on_area_de_colisao_body_entered(body):
	if body is Heroi:
		Alvo = body
		
		if not gerar_de_novo.is_stopped():
			gerar_de_novo.stop()


func _on_area_de_colisao_body_exited(body):
	if body is Heroi:
		Agente_de_navegacao.set_target_position(global_position)
		gerar_de_novo.start()
		Alvo = null


func _on_gerar_de_novo_timeout():
	Agente_de_navegacao.set_target_position(Ponto_de_geracao)
