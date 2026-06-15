package br.com.gymconnect.service;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import br.com.gymconnect.dto.ExercicioRequestDTO;
import br.com.gymconnect.exception.ConflictException;
import br.com.gymconnect.exception.ResourceNotFoundException;
import br.com.gymconnect.model.Exercicio;
import br.com.gymconnect.repository.CronogramaExercicioRepository;
import br.com.gymconnect.repository.ExercicioRepository;

@ExtendWith(MockitoExtension.class)
class ExercicioServiceTest {

    @Mock ExercicioRepository er;
    @Mock CronogramaExercicioRepository cer;
    @InjectMocks ExercicioService service;

    private Exercicio fixture(Long id, String nome) {
        Exercicio ex = new Exercicio();
        ex.setIdExercicio(id);
        ex.setNome(nome);
        ex.setLinkYoutube("https://www.youtube.com/shorts/abc123");
        return ex;
    }

    @Test
    void listar_retornaListaDoRepositorio() {
        List<Exercicio> lista = List.of(fixture(1L, "Supino"));
        when(er.findAll()).thenReturn(lista);

        assertThat(service.listar()).isEqualTo(lista);
    }

    @Test
    void cadastrar_salvaNovoExercicio() {
        ExercicioRequestDTO dto = new ExercicioRequestDTO("Agachamento", "https://www.youtube.com/shorts/abc", null);
        Exercicio salvo = fixture(1L, "Agachamento");
        when(er.save(any())).thenReturn(salvo);

        Exercicio resultado = service.cadastrar(dto);

        assertThat(resultado.getNome()).isEqualTo("Agachamento");
        verify(er).save(any(Exercicio.class));
    }

    @Test
    void atualizar_quandoEncontrado_atualizaESalva() {
        Exercicio existente = fixture(1L, "Supino");
        when(er.findById(1L)).thenReturn(Optional.of(existente));
        when(er.save(existente)).thenReturn(existente);

        ExercicioRequestDTO dto = new ExercicioRequestDTO("Supino Reto", "https://www.youtube.com/shorts/xyz", "desc");
        Exercicio resultado = service.atualizar(1L, dto);

        assertThat(resultado.getNome()).isEqualTo("Supino Reto");
        verify(er).save(existente);
    }

    @Test
    void atualizar_quandoNaoEncontrado_lancaResourceNotFoundException() {
        when(er.findById(99L)).thenReturn(Optional.empty());
        ExercicioRequestDTO dto = new ExercicioRequestDTO("X", "https://www.youtube.com/shorts/x", null);

        assertThatThrownBy(() -> service.atualizar(99L, dto))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void remover_quandoNaoEncontrado_lancaResourceNotFoundException() {
        when(er.existsById(99L)).thenReturn(false);

        assertThatThrownBy(() -> service.remover(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void remover_quandoEmUso_lancaConflictException() {
        when(er.existsById(1L)).thenReturn(true);
        when(cer.existsByExercicio_IdExercicio(1L)).thenReturn(true);

        assertThatThrownBy(() -> service.remover(1L))
                .isInstanceOf(ConflictException.class);
    }

    @Test
    void remover_quandoLivre_deletaDoRepositorio() {
        when(er.existsById(1L)).thenReturn(true);
        when(cer.existsByExercicio_IdExercicio(1L)).thenReturn(false);

        service.remover(1L);

        verify(er).deleteById(1L);
    }
}
