package br.com.gymconnect.config;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import br.com.gymconnect.model.Exercicio;
import br.com.gymconnect.repository.ExercicioRepository;

/**
 * Popula a biblioteca de exercicios com itens comuns na primeira execucao
 * (apenas se a tabela estiver vazia). Idempotente.
 */
@Component
public class ExercicioSeeder implements CommandLineRunner {

    private final ExercicioRepository er;

    public ExercicioSeeder(ExercicioRepository er) {
        this.er = er;
    }

    @Override
    public void run(String... args) {

        List<Exercicio> base = List.of(
            criar("Supino reto com barra",
                "https://www.youtube.com/watch?v=rT7DgCr-3pg",
                "Deite no banco com os pes apoiados no chao. Segure a barra um pouco mais que a largura dos ombros. Desca a barra ate a linha do peito controlando o movimento e empurre de volta sem travar os cotovelos."),
            criar("Agachamento livre",
                "https://www.youtube.com/watch?v=ultWZbUMPL8",
                "Pes na largura dos ombros, barra apoiada no trapezio. Desca flexionando quadril e joelhos mantendo a coluna neutra ate as coxas ficarem paralelas ao chao e suba empurrando pelos calcanhares."),
            criar("Levantamento terra",
                "https://www.youtube.com/watch?v=op9kVnSso6Q",
                "Barra rente as canelas, pegada na largura dos ombros. Mantenha a coluna reta, peito aberto e suba estendendo quadril e joelhos ao mesmo tempo. Desca controlando, sem arredondar as costas."),
            criar("Rosca direta com barra",
                "https://www.youtube.com/watch?v=kwG2ipFRgfo",
                "Em pe, cotovelos junto ao corpo. Flexione os cotovelos elevando a barra ate a altura dos ombros e desca devagar. Evite balancar o tronco para nao usar impulso."),
            criar("Triceps na polia (corda)",
                "https://www.youtube.com/watch?v=2-LAMcpzODU",
                "De frente para a polia alta, cotovelos fixos ao lado do corpo. Estenda os antebracos para baixo abrindo a corda no final e retorne controlando."),
            criar("Desenvolvimento de ombros com halteres",
                "https://www.youtube.com/watch?v=qEwKCR5JCog",
                "Sentado com as costas apoiadas, halteres na altura dos ombros. Empurre para cima ate quase estender os cotovelos e desca controlando ate a linha das orelhas."),
            criar("Puxada frontal (pulldown)",
                "https://www.youtube.com/watch?v=CAwf7n6Luuc",
                "Sentado, pegada aberta na barra. Puxe a barra ate a parte alta do peito contraindo as costas e retorne controlando a subida sem soltar de uma vez."),
            criar("Remada curvada com barra",
                "https://www.youtube.com/watch?v=vT2GjY_Umpw",
                "Tronco inclinado a cerca de 45 graus, coluna neutra. Puxe a barra em direcao ao abdomen contraindo as escapulas e desca controlando."),
            criar("Leg press 45",
                "https://www.youtube.com/watch?v=IZxyjW7MPJQ",
                "Pes na plataforma na largura dos ombros. Desca flexionando os joelhos ate cerca de 90 graus sem tirar o quadril do apoio e empurre de volta sem travar os joelhos."),
            criar("Cadeira extensora",
                "https://www.youtube.com/watch?v=YyvSfVjQeL0",
                "Sentado, tornozelos atras do apoio. Estenda os joelhos ate quase a extensao total contraindo o quadriceps e retorne controlando o peso.")
        );

        // Insere apenas os que ainda nao existem (por nome), mesmo que a
        // tabela ja tenha outros exercicios cadastrados.
        Set<String> existentes = er.findAll().stream()
                .map(e -> e.getNome() == null ? "" : e.getNome().trim().toLowerCase())
                .collect(Collectors.toSet());

        List<Exercicio> faltando = base.stream()
                .filter(e -> !existentes.contains(e.getNome().trim().toLowerCase()))
                .collect(Collectors.toList());

        if (!faltando.isEmpty()) {
            er.saveAll(faltando);
        }
    }

    private Exercicio criar(String nome, String link, String descricao) {
        Exercicio ex = new Exercicio();
        ex.setNome(nome);
        ex.setLinkYoutube(link);
        ex.setDescricao(descricao);
        return ex;
    }
}
