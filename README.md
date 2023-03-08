# branvier

A new Branvier project.

## Getting Started

This project is a starting point for a Branvier application.

### Folder Architecture

#### Main
* /lib
    - main.dart
    - /app
        - /data
        - /modules
        - /utils
        - /widgets
        - theme.dart
        - routes.dart

#### App
1. ##### Data - Models, repositories and services.
    * /data
        - /models (_data classes_)
        - /repositories (_source data handlers_)
        - /services (_global controllers_)
        - /sources (_raw data handlers: api, db, cloud, cache_)

#### Data Pattern
* Flow: **Source** > *Raw Data* > **Repository** > *Data Model* > **Service** > *Controllers*

The Repository layer is responsible for interacting with the data sources, such as a database or API.
The Service layer is responsible for implementing the business logic and using the Repository layer to retrieve and modify data as needed.
Finally, the Controller layer is responsible for handling incoming requests and returning responses, using the Service layer to process the requests.

By separating these layers, it becomes easier to make changes to the code without affecting other parts of the system.
It also makes testing and debugging easier since each layer can be tested independently.
This approach is commonly known as the "three-layer architecture" or "three-tier architecture".

Reference: "Clean Architecture: A Craftsman's Guide to Software Structure and Design" by Robert C. Martin.

##### Rules

* Source is a singleton that implemens an interface.
* Source/Repository are always consumed via constructors.
* Service is always consumed via injection (service locators).
* A Repository can only consume sources.
* A Service can consume repositories and/or other services.
* Only services can be accessed by controllers.

* All sources should have:
    - 1 abstract class interface
    - 1 mock implementation

* Class name convention:
    - models: No sufix. ex: User()
    - repositories: Sufix 'Repository'. ex: UserRepositoy()
    - services: Sufix 'Service'. ex: UserService()
    - sources:
    - interfaces: No sufix. ex: Api()
    - implementaion: Sufix from interface. ex: DioApi()

* Instance name convention:
    - Use the name of the class.
    - Use the interface name instead of implementation.
    - Ex: userService, userRepository, api

2. ##### Modules - Pages, controllers and components.
    * /modules
      /{module}
      - /{nest} (_nested pages_)
      - /widgets (_local components_)
      - {module}_controller.dart (_data consumer_)
      - {module}_page.dart (_user interface_)

##### Module Pattern
* Flow: *Data* > **Controller** > *Events* > **Page** > *Properties* > **Widgets**

* Page pattern:
    - Consumes the controller.
    - Handles mutable data like events.
    - Handles components.

* Component pattern:
    - Refactorates immutable data like properties.
    - Handles async states.
    - Handles animation logic.
    - When local, uses the name of the page as prefix. ex HomeMenu.

* Controller pattern:
    - All fields should be final and private.
    - Any conection to the page is exposed with a getter.
    - Any dependency is injected via service locator.

* Events name convention:
    - Every callback starts with on{EventName}. ex: onCardTap
    - Any list is decribed with -s sufix.

3. ##### Utils - Helpers and utilities.
    * /utils
      /constants (_colors, styles, urls_)
      /extensions (_int, string, list helpers_)
      /hooks (_reusable functions_)

4. ##### Widgets - Reusable components.
    * /widgets:
      /brand (_app components: logo, copyright, icons_)
      /modal (_temporary overlays: snackbar, sheets, dialogs, loaders_)
      /input (_user interactions: fields, checkbox, buttons_)
      /boxes (_component holders: cards, menus, images_)

#### Naming Conventions

##### 1. Data Functions

The *verb-noun* convention will be used.
Starting a function name with a verb helps to indicate the function action, while the noun indicates the type of data returned.
This convention can make function names more intuitive and easier to understand.
Ex:

###### Controller functions:
* fetchStories() for Future<List<Story>>
* streamStories() for Stream<List<Story>>

###### Service functions:
* From local source: loadUser() / saveUser()
* From external source: getUser() / getUsers()

###### Repository function:
If the repository only deals with books, then it may be reasonable to use getAll instead of getAllBooks.
Using getAll is specific enough and helps differentiate repository from services functions.
    
* If the class already defines the entity:
    - From local source: load() / save()
    - From external source:
        + getById(), getAll()
        + add(), update()
        + deleteById(), deleteAll()

2. Callback Functions

The *noun-verb* convention with 'on' preposition will be used.
The 'on' suggests that the action will happen after an event.
The noun describes the entity and the verb describes the action.

###### Widget callbacks:
* onTap() for VoidCallback aka void Function()

Controller callbacks:
* onStoryTap() for void Function(Story story)
* onFormSubmit() for void Function(Map form)
* onNameChange() for void Function(String name)

