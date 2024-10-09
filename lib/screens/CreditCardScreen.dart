import 'package:flutter/material.dart';
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
    if (nameController.text.isNotEmpty &&
        numberController.text.isNotEmpty &&
        cvvController.text.isNotEmpty &&
        expiryController.text.isNotEmpty) {
      if (editingCardId == null) {
        await dbHelper.insertCard(CreditCard(
          cardHolderName: nameController.text,
          cardNumber: numberController.text,
          cvv: cvvController.text,
          expiryDate: expiryController.text,
        ));
      } else {
        await dbHelper.updateCard(CreditCard(
          id: editingCardId,
          cardHolderName: nameController.text,
          cardNumber: numberController.text,
          cvv: cvvController.text,
          expiryDate: expiryController.text,
        ));
        editingCardId = null; // Reset after update
      }
      nameController.clear();
      numberController.clear();
      cvvController.clear();
      expiryController.clear();
      _loadCards();
    }
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

  void _deleteCard(int id) async {
    await dbHelper.deleteCard(id);
    _loadCards();
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
            SizedBox(height: 10),
            TextField(
              controller: numberController,
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
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(cards[index].cardHolderName!),
                      subtitle: Text(
                          'Número: ${cards[index].cardNumber!}\nVencimento: ${cards[index].expiryDate!}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.teal),
                            onPressed: () => _editCard(cards[index]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCard(cards[index].id!),
                          ),
                        ],
                      ),
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
