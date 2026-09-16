# Design inicial

Construir → operar → observar filas → investir → expandir. A decisão central é capacidade
de serviço versus demanda, não cliques de coleta. Vista lateral, corredores contínuos,
elevadores compartilhados entre hóspedes e limpeza. Identidade original: jardim urbano,
tons de azul, terracota e verde, formas geométricas legíveis.

Slice: recepção, quarto jardim, Bistrô Aurora, elevador; recepcionista e limpeza.
Caixa inicial 12.000. Preços, capacidades e manutenção residem em Resources.
Pausa/1x/2x/3x. Primeiro fluxo: terreno vazio, construir, contratar, abrir operação,
receber visitantes e corrigir gargalos. Sem login, backend ou monetização.

Economia inicial é hipótese de protótipo: validar retorno e gargalos com simulações
antes de declarar balanceamento concluído. Expansão de conteúdo aguarda ciclo integrado.

M3 acrescenta a decisão entre expandir área e melhorar a instalação existente.
Upgrades até N3 aumentam manutenção além do investimento inicial. Preços já contratados
são preservados. Atribuir limpeza a um andar prioriza esse andar e pode deixar outro
sem cobertura; modo automático distribui trabalho disponível. Hipóteses e critérios
numéricos estão em [M3_BALANCE](docs/M3_BALANCE.md).

M4 usa uma sequência curta de três objetivos: primeiras reservas, operação com
alimentação/limpeza e reconhecimento por reputação. Construção básica e N2 continuam
livres para que o jogador possa resolver gargalos antes de ganhar N3. Recompensas
liberam compras ou um título, sem injetar dinheiro. Saves anteriores preservam acesso.
Novos tipos de serviço entram em M5. Critérios e medições: [M4_PROGRESSION](docs/M4_PROGRESSION.md).

M5: Café Brisa oferece alimentação rápida e barata, com menos alívio que uma refeição.
Sala Horizonte atende lazer. Os três perfis alteram escolhas, orçamento e duração da
visita; a utilidade considera alívio efetivo, distância, fila, preço e rapidez.
Os serviços são opcionais e dependem da localização/demanda. Eventos previsíveis
alternam pressão de chegada e baixa procura, mantendo custos fixos. Parâmetros,
evidências e limites estão em [M5_CONTENT](docs/M5_CONTENT.md).

M6 facilita observar antes de investir: Operação organiza salas por fila e permite
isolar quartos sujos, salas em uso e andares. Indicadores têm escopo explícito
(estado atual do hotel ou resultado acumulado), sem estimativas de tendência.
Busca de construção, texto ampliado, foco visível e estados em português reduzem
barreiras de leitura. Construção no terreno ainda exige mouse; acessibilidade completa
e suporte a controller não são declarados concluídos.
