import 'package:get/get.dart';
import 'package:users_auth/data/repositories/auth_repository.dart';

import 'package:users_auth/model/user_model.dart';
import 'package:users_auth/data/repositories/user_repository.dart';

class UserController extends GetxController {
  final UserRepository repository;
  final AuthRepository authRepository;

  UserController({
    required this.repository,
    required this.authRepository,
  });

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final userId = await authRepository.getCurrentUserId();
      if (userId == null) throw Exception('Sesión no iniciada');

      final fetchedUsers = await repository.getUsers(userId);
      users.assignAll(fetchedUsers);
    } catch (e) {
      error.value = e.toString();
      users.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addUser(UserModel user) async {
    try {
      final userId = await authRepository.getCurrentUserId();
      if (userId == null) throw Exception('No hay sesión activa');

      final userWithOwner = UserModel(
        id: user.id,
        username: user.username,
        email: user.email,
        userId: userId,
      );

      final newUser = await repository.createUser(userWithOwner);
      users.add(newUser);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await repository.deleteUser(userId);
      users.removeWhere((user) => user.id == userId);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> updateUser(String userId, UserModel updatedUser) async {
    try {
      final user = await repository.updateUser(userId, updatedUser);
      final index = users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        users[index] = user;
      }
    } catch (e) {
      error.value = e.toString();
    }
  }
}
