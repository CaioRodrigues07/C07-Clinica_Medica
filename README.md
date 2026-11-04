# Projeto de Modelagem de Banco de Dados - Clínica Médica

**Integrantes do Grupo:**
- Jhonata De Oliveira Claudio 2061 GEC
- Pablo Teixeira Villela dos Santos 598 GES
- Caio Rodrigues Couto 447

**Tema Escolhido:** Sistema de Gestão para Clínica Médica

**Breve Explicação do Tema:**
O projeto consiste na modelagem de um banco de dados para gerenciar as rotinas de uma clínica médica. O escopo abrange:
- O controle de **Pacientes** e seus **Prontuários** (garantindo um prontuário único por paciente em uma relação 1:1).
- A categorização dos **Médicos** de acordo com suas **Especialidades** (onde uma especialidade possui vários médicos, mas cada médico responde por uma especialidade principal, relação 1:N).
- O registro de **Consultas**, que conecta os pacientes aos médicos em dias e horários específicos (resolvendo a relação N:M através de uma tabela intermediária bem definida).
