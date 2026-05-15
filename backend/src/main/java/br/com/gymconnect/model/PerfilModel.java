package br.com.gymconnect.model;

import java.sql.Date;

import javax.xml.crypto.Data;

import org.hibernate.annotations.ManyToAny;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter

@Entity
@Table(name="perfil")
public class PerfilModel {
    
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    @Column(name="id_perfil")
    private Long idPerfil;

    @OneToOne
    @JoinColumn(name="id_usuario", unique=true)
    private Usuario usuario;

    @Column(name="dataNascimento",nullable=true)
    private Date dataNascimento;

    @Column(name="altura",nullable=true)
    private Double altura;

    @Column(name="objetivo",nullable=true, length=50)
    private String objetivo;
}
