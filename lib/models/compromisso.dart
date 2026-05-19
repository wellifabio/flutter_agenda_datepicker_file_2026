class Compromisso {
  DateTime quando;
  String descricao;
  int? id;
  int? status;

  Compromisso(this.quando, this.descricao, [this.id, this.status]);

  String toCSV() {
    return '$quando;$descricao;$status';
  }
}
