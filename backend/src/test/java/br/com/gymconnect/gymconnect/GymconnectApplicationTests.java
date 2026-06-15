package br.com.gymconnect.gymconnect;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import br.com.gymconnect.model.Exercicio;
import br.com.gymconnect.model.TipoUsuario;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.repository.ExercicioRepository;
import br.com.gymconnect.repository.UsuarioRepository;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class GymconnectApplicationTests {

	@Autowired ExercicioRepository exercicioRepository;
	@Autowired UsuarioRepository usuarioRepository;

	@Test
	void contextLoads() {
		assertThat(exercicioRepository).isNotNull();
		assertThat(usuarioRepository).isNotNull();
	}

	@Test
	void exercicio_persisteERecupera() {
		Exercicio ex = new Exercicio();
		ex.setNome("Supino Reto");
		ex.setLinkYoutube("https://www.youtube.com/shorts/G3TTZ5VLTVM");

		Exercicio salvo = exercicioRepository.save(ex);

		assertThat(salvo.getIdExercicio()).isNotNull();
		assertThat(exercicioRepository.findById(salvo.getIdExercicio())).isPresent();
	}

	@Test
	void usuario_persisteERecupera() {
		Usuario u = new Usuario("Integração Teste", "integracao@test.com", "senha123", TipoUsuario.ALUNO);

		Usuario salvo = usuarioRepository.save(u);

		assertThat(salvo.getIdUsuario()).isNotNull();
		assertThat(usuarioRepository.findById(salvo.getIdUsuario())).isPresent();
	}
}
