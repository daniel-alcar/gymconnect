-- Atualiza os links do YouTube dos exercicios de carga
-- Execute este script no banco gymconnect para aplicar imediatamente,
-- sem precisar reiniciar o backend.
-- Na proxima inicializacao do backend o ExercicioSeeder fara a mesma atualizacao automaticamente.

USE gymconnect;

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/watch?v=fG_03xSzT2s'
WHERE LOWER(TRIM(nome)) = 'supino reto com barra';

UPDATE exercicios SET link_youtube = 'https://www.youtube.com/watch?v=8NpZd19SlpY'
WHERE LOWER(TRIM(nome)) = 'levantamento terra';

UPDATE exercicios SET link_youtube = 'https://youtu.be/4L5nBs8Eq7g?is=l2ohml3xBGvl1vB0'
WHERE LOWER(TRIM(nome)) = 'agachamento livre';

UPDATE exercicios SET link_youtube = 'https://youtu.be/FHyZEuRpSg4?is=mI57N1Viwn5ErfGO'
WHERE LOWER(TRIM(nome)) = 'rosca direta com barra';

UPDATE exercicios SET link_youtube = 'https://youtu.be/cQ5ae1dHTAQ?is=UVCEJjpnx9_Gmu3q'
WHERE LOWER(TRIM(nome)) = 'triceps na polia (corda)';

UPDATE exercicios SET link_youtube = 'https://youtu.be/rH-ns_GJM3U?is=LMonwsrgSSjKUlmH'
WHERE LOWER(TRIM(nome)) = 'desenvolvimento de ombros com halteres';

UPDATE exercicios SET link_youtube = 'https://youtu.be/YywSCu4Y360?is=i8N3s_AN9Bj_YPSB'
WHERE LOWER(TRIM(nome)) = 'puxada frontal (pulldown)';

UPDATE exercicios SET link_youtube = 'https://youtu.be/HpvaOR4H5Hg?is=3gb24aEknlG-aHhJ'
WHERE LOWER(TRIM(nome)) = 'remada curvada com barra';

UPDATE exercicios SET link_youtube = 'https://youtu.be/adPY6cd4h58?is=wkSTq-8poULytsDF'
WHERE LOWER(TRIM(nome)) = 'leg press 45';

UPDATE exercicios SET link_youtube = 'https://youtu.be/I_uBK4DDflU?is=YUv_0XUTzfpQyMCj'
WHERE LOWER(TRIM(nome)) = 'cadeira extensora';
