-- Atualiza os links do YouTube dos exercicios para o formato padronizado (Shorts)
-- Execute este script no banco gymconnect para aplicar imediatamente,
-- sem precisar reiniciar o backend.
-- Na proxima inicializacao do backend o ExercicioSeeder fara a mesma atualizacao automaticamente.

USE gymconnect;

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/G3TTZ5VLTVM'
WHERE LOWER(TRIM(nome)) = 'supino reto com barra';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/3uZE_E11eg4'
WHERE LOWER(TRIM(nome)) = 'agachamento livre';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/DjsLHZ4jxTU'
WHERE LOWER(TRIM(nome)) = 'levantamento terra';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/gOTvVYwY9oI'
WHERE LOWER(TRIM(nome)) = 'rosca direta com barra';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/0TQQyGm4fIc'
WHERE LOWER(TRIM(nome)) = 'triceps na polia (corda)';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/X3gv1x7ICw8'
WHERE LOWER(TRIM(nome)) = 'desenvolvimento de ombros com halteres';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/m3K_hQwD4Qw'
WHERE LOWER(TRIM(nome)) = 'puxada frontal (pulldown)';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/M-ssjJ7lgcE'
WHERE LOWER(TRIM(nome)) = 'remada curvada com barra';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/jhivJgnM3JE'
WHERE LOWER(TRIM(nome)) = 'leg press 45';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/u-MGUN8woow'
WHERE LOWER(TRIM(nome)) = 'cadeira extensora';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/0rRpv6o140o'
WHERE LOWER(TRIM(nome)) = 'rosca martelo com halteres';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/ot9nwSC1JnA'
WHERE LOWER(TRIM(nome)) = 'elevacao lateral com halteres';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/njXvYE8l2ho'
WHERE LOWER(TRIM(nome)) = 'supino inclinado com halteres';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/MENdoLpyj7c'
WHERE LOWER(TRIM(nome)) = 'crucifixo na maquina (voador)';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/shorts/T46yKiz8laY'
WHERE LOWER(TRIM(nome)) = 'cadeira flexora';
