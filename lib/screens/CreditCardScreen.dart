import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import necessário para TextInputFormatter
import '../model/creditCard.dart';
import '../db_helper/credit_card.dart';

class CreditCardScreen extends StatefulWidget {
  @override
  _CreditCardScreenState createState() => _CreditCardScreenState();
}

class _CreditCardScreenState extends State<CreditCardScreen> {
  final CreditCardDBHelper dbHelper = CreditCardDBHelper();
  List<CreditCard> cards = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  int? editingCardId;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    cards = await dbHelper.getCards();
    setState(() {});
  }

  void _addOrUpdateCard() async {
    String name = nameController.text;
    String number = numberController.text; // Mantém os espaços
    String cvv = cvvController.text;
    String expiry = expiryController.text;

    // Validação dos campos
    if (name.isEmpty) {
      _showErrorDialog('Nome do Titular não pode estar vazio.');
      return;
    }
    if (number.isEmpty || !RegExp(r"^(\d{4} ){3}\d{4}$").hasMatch(number)) {
      _showErrorDialog(
          'Número do Cartão deve ter 16 dígitos, incluindo espaços.');
      return;
    }
    if (cvv.isEmpty || !RegExp(r"^\d{3,4}$").hasMatch(cvv)) {
      _showErrorDialog('CVV deve ter 3 ou 4 dígitos.');
      return;
    }
    if (expiry.isEmpty ||
        !RegExp(r"^(0[1-9]|1[0-2])\/\d{2}$").hasMatch(expiry)) {
      _showErrorDialog('Data de Vencimento deve estar no formato MM/AA.');
      return;
    }

    // Se todas as validações passarem, prossiga para adicionar ou atualizar
    if (editingCardId == null) {
      await dbHelper.insertCard(CreditCard(
        cardHolderName: name,
        cardNumber: number,
        cvv: cvv,
        expiryDate: expiry,
      ));
    } else {
      await dbHelper.updateCard(CreditCard(
        id: editingCardId,
        cardHolderName: name,
        cardNumber: number,
        cvv: cvv,
        expiryDate: expiry,
      ));
      editingCardId = null; // Reset after update
    }
    _clearFields();
    _loadCards();
  }

  void _clearFields() {
    nameController.clear();
    numberController.clear();
    cvvController.clear();
    expiryController.clear();
    editingCardId = null; // Reset the editing ID
  }

  void _editCard(CreditCard card) {
    nameController.text = card.cardHolderName!;
    numberController.text = card.cardNumber!;
    cvvController.text = card.cvv!;
    expiryController.text = card.expiryDate!;
    editingCardId = card.id; // Set the ID for updating

    _showEditDialog(card);
  }

  void _showEditDialog(CreditCard card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Cartão de Crédito'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Nome do Titular'),
                ),
                TextField(
                  controller: numberController,
                  inputFormatters: [
                    CardNumberInputFormatter()
                  ], // Formatação do número do cartão
                  decoration:
                      const InputDecoration(labelText: 'Número do Cartão'),
                ),
                TextField(
                  controller: cvvController,
                  decoration: const InputDecoration(labelText: 'CVV'),
                ),
                TextField(
                  controller: expiryController,
                  decoration: const InputDecoration(
                      labelText: 'Data de Vencimento (MM/AA)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addOrUpdateCard(); // Chama a função de adicionar ou atualizar
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text('Salvar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content:
              const Text('Você tem certeza que deseja excluir este cartão?'),
          actions: [
            TextButton(
              onPressed: () {
                _deleteCard(id);
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text('Confirmar'),
            ),
            TextButton(
              onPressed: () {
                _clearFields();
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCard(int id) async {
    await dbHelper.deleteCard(id);
    _loadCards();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Cartões de Crédito')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Titular',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: numberController,
              inputFormatters: [
                CardNumberInputFormatter()
              ], // Formatação do número do cartão
              decoration: const InputDecoration(
                labelText: 'Número do Cartão',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cvvController,
              decoration: const InputDecoration(
                labelText: 'CVV',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: expiryController,
              decoration: const InputDecoration(
                labelText: 'Data de Vencimento (MM/AA)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOrUpdateCard,
              child: Text(editingCardId == null
                  ? 'Adicionar Cartão'
                  : 'Atualizar Cartão'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color.fromARGB(255, 32, 145, 250),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _clearFields,
              child: const Text('Limpar Campos'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white, // Cor do texto do botão
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.pink],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(cards[index].cardNumber!,
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                            '${cards[index].expiryDate!}         ${cards[index].cvv!}\n${cards[index].cardHolderName!}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.white),
                                onPressed: () => _editCard(cards[index]),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.white),
                                onPressed: () =>
                                    _showDeleteConfirmation(cards[index].id!),
                              ),
                            ],
                          ),
                        ),
                        // Adicionando a imagem abaixo dos botões
                        Align(
                          alignment: Alignment.centerRight, // Alinha à direita
                          child: Image.asset(
                            'assets/mastercard.png', // Caminho da sua imagem
                            height: 60, // Ajuste a altura conforme necessário
                            fit: BoxFit
                                .cover, // Ajusta a imagem para caber no espaço
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Classe para formatar o número do cartão
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(' ', '');
    if (newText.length > 16) {
      newText = newText.substring(0, 16); // Limita a 16 dígitos
    }
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' '); // Adiciona espaço a cada 4 dígitos
      }
      buffer.write(newText[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
