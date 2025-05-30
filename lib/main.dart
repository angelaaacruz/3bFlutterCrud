import 'package:flutter/material.dart';
import 'user_model.dart';
import 'api_service.dart';

void main() {
  runApp(MaterialApp(home: const UserScreen()));
}

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  UserScreenState createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  late Future<List<User>> futureUsers;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  int? editingId;

  @override
  void initState() {
    super.initState();
    futureUsers = ApiService.getUsers();
  }

  void refreshUsers() {
    setState(() {
      futureUsers = ApiService.getUsers();
    });
  }

  void handleSave() async {
    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    if (editingId == null) {
      await ApiService.addUser(username, email, password);
    } else {
      await ApiService.updateUser(editingId!, username, email, password);
      editingId = null;
    }

    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    refreshUsers();
  }

  void handleEdit(User user) {
    setState(() {
      editingId = user.id;
      usernameController.text = user.username;
      emailController.text = user.email;
      passwordController.text = ''; // Password reset not shown
    });
  }

  void handleDelete(int id) async {
    await ApiService.deleteUser(id);
    refreshUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter CRUD with Express and MySQL")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: "Username"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: handleSave,
                  child: Text(editingId == null ? "Add User" : "Update User"),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: futureUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No Users Found"));
                }
                return ListView(
                  children: snapshot.data!.map((user) {
                    return ListTile(
                      title: Text(user.username),
                      subtitle: Text(user.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => handleEdit(user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => handleDelete(user.id),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
