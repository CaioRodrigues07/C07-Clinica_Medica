SET NAMES utf8mb4;

USE clinica_medica;

DROP PROCEDURE IF EXISTS agendar_consulta;
DROP TRIGGER IF EXISTS trg_consulta_conflito_insert;
DROP TRIGGER IF EXISTS trg_consulta_conflito_update;

DELIMITER $$

CREATE PROCEDURE agendar_consulta(
  IN p_paciente  INT,
  IN p_medico    INT,
  IN p_data_hora DATETIME
)
BEGIN
  IF p_paciente IS NULL OR p_medico IS NULL OR p_data_hora IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Paciente, médico e data/hora são obrigatórios.';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM Paciente WHERE idPaciente = p_paciente) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Paciente não encontrado.';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM Medico WHERE idMedico = p_medico) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Médico não encontrado.';
  END IF;

  IF p_data_hora <= NOW() THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'A consulta deve ser agendada para uma data futura.';
  END IF;

  INSERT INTO Consulta (Paciente_idPaciente, Medico_idMedico, data_hora_consulta)
  VALUES (p_paciente, p_medico, p_data_hora);

  SELECT LAST_INSERT_ID() AS idconsulta;
END$$

CREATE TRIGGER trg_consulta_conflito_insert
BEFORE INSERT ON Consulta
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
    FROM Consulta
    WHERE Medico_idMedico = NEW.Medico_idMedico
      AND data_hora_consulta = NEW.data_hora_consulta
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'O médico já tem uma consulta neste horário.';
  END IF;
END$$

CREATE TRIGGER trg_consulta_conflito_update
BEFORE UPDATE ON Consulta
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
    FROM Consulta
    WHERE Medico_idMedico = NEW.Medico_idMedico
      AND data_hora_consulta = NEW.data_hora_consulta
      AND idconsulta <> NEW.idconsulta
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'O médico já tem uma consulta neste horário.';
  END IF;
END$$

DELIMITER ;
