# Projeto de Modelagem de Banco de Dados - Clínica Médica

**Integrantes do Grupo:**
- Pablo Teixeira Villela dos Santos 598 GES
- Caio Rodrigues Couto 447

**Tema Escolhido:** Sistema de Gestão para Clínica Médica

**Breve Explicação do Tema:**
O projeto consiste na modelagem de um banco de dados para gerenciar as rotinas de uma clínica médica. O escopo abrange:
- O controle de **Pacientes** e seus **Prontuários** (garantindo um prontuário único por paciente em uma relação 1:1).
- A categorização dos **Médicos** de acordo com suas **Especialidades** (onde uma especialidade possui vários médicos, mas cada médico responde por uma especialidade principal, relação 1:N).
- O registro de **Consultas**, que conecta os pacientes aos médicos em dias e horários específicos (resolvendo a relação N:M através de uma tabela intermediária bem definida).

---

## Documentação dos scripts

### `01_ddl.sql`: criação do banco e das tabelas

Transforma o modelo da 1ª entrega (`clinica_medica.mwb`) em SQL executável no MySQL 8.0.13 ou mais recente. Os nomes de tabelas e colunas são exatamente os do modelo, mas alguns problemas encontrados nele foram corrigidos (ver *Correções em relação ao modelo da 1ª entrega*, mais abaixo).

#### Comandos iniciais

| Comando | Por quê |
|---|---|
| `SET NAMES utf8mb4` | Faz a conexão enviar texto em UTF-8, para que nomes com acento (ex.: "João") sejam gravados corretamente pelos scripts seguintes. |
| `DROP DATABASE IF EXISTS clinica_medica` | Permite rodar o script de novo, do zero, sem erro de "banco já existe". **Apaga o banco anterior e os dados dele.** |
| `CREATE DATABASE ... utf8mb4 / utf8mb4_0900_ai_ci` | Cria o banco com um conjunto de caracteres que aceita qualquer caractere (acentos, ç) e uma ordenação que ignora acento e maiúsculas nas comparações. |
| `USE clinica_medica` | Garante que as tabelas sejam criadas dentro do banco do projeto. |
| `ENGINE = InnoDB` (em todas as tabelas) | O InnoDB é o mecanismo do MySQL que aplica chaves estrangeiras e suporta transações. |

#### Tabelas

| Tabela | Colunas | Restrições e motivo |
|---|---|---|
| **Especialidade** | `idEspecialidade`, `nome_especialidade` | PK auto incremento. `nome_especialidade` é obrigatório e `UNIQUE`, para não cadastrar a mesma especialidade duas vezes. |
| **Medico** | `idMedico`, `nome_medico`, `crm`, `Especialidade_idEspecialidade` | Nome e CRM obrigatórios. `crm` é `UNIQUE` porque identifica o médico no conselho e não pode se repetir. A FK para Especialidade é obrigatória: todo médico tem uma especialidade principal. |
| **Paciente** | `idPaciente`, `nome_paciente`, `data_nascimento`, `telefone` | Nome e data de nascimento obrigatórios (a data é usada no cálculo da idade). `telefone` é opcional, porque nem todo paciente informa. |
| **Prontuario** | `idProntuario`, `data_criacao`, `observacao`, `Paciente_idPaciente` | `data_criacao` assume a data do dia se não for informada (`DEFAULT (CURRENT_DATE)`). `Paciente_idPaciente` é obrigatório e `UNIQUE`, o que garante um prontuário por paciente. `observacao` é opcional. |
| **Consulta** | `idconsulta`, `Paciente_idPaciente`, `Medico_idMedico`, `data_hora_consulta` | Paciente, médico e data/hora obrigatórios: não existe consulta sem algum deles. O conflito de horário do médico é tratado pelo trigger em `05_procedure_trigger.sql`. |

#### Como cada relacionamento foi implementado

| Relacionamento | Implementação |
|---|---|
| Especialidade **1:N** Medico | FK `Medico.Especialidade_idEspecialidade` → `Especialidade.idEspecialidade`. Uma especialidade aparece em vários médicos, e cada médico aponta para uma só. |
| Paciente **1:1** Prontuario | FK `Prontuario.Paciente_idPaciente` → `Paciente.idPaciente`, com `UNIQUE`. A FK liga o prontuário ao paciente, e o `UNIQUE` impede um segundo prontuário para o mesmo paciente. |
| Paciente **N:M** Medico | Tabela associativa `Consulta`, com uma FK para cada lado. Cada linha é um encontro entre um paciente e um médico numa data e hora. |

Todas as FKs usam `ON DELETE NO ACTION` e `ON UPDATE NO ACTION`: o banco não deixa apagar uma especialidade que ainda tem médicos, nem um paciente que tenha consultas ou prontuário, nem um médico que tenha consultas. Isso evita registros "órfãos" e preserva o histórico de atendimentos.

#### Correções em relação ao modelo da 1ª entrega

| No modelo (`.mwb`) | No `01_ddl.sql` | Por quê |
|---|---|---|
| PK do Prontuario composta (`idProntuario` + `Paciente_idPaciente`) e índice da FK não único | PK só em `idProntuario` + `UNIQUE` em `Paciente_idPaciente` | Do jeito do modelo, o mesmo paciente podia ter vários prontuários, e o 1:1 não era garantido pelo banco. |
| Quase todas as colunas aceitavam `NULL` | `NOT NULL` em nomes, CRM, data de nascimento, data do prontuário e data/hora da consulta | Impede cadastros incompletos, como um médico sem CRM ou uma consulta sem horário. |
| `crm` e `nome_especialidade` podiam se repetir | `UNIQUE` nas duas colunas | Evita médicos e especialidades duplicados. |
| FK com o nome `fk_Protuario_Paciente` | `fk_Prontuario_Paciente` | Correção de digitação (só muda o nome da restrição). |

#### Regras verificadas

O script foi executado duas vezes seguidas num MySQL 8.0, sem erro. Em seguida, inserções de teste confirmaram que o banco recusa:

- um segundo prontuário para o mesmo paciente (`Duplicate entry ... Paciente_idPaciente_UNIQUE`);
- um CRM ou uma especialidade repetidos;
- um paciente sem nome ou uma consulta sem data/hora;
- uma consulta com médico inexistente (erro de FK);
- apagar um paciente que tem consulta, ou uma especialidade que tem médicos.

> **Observação:** no Windows, o MySQL guarda os nomes das tabelas em minúsculas, mas no Linux eles diferenciam maiúsculas de minúsculas. Por isso, os scripts devem usar os nomes exatamente como estão no DDL (`Paciente`, `Consulta`, `idconsulta`...).

### `05_procedure_trigger.sql`: procedure de agendamento e triggers de horário

Cria as regras de negócio do agendamento de consultas. O arquivo pode ser rodado de novo sem erro, porque começa apagando os objetos se eles já existirem (`DROP ... IF EXISTS`).

#### Procedure `agendar_consulta(p_paciente, p_medico, p_data_hora)`

**Por que foi criada:** para que o agendamento seja feito sempre do mesmo jeito, com validações e mensagens de erro claras, em vez de um `INSERT` direto na tabela `Consulta`. Quem usa o sistema (por exemplo, a recepção) só precisa chamar `CALL agendar_consulta(1, 2, '2026-12-01 10:00:00');`.

O que ela faz, em ordem:

| Etapa | Verificação | Mensagem se falhar |
|---|---|---|
| 1 | Os três parâmetros foram informados | `Paciente, médico e data/hora são obrigatórios.` |
| 2 | O paciente existe | `Paciente não encontrado.` |
| 3 | O médico existe | `Médico não encontrado.` |
| 4 | A data/hora é futura (não dá para agendar no passado) | `A consulta deve ser agendada para uma data futura.` |
| 5 | Insere a consulta e retorna o `idconsulta` gerado | — |

- `SIGNAL SQLSTATE '45000'` interrompe a procedure e devolve a mensagem para quem chamou. O código `45000` é o reservado para erros definidos pelo usuário.
- As verificações 2 e 3 repetem o que as FKs já garantem, mas trocam o erro técnico de FK por uma mensagem que a recepção entende.
- O conflito de horário do médico **não** é verificado aqui, e sim no trigger abaixo. Assim a regra vale também para inserções feitas fora da procedure.
- `DELIMITER $$` troca o fim de comando de `;` para `$$` enquanto os objetos são criados, porque o corpo deles tem vários `;` internos.

#### Triggers `trg_consulta_conflito_insert` e `trg_consulta_conflito_update`

**Por que foram criados:** um médico não pode atender dois pacientes ao mesmo tempo. Os triggers garantem essa regra no próprio banco, qualquer que seja a forma de gravar a consulta: pela procedure, por um `INSERT` direto ou por uma remarcação com `UPDATE`.

| Trigger | Quando dispara | O que faz |
|---|---|---|
| `trg_consulta_conflito_insert` | `BEFORE INSERT` em `Consulta` | Se o mesmo médico já tem uma consulta exatamente nessa data/hora, cancela a inserção com `O médico já tem uma consulta neste horário.` |
| `trg_consulta_conflito_update` | `BEFORE UPDATE` em `Consulta` | Mesma verificação ao remarcar, ignorando a própria consulta (`idconsulta <> NEW.idconsulta`), para que alterar outro campo da consulta não seja visto como conflito. |

- `BEFORE` faz a verificação antes de gravar, então a linha inválida nunca chega à tabela.
- `NEW` representa a linha que está sendo inserida ou o novo valor da linha que está sendo alterada.
- O trigger de `UPDATE` é um **extra**: sem ele, o enunciado já estaria atendido, mas uma remarcação poderia criar o conflito que o trigger de `INSERT` impede.
- Consideramos conflito apenas o **mesmo horário exato**, porque o modelo não guarda a duração da consulta.
- Os triggers só valem para as consultas gravadas depois deles. Como o `02_inserts.sql` roda antes, os dados iniciais foram montados sem conflitos de horário.

#### Regras verificadas

O script foi executado duas vezes seguidas num MySQL 8.0, sem erro, e testado com dados de exemplo:

- **Funcionaram:** agendar pela procedure; o mesmo horário com **outro** médico; remarcar uma consulta para um horário livre; alterar o paciente de uma consulta sem mudar o horário.
- **Foram recusados, com a mensagem esperada:** paciente inexistente; médico inexistente; data no passado; parâmetro nulo; agendar um médico num horário já ocupado (pela procedure e por `INSERT` direto); remarcar para um horário em que o médico já atende.

> **Observação:** com o log binário ativo (padrão do MySQL 8), só um usuário com privilégio `SUPER` (como o `root`) pode criar triggers e functions. Com outro usuário, é preciso antes rodar `SET GLOBAL log_bin_trust_function_creators = 1;` como root.

### `07_usuarios_roles.sql`: role e usuários da recepção

Cria a role `recepcao` e dois usuários ligados a ela. **Roda por último**, porque o MySQL não aceita conceder permissão (`GRANT`) sobre uma view, procedure ou function que ainda não existe.

#### Por que usar uma role

Uma role é um "pacote" de permissões com nome. Em vez de repetir os mesmos `GRANT`s para cada funcionário da recepção, as permissões são dadas uma vez à role, e a role é dada aos usuários. Se a recepção precisar de uma permissão nova, basta alterar a role, e todos os usuários ligados a ela recebem a mudança.

#### Permissões da role `recepcao`

A recepção cadastra pacientes, abre prontuários e agenda, remarca e cancela consultas. Ela recebe só o necessário para isso (**princípio do menor privilégio**):

| Objeto | Permissões | Por quê |
|---|---|---|
| `Paciente` | `SELECT`, `INSERT`, `UPDATE` | Cadastrar pacientes e atualizar dados como o telefone. Sem `DELETE`: apagar um paciente apagaria o histórico dele. |
| `Prontuario` | `SELECT`, `INSERT` | Abrir o prontuário no cadastro do paciente. Sem `UPDATE`: as observações clínicas são responsabilidade do médico. |
| `Consulta` | `SELECT`, `INSERT`, `UPDATE`, `DELETE` | Agendar, remarcar e cancelar consultas. Os triggers continuam impedindo conflitos de horário. |
| `Medico`, `Especialidade` | `SELECT` | Consultar médicos e especialidades para agendar, sem poder alterar o cadastro. |
| `vw_agenda_consultas` | `SELECT` | Ver a agenda completa (paciente, idade, médico e especialidade) numa única consulta. |
| `agendar_consulta` (procedure) | `EXECUTE` | Agendar pelo caminho com validações e mensagens claras. |
| `calcular_idade` (function) | `EXECUTE` | Usar o cálculo de idade nas próprias consultas. |

#### Usuários

| Usuário | Senha (fictícia) |
|---|---|
| `ana_recepcao@localhost` | `Ana@Recepcao2026` |
| `bruno_recepcao@localhost` | `Bruno@Recepcao2026` |

- As senhas são **fictícias**, só para demonstração, porque este arquivo é público. As senhas têm maiúscula, minúscula, número e símbolo, para passar na política de senhas do MySQL caso ela esteja ativa.
- `@localhost`: os usuários só conseguem se conectar a partir da própria máquina do servidor.
- `GRANT 'recepcao' TO ...` liga a role aos dois usuários.
- `SET DEFAULT ROLE 'recepcao' TO ...` é **obrigatório**: no MySQL, uma role concedida fica inativa até ser ativada. Sem esse comando, o usuário faria login sem nenhuma permissão e teria que rodar `SET ROLE` a cada conexão.
- O script começa com `DROP USER IF EXISTS` e `DROP ROLE IF EXISTS` para poder ser rodado de novo sem erro.

#### Regras verificadas

O script foi executado depois dos arquivos 01 a 06 e repetido, sem erro. Logado como `ana_recepcao`, `CURRENT_ROLE()` mostrou a role `recepcao` já ativa, e:

- **Funcionaram:** ler a view da agenda; usar `calcular_idade`; cadastrar um paciente e abrir o prontuário dele; atualizar o telefone; agendar pela procedure; cancelar a consulta; consultar médicos.
- **Foram negados pelo MySQL (`command denied`):** apagar paciente; alterar prontuário; cadastrar médico; alterar especialidade; apagar a tabela `Consulta`; criar um usuário.

O usuário `bruno_recepcao` também entrou com a role ativa.
