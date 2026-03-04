with open("lib/main.dart", "r", encoding="utf-8") as f:
    text = f.read()

text = text.replace("import 'providers/locale_provider.dart';", "import 'providers/locale_provider.dart';\nimport 'providers/auth_provider.dart';")

old_runapp = """  runApp(
    ProviderScope(
      child: MyApp(localStore: localStore),
    ),
  );"""

new_runapp = """  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(localStore),
      ],
      child: MyApp(localStore: localStore),
    ),
  );"""

text = text.replace(old_runapp, new_runapp)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(text)
