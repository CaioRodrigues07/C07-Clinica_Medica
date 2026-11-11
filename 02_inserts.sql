SET NAMES utf8mb4;

USE clinica_medica;

INSERT INTO Especialidade (idEspecialidade, nome_especialidade) VALUES
(1, 'Cardiologia'),
(2, 'Dermatologia'),
(3, 'Ortopedia'),
(4, 'Pediatria'),
(5, 'Neurologia');

INSERT INTO Medico (idMedico, nome_medico, crm, Especialidade_idEspecialidade) VALUES
(1, 'Dr. Carlos Almeida',  'CRM-MG 11111', 1),
(2, 'Dra. Fernanda Lima',  'CRM-MG 22222', 2),
(3, 'Dr. Roberto Souza',   'CRM-MG 33333', 3),
(4, 'Dra. Juliana Prado',  'CRM-MG 44444', 4),
(5, 'Dr. Marcelo Tavares', 'CRM-MG 55555', 1);

INSERT INTO Paciente (idPaciente, nome_paciente, data_nascimento, telefone) VALUES
(1, 'Ana Beatriz Costa',   '1990-03-15', '(35) 99111-1111'),
(2, 'Bruno Henrique Dias', '1985-07-22', '(35) 99222-2222'),
(3, 'Camila Ferreira',     '2001-11-05', '(35) 99333-3333'),
(4, 'Diego Martins',       '1978-01-30', '(35) 99444-4444'),
(5, 'Eduarda Nogueira',    '2015-09-12', NULL);

INSERT INTO Prontuario (idProntuario, data_criacao, observacao, Paciente_idPaciente) VALUES
(1, '2026-01-10', 'Hipertensão controlada com medicação.',  1),
(2, '2026-02-03', 'Histórico de lesão no joelho direito.',   2),
(3, '2026-03-18', 'Acompanhamento de dermatite atópica.',    3),
(4, '2026-04-25', 'Check-up anual sem alterações.',          4),
(5, '2026-05-07', 'Vacinação em dia; crescimento adequado.', 5);

INSERT INTO Consulta (idconsulta, Paciente_idPaciente, Medico_idMedico, data_hora_consulta) VALUES
(1, 1, 1, '2026-11-16 09:00:00'),
(2, 2, 3, '2026-11-16 10:00:00'),
(3, 3, 2, '2026-11-17 14:30:00'),
(4, 5, 4, '2026-11-18 08:30:00'),
(5, 4, 5, '2026-11-18 11:00:00'),
(6, 1, 5, '2026-11-19 15:00:00');
