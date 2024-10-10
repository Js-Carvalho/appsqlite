import 'package:appsqlite/model/User.dart';
import 'package:appsqlite/services/UserService.dart';
import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userContactController = TextEditingController();
  final TextEditingController _userDescriptionController =
      TextEditingController();
  final UserService _userService = UserService();
  List<User> _userList = [];

  @override
  void initState() {
    super.initState();
    _getAllUsers();
  }

  Future<void> _getAllUsers() async {
    try {
      var users = await _userService.readAllUsers();
      setState(() {
        _userList = users;
      });
    } catch (e) {
      print("Erro ao obter usuários: $e");
    }
  }

  Future<void> _addUser() async {
    if (_userNameController.text.isNotEmpty &&
        _userContactController.text.isNotEmpty &&
        _userDescriptionController.text.isNotEmpty) {
      var user = User(
        name: _userNameController.text,
        contact: _userContactController.text,
        description: _userDescriptionController.text,
      );
      await _userService.saveUser(user);
      _clearFields(); // Limpa os campos após adicionar o usuário
      await _getAllUsers();
    }
  }

  void _clearFields() {
    _userNameController.clear();
    _userContactController.clear();
    _userDescriptionController.clear();
  }

  Future<void> _editUser(User user) async {
    _userNameController.text = user.name ?? '';
    _userContactController.text = user.contact ?? '';
    _userDescriptionController.text = user.description ?? '';

    final result = await showDialog<User?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Usuário'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _userNameController,
                  decoration: const InputDecoration(labelText: 'Usuário'),
                ),
                TextField(
                  controller: _userContactController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _userDescriptionController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                var updatedUser = User(
                  id: user.id,
                  name: _userNameController.text,
                  contact: _userContactController.text,
                  description: _userDescriptionController.text,
                );
                await _userService.updateUser(updatedUser);
                Navigator.pop(context, updatedUser);
              },
              child: const Text('Salvar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await _getAllUsers();
    }
  }

  void _showDeleteConfirmation(int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content:
              const Text('Você tem certeza que deseja excluir este usuário?'),
          actions: [
            TextButton(
              onPressed: () {
                _deleteUser(userId);
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

  Future<void> _deleteUser(int userId) async {
    await _userService.deleteUser(userId);
    await _getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Usuários"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Formulário de Cadastro
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _userContactController,
              decoration: const InputDecoration(labelText: 'Contato'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _userDescriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addUser,
              child: const Text('Adicionar Usuário'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 32, 145, 250),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50), // Full width
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _clearFields,
              child: const Text('Limpar Campos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50), // Full width
              ),
            ),
            const SizedBox(height: 20),
            // Listagem de Usuários
            Expanded(
              child: ListView.builder(
                itemCount: _userList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(_userList[index].name ?? ''),
                      subtitle: Text(_userList[index].contact ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.teal),
                            onPressed: () => _editUser(_userList[index]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _showDeleteConfirmation(_userList[index].id!),
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
