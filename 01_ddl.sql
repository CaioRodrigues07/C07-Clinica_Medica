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
