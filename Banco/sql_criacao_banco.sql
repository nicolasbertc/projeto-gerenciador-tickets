--
-- Arquivo gerado com SQLiteStudio v3.4.4 em dom set 8 22:08:45 2024
--
-- Codificação de texto usada: System
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Tabela: funcionarios
CREATE TABLE IF NOT EXISTS funcionarios (cd_funcionario INTEGER PRIMARY KEY UNIQUE, nm_funcionario TEXT (255) NOT NULL, cd_cpf INTEGER UNIQUE, ie_situacao TEXT (1), dt_criacao TEXT (255), dt_edicao TEXT (255));

-- Tabela: tickets
CREATE TABLE IF NOT EXISTS tickets (cd_ticket INTEGER PRIMARY KEY UNIQUE, cd_funcionario INTEGER, nm_funcionario TEXT (255), ie_situacao TEXT (2), dt_entrega TEXT (255));

COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
