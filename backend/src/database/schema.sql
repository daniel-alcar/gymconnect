CREATE DATABASE IF NOT EXISTS teste_gymconnect;
USE teste_gymconnect;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario BIGINT AUTO_INCREMENT PRIMARY KEY,
    uuid_usuario CHAR(16) NOT NULL UNIQUE,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL,
    senha VARCHAR(100) NOT NULL,
    tipo ENUM('CLIENTE', 'ALUNO') NOT NULL,
    CNPJ CHAR(14),
    CPF CHAR(11),
    id_cliente BIGINT NULL,
    CONSTRAINT CHK_DOCUMENTO CHECK (
        (CNPJ IS NULL AND CPF IS NULL) OR 
        (CPF IS NULL AND CNPJ IS NULL)
    ),
    UNIQUE(CNPJ),
    UNIQUE(CPF),
    FOREIGN KEY (id_cliente) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS exercicios (
    id_exercicio BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    link_youtube VARCHAR(264) NOT NULL
);

CREATE TABLE IF NOT EXISTS cronograma (
    id_cronograma BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_aluno BIGINT NOT NULL,
    dias_totais INT,
    FOREIGN KEY (id_aluno) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cronograma_exercicio (
    id_cronograma_exercicio BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_cronograma BIGINT NOT NULL,
    id_exercicio BIGINT NOT NULL,
    dia_semana ENUM('Segunda', 'Terca', 'Quarta', 'Quinta', 'Sexta', 'Sabado', 'Domingo'),
    serie INT,
    repeticao INT,
    carga INT,
    FOREIGN KEY (id_cronograma) REFERENCES cronograma(id_cronograma) ON DELETE CASCADE,
    FOREIGN KEY (id_exercicio) REFERENCES exercicios(id_exercicio) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cronograma_execucao (
    id_execucao BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_cronograma BIGINT NOT NULL,
    status ENUM('FEITO', 'NAO FEITO'),
    FOREIGN KEY (id_cronograma) REFERENCES cronograma(id_cronograma) ON DELETE CASCADE
);
