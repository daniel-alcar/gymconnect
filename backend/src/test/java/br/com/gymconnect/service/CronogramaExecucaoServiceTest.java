package br.com.gymconnect.service;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import br.com.gymconnect.exception.BadRequestException;
import br.com.gymconnect.exception.ForbiddenException;
import br.com.gymconnect.exception.ResourceNotFoundException;
import br.com.gymconnect.model.Cronograma;
import br.com.gymconnect.model.CronogramaExecucao;
import br.com.gymconnect.model.StatusExecucao;
import br.com.gymconnect.model.TipoUsuario;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.repository.CronogramaExecucaoRepository;
import br.com.gymconnect.repository.CronogramaRepository;

@ExtendWith(MockitoExtension.class)
class CronogramaExecucaoServiceTest {

    @Mock CronogramaExecucaoRepository execRepo;
    @Mock CronogramaRepository cronogramaRepo;
    @InjectMocks CronogramaExecucaoService service;

    private Usuario alunoFixture(long id) {
        Usuario u = new Usuario("Aluno Teste", "aluno@test.com", "senha123", TipoUsuario.ALUNO);
        u.setIdUsuario(id);
        return u;
    }

    private Cronograma cronogramaFixture(Long id, long idAluno) {
        Cronograma c = new Cronograma();
        c.setIdCronograma(id);
        c.setAluno(alunoFixture(idAluno));
        return c;
    }

    // ---- cadastrar ----

    @Test
    void cadastrar_semCronograma_lancaBadRequestException() {
        CronogramaExecucao body = new CronogramaExecucao();
        body.setStatus(StatusExecucao.FEITO);

        assertThatThrownBy(() -> service.cadastrar(body, 1L))
                .isInstanceOf(BadRequestException.class);
    }

    @Test
    void cadastrar_semStatus_lancaBadRequestException() {
        CronogramaExecucao body = new CronogramaExecucao();
        Cronograma c = new Cronograma();
        c.setIdCronograma(1L);
        body.setCronograma(c);

        assertThatThrownBy(() -> service.cadastrar(body, 1L))
                .isInstanceOf(BadRequestException.class);
    }

    @Test
    void cadastrar_cronogramaNaoEncontrado_lancaResourceNotFoundException() {
        CronogramaExecucao body = new CronogramaExecucao();
        Cronograma c = new Cronograma();
        c.setIdCronograma(99L);
        body.setCronograma(c);
        body.setStatus(StatusExecucao.FEITO);
        when(cronogramaRepo.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.cadastrar(body, 1L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void cadastrar_cronogramaDeOutroAluno_lancaForbiddenException() {
        Cronograma cronograma = cronogramaFixture(1L, 2L); // cronograma do aluno 2
        CronogramaExecucao body = new CronogramaExecucao();
        body.setCronograma(cronograma);
        body.setStatus(StatusExecucao.FEITO);
        when(cronogramaRepo.findById(1L)).thenReturn(Optional.of(cronograma));

        assertThatThrownBy(() -> service.cadastrar(body, 1L)) // aluno 1 tenta acessar
                .isInstanceOf(ForbiddenException.class);
    }

    @Test
    void cadastrar_dadosValidos_salvaExecucao() {
        Cronograma cronograma = cronogramaFixture(1L, 1L);
        CronogramaExecucao body = new CronogramaExecucao();
        body.setCronograma(cronograma);
        body.setStatus(StatusExecucao.FEITO);

        CronogramaExecucao salvo = new CronogramaExecucao();
        salvo.setStatus(StatusExecucao.FEITO);
        when(cronogramaRepo.findById(1L)).thenReturn(Optional.of(cronograma));
        when(execRepo.save(any())).thenReturn(salvo);

        CronogramaExecucao resultado = service.cadastrar(body, 1L);

        assertThat(resultado.getStatus()).isEqualTo(StatusExecucao.FEITO);
        verify(execRepo).save(any());
    }

    // ---- atualizarStatus ----

    @Test
    void atualizarStatus_execucaoNaoEncontrada_lancaResourceNotFoundException() {
        when(execRepo.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.atualizarStatus(99L, StatusExecucao.FEITO, 1L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void atualizarStatus_execucaoDeOutroAluno_lancaForbiddenException() {
        CronogramaExecucao execucao = new CronogramaExecucao();
        execucao.setCronograma(cronogramaFixture(1L, 2L)); // aluno 2
        when(execRepo.findById(1L)).thenReturn(Optional.of(execucao));

        assertThatThrownBy(() -> service.atualizarStatus(1L, StatusExecucao.NAO_FEITO, 1L))
                .isInstanceOf(ForbiddenException.class);
    }

    @Test
    void atualizarStatus_dadosValidos_atualizaERetorna() {
        Cronograma cronograma = cronogramaFixture(1L, 1L);
        CronogramaExecucao execucao = new CronogramaExecucao();
        execucao.setCronograma(cronograma);
        execucao.setStatus(StatusExecucao.NAO_FEITO);
        when(execRepo.findById(1L)).thenReturn(Optional.of(execucao));
        when(execRepo.save(execucao)).thenReturn(execucao);

        CronogramaExecucao resultado = service.atualizarStatus(1L, StatusExecucao.FEITO, 1L);

        assertThat(resultado.getStatus()).isEqualTo(StatusExecucao.FEITO);
        verify(execRepo).save(execucao);
    }
}
