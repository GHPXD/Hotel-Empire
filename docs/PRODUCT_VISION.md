/goal Você será responsável por desenvolver um jogo comercial original de gerenciamento de hotel em **Godot 4.x**, inspirado conceitualmente no loop de jogos clássicos de hotel e gerenciamento vertical como Theme Hotel, mas sem copiar propriedade intelectual protegida.

Este documento representa a **visão permanente do produto**.

Não tente implementar tudo imediatamente.

Os detalhes aqui descritos representam o destino arquitetural e de game design do projeto.

A execução deverá acontecer incrementalmente através de milestones separados.

---

# 1. VISÃO DO PRODUTO

Criar um jogo tycoon 2D no qual o jogador começa administrando um hotel pequeno e progressivamente constrói um enorme complexo vertical.

O principal prazer do jogo deverá vir de:

* construir;
* observar;
* identificar problemas;
* entender suas causas;
* otimizar;
* expandir;
* enfrentar novos gargalos.

O hotel deve funcionar como uma grande simulação interconectada.

Exemplo:

mais quartos
→ mais hóspedes
→ maior demanda pelos elevadores
→ filas maiores
→ atraso nos serviços
→ hóspedes insatisfeitos
→ reputação cai
→ jogador precisa reorganizar o hotel.

O jogo não deve ser apenas:

> clicar para ganhar dinheiro.

O jogo deve ser:

> construir um sistema, observar seu comportamento e resolver problemas emergentes.

---

# 2. ORIGINALIDADE

O jogo pode se inspirar em conceitos gerais de tycoons de hotel, porém deve possuir:

* código original;
* arte original;
* interface original;
* personagens originais;
* textos originais;
* sons originais;
* estrutura própria;
* identidade visual própria;
* nome próprio.

Não copiar:

* sprites do Theme Hotel;
* UI;
* personagens;
* textos;
* mapas;
* músicas;
* sons;
* código;
* nome;
* branding.

O objetivo é produzir um **sucessor espiritual moderno**, não um clone literal.

---

# 3. ENGINE

Engine:

Godot 4.x estável.

Linguagem:

GDScript tipado.

Priorizar APIs e práticas atuais do Godot.

Desktop será inicialmente a principal plataforma de desenvolvimento.

Entretanto, a arquitetura deve evitar dependências desnecessárias que impeçam futuramente:

* Windows;
* Linux;
* macOS;
* Android;
* iOS;
* Web.

---

# 4. PILARES DO GAME DESIGN

Toda feature deverá fortalecer pelo menos um dos seguintes pilares.

## P1 — Construção

O jogador deve sentir que está criando fisicamente um hotel.

## P2 — Simulação

Hóspedes e funcionários devem agir como entidades que possuem objetivos próprios.

## P3 — Gargalos

Expansão deve inevitavelmente criar problemas logísticos.

## P4 — Legibilidade

O jogador precisa entender por que algo está funcionando mal.

## P5 — Progressão

O hotel deve começar extremamente simples e tornar-se progressivamente complexo.

## P6 — Expressão

Hotéis diferentes devem poder funcionar de maneiras diferentes.

---

# 5. CORE LOOP

Loop principal:

Construir
→ receber hóspedes
→ hóspedes utilizarem serviços
→ gerar receita
→ observar comportamento
→ identificar gargalos
→ investir
→ melhorar
→ expandir
→ desbloquear novos sistemas
→ repetir.

---

# 6. VISÃO DO HOTEL

Perspectiva:

lateral 2D.

O hotel cresce principalmente verticalmente.

Exemplo conceitual:

```text
┌───────────────────────────────────────────┐
│ SPA      │ SUITE  │ SUITE  │ ELEVADOR   │
├───────────────────────────────────────────┤
│ ACADEMIA │ CAFÉ   │ QUARTO │ ELEVADOR   │
├───────────────────────────────────────────┤
│ QUARTO   │ QUARTO │ QUARTO │ ELEVADOR   │
├───────────────────────────────────────────┤
│ RECEPÇÃO │ LOBBY  │ LOJA   │ ELEVADOR   │
└───────────────────────────────────────────┘
```

---

# 7. SISTEMA DE CONSTRUÇÃO

O jogador deverá futuramente poder:

* construir andares;
* construir salas;
* demolir;
* melhorar salas;
* reorganizar áreas;
* construir transporte vertical;
* criar serviços;
* expandir horizontalmente quando apropriado.

O sistema deverá utilizar grid.

Construção precisa validar:

* espaço disponível;
* dinheiro;
* suporte estrutural;
* limites;
* overlap;
* requisitos.

Preview:

verde = construção válida.

vermelho = construção inválida.

---

# 8. SALAS

Arquitetura deve ser data-driven.

Uma nova sala comum não deve exigir alterações em diversos sistemas centrais.

Criar conceito equivalente a:

RoomDefinition.

Dados possíveis:

* id;
* nome;
* categoria;
* tamanho;
* custo;
* manutenção;
* capacidade;
* duração do serviço;
* receita;
* requisitos;
* funcionários;
* qualidade;
* satisfação;
* nível de desbloqueio;
* sprite;
* scene;
* upgrades.

Utilizar preferencialmente Custom Resources do Godot.

---

# 9. CATEGORIAS FUTURAS

## Hospedagem

* quarto econômico;
* quarto padrão;
* quarto premium;
* suíte;
* suíte presidencial.

## Alimentação

* restaurante;
* café;
* buffet;
* bar;
* room service.

## Entretenimento

* arcade;
* cinema;
* nightclub;
* lounge.

## Bem-estar

* academia;
* spa;
* sauna;
* piscina.

## Serviços

* lavanderia;
* segurança;
* manutenção;
* business center.

## Comércio

* gift shop;
* lojas;
* conveniência.

## Infraestrutura

* recepção;
* corredores;
* elevadores;
* escadas;
* áreas de funcionários.

Não implementar tudo inicialmente.

---

# 10. HÓSPEDES

Guest deverá ser uma entidade simulada.

Cada hóspede possuirá, no mínimo:

* identidade;
* orçamento;
* felicidade;
* paciência;
* quarto;
* dinheiro;
* necessidades;
* objetivo atual;
* estado;
* histórico básico da estadia.

Possíveis estados:

ARRIVING
ENTERING
CHECK_IN
WAITING
GOING_TO_ROOM
USING_ROOM
CHOOSING_ACTIVITY
GOING_TO_SERVICE
WAITING_IN_QUEUE
USING_SERVICE
LEAVING.

A implementação pode evoluir, mas deve evitar sequências totalmente hardcoded.

---

# 11. NECESSIDADES

Sistema base:

* hunger;
* energy;
* entertainment;
* comfort;
* patience;
* happiness.

Posteriormente:

* hygiene;
* relaxation;
* social;
* business;
* luxury.

Necessidades evoluem ao longo do tempo.

Serviços as modificam.

---

# 12. SISTEMA DE DECISÃO

Preferir sistema de utility AI simples.

Exemplo conceitual:

Hunger = 90.

Restaurant:

utility = 0.91.

Cafe:

utility = 0.66.

Room:

utility = 0.25.

Decisão poderá considerar:

* necessidade;
* distância;
* preço;
* fila;
* qualidade;
* disponibilidade;
* orçamento;
* personalidade.

Começar simples.

Não criar framework excessivamente complexo antes de ser necessário.

---

# 13. ARQUÉTIPOS DE HÓSPEDES

Arquitetura deverá futuramente permitir:

* turista;
* executivo;
* família;
* casal;
* mochileiro;
* hóspede de luxo;
* VIP;
* influenciador;
* celebridade;
* participante de conferência.

Cada perfil pode afetar:

* orçamento;
* exigência;
* paciência;
* serviços preferidos;
* duração da estadia.

---

# 14. FILAS

Fila deve ser um sistema reutilizável.

Poderá ser utilizada por:

* recepção;
* restaurante;
* café;
* spa;
* academia;
* elevadores;
* lojas.

Salas podem possuir:

* queue_capacity;
* service_capacity;
* service_duration.

Filas devem afetar satisfação.

---

# 15. ELEVADORES

Elevadores são sistema central do jogo.

Devem suportar futuramente:

* capacidade;
* velocidade;
* fila;
* passageiros;
* destinos;
* upgrades;
* tempo de abertura;
* utilização;
* manutenção.

O sistema deve medir:

* espera média;
* espera máxima;
* utilização;
* passageiros transportados;
* tamanho das filas.

Congestionamento precisa ter impacto real na experiência do hóspede.

---

# 16. PATHFINDING

Personagens precisam navegar:

horizontalmente pelo andar;

e verticalmente pelo hotel.

Quando necessário, utilizar arquitetura hierárquica:

origem
→ andar atual
→ transporte vertical
→ andar alvo
→ sala alvo.

Não recalcular caminhos completos desnecessariamente a cada frame.

---

# 17. FUNCIONÁRIOS

Inicialmente:

* Receptionist;
* Cleaner.

Posteriormente:

* Chef;
* Waiter;
* Maintenance;
* Security;
* Bartender;
* Manager;
* Spa Therapist.

Atributos potenciais:

* salário;
* velocidade;
* skill;
* carga de trabalho;
* estado;
* atribuição.

---

# 18. LIMPEZA

Após uso, quartos podem acumular sujeira.

Fluxo:

quarto fica sujo
→ cleaner recebe tarefa
→ desloca-se
→ limpa
→ quarto volta a ficar disponível.

Poucos cleaners devem gerar problemas reais de operação.

---

# 19. ECONOMIA

Sistema centralizado.

Controlar:

* cash;
* revenue;
* expenses;
* profit.

Receitas podem vir de:

* hospedagem;
* restaurantes;
* serviços;
* lojas;
* atividades.

Despesas:

* construção;
* manutenção;
* salários;
* upgrades.

---

# 20. LEDGER

Registrar transações importantes.

Exemplo:

+120 Room Booking
+20 Restaurant
-80 Salary
-15 Maintenance.

Isso permitirá analytics futuros.

---

# 21. SATISFAÇÃO

Cada hóspede deve possuir experiência individual.

Possíveis fatores:

* qualidade do quarto;
* limpeza;
* tempo de espera;
* preço;
* serviços;
* conforto;
* congestionamento.

Ao sair, calcular avaliação final.

---

# 22. REPUTAÇÃO

A reputação do hotel deve ser influenciada pelas experiências dos hóspedes.

Ela poderá controlar:

* quantidade de visitantes;
* tipos de hóspedes;
* preços aceitáveis;
* progressão;
* desbloqueios.

---

# 23. REVIEWS

Posteriormente gerar avaliações procedurais baseadas no que realmente ocorreu.

Exemplo:

"O quarto era excelente, mas o elevador demorava muito."

"Gostei do restaurante."

"Esperei muito para fazer check-in."

Reviews nunca devem ser puramente aleatórias.

---

# 24. PROGRESSÃO

O jogador começa com poucos sistemas disponíveis.

Novos conteúdos são desbloqueados gradualmente.

Exemplo conceitual:

Reception
→ Bedroom
→ Restaurant
→ Cafe
→ Gym
→ Laundry
→ Pool
→ Spa.

A progressão final deverá ser balanceada posteriormente.

---

# 25. UPGRADES

Salas podem possuir níveis.

Exemplo:

Restaurant I
Restaurant II
Restaurant III.

Possíveis benefícios:

* capacidade;
* velocidade;
* qualidade;
* receita;
* aparência.

---

# 26. EVENTOS

Arquitetura preparada para eventos data-driven.

Exemplo:

Music Festival

Visitors +40%.

Restaurant Demand +25%.

Outro:

Business Conference

Business Guests +100%.

Conference Demand +80%.

Não implementar eventos antes do core estar sólido.

---

# 27. OBJETIVOS

Sistema futuro para objetivos:

* atingir X hóspedes;
* ganhar X dinheiro;
* construir X andares;
* manter satisfação;
* atingir reputação;
* servir determinados clientes.

---

# 28. CENÁRIOS

Planejar futuramente:

* Small Town Hotel;
* Big City Hotel;
* Beach Resort;
* Luxury Tower;
* Casino Resort;
* Budget Hotel.

Cada cenário poderá modificar:

* economia;
* demanda;
* hóspedes;
* eventos;
* objetivos.

---

# 29. HOTEL THEMES

Arquitetura preparada futuramente para:

* Urban;
* Tropical;
* Luxury;
* Retro;
* Japanese-inspired;
* Futuristic;
* Mountain Resort;
* Beach Resort.

Sempre utilizando identidade original.

---

# 30. ANALYTICS

O jogador deverá futuramente conseguir investigar o próprio hotel.

Métricas:

* receita;
* despesas;
* lucro;
* ocupação;
* satisfação;
* tempo de espera;
* filas;
* utilização de salas;
* utilização de elevadores.

---

# 31. HEATMAPS

Planejar:

* tráfego;
* congestionamento;
* satisfação;
* lucro;
* espera.

Heatmaps devem ajudar o jogador a diagnosticar problemas.

---

# 32. UX DE PROBLEMAS

Não mostrar apenas:

Satisfaction -10.

Mostrar causa.

Exemplo:

ELEVATOR CONGESTION

Average Wait:
71 seconds.

Possible solution:
additional elevator capacity.

O jogador precisa entender relações de causa e efeito.

---

# 33. UI

Direção:

* limpa;
* altamente legível;
* estilizada;
* amigável;
* game-like.

Evitar aparência de dashboard SaaS.

HUD principal:

* dinheiro;
* hóspedes;
* reputação;
* lucro;
* tempo;
* velocidade.

Controles:

Pause
1x
2x
3x.

---

# 34. INSPEÇÃO DE HÓSPEDES

Ao selecionar um hóspede, mostrar futuramente:

* nome;
* perfil;
* felicidade;
* necessidades;
* dinheiro;
* objetivo;
* quarto;
* duração da estadia.

---

# 35. DEBUGGING

Criar futuramente um Simulation Inspector.

Exemplo:

Guest #047

State:
GOING_TO_RESTAURANT

Target:
Restaurant_02

Hunger:
91

Candidate Actions:

Restaurant = 0.91
Cafe = 0.62
Room = 0.18.

Isso deve existir antes de a simulação ficar grande.

---

# 36. SAVE SYSTEM

Salvar:

* hotel;
* floors;
* rooms;
* dinheiro;
* reputação;
* employees;
* progression;
* upgrades;
* estado necessário de simulação.

Usar versionamento.

Exemplo:

save_version = 1.

Evitar serialização frágil diretamente da scene tree.

---

# 37. PERFORMANCE

Arquitetura deve futuramente suportar centenas de entidades.

Objetivo de longo prazo:

500 hóspedes simultâneos com boa performance em hardware desktop intermediário.

Stretch goal:

1000 entidades simuladas.

Não tentar otimizar isso antes de termos gameplay funcionando.

---

# 38. SIMULATION TICK

Não executar decisões pesadas de IA em todo frame.

Quando apropriado:

Rendering:

60 FPS.

Simulation:

5–10 ticks/s.

Distribuir atualizações quando necessário.

---

# 39. HEADLESS SIMULATION

Objetivo futuro extremamente importante.

Permitir executar simulações sem interface.

Exemplo conceitual:

```bash
godot --headless -- --simulate --days=30 --seed=123
```

Gerar resultados como:

* revenue;
* expenses;
* profit;
* satisfaction;
* queue times;
* elevator wait;
* occupancy.

Idealmente exportar:

JSON ou CSV.

---

# 40. DETERMINISMO

Quando viável, usar seeds reproduzíveis.

Isso permitirá reproduzir bugs e comparar balanceamento.

---

# 41. DIREÇÃO ARTÍSTICA

Inicialmente usar placeholders claros.

Arte final não deve bloquear desenvolvimento.

Direção futura sugerida:

2D stylized cozy tycoon.

Características:

* formas claras;
* boa leitura em escala pequena;
* personagens simples;
* ambientes expressivos;
* animações leves;
* identidade própria.

---

# 42. ANIMAÇÕES

Mínimo futuro:

* Idle;
* Walk;
* Wait;
* Use;
* Enter;
* Exit.

Funcionários podem possuir ações específicas.

---

# 43. ÁUDIO

Preparar arquitetura para:

* music;
* ambience;
* UI;
* construction;
* elevator;
* restaurant;
* guest reactions.

Não priorizar antes do gameplay.

---

# 44. PRINCÍPIO DE COMPLEXIDADE

Nunca construir arquitetura genérica apenas por antecipação.

Antes de generalizar:

1 implementação prova a mecânica.

3 implementações provam o padrão.

Depois disso, generalize quando necessário.

---

# 45. PRINCÍPIO DE CONTEÚDO

Antes de criar dezenas de salas:

1 sala deve funcionar.

Depois:

3 tipos diferentes devem funcionar usando a mesma arquitetura.

Somente depois:

expandir conteúdo.

---

# 46. PRINCÍPIO DE QUALIDADE

Prioridade:

1. correctness;
2. gameplay;
3. simulation;
4. usability;
5. performance;
6. visuals;
7. polish.

Nunca use polish para esconder simulação quebrada.

---

# 47. ROADMAP DE LONGO PRAZO

M0 — Bootstrap
M1 — Single Floor Construction
M2 — Guest Core Loop
M3 — Economy + Services
M4 — Staff + Cleaning
M5 — Verticality
M6 — Elevators
M7 — Satisfaction + Reputation
M8 — Progression
M9 — Content Expansion
M10 — Analytics
M11 — Advanced Simulation
M12 — Art & Animation
M13 — Balance
M14 — Optimization
M15 — QA & Release Preparation.

---

# 48. OBJETIVO FINAL

O resultado deve ser um tycoon original no qual hotéis possam tornar-se sistemas complexos com:

* dezenas de andares;
* centenas de hóspedes;
* múltiplos funcionários;
* múltiplos elevadores;
* filas;
* gargalos;
* serviços;
* economia;
* upgrades;
* reputação;
* progressão;
* eventos;
* analytics.

Mas nenhum desses sistemas justifica avançar antes que a fundação anterior esteja sólida.

Este documento representa o destino do projeto.

NÃO tente implementar tudo agora.

A execução deverá seguir o protocolo operacional e o milestone atual fornecidos separadamente.
