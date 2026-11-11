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
