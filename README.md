# Architecture

## Modular with Clean Architecture 🫧

```md
- /lib
  - /app
    - /data (always global)
      - /models
      - /repositories
      - /source
    - /modules
      - /module (local domain)
        - /services
        - /views
          - controller.dart
          - page.dart
        - /widgets
        - module.dart
    - /shared (shared domain)
      - /services
      - /utils 
      - /widgets
    - app_module.dart
    - app_routes.dart
    - app_widget.dart
  - main.dart
```

- To know more about Flutter Modular: [Getting Started](https://github.com/branvier-dev/branvier_template.git)

## Getting Started 🔥

### Download Branvier's [Project Template](https://github.com/branvier-dev/branvier_template.git)

The Branvier's **Project Template** already comes with core packages, linter and some examples. Now you just have to install the architecture's core snippets.

Installing Snippets

1. Command: *Snippets: Configure User Snippets*
2. Choose: *New Global Snipper File*
3. Copy 'branvier.code-snippets' in the root of this project

| Snippets        | Description                         |
|-----------------|-------------------------------------|
| gextension      | Generates a Extension on class      |
| grepository     | Generates a Repository class        |
| gserviceapp     | Generates a Service class           |
| gcontroller     | Generates a Controller class        |
| gpage           | Generates a Page class              |
| gmodule         | Generates a Module class            |
| ggetservice     | {1}Service get {2} => Modular.get() |
| ggetcontroller  | {1}Controller {..} => Modular.get() |

> ### That's it, you are ready to go! ✨

## Model

---

A object that represents a entity.

```dart
class User {
  final int id;
  final String name;
  final String? avatar_url; // nullable for optional fields

  User.fromMap(...); //serilializing utils.
}
```

### Extension: [Dart Safe Data Class](https://marketplace.visualstudio.com/items?itemName=ArthurMiranda.dart-safe-data-class)

---

With **Json**

1. Create .dart file and open it.
2. Paste raw json.
3. With the file open: *> Dart Data Class Generator: Generate from JSON*

With **Dart**

![Dart Class .gif](https://github.com/ricardoemerson/dart-data-class-generator/raw/HEAD/assets/gif_from_class.gif)

## Source

The source usually expose simple APIs to perform **CRUD** operations (Create, Read, Update, Delete).
  
```dart
class DioApi extends IApi {// http clint
  final _api = Dio(); //source

  @override
  Future get(String path) async {
    //get from client.
  }
}

class HiveBox extends IBox {// key/value storage
  final _box = HiveBox(); //source

  @override
  Future read(String key) async {
    //read from storage.
  }
}
```

> The `base app` project already has an interface for http and key/value sources: `IApi` & `IBox`. They are included in the template.

## Source Testing

> This template includes `MockApi` and `FakeBox`.

### MockApi

---

> `Mock` simulates a real class, but doesn't implements all it's functions.

```dart
class MockApi extends Mock implements IApi { // `Mock` from mocktail
  @override
  var baseUrl = '';

  @override
  final headers = <String, dynamic>{};
  // get, post, put, delete will throw unimplemented error.
}
```

> Use `mocktail` for implementing `get`, `post`, `put` or `delete`.

```dart
//if Api is Mock, implements `post`.
when(() => api.post(any())).thenReturn({'status': 'sucess'});

//if Api !is Mock, the real implementation will be called as usual.
final data = await api.post('/path', {...}); // -> {'status': 'sucess'}
```

### FakeBox

---
> `Fake` is a full functional implementation for quick testing.

```dart
// use initialData param when a initial storage is needed.
final box = FakeBox({
  'language': 'pt',
  'theme': 'dark',
});

// use `storage` param to check the contents.
print(box.storage['theme']) // -> 'dark'.

// reading/writing is fully functional.
final repository = BookRepository(MockApi(),box);
```

> Both Mock/Fake implements `IApi` & `IBox`. They are included in this template.

### Api Integration Test

---
A integration test verifies the integration between two units. Api Integration test diagnoses our app communication with the Client (connectivity, performance, security and more).

```dart
void main() {
  final isTestUrl = true;

  final api = RealApi();
  final api.baseUrl = isTestUrl ? 'http://test.api.com' : 'http://www.api.com';

  group('Api', () {
    test('post', () async {
      final data = await api.post('/path', {...});

      expect(data['status'], 'sucess');
    });
  });
}
```

> Use this as quick diagnosis for your repositories.
>
## Repository

---

The Repository handles raw data from multiple Sources to Models.

```dart
class UserRepository {
  UserRepository(this._api, this._box, this._safe);

  final IApi _api;
  final IBox _box;
  final IBox _safe;

  static const key = 'user'; //storage's key

  ///Logins user. Gets from api, stores in cache.
  Future<User> login(Json user) async {
    final map = _api.get('/login?user=${user.toJson()}'); //api
    await _box.write(key, jsonEncode(map)); //cache
    return User.fromMap(map); //model
  }

  ///Remembers password. Stores encrypted.
  Future<User> savePassword(String password) async {
    await _safe.write(key, password); //encrypted
  }
}
```

## Repository Test

> For testing we'll be using `mocktail` package.

```dart
void main() {
final isIntegrationTest = false;

  group('UserRepository', () {
    late UserRepository repository;
    late MockBox shared;
    late MockBox safe;
    late MockApi api;

    setUp(() { //create a new instance for each test.
      api = isIntegrationTest ? RealApi() : MockApi();
      shared = FakeBox();
      safe = FakeBox();
      repository = UserRepository(api, shared, safe);
    });

    test('login', () async { 
      when(() => api.get(any())).thenReturn(User(id: 0).toMap()); // if api is Mock
      final user = await repository.login({'email': '@', 'password': '1'});

      //verify the real/mock output.
      expect(user.id, 0);
    });

    test('savePassword', () async {
      await repository.savePassword('123');

      //verify if the FakeBox is correctly writing.
      expect(safe.storage.containsKey(UserRepository.key), true);
      expect(safe.storage[UserRepository.key], '123');
    });
  });
}
```

## State Management - ASP (Atomic State Pattern)

**Logic:** Controller/Service

```dart
/// For primitives (num, bool, enum), use `Atom()`:
final _count = Atom(0);
final _loading = Atom(false);
final _book = Atom<Book?>(null); // init with null

/// For collections (list, set, map), use `.asAtom()`:
final _books = <Book>[].asAtom();
final _library = <String, List<Book>>[].asAtom();

// expose with getters.
int get count => _count.value; 
Book? get book => _user.value; // nullable
List<Book> get books => _user.value;

// setting state.
void increment() => _count.value++; 

// always void.
Future<void> getBooks() async {
  _books.value = await {...}; // _repository.getBooks();
}
```

**View:** Page/Widget

```dart
// reacts to _count.value changes
RxBuilder(
  builder: (context) => Text(controller.count),
); 
```

### AsyncBuilder

---
> Use `AsyncBuilder` for quick building any async value.

```dart
// Build model and show async states (loading, error, success).
AsyncBuilder(
  future: controller.getBooks,
  builder: (books) {
    return ListView.builder(...);
  },
)
```

## WORK IN PROGRESS - Service

---
The Service manages the global business logic of a source.

Reponsabilities:

- Retrieve data from external sources.
- Process data to fit the business rules.
- Save and manage the state of the data globally.

```dart
class UserService extends Disposable { // <-- optional, adds `dispose`
  UserService(this._repository) {
    init();
  }

  //The user of the user is private.
  final _user = User(); // inits with null.

  //It value can be acessed globally.
  User? get user => _user.value;

  ///Initializer for async dependencies.
  Future<void> init() async { //Loads from cache, if any.
    _user.value = await repository.getUser();
  }

  ///Logs the user. Sets the user.
  Future<void> login(Json map, {bool remember = false}) async {
    _user.value = await repository.login(map);
    if (remember) await repository.savePassword(map['password']);
  }

  void dispose() {} // <- optional

}
```

## Controller

---
The Controller manages the local business logic of a view.

### Reponsabilities

- Handle input: gather inputs, validate, clean and send to services.
- Handle outputs: navigation, nests, dialogs, snackbars and bottomsheets.

```dart

class LoginController {

  //Dependencies.
  UserService _userService = Modular.get();

  //States
  final formx = FormController(); // component controller.
  final _isRememberChecked = Atom(false); // component state.

  //Inputs
  bool get isCheck => _isRememberChecked.value; // component getter.
  User get user => _userService.user;

  //Events
  Future<void> onLoginTap() async { // tapped button
    if(formx.validate()) return await _login(formx.form); 
  }
  Future<void> onLoginSubmit(Json map) async => _login(map); // pressed enter

  ///On login event. Logs the user.
  Future<void> _login(Json map) async {
    try { 
      await _user.login(map, remember: isCheck); //handle erros in a try catch block

      //on success
      await Modular.to.navigate('/home'); //pop login

    } on ApiException catch (e) {
      if (e.message != 'API.LOGIN.USER_NOT_FOUND') return;

      //on not found, register
      await Modular.to.pushNamed('/signup'); //keep login

    } catch (e) {
      callDialog('Non identified error. Please call support.'); //on failure

      formx.reset(); //resets ui to clean and maybe try again.
    }
  }
  
}
```

## Module

---
The module binds the business **logic** (Service/Controller) to the **global** view (Page).

```dart
///Binds [MyController] to [MyPage].
class MyModule extends Module {

  @override
  void binds(i) {
    i.addSingleton<IApi>(DioApi.new);
    i.addSingleton<IBox>(HiveBox.new);
    i.addLazySingleton<IUserRepository>(UserRepository.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => HomePage(data: r.args.data));
    r.module('/user', module: UserModule());
  }
}
```

> To know more about Flutter Modular: [Getting Started](https://github.com/branvier-dev/branvier_template.git)

## Navigation

---

In the `app_routes.dart` files lies all the app routes.

```dart
mixin AppRoutes {
  // * User Module
  static const home = '/home/';
  static const books = '/home/books';
  static final book = (id) => '/home/books/$id/';

  // * Auth Module
  static const login = '/auth/login/';
  static const register = '/auth/register/';
}
    
```

## Page

---
The page manages the global view **ui** and **events**.

- Binded to a route.
- Must have a Scaffold.

```dart
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() => LoginPageState();
}


class LoginPageState extends State {
  final controller = LoginController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('login.appbar.title'.tr)),
      body: LoginContainer( // wrap component
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ThemeButtonWidget(), // widget view (not a component)
            const AppLogo(), // leaf component
            Formx(
              controller: controller.formx, // export state to controller
              onSubmit: controller.onLoginSubmit, // event
              child: Column(
                children: [
                  Fieldx.required('email'),
                  Fieldx.required('password'),
                ],
              ),
            ),
            ElevatedButton(
              onTap: controller.onLoginTap, // event
              child: Text('login.form.button'.tr),
            ).async(),
          ],
        ),
      ),
    );
  }
}
```

## Widget

---
The widget manages the local view **ui** and **events**.

- Not binded to any route and can be used by any page.
- When having a `Controller` add the suffix `Widget`

```dart
class ThemeButtonWidget extends StatefulWidget {
  ThemeButtonWidget({super.key});

  @override
  State createState() => ThemeButtonState();
}

class ThemeButtonState extends State {

  // local instance
  final controller = ThemeButtonController();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(54, 180),
        backgroundColor: Colors.purple,
      ),
      onTap: controller.onThemeTap,
      child: Text('theme.button.change'.tr),
    ).async(); // <- flutter_async library
  }
}
```

## Components

---

UI Elements that have **zero** business logic (Service/Controller).

- Encapsulate all styling and layout into specific widgets (stateless).
- Handles animation logic and callback events (stateful).
- Handles ui on async states and exceptions (indicators).

```md
- /widgets:
  - /input (input events: fields, checkbox, buttons)
  - /output (output events: snackbar, sheets, dialogs)
  - /leafs (childless widgets: logo, images, icons, loaders)
  - /wraps (parent widgets: cards, menus)
```

> TODO: Add articles about composites.

## Translation

---

### Setup

```dart
main() async {

  // * Optional configs.
  //
  Translation.setPath(String path) //Defaults to 'assets/translations/'
  Translation.setInitial(Locale locale) //Defaults to system's Locale.
  Translation.setFallback(Locale locale) //Defaults to en_US.
  Translation.setLogger(bool isActive) //Defaults to true.
  Translation.setLazyLoad(bool isLazy) //Defaults to false.

  // Setup.
  {...} => MaterialApp(
    localizationsDelegates: Translation.delegates, // <- just that :)

    //Use this key only if you are not using [flutter_modular]
    navigatorKey: Branvier.navigatorKey, // <- optional
  );

  // 
}
```

Your json files have to be named in the Locale format. Any separator will work. You can also use only the language code, without country code. Ex: es, pt, for neutral languages that works for any country.

```dart
> asset/translations/en_US.dart

{
  "home.button.increment": "Increase 1", 
  "home.button": "Press", 
}

> asset/translations/pt_BR.dart

{
  "home.button.increment": "Somar 1", 
  "home.button": "Aperte", 
}

```

### Translate with `.tr` or `.trn`

- `.tr` Pattern: 'a.b.c' -> 'a.b' -> 'a' -> returns 'a.b.c' if no pattern found.
- `.trn` Pattern: 'a.b.c' -> 'a.b' -> 'a' -> returns null if no pattern found.

```dart
  ElevatedButton(
    onTap: controller.onIncrement,
    child: Text('home.button.increment'.tr), // 'Somar 1'
  ).async(),
  ElevatedButton(
    onTap: controller.onIncrement,
    // Since there is no .decrement. It fallbacks to 'home.button'.tr
    child: Text('home.button.decrement'.tr), // 'Aperte'
  ).async(),

```

### Change Language with `Translate.to.changeLanguage()`

```dart
  ElevatedButton(
    onTap: () async => Translate.to.changeLanguage('en'),
    child: Text('home.button'.tr), // 'Aperte' -> 'Press'
  ).async(),

```

## Naming Conventions

### - Variables

Simply use the `class name`:

- userService
- bookRepository

For states, use the getter as private:

- State: final `_user` = ...;
- Getter: get `user` => _user.value;

### - Functions

Use `get<Value>` when returning data and `on<Value>` on callback events.

For async getter functions: `Future<T> Function()`

- getStories() when T is `<List<Story>>`
- getStory() when T is `<Story>`

For callback functions: `void Function(T value)`

- onRegisterTap() -> void onRegisterTap()
- onStoryTap() -> void onStoryTap(Story story)

For `Repository`, use CRUD base conventions:

- getById(), getAll()
- add(), update()
- deleteById(), deleteAll()
