import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/data/model/user_model.dart';
import 'package:corp_app/domain/service/user_service.dart';
import 'package:corp_app/presentation/old/widget/custom_text_field/custom_text_field.dart';
import 'package:flutter/material.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key, required this.corpId});

  final String corpId;

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _workers = [];
  bool _isLoading = false;
  bool _isAdding = false;
  String _searchQuery = '';

  List<UserModel> get _filteredWorkers {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return _workers;

    return _workers.where((user) {
      return user.login.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.id.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final workers = await UserService.getAllUsersInCorp(
        corpId: widget.corpId,
      );

      if (!mounted) return;

      setState(() {
        _workers = workers;
      });
    } catch (e) {
      if (!mounted) return;
      _showMessage('Не удалось загрузить сотрудников: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAddDialog() async {
    final emailController = TextEditingController();
    bool submitted = false;

    try {
      final email = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          void submit() {
            if (submitted) return;

            submitted = true;
            Navigator.of(dialogContext).pop(emailController.text.trim());
          }

          return AlertDialog(
            title: const Text('Добавить сотрудника'),
            iconColor: AppColor.green,
            content: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Электронная почта',
                hintText: 'worker@example.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => submit(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Отмена'),
              ),
              FilledButton(onPressed: submit, child: const Text('Добавить')),
            ],
          );
        },
      );

      if (!mounted || email == null || email.isEmpty) return;

      if (!email.contains('@') ||
          email.startsWith('@') ||
          email.endsWith('@')) {
        _showMessage('Введите корректный email');
        return;
      }

      await _addWorker(email);
    } finally {
      emailController.dispose();
    }
  }

  Future<void> _addWorker(String email) async {
    if (_isAdding) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final success = await UserService.setUserInCorpByEmail(
        corpId: widget.corpId,
        userEmail: email,
      );

      if (!mounted) return;

      if (success) {
        _showMessage('Сотрудник добавлен');
        await _loadWorkers();
      } else {
        _showMessage('Не удалось добавить сотрудника. Проверьте email.');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Ошибка при добавлении сотрудника: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  Future<void> _confirmDelete(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Удалить сотрудника?'),
          content: Text(
            'Вы действительно хотите удалить ${user.login} '
            'из списка сотрудников?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      final success = await UserService.deleteUserInCorpById(
        corpId: widget.corpId,
        userId: user.id,
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _workers.removeWhere((worker) => worker.id == user.id);
        });

        _showMessage('Сотрудник удалён');
      } else {
        _showMessage('Не удалось удалить сотрудника');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Ошибка при удалении: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _buildWorkerTile(UserModel user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColor.green.withValues(alpha: 0.15),
          child: Text(
            _initials(user.login.isNotEmpty ? user.login : user.email),
            style: TextStyle(
              color: AppColor.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.login.isEmpty ? 'Без имени' : user.login,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user.email.isEmpty ? 'Email не указан' : user.email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              'ID: ${user.id}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
        trailing: IconButton(
          tooltip: 'Удалить сотрудника',
          onPressed: () => _confirmDelete(user),
          icon: const Icon(Icons.person_remove_outlined, color: Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workers = _filteredWorkers;

    return Scaffold(
      floatingActionButton: Column(
        children: [
          SizedBox(height: 350),
          FloatingActionButton.extended(
            onPressed: _isAdding ? null : _showAddDialog,
            backgroundColor: AppColor.green,
            foregroundColor: Colors.white,
            icon: _isAdding
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.person_add_alt_1),
            label: Text(_isAdding ? 'Добавление...' : 'Добавить'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: CustomTextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              hint: 'Поиск email',
              prefixIcon: const Icon(Icons.search),
              focusedBorderColor: AppColor.green,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.groups_outlined),
                const SizedBox(width: 8),
                Text(
                  'Сотрудников: ${_workers.length}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading && _workers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadWorkers,
                    child: workers.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 30),
                              Icon(
                                _searchQuery.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.people_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Сотрудники не найдены'
                                      : 'Пока нет сотрудников',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              if (_searchQuery.isEmpty) ...[
                                const SizedBox(height: 8),
                                const Center(
                                  child: Text(
                                    'Нажмите «Добавить», чтобы пригласить '
                                    'сотрудника по email.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: workers.length,
                            itemBuilder: (context, index) {
                              return _buildWorkerTile(workers[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
