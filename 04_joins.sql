SET NAMES utf8mb4;

USE clinica_medica;

SELECT p.nome_paciente, pr.data_criacao, pr.observacao
FROM Paciente p
INNER JOIN Prontuario pr ON pr.Paciente_idPaciente = p.idPaciente
ORDER BY p.nome_paciente;

SELECT e.nome_especialidade, m.nome_medico, m.crm
FROM Especialidade e
LEFT JOIN Medico m ON m.Especialidade_idEspecialidade = e.idEspecialidade
ORDER BY e.nome_especialidade, m.nome_medico;

SELECT c.idconsulta, c.data_hora_consulta, p.nome_paciente, m.nome_medico
FROM Consulta c
INNER JOIN Paciente p ON p.idPaciente = c.Paciente_idPaciente
INNER JOIN Medico   m ON m.idMedico   = c.Medico_idMedico
ORDER BY c.data_hora_consulta;
