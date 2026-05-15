package br.com.gymconnect.model;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class CronogramaExecucaoDAO {

    public void registrarExecucao(long idCronograma, String status, Connection conn) {

        String sql = """
            INSERT INTO cronograma_execucao
            (id_cronograma, status)
            VALUES (?, ?)
        """;

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, idCronograma);
            stmt.setString(2, status);

            stmt.executeUpdate();

            System.out.println("Execução registrada!");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}