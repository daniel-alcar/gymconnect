/// Linha de exercício do formulário de "Criar Treino" (perfil CLIENTE).
///
/// O professor SELECIONA um exercício existente da biblioteca (idExercicio) e
/// informa apenas séries / repetições / carga.
class ExercicioForm {
  int? idExercicio;
  String series;
  String repeticoes;
  String carga;

  ExercicioForm({
    this.idExercicio,
    this.series = '',
    this.repeticoes = '',
    this.carga = '',
  });

  int? get serieInt => int.tryParse(series.trim());
  int? get repeticaoInt => int.tryParse(repeticoes.trim());
  int? get cargaInt => int.tryParse(carga.trim());

  bool get valido => idExercicio != null;
}
