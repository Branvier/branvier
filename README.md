# branvier

A new Branvier project.

## Getting Started

This project is a starting point for a Branvier application.

### The Pattern

Time to refactor. Branvier uses what patterns after all?

- Branvier uses MVC with Three-Tier or Three-Layer!

Let's clear things up:

- The MVC pattern is only concerned with organizing the logic in the user interface (presentation layer).
- Three-tier architecture has a broader concern. It’s about organizing the code in the whole application.

And they work really nice together! Both are simple and efficient. That's all Branvier is and wants.

Normally for small project, using only the MVC is enough. But for bigger project, the 3-Layer architecture
solves a big problem: As your app grows, the controller starts to look quite messy.

The MVC stands for Model-View-Controller. With this idea:

- Model - Handles data operations.
- View - Handles calls/events and presents the ui.
- Controller - Manages business logic.

With 3-Layer:

- The View and Controller stays on the presentation layer.
- The presentation layer gets as thin as possible and limited to events.
- All the business-related operations goes to the Application layer Services.
- The "Model" is broken into Source/Repository/Models.

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
Provider, Bloc as example.

- First, boilerplate code. This is time consuming means less productivity.
- Over-engineering. Overkill rules for simples cases.
- Performance. Can be easily be implemented poorly, leading to memory leaks.
- Complexity. Depends on package rules and even code generator which slows down the learning curve.

Architecture like Riverpod and Bloc handles business logic for each component, so for each
widget, we'll have a provider or bloc to manage the state.

This is good for having a encapsulated logic of components, but there are some drawbacks:

- Since the logic is tightly coupled to the widget, events can be difficult to track in the code.
- As the app grows, you may have lots and lots of blocs/providers, which can slow down the app.

The purpose here is:

- Go simple, we need the least learning curve possible.
- No boilerplate.
- Avoid framework packages and code generators.
- Use Flutter best pratices and naming conventions.
- Respect the SRP - Single Responsibility Principle.

Reference:
<https://openclassrooms.com/en/courses/5684146-create-web-applications-efficiently-with-the-spring-boot-mvc-framework/6156961-organize-your-application-code-in-three-tier-architecture>

### Folder Architecture

#### Main

- /lib
  - main.dart
  - /app
    - /data
    - /services
    - /modules
    - /utils
    - /widgets
    - theme.dart
    - routes.dart

#### App

##### Data - Models, repositories and sources

    - /data
        - /models (_data classes_)
        - /repositories (_source data handlers_)
        - /sources (_raw data handlers: api, db, cloud, cache_)

#### Data Pattern

- Flow: **Source** > _Raw Data_ > **Repository** > _Data Model_ > **Service** > _Controllers_

The Repository layer is responsible for interacting with the data sources, such as a database or API.
The Service layer is responsible for implementing the business logic and using the Repository layer to retrieve and modify data as needed.
Finally, the Controller layer is responsible for handling incoming requests and returning responses, using the Service layer to process the requests.

By separating these layers, it becomes easier to make changes to the code without affecting other parts of the system.
It also makes testing and debugging easier since each layer can be tested independently.
This approach is commonly known as the "three-layer architecture" or "three-tier architecture".

Reference: "Clean Architecture: A Craftsman's Guide to Software Structure and Design" by Robert C. Martin.

##### Rules

- Source is a singleton that implemens an interface.
- Source/Repository are always consumed via constructors.
- Service is always consumed via injection (service locators).
- A Repository can only consume sources.
- A Service can consume repositories and/or other services.
- Only services can be accessed by controllers.

- All sources should have:
  - 1 abstract class interface
  - 1 mock implementation

- Class name convention:
  - models: No sufix. ex: User()
  - repositories: Sufix 'Repository'. ex: UserRepositoy()
  - services: Sufix 'Service'. ex: UserService()
  - sources:
  - interfaces: No sufix. ex: Api()
  - implementaion: Sufix from interface. ex: DioApi()

- Instance name convention:
  - Use the name of the class.
  - Use the interface name instead of implementation.
  - Ex: userService, userRepository, api

##### Services - The Business Logic Layer

    - /services
        - /app (_theme, localisation, navigation_)
        - /data (_with api data access_)
        - {my}_service.dart
        - {other}_service.dart

You can have many services as our app grows. It's important to group them. So we don't get lost.

Each folder:

- /app fore common global app related services, like theming and translation.
- /data for services that store state from api.
- {...} put the rest in the root folder and group them later.

By doing this, we'll have a sense of hierarchy in our Services.
As they are runtime injectables, we can consume them interchangebly.

The idea is: {root}Service  <-  {app}Service  <-  {data}Service.
In this example, {data}Service are only consumed and never calls other services.

##### Modules - Pages, Controllers and Components

    - /modules
      /{module}
      - /{nest} (_nested pages_)
      - /widgets (_local components_)
      - {module}_controller.dart (_data consumer_)
      - {module}_page.dart (_user interface_)

##### Module Pattern

- Flow: _Data_ > **Controller** > _Events_ > **Page** > _Properties_ > **Widgets**

The idea here is to manage only UI and EVENTS, all business logic in handled by the responsible Service.
The Page will send events or receive inputs/endpoints (business logic parameters).
The Component will encapsulate layout, styling and handle events to uplift them as callbacks.

- Controller pattern:
  - Const. No fields, no state management.
  - Any conection to the page is exposed with a getter.
  - Any dependency is injected privately via service locator getter.
  - Any event is forwarded directly to the respective service.

- Page pattern:
  - Injects the page controller.
  - Should expose business logic parameters (events and inputs).
  - Should omit non-business logic parameters (styling and layout).

- Component pattern:
  - Should never inject a dependency.
  - Encapsulate all styling and layout into specific widgets (stateless).
  - Handles animation logic and callback events (stateful).
  - Handles async states and exceptions (builders).

- Events name convention:
  - Starts with on{EventName}. ex: onCardTap
  - Follows by a NOUN of the entity where this was fired.
  - End with a VERB that describes the action taken.
  - Usually the name of the class as noun and callback parameter name as verb is a good option.

3. ##### Utils - Helpers and utilities

    - /utils
      /constants (_colors, styles, urls_)
      /extensions (_int, string, list helpers_)
      /hooks (_reusable functions_)

4. ##### Widgets - Reusable components

    - /widgets:
      /brand (_app components: logo, copyright, icons_)
      /modal (_temporary overlays: snackbar, sheets, dialogs, loaders_)
      /input (_user interactions: fields, checkbox, buttons_)
      /boxes (_component holders: cards, menus, images_)

#### Naming Conventions

##### 1. Data Functions

The _verb-noun_ convention will be used.
Starting a function name with a verb helps to indicate the function action, while the noun indicates the type of data returned.
This convention can make function names more intuitive and easier to understand.
Ex:

###### Controller functions

- fetchStories() for Future <List.<Story.>>
- streamStories() for Stream <List.<Story.>>

###### Service functions

- From local source: loadUser() / saveUser()
- From external source: getUser() / getUsers()

###### Repository function

If the repository only deals with books, then it may be reasonable to use getAll instead of getAllBooks.
Using getAll is specific enough and helps differentiate repository from services functions.

- If the class already defines the entity:
  - From local source: load() / save()
  - From external source:
    - getById(), getAll()
    - add(), update()
    - deleteById(), deleteAll()

2. Callback Functions

The _noun-verb_ convention with 'on' preposition will be used.
The 'on' suggests that the action will happen after an event.
The noun describes the entity and the verb describes the action.

###### Widget callbacks

- onTap() for VoidCallback aka void Function()

Controller callbacks:

- onStoryTap() for void Function(Story story)
- onFormSubmit() for void Function(Map form)
- onNameChange() for void Function(String name)
