import 'package:appsqlite/db_helper/repository.dart';
import 'package:appsqlite/model/User.dart';

class UserService {
  late Repository _repository;
  UserService() {
    _repository = Repository();
  }
  //Save User
  saveUser(User user) async {
    return await _repository.insertData('users', user.userMap());
  }

  //Read All Users
  Future<List<User>> readAllUsers() async {
    var usersData = await _repository
        .readData('users'); // Assume que isso retorna uma lista de mapas
    return usersData.map<User>((user) {
      return User(
        id: user['id'], // Certifique-se de que 'id' existe no mapa
        name: user['name'],
        contact: user['contact'],
        description: user['description'],
      );
    }).toList();
  }

  //Edit User
  updateUser(User user) async {
    return await _repository.updateData('users', user.userMap());
  }

  deleteUser(userId) async {
    return await _repository.deleteDataById('users', userId);
  }
}
