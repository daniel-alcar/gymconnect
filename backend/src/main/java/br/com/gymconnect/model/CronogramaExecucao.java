package br.com.gymconnect.model;

import java.time.LocalDate;

import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "cronograma_execucao")
public class CronogramaExecucao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_execucao")
    private Long idExecucao;

    @ManyToOne
    @JoinColumn(name = "id_cronograma", nullable = false)
    private Cronograma cronograma;

    @Convert(converter = StatusExecucaoConverter.class)
    @Column(name = "status")
    private StatusExecucao status;

    @Column(name = "dataExecucao")
    private LocalDate dataExecucao;

    @PrePersist
    @PreUpdate
    private void sincronizarDataComStatus() {
        if (status == StatusExecucao.FEITO) {
            if (dataExecucao == null) {
                dataExecucao = LocalDate.now();
            }
        } else {
            dataExecucao = null;
        }
    }
}
