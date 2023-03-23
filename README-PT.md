# Arquitetura

## MVC com Arquitetura de 3 Camadas

O MVC significa Model-View-Controller. Com esta ideia:

- Model - Gerencia operações de dados.
- View - Gerencia chamadas/eventos e apresenta a interface do usuário.
- Controller - Gerencia a lógica de negócios.

Com 3 Camadas:

- A View e Controller são a camada de apresentação.
- Todas as operações globais relacionadas a negócios de dados vão para o Service.
- Todas as operações locais e relacionadas à visualização vão para o Controller.
- O "Model" é dividido em Source/Repository/Models.

Visão Geral:

- Camada de Dados (Model, Repository, Source).
- Camada de Lógica de Negócios (Service).
- Camada de Apresentação (Controller, View).

TLDR:
Podemos relacionar tudo com uma cozinha!

Na cozinha, temos a **Despensa**, o **Chef**, o **Garçom**, a **Mesa** e a **Comida**.

O mesmo se aplica ao **Repository**, **Service**, **Controller**, **View** e **Model**.

Cada um tem suas próprias responsabilidades. A **Despensa** não sabe cozinhar, apenas fornece ingredientes. O **Chef** pega esses ingredientes, cozinha a **Comida** e envia-a para o **Garçom**. O **Garçom** envia a **Comida** para a **Mesa**, recebendo pedidos e notifica o **Chef** se precisar de algo mais.

Os dados aqui são os ingredientes que são armazenados na Despensa.

A camada de lógica de negócios é gerenciada apenas pelo **Chef**, que deve ser capaz de fazer tudo relacionado à **Comida**.

O apresentador tem a **Mesa** e o **Garçom**, que é responsável por limpar, configurar e servir a **Comida**.

Folder

    - /lib
      - main.dart
      - /app
        - /data
          - /models
          - /repositories
          - /sources

        - /services (global)
          - /app (front-services: theme, translation)
          - /data (back-services: gerencia entidades, ex: usuário)

        - /modules
          - /{...}
            - /widgets (local)
            - /controllers (local)
            - {name}_page.dart

        - /utils
        - /widgets (shared)
        - theme.dart
        - routes.dart

## Camada de Dados

A camada de dados é dividida em: Source, Repository e Model. Essa camada é o nível mais baixo da aplicação e interage com bancos de dados, solicitações de rede e outras fontes de dados assíncronas.

- Fluxo: Source > Raw Data > Repository > Data Model

## Model

Um objeto que representa uma entidade.

```dart
class Usuario {
  int id;
  String nome;
  String email;

  Usuario.fromMap(...); //utilitário de serialização
}
```

## Source

A source geralmente expõe APIs simples para executar operações **CRUD** (Create, Read, Update, Delete).

```dart
class Api extends IApi {
  Future<Json> get(String path) async {
    //ler do banco de dados or solicitação de rede
  }
}
```

## Repository

O Repository lida com dados brutos de várias Sources para Models.

```dart
class UserRepository {
  UserRepository(this._api, this._box, this._safe);

  ///Logins usuário. Pega da API, armazena em cache.
  Future<User> login(Json user) async {
    final map = _api.get('/login?user=${user.toJson()}'); //api
await_box.write('user', jsonEncode(map)); //cache
    return User.fromMap(map); //model
  }

  ///Lembra a senha. Armazena criptografada.
  Future<User> savePassword(String password) async {
    await _safe.write('user_password', password); //criptografado
  }
}
```

# Camada de Lógica de Negócios

Essa camada conecta os eventos do apresentador aos dados dos repositórios, processando os dados.

- Fluxo: Data Model > **Service** > Controllers/View

## Service

O Service implementa a lógica de negócios real e a manipulação de dados.

Responsabilidades:

- Recuperar dados de fontes externas.
- Processar dados para se adequar às regras de negócios.
- Salvar e gerenciar o estado dos dados globalmente.

```dart
//Qualquer operação relacionada ao [User] deve ser feita apenas aqui.
class UserService extends GetxService {
  UserService(this._repository);

  // O estado do usuário é privado.
  final _state = Rxn<Usuario>();

  // Seu valor pode ser acessado globalmente.
  Usuario? get value => _state.value;

  @override
  void onInit() async { //Carrega do cache, se houver.
    _state.value = await repository.load();
    super.onReady();
  }

  ///Login do usuário. Define o estado.
  Future<void> login(Json map, {bool remember = false}) async {
    _state.value = await repository.login(map);
    if (remember) await repository.savePassword(map['password']);
  }
}
```

# Apresentação

Esta camada gerencia todos os eventos e entradas para atualizar a visualização e seus componentes de acordo.

- Fluxo: Dados > **Controller** > Eventos > **Página** > Propriedades > **Widgets**

## Controller

O Controller gerencia e encapsula todos os estados e lógica de negócios de um componente.

### Responsabilidades

Gerenciar entrada: coletar entradas, validar, limpar e enviar para serviços.
