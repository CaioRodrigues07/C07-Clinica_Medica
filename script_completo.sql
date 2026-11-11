SET NAMES utf8mb4;

DROP DATABASE IF EXISTS clinica_medica;

CREATE DATABASE clinica_medica
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE clinica_medica;

CREATE TABLE Especialidade (
  idEspecialidade     INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nome_especialidade  VARCHAR(45)  NOT NULL,
  UNIQUE INDEX nome_especialidade_UNIQUE (nome_especialidade)
) ENGINE = InnoDB;

CREATE TABLE Medico (
  idMedico                       INT           NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nome_medico                    VARCHAR(100)  NOT NULL,
  crm                            VARCHAR(20)   NOT NULL,
  Especialidade_idEspecialidade  INT           NOT NULL,
  UNIQUE INDEX crm_UNIQUE (crm),
  INDEX fk_Medico_Especialidade1_idx (Especialidade_idEspecialidade),
  CONSTRAINT fk_Medico_Especialidade1
    FOREIGN KEY (Especialidade_idEspecialidade)
    REFERENCES Especialidade (idEspecialidade)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;

CREATE TABLE Paciente (
  idPaciente       INT           NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nome_paciente    VARCHAR(100)  NOT NULL,
  data_nascimento  DATE          NOT NULL,
  telefone         VARCHAR(45)   NULL
) ENGINE = InnoDB;

CREATE TABLE Prontuario (
  idProntuario         INT           NOT NULL AUTO_INCREMENT PRIMARY KEY,
  data_criacao         DATE          NOT NULL DEFAULT (CURRENT_DATE),
  observacao           VARCHAR(200)  NULL,
  Paciente_idPaciente  INT           NOT NULL,
  UNIQUE INDEX Paciente_idPaciente_UNIQUE (Paciente_idPaciente),
  CONSTRAINT fk_Prontuario_Paciente
    FOREIGN KEY (Paciente_idPaciente)
    REFERENCES Paciente (idPaciente)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;

CREATE TABLE Consulta (
  idconsulta           INT       NOT NULL AUTO_INCREMENT PRIMARY KEY,
  Paciente_idPaciente  INT       NOT NULL,
  Medico_idMedico      INT       NOT NULL,
  data_hora_consulta   DATETIME  NOT NULL,
  INDEX fk_Paciente_has_Medico_Medico1_idx (Medico_idMedico),
  INDEX fk_Paciente_has_Medico_Paciente1_idx (Paciente_idPaciente),
  CONSTRAINT fk_Paciente_has_Medico_Paciente1
    FOREIGN KEY (Paciente_idPaciente)
    REFERENCES Paciente (idPaciente)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_Paciente_has_Medico_Medico1
    FOREIGN KEY (Medico_idMedico)
    REFERENCES Medico (idMedico)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;

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

SET NAMES utf8mb4;

USE clinica_medica;

UPDATE Paciente
SET telefone = '(35) 98888-0000'
WHERE idPaciente = 1;

UPDATE Consulta
SET data_hora_consulta = '2026-11-20 09:30:00'
WHERE idconsulta = 2;

UPDATE Prontuario
SET observacao = 'Check-up anual sem alterações; retorno em 12 meses.'
WHERE Paciente_idPaciente = 4;

DELETE FROM Consulta
WHERE idconsulta = 6;

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

USE clinica_medica;

DROP USER IF EXISTS 'ana_recepcao'@'localhost', 'bruno_recepcao'@'localhost';
DROP ROLE IF EXISTS 'recepcao';

CREATE ROLE 'recepcao';

GRANT SELECT, INSERT, UPDATE ON clinica_medica.Paciente TO 'recepcao';
GRANT SELECT, INSERT ON clinica_medica.Prontuario TO 'recepcao';
GRANT SELECT, INSERT, UPDATE, DELETE ON clinica_medica.Consulta TO 'recepcao';
GRANT SELECT ON clinica_medica.Medico TO 'recepcao';
GRANT SELECT ON clinica_medica.Especialidade TO 'recepcao';
GRANT SELECT ON clinica_medica.vw_agenda_consultas TO 'recepcao';
GRANT EXECUTE ON PROCEDURE clinica_medica.agendar_consulta TO 'recepcao';
GRANT EXECUTE ON FUNCTION clinica_medica.calcular_idade TO 'recepcao';

CREATE USER 'ana_recepcao'@'localhost' IDENTIFIED BY 'Ana@Recepcao2026';
CREATE USER 'bruno_recepcao'@'localhost' IDENTIFIED BY 'Bruno@Recepcao2026';

GRANT 'recepcao' TO 'ana_recepcao'@'localhost', 'bruno_recepcao'@'localhost';

SET DEFAULT ROLE 'recepcao' TO 'ana_recepcao'@'localhost', 'bruno_recepcao'@'localhost';
