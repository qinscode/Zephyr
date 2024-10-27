// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

// Models
import 'models/notes_model.dart';
import 'models/tasks_model.dart';
import 'models/folder_model.dart';
import 'models/settings_model.dart';
import 'models/trash_model.dart';

// Services
import 'services/storage_service.dart';
import 'services/search_service.dart';

// Screens
import 'screens/home_screen.dart';

// Theme
import 'theme/app_theme.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化共享首选项
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 运行应用
  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 注册所有需要的Provider
        ChangeNotifierProvider(
          create: (_) => NotesModel(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => TasksModel(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => FolderModel(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsModel(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => TrashModel(storageService),
        ),
        // 注册Search Service
        Provider(
          create: (_) => SearchService(),
        ),
      ],
      child: Consumer<SettingsModel>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Notes App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            debugShowCheckedModeBanner: false,
            home: const HomeScreen(),
            builder: (context, child) {
              return MediaQuery(
                // 设置文字缩放比例
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: settings.fontSize.scale,
                ),
                child: child!,
              );
            },
            localizationsDelegates: const [
              // 添加本地化支持
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('zh', 'CN'),
            ],
          );
        },
      ),
    );
  }
}

// 定义一个全局键用于访问Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 定义一个用于处理返回按钮的Wrapper Widget
class BackButtonInterceptor extends StatelessWidget {
  final Widget child;

  const BackButtonInterceptor({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 获取当前路由信息
        final currentRoute = ModalRoute.of(context);
        if (currentRoute?.isFirst ?? false) {
          // 如果是首页，显示退出确认对话框
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App?'),
              content: const Text('Are you sure you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          return shouldExit ?? false;
        }
        return true;
      },
      child: child,
    );
  }
}

// 错误处理Widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({
    super.key,
    required this.child,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Error? _error;

  @override
  void initState() {
    super.initState();
    ErrorWidget.builder = (FlutterErrorDetails details) {
      setState(() {
        _error = details.exception as Error;
      });
      return Container(); // 返回空容器防止更多错误
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Material(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Oops! Something went wrong.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error.toString(),
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                    });
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}