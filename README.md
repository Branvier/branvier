# Architecture

## MVC with Clean Architecture

The MVC stands for Model-View-Controller. With this idea:

- Model - Handles data operations.
- View - Handles calls/events and presents the ui.
- Controller - Manages business logic.

With Clean:

- The View and Controller are the presentation layer.
- All the global and data business-related operations goes to the Service.
- All the local and view business-related operations goes to the Controller.
- The "Model" is broken into Source/Repository/Models.

Overview:

- Data Layer (Source, Repository, Model).
- Business Logic Layer (Service, Controller).
- Presentation Layer (View, Components)  

Flow:

- Data: **Source** > _Raw Data_ > **Repository** > _Models_
- Logic: _Models_ > **Service** > _Operations_ > **Controllers** > _Events_
- Presenter: _Events_ > **Page** > _Properties_ > **Components**

TLDR:
We can relate all to a Kitchen!

In the Kitchen, we have the **Pantry**, the **Chef**, the **Waiter**, the **Table** and the **Food**.

The same applies to **Repository**, **Service**, **Controller**, **View** and **Model**.

Each one has its own reponsabilities. The **Pantry** doesnt know how to cook, just provides ingredients. The **Chef** takes those to cook the **Food** and send it to the **Waiter**. The **Waiter** sends the **Food** to the **Table**, taking orders and notifying the **Chef** if anything else is needed.

- The data here, are the ingredients who are stored in the **Patry**.
- The business logic layer is handled by the **Chef** only him should be able to do everything related to the **Food**.
- The presenter has the **Table** and the **Waiter** who is responsible to clean, set it up and serve the **Food**.

Folder

```md
- /lib
  - main.dart
  - /app
    - /data
      - /models
      - /repositories
      - /source
    - /services (global)
      - /app (front-services: theme, translation)
      - /data (back-services: manages entities, ex: user)
    - /modules
      - /{...}
        - /widgets (local)
        - /controllers (local)
        - {name}_page.dart
    - /utils
    - /widgets (shared)
    - theme.dart
    - routes.dart
```

### Template

---

> Clone Branvier's [Project Template](https://github.com/branvier-dev/branvier_template.git)

### Snippets

---
> Installing

1. Command: _Snippets: Configure User Snippets_
2. Choose: _New Global Snipper File_
3. Copy 'branvier.code-snippets' in the root of this project

| Snippets    | Description                     |
|-------------|---------------------------------|
| gservice    | Generates a Service class       |
| gcontroller | Generates a Controller class    |
| grepository | Generates a Repository class    |
| gfromlist   | Generates Model.fromList method |

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
3. With the file open: _> Dart Data Class Generator: Generate from JSON_

With **Dart**

![Dart Class .gif](https://github.com/ricardoemerson/dart-data-class-generator/raw/HEAD/assets/gif_from_class.gif)

## Source

---
The source usually expose simple APIs to perform **CRUD** operations (Create, Read, Update, Delete).
  
```dart
class Api extends IApi {
  Future<Json> get(String path) async {
    //read from database or network request.
  }
}
```

## Repository

---

The Repository handles raw data from multiple Sources to Models.

```dart
class UserRepository {
  UserRepository(this._api, this._box, this._safe);

  ///Logins user. Gets from api, stores in cache.
  Future<User> login(Json user) async {
    final map = _api.get('/login?user=${user.toJson()}'); //api
    await _box.write('user', jsonEncode(map)); //cache
    return User.fromMap(map); //model
  }

  ///Remembers password. Stores encrypted.
  Future<User> savePassword(String password) async {
    await _safe.write('user_password', password); //encrypted
  }
}
```

## State Management

---
The package includes GetX reactivity.
We added `.obn`, which is the same as `.obs` with `null` as initial value.

Logic

```dart
// it's private, must only be modified here.
final _count = 0.obs;
final _user = User().obn;

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
The Service implements the actual business logic and data manipulation.

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
The Controller manages and encapsulates all state and business logic of a component.

### Reponsabilities

- Handle input: gather inputs, validate, clean and send to services.
- Handle outputs: navigation, nests, dialogs, snackbars and bottomsheets.
- Receive requests and treat possible errors/exceptions from services to the ui.
- Single reponsability. Will handle business logic of components. 1 for each business logic.

```dart
//Anything operation related to login the [User] must only be done here.
class LoginController {

  ///The state from UserService. Read only.
  UserService _user = Modular.get();

  ///Controls a component. Attached.
  final formx = FormController();

  ///State of the remember password checkbox.
  final _isRememberChecked = false.obs;

  ///Sends the state to the view. Read only.
  bool get isCheck => _isRememberChecked.value;

  ///On login tap. Logs the user.
  Future<void> onLoginTap() async {
    if(formx.validate()) return await _login(formx.form);
  }

  ///On login submit (keyboard enter). Logs the user.
  Future<void> onLoginSubmit(Json map) async => _login(map);

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

### It's higly recommended to have single reponsability components

- Which means that same view can have many controllers.
- One controller should never communicate with another.

This makes much easier integration tests, which each single controller should have.

```dart
//this controller shares the same view as LoginController
class OtherController {
  ///Dont worry about calling again, its always the same instance. Read only.
  OtherService _otherService = Modular.get();

  ///Do another thing different than login feature.
  Future<void> onOtherEvent() async {
    //handle errors...
    await _otherService.doSomething();
  }
}
```

## View

The idea here is to manage only UI and EVENTS, all business logic in handled by the responsible Controller/Service.
The Page will send events or receive inputs/endpoints (business logic parameters).
The Component will encapsulate layout, styling and handle events to uplift them as callbacks.

### Responsabilities

- Injects the page controller.
- Expose business logic parameters (events and inputs).
- Omit non-business logic parameters (styling and layout).

- Component pattern:
  - Encapsulate all styling and layout into specific widgets (stateless).
  - Handles animation logic and callback events (stateful).
  - Handles ui on async states and exceptions (indicators).

```dart
class OtherComponent extends StatelessWidget {

  OtherController get controller => Moduler.get();

    @override
  Widget build(BuildContext context) {
    return ... // call controller if needed.
  }
}
```

### Widgets - Reusable components

```md
- /widgets:
  /brand (_app components: logo, copyright, icons_)
  /modal (_temporary overlays: snackbar, sheets, dialogs, loaders_)
  /input (_user interactions: fields, checkbox, buttons_)
  /boxes (_component holders: cards, menus, images_)
```

## Module

---

```dart
class MyModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => MyController()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, args) => const MyPage()),
  ];
}
```

## Naming Conventions

---

## Data Functions

The _verb-noun_ convention will be used.
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

The _noun-verb_ convention with 'on' preposition will be used.
The 'on' suggests that the action will happen after an event.
The noun describes the entity and the verb describes the action.

## Widget callbacks

- onTap() for VoidCallback aka void Function()

Controller callbacks:

- onStoryTap() for void Function(Story story)
- onFormSubmit() for void Function(Map form)
- onNameChange() for void Function(String name)
