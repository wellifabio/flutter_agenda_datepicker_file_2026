import 'package:table_calendar/table_calendar.dart';

import '../root/file.dart';
import './style/colors.dart';
import '../models/compromisso.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Compromisso> compromissos = [];
  List<Compromisso> agendados = [];
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final Set<DateTime> _selectedDays = {};
  final List<String> status = [
    "Agendado",
    "Concluido",
    "Cancelado",
    "Esquecido",
  ];

  @override
  void initState() {
    carregarCompromissos();
    super.initState();
  }

  void carregarCompromissos() async {
    List<String> linhas = (await GerenciaArquivo.lerArquivo()).split('\n');
    setState(() {
      int indice = 0;
      compromissos = linhas
          .where((linha) => linha.trim().isNotEmpty)
          .map((linha) {
            List<String> partes = linha.split(';');
            if (partes.length >= 3) {
              return Compromisso(
                DateTime.parse(partes[0]),
                partes[1],
                indice++,
                int.parse(partes[2]),
              );
            }
          })
          .whereType<Compromisso>()
          .toList();
    });
    marcarDiasComCompromissos();
  }

  void marcarDiasComCompromissos() async {
    for (int i = 0; i < compromissos.length; i++) {
      setState(() {
        _selectedDays.add(
          DateTime.utc(
            compromissos[i].quando.year,
            compromissos[i].quando.month,
            compromissos[i].quando.day,
          ),
        );
        if (compromissos[i].quando.isBefore(DateTime.now())) {
          compromissos[i].status = 3;
        }
        if (compromissos[i].status == null) {
          agendados.add(compromissos[i]);
        }
      });
    }
  }

  void salvarDados() {
    String conteudo = compromissos.map((c) => c.toCSV()).join('\n');
    GerenciaArquivo.salvarArquivo(conteudo);
    carregarCompromissos();
  }

  void modalCompromisso(String? descricao, DateTime? qdo, int? indice) {
    final controller = TextEditingController(text: descricao);
    DateTime dataSelecionada = qdo ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text(
                indice != null ? 'Editar compromisso' : 'Novo compromisso',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller,
                    style: TextStyle(color: AppColors.p1),
                    onChanged: (value) {
                      descricao = value;
                    },
                    maxLines: null,
                    minLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: "Digite a descrição aqui",
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Quando: ${dataSelecionada.day.toString().padLeft(2, '0')}/${dataSelecionada.month.toString().padLeft(2, '0')}/${dataSelecionada.year} - ${dataSelecionada.hour.toString().padLeft(2, '0')}:${dataSelecionada.minute.toString().padLeft(2, '0')}',
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final data = await showDatePicker(
                        context: context,
                        initialDate: dataSelecionada,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2100),
                      );
                      if (data != null) {
                        dialogSetState(() {
                          dataSelecionada = DateTime(
                            data.year,
                            data.month,
                            data.day,
                            dataSelecionada.hour,
                            dataSelecionada.minute,
                          );
                        });
                      }
                    },
                    child: Text('Selecionar data'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final hora = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: dataSelecionada.hour,
                          minute: dataSelecionada.minute,
                        ),
                      );
                      if (hora != null) {
                        dialogSetState(() {
                          dataSelecionada = DateTime(
                            dataSelecionada.year,
                            dataSelecionada.month,
                            dataSelecionada.day,
                            hora.hour,
                            hora.minute,
                          );
                        });
                      }
                    },
                    child: Text('Selecionar hora'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Preecnha a descrição do compromisso!"),
                        ),
                      );
                    } else {
                      Navigator.of(context).pop();
                      setState(() {
                        final descricao = controller.text.trim();
                        if (indice != null) {
                          compromissos[indice] = Compromisso(
                            dataSelecionada,
                            descricao.isNotEmpty
                                ? descricao
                                : compromissos[indice].descricao,
                          );
                        } else {
                          compromissos.add(
                            Compromisso(dataSelecionada, descricao),
                          );
                        }
                      });
                      salvarDados();
                    }
                  },
                  child: Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void modalExcluir(int indice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Excluir comproisso'),
          content: Text('Tem certeza que deseja excluir este compromisso?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  compromissos.removeAt(indice);
                });
                salvarDados();
              },
              child: Text('Sim'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Não'),
            ),
          ],
        );
      },
    );
  }

  void modalCompromissos(DateTime? dia) {
    List<dynamic> lista = dia != null
        ? compromissos
              .where(
                (c) =>
                    c.quando.year == dia.year &&
                    c.quando.month == dia.month &&
                    c.quando.day == dia.day,
              )
              .toList()
        : agendados;
    String titulo = dia != null
        ? 'Compromissos para o dia ${dia.day}'
        : 'Todos os compromissos';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: lista.isEmpty
              ? Text('Não há compromissos agendados para esta data.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.separated(
                    itemBuilder: (context, i) {
                      return ListTile(
                        leading: Text(status[lista[i].status ?? 0]),
                        title: Text(
                          '${DateFormat('dd/MM/yyyy').format(lista[i].quando)} - ${DateFormat('hh:mm').format(lista[i].quando)}',
                        ),
                        subtitle: Text('${lista[i].id} ${lista[i].descricao}'),
                        trailing: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            modalExcluir(lista[i].id);
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.p1,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.delete, color: AppColors.p4),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          modalCompromisso(
                            lista[i].descricao,
                            lista[i].quando,
                            lista[i].id,
                          );
                        },
                      );
                    },
                    shrinkWrap: true,
                    separatorBuilder: (_, _) => Divider(),
                    itemCount: lista.length,
                  ),
                ),
          actions: [
            if (dia != null && dia.isAfter(DateTime.now()))
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  modalCompromisso(null, dia, null);
                },
                child: Text("Agendar"),
              ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Fechar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda de compromissos'),
        actions: [
          GestureDetector(
            onTap: () => modalCompromisso(null, null, null),
            child: Container(
              margin: EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.p4,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: AppColors.p1, size: 35),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TableCalendar(
                locale: 'pt_BR',
                focusedDay: DateTime.now(),
                firstDay: DateTime.utc(2026, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return _selectedDays.contains(day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  modalCompromissos(selectedDay);
                },
              ),
              Text('Do total de ${compromissos.length} você possui'),
              ElevatedButton(
                onPressed: () => modalCompromissos(null),
                child: Text('${agendados.length} compromissos agendados'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
