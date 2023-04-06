# Architecture

## MVC with Clean Architecture 🫧

>Flutter Modular + Getx* approach:

*Getx Reactive State Management only (included in this package).

- The "Model" is broken into Source/Repository/Models.
- All the global and data business-related operations goes to the Service.
- All the local and view business-related operations goes to the Controller.
- The View stays on the presentation layer.

```md
- /lib
  - main.dart
  - /app
    - /data
      - /models
      - /repositories
      - /source
    - /services
      - /app (front-services: theme, translation)
      - /data (back-services: manages entities, ex: user)
    - /modules
      - /module
        - /widgets (local)
        - controller.dart
        - module.dart
        - page.dart
    - /utils
    - /widgets (shared)
    - theme.dart
    - routes.dart
```

- To know more about Flutter Modular: [Getting Started](https://github.com/branvier-dev/branvier_template.git)

## Gettins Started 🔥

---

### Download Branvier's [Project Template](https://github.com/branvier-dev/branvier_template.git)

The Branvier's **Project Template** already comes with everything you need, core packages, linter and some examples. Now you just have to install the architecture's core snippets.

Installing Snippets

1. Command: *Snippets: Configure User Snippets*
2. Choose: *New Global Snipper File*
3. Copy 'branvier.code-snippets' in the root of this project

| Snippets        | Description                         |
|-----------------|-------------------------------------|
| gextension      | Generates a Extension on class      |
| grepository     | Generates a Repository class        |
| gserviceapp     | Generates a App Service class       |
| gservicedata    | Generates a Data Service class      |
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
  final int? id; //prefer nullable
  final String? name;
  final String? email;

  User.fromMap(...); //serilializing utils.
}
```

### Extension: [Dart Data Class Generator](https://marketplace.visualstudio.com/items?itemName=ricardo-emerson.dart-data-class-tools)

---

With **Json**

1. Create .dart file and open it.
2. Paste raw json.
3. With the file open: *> Dart Data Class Generator: Generate from JSON*

With **Dart**

![Dart Class .gif](https://github.com/ricardoemerson/dart-data-class-generator/raw/HEAD/assets/gif_from_class.gif)

## Source

---
The source usually expose simple APIs to perform **CRUD** operations (Create, Read, Update, Delete).
  
```dart
class DioApi extends IApi {// http clint
  final _storage = Dio(); //source

  @override
  Future<T> get<T>(String path) async {
    //get from client.
  }
}

class SharedBox extends IBox {// key/value storage
  final _storage = SharedPreferences(); //source

  @override
  Future<String> read(String key) async {
    //read from storage.
  }
}
```

> The project already has an interface for http and key/value sources: `IApi` & `IBox`. They are included in this package.

## Source Mock

```dart
// you can easily mock any request
MockApi({
  '/login': User(id: 0, name: 'test').toMap(),
  '/user/books': 3.list((i) => Book(id: i).toMap());,
}); 

// you can add a initial fake storage for testing
MockBox({
  'language': 'pt',
  'theme': 'dark',
});
```

> Both Mocks implements `IApi` & `IBox`. They are included in this package.

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

```dart
void main() {

  group('UserRepository', () {
    final shared = MockBox();
    final safe = MockBox();
    final api = MockApi({
      '/login': User(id: '0').toMap(),
    });
    final repository = UserRepository(api, shared, safe);

    setUp(() { //called before any test inside this group.
      shared.reset();
      safe.reset();
    });

    test('login', () async { 
      final user = await repository.login({'email': '@', 'password': '1'});

      //verify the MockApi output.
      expect(user.id, '0');
    });

    test('savePassword', () async {
      await repository.savePassword('123');

      //verify if the MockBox is correctly writing.
      expect(safe.storage.containsKey(UserRepository.key), true);
      expect(safe.storage[UserRepository.key], '123');
    });
  });
}

```

> This approach uses no external packages nor code generators. 🫧

## State Management

---
The package includes GetX reactivity.
We added `.obn`, which is the same as `.obs` with `null` as initial value.

Logic

```dart
// private, must only be modified here.
final _count = 0.obs;
final _user = User().obn; // init with null

// always use getters.
int get count => _count.value; 
User? get user => _user.value; // nullable

// setting state.
void increment() => _count.value++; 
```

View

```dart
Obx(()=> Text(controller.count)); // reacts to _count.value changes
```

### Extension: [GetX Light Bulb](https://marketplace.visualstudio.com/items?itemName=HyLun.getx-light-bulb)

---
Adds these to the context menu (cmd + .):

- Wrap with Obx
- Remove this Obx

## Service

---
The Service manages the global business logic of a source.

Reponsabilities:

- Retrieve data from external sources.
- Process data to fit the business rules.
- Save and manage the state of the data globally.

```dart
//Any operation related to [User] must only be done here.
class UserService {
  UserService(this._repository);

  //The state of the user is private.
  final _state = User().obn; // inits with null.

  //It value can be acessed globally.
  User? get value => _state.value;

  ///Initializer for async dependencies.
  Future<void> init() async { //Loads from cache, if any.
    _state.value = await repository.load();
  }

  ///Logs the user. Sets the state.
  Future<void> login(Json map, {bool remember = false}) async {
    _state.value = await repository.login(map);
    if (remember) await repository.savePassword(map['password']);
  }
}
```

## Controller

---
The Controller manages the local business logic of a view.

### Reponsabilities

- Handle input: gather inputs, validate, clean and send to services.
- Handle outputs: navigation, nests, dialogs, snackbars and bottomsheets.
- Receive requests and treat possible errors/exceptions from services to the ui.
- Single reponsability. Will handle business logic of components. 1 for each business logic.

```dart
//Anything operation related to login the [User] must only be done here.
class LoginController {

  //Dependencies.
  UserService _user = Modular.get();

  //States
  final formx = FormController(); // component controller.
  final _isRememberChecked = false.obs; // component state.

  //Inputs
  bool get isCheck => _isRememberChecked.value; // component getter.

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
  final List<Bind> binds = [
    Bind.lazySingleton<MyController>(
      (i) => MyController(),
      //create onDispose() method on controller.
      onDispose: (controller) => controller.onDispose(),
    ),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, args) => const MyPage()),
  ];
}
```

> To know more about Flutter Modular: [Getting Started](https://github.com/branvier-dev/branvier_template.git)

## Page

---
The page manages the global view **ui** and **events**.

- Binded to a route.
- Must have a Scaffold.
- Expose business logic parameters (events and inputs).
- Omit non-business logic parameters (styling and layout).

```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  /// Get instance of [LoginController].
  LoginController get controller => Modular.get();

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
            FormX(
              controller: controller.formx, // export state to controller
              onSubmit: controller.onLoginSubmit, // event
              child: Column(
                children: [
                  Field.required('email'),
                  Field.required('password'),
                ],
              ),
            ),
            ElevatedButtonX(
              onTap: controller.onLoginTap, // event
              child: Text('login.form.button'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
```

## WidgetModule

---
The widget module binds the business **logic** (Service/Controller) to the **local** view (Widget).

```dart
class ThemeButtonModule extends WidgetModule {
  ThemeButtonModule({super.key}); // add super constructor

  @override
  final List<Bind> binds = [
    Bind.lazySingleton<ThemeButtonController>(
      (i) => ThemeButtonController(),
      //create onDispose() method on controller.
      onDispose: (controller) => controller.onDispose(),
    ),
  ];

  @override
  Widget get view => ThemeButtonWidget(); // use 'Widget' as suffix.
}
```

> To know more about Flutter Modular: [Getting Started](https://github.com/branvier-dev/branvier_template.git)
>
## Widget

---
The widget manages the local view **ui** and **events**.

- Not binded to any route.
- No Scaffold: can be used by any page.
- Expose business logic parameters (events and inputs).
- Omit non-business logic parameters (styling and layout).

```dart
class ThemeButtonWidget extends ThemeButtonModule {
  ThemeButtonWidget({super.key});

  ThemeButtonController get controller => Modular.get();

  @override
  Widget build(BuildContext context) {
    return ElevatedButtonX(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(54, 180),
        backgroundColor: Colors.purple,
      ),
      onTap: controller.onThemeTap,
      child: Text('theme.button.change'.tr),
    );
  }
}
```

> This is really useful when your page gets **too many** features.
> TODO: Add Snippet.

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

  // Init [Translation] before the app starts.
  Translation.init(
    initialLocale: 'pt',
    translations: { // Map<String, Map<String,String>>
      'pt': {
        'home.button.increment': 'Somar 1',
        'home.button': 'Aperte',
      },
      'en': {
        'home.button.increment': 'Add 1',
        'home.button': 'Press',
      },
    }
  );

  // Recommended: You can also load all .json files from asset folder. Ex en.json, etc.
  await Translation.initAsset('pt','assets/translations');

  {...} => MaterialApp();
}
```

### Translate with `.tr` or `.trn`

- `.tr` Pattern: 'a.b.c' -> 'a.b' -> 'a' -> returns 'a.b.c' if no pattern found.
- `.trn` Pattern: 'a.b.c' -> 'a.b' -> 'a' -> returns null if no pattern found.

```dart
  ElevatedButtonX(
    onTap: controller.onIncrement,
    child: Text('home.button.increment'.tr), // 'Somar 1'
  ),
  ElevatedButton(
    onTap: controller.onIncrement,
    // Since there is no .decrement. It fallbacks to 'home.button'.tr
    child: Text('home.button.decrement'.tr), // 'Aperte'
  ),

```

### Change Language with `Translate.changeLanguage()`

```dart
  ElevatedButtonX(
    onTap: () async => Translate.changeLanguage('en'),
    child: Text('home.button'.tr), // 'Aperte' -> 'Press'
  ),

```

## Naming Conventions

---

## Data Functions

The *verb-noun* convention will be used.
Starting a function name with a verb helps to indicate the function action, while the noun indicates the type of data returned.
This convention can make function names more intuitive and easier to understand.
Ex:

### Controller functions

- fetchStories() for Future <List.<Story.>>
- streamStories() for Stream <List.<Story.>>

### Service functions

- From local source: loadUser() / saveUser()
- From external source: getUser() / getUsers()

### Repository function

If the repository only deals with books, then it may be reasonable to use getAll instead of getAllBooks.
Using getAll is specific enough and helps differentiate repository from services functions.

- If the class already defines the entity:
  - From local source: load() / save()
  - From external source:
    - getById(), getAll()
    - add(), update()
    - deleteById(), deleteAll()

## Callback Functions

The *noun-verb* convention with 'on' preposition will be used.
The 'on' suggests that the action will happen after an event.
The noun describes the entity and the verb describes the action.

## Widget callbacks

- onTap() for VoidCallback aka void Function()

Controller callbacks:

- onStoryTap() for void Function(Story story)
- onFormSubmit() for void Function(Map form)
- onNameChange() for void Function(String name)
