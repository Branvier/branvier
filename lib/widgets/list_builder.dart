part of '/branvier.dart';

typedef AnimatedItemBuilder<W extends Widget, E> = W Function(
  BuildContext context,
  Animation<double> animation,
  E item,
  int i,
);

typedef RemovedItemBuilder<W extends Widget, E> = W Function(
  BuildContext context,
  Animation<double> animation,
  E item,
);

typedef UpdatedItemBuilder<W extends Widget, E> = W Function(
  BuildContext context,
  Animation<double> animation,
  E item,
);

class ListConfig<T> {
  const ListConfig({
    this.animation,
    this.duration = const Duration(milliseconds: 500),
    this.equality,
    this.removeItemBuilder,
    this.updateItemBuilder,
    this.insertDuration,
    this.removeDuration,
    this.updateDuration,
    this.spawnIsolate,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
  });

  ///Custom base animation.
  final Widget Function(Animation<double> animation, Widget child)? animation;

  ///Global animation duration.
  final Duration duration;

  ///Custom equality. If none uses equality operator "==".
  final bool Function(T oldItem, T newItem)? equality;

  //Animated list configs.
  final RemovedItemBuilder<Widget, T>? removeItemBuilder;
  final UpdatedItemBuilder<Widget, T>? updateItemBuilder;

  //Individual duration. Overrides global.
  final Duration? insertDuration;
  final Duration? removeDuration;
  final Duration? updateDuration;
  final bool? spawnIsolate;

  //Flutter list configs.
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
}

class ListBuilder<T extends Object> extends StatelessWidget {
  const ListBuilder({
    required this.list,
    required this.builder,
    this.config = const ListConfig(),
    super.key,
  });

  ///Your list of items.
  final List<T> list;

  ///Your item builder.
  final Widget Function(T item, int i) builder;

  ///Aditional config to this list builder.
  final ListConfig config;

  @override
  Widget build(BuildContext context) {
    return ImplicitlyAnimatedList<T>(
      items: list,
      insertDuration: config.insertDuration ?? config.duration,
      removeDuration: config.removeDuration ?? config.duration,
      updateDuration: config.updateDuration ?? config.duration,
      removeItemBuilder: config.removeItemBuilder,
      updateItemBuilder: config.updateItemBuilder,
      scrollDirection: config.scrollDirection,
      reverse: config.reverse,
      padding: config.padding,
      primary: config.primary,
      physics: config.physics,
      controller: config.controller,
      shrinkWrap: config.shrinkWrap,
      spawnIsolate: config.spawnIsolate,
      itemBuilder: (_, anim, item, index) {
        //Default animation.
        final defaultAnimation = SizeFadeTransition(
          animation: anim,
          child: builder(item, index),
        );

        //Checks for a custom animator. If none, uses default.
        final animation = config.animation ?? (_, __) => defaultAnimation;

        //Returns the animated list builder.
        return animation(anim, builder(item, index));
      },
      //Compares the old items with new ones.
      areItemsTheSame: config.equality ?? (old, item) => old == item,
    );
  }
}
