SET NAMES utf8mb4;

USE clinica_medica;

DROP VIEW IF EXISTS vw_agenda_consultas;
DROP FUNCTION IF EXISTS calcular_idade;

DELIMITER $$

CREATE FUNCTION calcular_idade(p_data_nascimento DATE)
RETURNS INT
NOT DETERMINISTIC
NO SQL
BEGIN
  RETURN TIMESTAMPDIFF(YEAR, p_data_nascimento, CURDATE());
END$$

DELIMITER ;

CREATE VIEW vw_agenda_consultas AS
SELECT c.idconsulta,
       c.data_hora_consulta,
       p.nome_paciente,
       calcular_idade(p.data_nascimento) AS idade_paciente,
       m.nome_medico,
       e.nome_especialidade
FROM Consulta c
INNER JOIN Paciente      p ON p.idPaciente      = c.Paciente_idPaciente
INNER JOIN Medico        m ON m.idMedico        = c.Medico_idMedico
INNER JOIN Especialidade e ON e.idEspecialidade = m.Especialidade_idEspecialidade;

SELECT calcular_idade('1990-03-15') AS idade_exemplo;
SELECT * FROM vw_agenda_consultas ORDER BY data_hora_consulta;
