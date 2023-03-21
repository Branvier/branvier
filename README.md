# Architecture

## MVC with Three-Layer Architecure

The MVC stands for Model-View-Controller. With this idea:

- Model - Handles data operations.
- View - Handles calls/events and presents the ui.
- Controller - Manages business logic.

With 3-Layer:

- The View and Controller are the presentation layer.
- All the global and data business-related operations goes to the Service.
- All the local and view business-related operations goes to the Controller.
- The "Model" is broken into Source/Repository/Models.

Overview:

- Data Layer (Model, Repository, Source).
- Business Logic Layer (Service).
- Presentation Layer (Controller, View)  

TLDR:
We can relate all to a Kitchen!

In the Kitchen, we have the **Pantry**, the **Chef**, the **Waiter**, the **Table** and the **Food**.

The same applies to **Repository**, **Service**, **Controller**, **View** and **Model**.

Each one has its own reponsabilities. The **Pantry** doesnt know how to cook, just provides ingredients. The **Chef** takes those to cook the **Food** and send it to the **Waiter**. The **Waiter** sends the **Food** to the **Table**, taking orders and notifying the **Chef** if anything else is needed.

- The data here, are the ingredients who are stored in the **Patry**.
- The business logic layer is handled by the **Chef** only him should be able to do everything related to the **Food**.
- The presenter has the **Table** and the **Waiter** who is responsible to clean, set it up and serve the **Food**.

Folder

    - /lib
      - main.dart
      - /app
        - /data
          - /models
          - /repositories
          - /sources

        - /services
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

# Data Layer

The data layer is split in: Source, Repository and Model. This layer is the lowest level of application and interacts with databases, network requests and other async data sources.

- Flow: **Source** > _Raw Data_ > **Repository** > _Data Model_

## Model

A object that represents a entity.

```dart
class User {
  int id;
  String name;
  String email;

  User.fromMap(...); //serilializing utils.
}
```

## Source

The source usually expose simple APIs to perform **CRUD** operations (Create, Read, Update, Delete).
  
```dart
class Api extends IApi {
  Future<Json> get(String path) async {
    //read from database or network request.
  }
}
```

## Repository

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

# Business Logic Layer

This Layer connects the events from presenter to the data from repositories, processing the data.

- Flow: _Data Model_ > **Service** > _Controllers/View_

## Service

The Service manages and encapsulates all state and business logic related to a model.

Reponsabilities:

- Retrieve data from external sources.
- Process data to fit the business rules.
- Save and manage the state of the data globally.

```dart
//Anything operation related to [User] must only be done here.
class UserService extends GetxService {
  UserService(this._repository);

  //The state of the user is private.
  final _state = Rxn<User>();

  //It value can be acessed globally.
  User? get value => _state.value;

  @override
  void onInit() async { //Loads from cache, if any.
    _state.value = await repository.load();
    super.onReady();
  }

  ///Logs the user. Sets the state.
  Future<void> login(Json map, {bool remember = false}) async {
    _state.value = await repository.login(map);
    if (remember) await repository.savePassword(map['password']);
  }
}
```

# Presentation

This layers handles all the events and inputs to update the view and its components accordingly.

- Flow: _Data_ > **Controller** > _Events_ > **Page** > _Properties_ > **Widgets**

## Controller

The Controller manages and encapsulates all state and business logic of a component.

### Reponsabilities

- Handle input: gather inputs, validate, clean and send to services.
- Handle outputs: navigation, nests, dialogs, snackbars and bottomsheets.
- Receive requests and treat possible errors/exceptions from services to the ui.
- Single reponsability. Will handle business logic of components. 1 for each business logic.

```dart
//Anything operation related to login the [User] must only be done here.
class LoginController extends GetxController {

  ///The state from UserService. Read only.
  UserService _user = Get.find();

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
      await Get.offNamed(Routes.HOME);

    } on ApiException catch (e) {
      if (e.message != 'API.LOGIN.USER_NOT_FOUND') return;

      //on not found, register
      await Get.toNamed(Routes.SIGNIN); 

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
class ForgotPasswordController extends GetxController {
  ///Dont worry about calling again, its always the same instance. Read only.
  UserService _user = Get.find();

  ///On forgot password. Resets password with email.
  Future<void> onForgotPassword(String email) async {
    //handle errors...
    await _user.resetPassword(email);

    //output to the user
    Get.snackbar(
      'app.forgotPasswordSuccess'.tr,
      'app.forgotPasswordSuccessMessage'.tr,
    );
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
class LoginPage extends GetView<LoginController> {
    @override
  Widget build(BuildContext context) {
    return ...
    ... FormX(
      onSubmit: controller.onLoginSubmit, //the event forwards to the controller.
      child: Column(
        children: [
          Field('name'),
          Field('email'),
          Field('password'),
        ],
      //internally calls Get.find()  
      GetBuilder<ForgotPasswordController>(
        builder: (controller) {
        return ForgotPasswordButton(onSubmit: controller.onForgotPasswordSubmit),
        },
      ),
    ),
  }
}
```

### Widgets - Reusable components

    - /widgets:
      /brand (_app components: logo, copyright, icons_)
      /modal (_temporary overlays: snackbar, sheets, dialogs, loaders_)
      /input (_user interactions: fields, checkbox, buttons_)
      /boxes (_component holders: cards, menus, images_)

## Injections

For injecting depencies we use Get.find service locator. They'll be used for only two types of class:

- Service (GetXService)
- Controller (GetXController)

```
// todo: how and where to instantiate
```

# Naming Conventions

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

###### Widget callbacks

- onTap() for VoidCallback aka void Function()

Controller callbacks:

- onStoryTap() for void Function(Story story)
- onFormSubmit() for void Function(Map form)
- onNameChange() for void Function(String name)

## The Pattern

Closer look:

   +---------------------------------+
   |            Data Layer           |
   |   (Source/Repository/Model)     |
   +---------------------------------+
                |       ^
   calls/returns|       |fetches/stores data
                v       |
   +---------------------------------+
   |      Business Logic Layer       |
   |            (Services)           |
   +---------------------------------+
                |       ^
   calls/updates|       |handles events
                v       |
   +---------------------------------+
   |       Presentation Layer        |
   |        (Controller/View)        |
   +---------------------------------+

Other Architectures. Why not?

- First, boilerplate code. This is time consuming means less productivity.
- Over-engineering. Overkill rules for simples cases.
- Performance. Can be easily be implemented poorly, leading to memory leaks.
- Complexity. Depends on package rules and even code generator which slows down the learning curve.
- Some logic is tightly coupled to the widget, events can be difficult to track in the code.
- As the app grows, you may have lots and lots of blocs/providers, which can slow down the app.

The purpose here is:

- Go simple, we need the least learning curve possible.
- No boilerplate.
- Avoid framework packages and code generators.
- Use Flutter best pratices and naming conventions.
- Respect the SRP - Single Responsibility Principle.

Reference:
<https://openclassrooms.com/en/courses/5684146-create-web-applications-efficiently-with-the-spring-boot-mvc-framework/6156961-organize-your-application-code-in-three-tier-architecture>

Reference: "Clean Architecture: A Craftsman's Guide to Software Structure and Design" by Robert C. Martin.
