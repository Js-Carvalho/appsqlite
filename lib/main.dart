import 'package:appsqlite/screens/UserScreen.dart'; // Importar a nova tela de usuários
import 'package:appsqlite/screens/CreditCardScreen.dart'; // Importar a tela de cartões de crédito
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exemplo SQLITE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // Para controlar a aba selecionada

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _getPage(int index) {
      switch (index) {
        case 0:
          return const UserScreen();
        case 1:
          return CreditCardScreen();
        default:
          return const UserScreen();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Métodos do 777"),
      ),
      body: _getPage(_selectedIndex), // Chama a página selecionada
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Usuários',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Cartões',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
