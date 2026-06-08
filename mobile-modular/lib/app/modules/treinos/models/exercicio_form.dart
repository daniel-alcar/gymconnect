/// Linha de exercício do formulário de "Criar Treino" (perfil CLIENTE).
///
/// Modelo de entrada da UI — convertido para chamadas de API no repository.
class ExercicioForm {
  String nome;
  String series;
  String repeticoes;
  String carga;
  String video;

  ExercicioForm({
    this.nome = '',
    this.series = '',
    this.repeticoes = '',
    this.carga = '',
    this.video = '',
  });

  int? get serieInt => int.tryParse(series.trim());
  int? get repeticaoInt => int.tryParse(repeticoes.trim());
  int? get cargaInt => int.tryParse(carga.trim());

  bool get valido => nome.trim().isNotEmpty;
}
