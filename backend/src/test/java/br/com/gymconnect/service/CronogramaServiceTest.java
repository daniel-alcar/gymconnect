package br.com.gymconnect.service;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import br.com.gymconnect.exception.BadRequestException;
import br.com.gymconnect.exception.ResourceNotFoundException;
import br.com.gymconnect.model.Cronograma;
import br.com.gymconnect.model.TipoUsuario;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.repository.CronogramaRepository;
import br.com.gymconnect.repository.UsuarioRepository;

@ExtendWith(MockitoExtension.class)
class CronogramaServiceTest {

    @Mock CronogramaRepository cr;
    @Mock UsuarioRepository ur;
    @InjectMocks CronogramaService service;

    private Usuario alunoFixture(long id) {
        Usuario u = new Usuario("Aluno Teste", "aluno@test.com", "senha123", TipoUsuario.ALUNO);
        u.setIdUsuario(id);
        return u;
    }

    @Test
    void cadastrar_semAluno_lancaBadRequestException() {
        Cronograma c = new Cronograma();

        assertThatThrownBy(() -> service.cadastrar(c))
                .isInstanceOf(BadRequestException.class);
    }

    @Test
    void cadastrar_alunoNaoEncontrado_lancaResourceNotFoundException() {
        Cronograma c = new Cronograma();
        c.setAluno(alunoFixture(99L));
        when(ur.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.cadastrar(c))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void cadastrar_comAlunoValido_salvaERetorna() {
        Usuario aluno = alunoFixture(1L);
        Cronograma c = new Cronograma();
        c.setAluno(aluno);
        when(ur.findById(1L)).thenReturn(Optional.of(aluno));
        when(cr.save(c)).thenReturn(c);

        Cronograma resultado = service.cadastrar(c);

        assertThat(resultado.getAluno()).isEqualTo(aluno);
        verify(cr).save(c);
    }

    @Test
    void remover_quandoNaoEncontrado_lancaResourceNotFoundException() {
        when(cr.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.remover(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void remover_quandoEncontrado_deletaCronograma() {
        Cronograma c = new Cronograma();
        when(cr.findById(1L)).thenReturn(Optional.of(c));

        service.remover(1L);

        verify(cr).delete(c);
    }

    @Test
    void listar_alunoNaoEncontrado_lancaResourceNotFoundException() {
        when(ur.existsById(99L)).thenReturn(false);

        assertThatThrownBy(() -> service.listar(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void listar_alunoExistente_retornaLista() {
        when(ur.existsById(1L)).thenReturn(true);
        when(cr.findByAlunoIdUsuario(1L)).thenReturn(List.of());

        assertThat(service.listar(1L)).isEmpty();
    }
}
