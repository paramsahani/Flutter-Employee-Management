import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/core/theme/colorTheme_Type.dart';
import 'package:my_app/data/models/user_model.dart';
import 'package:my_app/presentation/providers/auth_provider.dart';
import 'package:my_app/presentation/providers/employee_provider.dart';
import 'package:my_app/presentation/widgets/app_router.dart';
import 'package:provider/provider.dart';
import 'package:my_app/presentation/providers/themeProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///  INIT HIVE
  await Hive.initFlutter();

  ///  SAFE ADAPTER REGISTER
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserModelAdapter());
  }

  ///  SAFE BOX OPEN
  if (!Hive.isBoxOpen('users')) {
    await Hive.openBox<UserModel>('users');
  }
  await Hive.openBox('employees');

  ///  THEME INIT
  final themeProvider = ThemeProvider();
  await themeProvider.init(ColorTheme.light);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),

        ///  AUTH PROVIDER
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final auth = context.read<AuthProvider>();
    await auth.checkLogin(); // WAIT properly

    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    ///  LOADER UNTIL SESSION LOAD
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      routerConfig: router,
    );
  }
}
