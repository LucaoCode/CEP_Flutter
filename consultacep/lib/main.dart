import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    title: 'Consulta CEP',
    home: ConsultaCepPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class ConsultaCepPage extends StatefulWidget {
  @override
  _ConsultaCepPageState createState() => _ConsultaCepPageState();
}

class _ConsultaCepPageState extends State<ConsultaCepPage> {
  final TextEditingController _cepController = TextEditingController();
  String _resultado = '';

  Future<void> _consultarCep() async {
    final cep = _cepController.text.trim();

    if (cep.length != 8 || int.tryParse(cep) == null) {
      setState(() {
        _resultado = 'CEP inválido. Digite 8 números.';
      });
      return;
    }

    final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('erro')) {
          setState(() {
            _resultado = 'CEP não encontrado.';
          });
        } else {
          setState(() {
            _resultado = '''
CEP: ${data['cep']}
Logradouro: ${data['logradouro']}
Bairro: ${data['bairro']}
Cidade: ${data['localidade']}
UF: ${data['uf']}
          ''';
          });
        }
      } else {
        setState(() {
          _resultado = 'Erro na consulta. Código: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _resultado = 'Erro na conexão.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Consulta de CEP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cepController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Digite o CEP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _resultado,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _consultarCep,
        child: Icon(Icons.search),
        tooltip: 'Consultar CEP',
      ),
    );
  }
}
