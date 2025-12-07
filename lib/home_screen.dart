import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'todo_model.dart';
import 'database_helper.dart';
import 'login_screen.dart';
import 'counter_provider.dart';
import 'profile_screen.dart';
import 'stream_service.dart';

// ================== WARNA ==================
const Color primaryColor = Color(0xFF9F7AEA);
const Color accentColorOrange = Color(0xFFFF9800);
const Color accentColorPink = Color(0xFFF48FB1);
const Color backgroundColor = Color(0xFFF7F2FF);
const Color bannerColor = Color(0xFF3B417A);

// ================== HOME SCREEN ==================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Animasi Banner
  Color _animatedColor = accentColorOrange;
  double _animatedSize = 50.0;
  Timer? _timer;

  // Stream Service (Broadcast)
  final StreamService _streamService = StreamService();

  // Data User & Todo
  String _username = 'Pengguna';
  List<Todo> todos = [];
  bool isLoading = false;

  DateTime? _lastRefreshTime;
  String selectedFilter = 'Semua';
  final List<String> categories = [
    'Pekerjaan',
    'Pribadi',
    'Belanja',
    'Olahraga',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _initData();

    // Multi-listener
    _streamService.messageStream.listen((event) {
      debugPrint("Listener 1 menerima: $event");
    });
    _streamService.messageStream.listen((event) {
      debugPrint("Listener 2 menerima: $event");
    });

    // Animasi Banner
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _animatedColor = _animatedColor == accentColorOrange
              ? accentColorPink
              : accentColorOrange;
          _animatedSize = _animatedSize == 50.0 ? 60.0 : 50.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamService.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    await _loadUsername();
    await _refreshTodos();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('last_username') ?? 'Pengguna';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _refreshTodos() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.readTodosByUser(_username);
    if (mounted) {
      setState(() {
        todos = data;
        isLoading = false;
        _lastRefreshTime = DateTime.now();
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data from Cache (Local DB)"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> toggleTodoStatus(
      String id, bool currentStatus, Todo todo) async {
    todo.isCompleted = !currentStatus;
    await DatabaseHelper.instance.update(todo);
    _refreshTodos();
  }

  Future<void> deleteTodo(String id) async {
    await DatabaseHelper.instance.delete(id);
    _refreshTodos();
  }

  List<Todo> get filteredTodos {
    return selectedFilter == 'Semua'
        ? todos
        : todos.where((t) => t.category == selectedFilter).toList();
  }

  Widget _buildTodoItem(Todo todo) {
    return Card(
      child: ListTile(
        title: Text(todo.title),
        trailing: IconButton(
          icon: Icon(
            todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: todo.isCompleted ? primaryColor : Colors.grey,
          ),
          onPressed: () => toggleTodoStatus(todo.id, todo.isCompleted, todo),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      height: 150,
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRIORITY HUB',
            style: TextStyle(
              fontSize: _animatedSize,
              fontWeight: FontWeight.w900,
              color: _animatedColor,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Atur tugas Anda, raih produktivitas tertinggi.',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.person, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.wifi_tethering, color: Colors.green),
                onPressed: () {
                  _streamService
                      .sendMessage("Update dari HomeScreen oleh $_username");
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: _logout,
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildBanner(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Consumer<CounterProvider>(
                      builder: (context, counter, _) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text('Counter Global'),
                              Text(
                                counter.count.toString(),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: counter.decrement,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: counter.increment,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                      Column(
                        children: filteredTodos.map(_buildTodoItem).toList(),
                      ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
