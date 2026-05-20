class Compromisso {
  DateTime quando;
  String descricao;
  int status;
  int? indice;

  Compromisso(this.quando, this.status, this.descricao, [this.indice]);

  String toCSV() {
    return '$quando,$status,$descricao';
  }
}
