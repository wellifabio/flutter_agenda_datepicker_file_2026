import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class GerenciaArquivo {
  static Future<String> get _caminhoLocal async {
    final diretorio = await getApplicationDocumentsDirectory();
    return diretorio.path;
  }

  static Future<File> get _arquivoLocal async {
    final caminho = await _caminhoLocal;
    return File('$caminho/compromissos.csv');
  }

  static Future<File> salvarArquivo(String texto) {
    return _arquivoLocal.then((arquivo) => arquivo.writeAsString(texto));
  }

  static Future<String> lerArquivo() async {
    try {
      final arquivo = await _arquivoLocal;
      String conteudo = await arquivo.readAsString();
      return conteudo;
    } catch (e) {
      return '';
    }
  }
}
