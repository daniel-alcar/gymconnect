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
                "https://www.youtube.com/watch?v=rT7DgCr-3pg",
                "Deite no banco com os pes apoiados no chao. Segure a barra um pouco mais que a largura dos ombros. Desca a barra ate a linha do peito controlando o movimento e empurre de volta sem travar os cotovelos."),
            criar("Agachamento livre",
                "https://youtu.be/4L5nBs8Eq7g?is=l2ohml3xBGvl1vB0",
                "Pes na largura dos ombros, barra apoiada no trapezio. Desca flexionando quadril e joelhos mantendo a coluna neutra ate as coxas ficarem paralelas ao chao e suba empurrando pelos calcanhares."),
            criar("Levantamento terra",
                "https://www.youtube.com/watch?v=op9kVnSso6Q",
                "Barra rente as canelas, pegada na largura dos ombros. Mantenha a coluna reta, peito aberto e suba estendendo quadril e joelhos ao mesmo tempo. Desca controlando, sem arredondar as costas."),
            criar("Rosca direta com barra",
                "https://youtu.be/FHyZEuRpSg4?is=mI57N1Viwn5ErfGO",
                "Em pe, cotovelos junto ao corpo. Flexione os cotovelos elevando a barra ate a altura dos ombros e desca devagar. Evite balancar o tronco para nao usar impulso."),
            criar("Triceps na polia (corda)",
                "https://youtu.be/cQ5ae1dHTAQ?is=UVCEJjpnx9_Gmu3q",
                "De frente para a polia alta, cotovelos fixos ao lado do corpo. Estenda os antebracos para baixo abrindo a corda no final e retorne controlando."),
            criar("Desenvolvimento de ombros com halteres",
                "https://youtu.be/rH-ns_GJM3U?is=LMonwsrgSSjKUlmH",
                "Sentado com as costas apoiadas, halteres na altura dos ombros. Empurre para cima ate quase estender os cotovelos e desca controlando ate a linha das orelhas."),
            criar("Puxada frontal (pulldown)",
                "https://youtu.be/YywSCu4Y360?is=i8N3s_AN9Bj_YPSB",
                "Sentado, pegada aberta na barra. Puxe a barra ate a parte alta do peito contraindo as costas e retorne controlando a subida sem soltar de uma vez."),
            criar("Remada curvada com barra",
                "https://youtu.be/HpvaOR4H5Hg?is=3gb24aEknlG-aHhJ",
                "Tronco inclinado a cerca de 45 graus, coluna neutra. Puxe a barra em direcao ao abdomen contraindo as escapulas e desca controlando."),
            criar("Leg press 45",
                "https://youtu.be/adPY6cd4h58?is=wkSTq-8poULytsDF",
                "Pes na plataforma na largura dos ombros. Desca flexionando os joelhos ate cerca de 90 graus sem tirar o quadril do apoio e empurre de volta sem travar os joelhos."),
            criar("Cadeira extensora",
                "https://youtu.be/I_uBK4DDflU?is=YUv_0XUTzfpQyMCj",
                "Sentado, tornozelos atras do apoio. Estenda os joelhos ate quase a extensao total contraindo o quadriceps e retorne controlando o peso.")
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
