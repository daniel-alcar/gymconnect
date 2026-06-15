package br.com.gymconnect.config;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import br.com.gymconnect.model.Exercicio;
import br.com.gymconnect.repository.ExercicioRepository;

/**
 * Popula a biblioteca de exercicios com itens comuns e sincroniza links
 * desatualizados a cada inicializacao. Idempotente.
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
                "https://www.youtube.com/shorts/G3TTZ5VLTVM",
                "Deite no banco com os pes apoiados no chao. Segure a barra um pouco mais que a largura dos ombros. Desca a barra ate a linha do peito controlando o movimento e empurre de volta sem travar os cotovelos."),
            criar("Agachamento livre",
                "https://www.youtube.com/shorts/3uZE_E11eg4",
                "Pes na largura dos ombros, barra apoiada no trapezio. Desca flexionando quadril e joelhos mantendo a coluna neutra ate as coxas ficarem paralelas ao chao e suba empurrando pelos calcanhares."),
            criar("Levantamento terra",
                "https://www.youtube.com/shorts/DjsLHZ4jxTU",
                "Barra rente as canelas, pegada na largura dos ombros. Mantenha a coluna reta, peito aberto e suba estendendo quadril e joelhos ao mesmo tempo. Desca controlando, sem arredondar as costas."),
            criar("Rosca direta com barra",
                "https://www.youtube.com/shorts/gOTvVYwY9oI",
                "Em pe, cotovelos junto ao corpo. Flexione os cotovelos elevando a barra ate a altura dos ombros e desca devagar. Evite balancar o tronco para nao usar impulso."),
            criar("Triceps na polia (corda)",
                "https://www.youtube.com/shorts/0TQQyGm4fIc",
                "De frente para a polia alta, cotovelos fixos ao lado do corpo. Estenda os antebracos para baixo abrindo a corda no final e retorne controlando."),
            criar("Desenvolvimento de ombros com halteres",
                "https://www.youtube.com/shorts/X3gv1x7ICw8",
                "Sentado com as costas apoiadas, halteres na altura dos ombros. Empurre para cima ate quase estender os cotovelos e desca controlando ate a linha das orelhas."),
            criar("Puxada frontal (pulldown)",
                "https://www.youtube.com/shorts/m3K_hQwD4Qw",
                "Sentado, pegada aberta na barra. Puxe a barra ate a parte alta do peito contraindo as costas e retorne controlando a subida sem soltar de uma vez."),
            criar("Remada curvada com barra",
                "https://www.youtube.com/shorts/M-ssjJ7lgcE",
                "Tronco inclinado a cerca de 45 graus, coluna neutra. Puxe a barra em direcao ao abdomen contraindo as escapulas e desca controlando."),
            criar("Leg press 45",
                "https://www.youtube.com/shorts/jhivJgnM3JE",
                "Pes na plataforma na largura dos ombros. Desca flexionando os joelhos ate cerca de 90 graus sem tirar o quadril do apoio e empurre de volta sem travar os joelhos."),
            criar("Cadeira extensora",
                "https://www.youtube.com/shorts/u-MGUN8woow",
                "Sentado, tornozelos atras do apoio. Estenda os joelhos ate quase a extensao total contraindo o quadriceps e retorne controlando o peso."),
            criar("Rosca martelo com halteres",
                "https://www.youtube.com/shorts/0rRpv6o140o",
                "Em pe, halteres em posicao neutra com o polegar para cima. Flexione os cotovelos elevando os halteres sem girar os antebracos, mantendo os cotovelos junto ao corpo. Contraia biceps e braquiorradial no topo e desca devagar resistindo ao peso."),
            criar("Elevacao lateral com halteres",
                "https://www.youtube.com/shorts/ot9nwSC1JnA",
                "Em pe ou sentado, halteres ao lado do corpo com leve flexao nos cotovelos. Eleve os bracos lateralmente ate a altura dos ombros sem usar impulso do tronco. Concentre na contracao do deltoide lateral e retorne controlando a descida."),
            criar("Supino inclinado com halteres",
                "https://www.youtube.com/shorts/njXvYE8l2ho",
                "Banco entre 30 e 45 graus. Halteres na altura dos ombros com cotovelos levemente abertos. Empurre os halteres para cima aproximando-os no topo sem travar os cotovelos. Desca controlando ate o nivel do peitoral superior, sentindo o alongamento."),
            criar("Crucifixo na maquina (voador)",
                "https://www.youtube.com/shorts/MENdoLpyj7c",
                "Ajuste o banco e os apoios na altura dos ombros. Com cotovelos levemente flexionados, una os bracos a frente do peito contraindo o peitoral no encontro dos apoios. Retorne controlando sem deixar o peso bater no fim do movimento."),
            criar("Cadeira flexora",
                "https://www.youtube.com/shorts/T46yKiz8laY",
                "Ajuste o eixo da maquina alinhado com os joelhos e sente com costas apoiadas. Coloque os tornozelos atras do apoio e flexione os joelhos trazendo os calcanhares em direcao aos gluetos, contraindo o posterior de coxa no final. Retorne controlando sem travar os joelhos.")
        );

        Map<String, Exercicio> existentesPorNome = er.findAll().stream()
                .filter(e -> e.getNome() != null)
                .collect(Collectors.toMap(
                        e -> e.getNome().trim().toLowerCase(),
                        e -> e,
                        (a, b) -> a));

        // Insere os que ainda nao existem
        List<Exercicio> faltando = base.stream()
                .filter(e -> !existentesPorNome.containsKey(e.getNome().trim().toLowerCase()))
                .collect(Collectors.toList());

        if (!faltando.isEmpty()) {
            er.saveAll(faltando);
        }

        // Atualiza links desatualizados nos exercicios ja existentes
        List<Exercicio> paraAtualizar = base.stream()
                .map(b -> {
                    Exercicio ex = existentesPorNome.get(b.getNome().trim().toLowerCase());
                    if (ex != null && !b.getLinkYoutube().equals(ex.getLinkYoutube())) {
                        ex.setLinkYoutube(b.getLinkYoutube());
                        return ex;
                    }
                    return null;
                })
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        if (!paraAtualizar.isEmpty()) {
            er.saveAll(paraAtualizar);
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
