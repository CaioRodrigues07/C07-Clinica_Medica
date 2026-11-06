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
