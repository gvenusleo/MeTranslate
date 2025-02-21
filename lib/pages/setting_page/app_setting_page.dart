import "package:flutter/material.dart";
import "package:launch_at_startup/launch_at_startup.dart";
import "package:lex/global.dart";
import "package:lex/providers/theme_provider.dart";
import "package:lex/utils/font_utils.dart";
import "package:lex/widgets/list_tile_group_title.dart";
import "package:local_notifier/local_notifier.dart";
import "package:provider/provider.dart";
import "package:window_manager/window_manager.dart";

/// 应用设置页面
class AppSettingPage extends StatefulWidget {
  const AppSettingPage({super.key});

  @override
  State<AppSettingPage> createState() => _AppSettingPageState();
}

class _AppSettingPageState extends State<AppSettingPage> {
  final List<String> _themeModes = [
    "跟随系统",
    "浅色模式",
    "深色模式",
  ];
  // 窗口透明度
  late double _windowOpacity;
  // 窗口是非跟随鼠标
  late bool _windowFllowCursor;
  // 是否开机自启动
  bool _launchAtStartup = false;
  // 启动时隐藏窗口
  late bool _hideWindowAtStartup;
  // 使用代理
  bool _useProxy = prefs.getBool("useProxy") ?? false;
  // 代理地址
  final String _proxyAddress = prefs.getString("proxyAddress") ?? "";

  final TextEditingController _proxyAddressController = TextEditingController();

  @override
  void initState() {
    launchAtStartup.isEnabled().then((value) {
      setState(() {
        _launchAtStartup = value;
      });
    });
    _windowOpacity = prefs.getDouble("windowOpacity") ?? 1.0;
    _windowFllowCursor = prefs.getBool("windowFollowCursor") ?? false;
    _hideWindowAtStartup = prefs.getBool("hideWindowAtStartup") ?? false;
    _proxyAddressController.text = _proxyAddress;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("应用设置"),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 18),
        children: [
          const ListTileGroupTitle(title: "主题设置"),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text("主题背景"),
            subtitle: const Text("设置应用主题背景"),
            trailing: Text(
              _themeModes[context.watch<ThemeProvider>().themeMode],
              style: const TextStyle(fontSize: 16),
            ),
            onTap: setThemeMode,
          ),
          ListTile(
            leading: const Icon(Icons.font_download_outlined),
            title: const Text("全局字体"),
            subtitle: const Text("设置应用界面字体"),
            trailing: Text(
              context.watch<ThemeProvider>().fontFamily == "system"
                  ? "默认字体"
                  : context.watch<ThemeProvider>().fontFamily.split(".").first,
              style: const TextStyle(fontSize: 16),
            ),
            onTap: setGlobalFont,
          ),
          SwitchListTile(
            value: context.watch<ThemeProvider>().useSystemThemeColor,
            onChanged: (value) async {
              context.read<ThemeProvider>().changeUseSystemAccentColor(value);
            },
            secondary: const Icon(Icons.color_lens_outlined),
            title: const Text("使用系统主题颜色"),
            subtitle: const Text("应用主题颜色跟随系统"),
          ),
          ListTile(
            leading: const Icon(Icons.opacity_outlined),
            title: const Text("窗口透明度"),
            subtitle: const Text("设置应用窗口透明度"),
            trailing: SizedBox(
              width: 140,
              child: Slider(
                value: _windowOpacity,
                min: 0.5,
                max: 1.0,
                divisions: 5,
                label: _windowOpacity.toStringAsFixed(1),
                onChanged: (value) async {
                  setState(() {
                    _windowOpacity = value;
                  });
                  prefs.setDouble("windowOpacity", value);
                  windowManager.setOpacity(value);
                },
              ),
            ),
          ),
          const ListTileGroupTitle(title: "窗口设置"),
          SwitchListTile(
            value: _windowFllowCursor,
            onChanged: (value) async {
              setState(() {
                _windowFllowCursor = value;
              });
              await prefs.setBool("windowFollowCursor", value);
            },
            secondary: const Icon(Icons.window_outlined),
            title: const Text("窗口跟随鼠标"),
            subtitle: const Text("划词翻译时窗口跟随鼠标"),
          ),
          SwitchListTile(
            value: _launchAtStartup,
            onChanged: (value) async {
              setState(() {
                _launchAtStartup = value;
              });
              if (value == true) {
                await launchAtStartup.enable();
              } else {
                await launchAtStartup.disable();
              }
            },
            secondary: const Icon(Icons.open_in_new_outlined),
            title: const Text("开机自启动"),
            subtitle: const Text("登录系统时自动启动"),
          ),
          SwitchListTile(
            value: _hideWindowAtStartup,
            onChanged: (value) async {
              setState(() {
                _hideWindowAtStartup = value;
              });
              await prefs.setBool("hideWindowAtStartup", value);
            },
            secondary: const Icon(Icons.visibility_off_outlined),
            title: const Text("启动时隐藏窗口"),
            subtitle: const Text("启动应用时自动隐藏到系统托盘"),
          ),
          const ListTileGroupTitle(title: "网络设置"),
          SwitchListTile(
            value: _useProxy,
            onChanged: (value) async {
              if (value == true &&
                  (prefs.getString("proxyAddress") ?? "").isEmpty) {
                LocalNotification notification = LocalNotification(
                  title: "Lex",
                  body: "请先设置代理地址！",
                  actions: [
                    LocalNotificationAction(
                      text: "确定",
                    ),
                  ],
                );
                notification.show();
                return;
              }
              setState(() {
                _useProxy = value;
              });
              await prefs.setBool("useProxy", value);
            },
            secondary: const Icon(Icons.travel_explore_outlined),
            title: const Text("使用代理"),
            subtitle: const Text("使用代理服务器进行翻译"),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 54, right: 28),
            child: TextField(
              controller: _proxyAddressController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "代理地址",
                prefixText: "http://",
              ),
              onChanged: (value) {
                prefs.setString("proxyAddress", value);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 设置主题模式
  Future<void> setThemeMode() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.dark_mode_outlined),
          title: const Text("主题背景"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _themeModes.map((e) {
              return RadioListTile(
                value: _themeModes.indexOf(e),
                groupValue: context.watch<ThemeProvider>().themeMode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<ThemeProvider>().changeThemeMode(value);
                    Navigator.pop(context);
                  }
                },
                title: Text(e),
              );
            }).toList(),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("取消"),
            ),
          ],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 12,
          ),
          scrollable: true,
        );
      },
    );
  }

  /// 设置全局字体
  Future<void> setGlobalFont() async {
    List<String> fonts = await readAllFont();
    fonts.insert(0, "system");
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setFontState) {
          return AlertDialog(
            icon: const Icon(Icons.font_download_outlined),
            title: const Text("全局字体"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ...fonts.map((e) {
                  if (e == "system") {
                    return RadioListTile(
                      value: e,
                      groupValue: context.watch<ThemeProvider>().fontFamily,
                      onChanged: (value) {
                        if (value != null) {
                          context.read<ThemeProvider>().changeFontFamily(value);
                          Navigator.pop(context);
                        }
                      },
                      title: const Text("默认字体"),
                    );
                  }
                  return RadioListTile(
                    value: e,
                    groupValue: context.watch<ThemeProvider>().fontFamily,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<ThemeProvider>().changeFontFamily(value);
                        Navigator.pop(context);
                      }
                    },
                    title: Text(
                      e.split(".").first,
                      style: TextStyle(fontFamily: e),
                    ),
                    secondary: IconButton(
                      onPressed: () async {
                        /* 删除字体 */
                        if (context.read<ThemeProvider>().fontFamily == e) {
                          context
                              .read<ThemeProvider>()
                              .changeFontFamily("system");
                        }
                        await deleteFont(e);
                        setFontState(() {
                          fonts.remove(e);
                        });
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: FilledButton.tonalIcon(
                      onPressed: () async {
                        await loadLocalFont();
                        readAllFont().then((value) {
                          fonts = value;
                          fonts.insert(0, "system");
                          setFontState(() {});
                        });
                      },
                      icon: const Icon(Icons.add_outlined),
                      label: const Text("导入字体"),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("取消"),
              ),
            ],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 12,
            ),
            scrollable: true,
          );
        });
      },
    );
  }
}
