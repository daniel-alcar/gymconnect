package br.com.gymconnect.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "registro_diario")
public class RegistroDiarioModel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_registro")
    private Long idRegistro;

    @ManyToOne
    @JoinColumn(name = "id_execucao", nullable = false)
    private CronogramaExecucao execucao;

    @Column(name = "peso", nullable = true)
    private Double peso;

}
