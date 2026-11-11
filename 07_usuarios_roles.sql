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
