// ignore_for_file: overridden_fields, lines_longer_than_80_chars

part of '/branvier.dart';

enum PageTransition {
  theme,
  fade,
  rightToLeft,
  leftToRight,
  topToBottom,
  bottomToTop,
  scale,
  rotate,
  size,
  rightToLeftWithFade,
  leftToRightWithFade,
  leftToRightJoined,
  rightToLeftJoined,
  topToBottomJoined,
  bottomToTopJoined,
  leftToRightPop,
  rightToLeftPop,
  topToBottomPop,
  bottomToTopPop,
}

class PageObserver extends RouteObserver<PageRoute> {
  PageObserver({this.onReplace, this.onPush, this.onPop});

  final void Function(Route? route, Route? prev)? onReplace;
  final void Function(Route route, Route? prev)? onPush;
  final void Function(Route route, Route? prev)? onPop;

  @override
  void didPush(Route route, Route? previousRoute) {
    onPush?.call(route, previousRoute);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    onReplace?.call(newRoute, oldRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    onPop?.call(route, previousRoute);
    super.didPop(route, previousRoute);
  }
}

/// This package allows you amazing transition for your routes
/// Page transition class extends PageRouteBuilder
class PageBuilder<T> extends PageRouteBuilder<T> {
  /// Page transition constructor. We can pass the next page as a child,
  PageBuilder({
    required this.child,
    required this.type,
    this.childCurrent,
    this.ctx,
    this.inheritTheme = false,
    this.curve = Curves.linear,
    this.alignment,
    this.duration = const Duration(milliseconds: 200),
    this.reverseDuration = const Duration(milliseconds: 200),
    this.fullscreenDialog = false,
    this.opaque = false,
    this.isIos = false,
    this.matchingBuilder = const CupertinoPageTransitionsBuilder(),
    super.settings,
  })  : assert(
          // ignore: avoid_bool_literals_in_conditional_expressions
          inheritTheme ? ctx != null : true,
          "'ctx' cannot be null when 'inheritTheme' is true, set ctx: context",
        ),
        super(
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) {
            return inheritTheme
                ? InheritedTheme.captureAll(ctx!, child)
                : child;
          },
          maintainState: true,
          opaque: opaque,
          fullscreenDialog: fullscreenDialog,
        );

  /// Child for your next page
  final Widget child;

  // ignore: public_member_api_docs
  final PageTransitionsBuilder matchingBuilder;

  /// Child for your next page
  final Widget? childCurrent;

  /// Transition types
  final PageTransition type;

  /// Curves for transitions
  final Curve curve;

  /// Alignment for transitions
  final Alignment? alignment;

  /// Duration for your transition default is 300 ms
  final Duration duration;

  /// Duration for your pop transition default is 300 ms
  final Duration reverseDuration;

  /// Context for inherit theme
  final BuildContext? ctx;

  /// Optional inherit theme
  final bool inheritTheme;

  /// Optional fullscreen dialog mode
  @override
  final bool fullscreenDialog;

  @override
  final bool opaque;

  // ignore: public_member_api_docs
  final bool isIos;

  @override
  Duration get transitionDuration => duration;

  @override
  // ignore: public_member_api_docs
  Duration get reverseTransitionDuration => reverseDuration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (type) {
      case PageTransition.theme:
        return Theme.of(context).pageTransitionsTheme.buildTransitions(
              this,
              context,
              animation,
              secondaryAnimation,
              child,
            );

      case PageTransition.fade:
        if (isIos) {
          final fade = FadeTransition(opacity: animation, child: child);
          return matchingBuilder.buildTransitions(
            this,
            context,
            animation,
            secondaryAnimation,
            fade,
          );
        }
        return FadeTransition(opacity: animation, child: child);
        // ignore: dead_code
        break;

      /// PageTransitionType.rightToLeft which is the give us right to left transition
      case PageTransition.rightToLeft:
        final slideTransition = SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
        if (isIos) {
          return matchingBuilder.buildTransitions(
            this,
            context,
            animation,
            secondaryAnimation,
            child,
          );
        }
        return slideTransition;
        // ignore: dead_code
        break;

      /// PageTransitionType.leftToRight which is the give us left to right transition
      case PageTransition.leftToRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
        // ignore: dead_code
        break;

      /// PageTransitionType.topToBottom which is the give us up to down transition
      case PageTransition.topToBottom:
        if (isIos) {
          final topBottom = SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
          return matchingBuilder.buildTransitions(
            this,
            context,
            animation,
            secondaryAnimation,
            topBottom,
          );
        }
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
        // ignore: dead_code
        break;

      /// PageTransitionType.downToUp which is the give us down to up transition
      case PageTransition.bottomToTop:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
        // ignore: dead_code
        break;

      /// PageTransitionType.scale which is the scale functionality for transition you can also use curve for this transition

      case PageTransition.scale:
        assert(alignment != null, """
                When using type "scale" you need argument: 'alignment'
                """);
        if (isIos) {
          final scale = ScaleTransition(
            alignment: alignment!,
            scale: animation,
            child: child,
          );
          return matchingBuilder.buildTransitions(
            this,
            context,
            animation,
            secondaryAnimation,
            scale,
          );
        }
        return ScaleTransition(
          alignment: alignment!,
          scale: CurvedAnimation(
            parent: animation,
            curve: Interval(
              0,
              0.50,
              curve: curve,
            ),
          ),
          child: child,
        );
        // ignore: dead_code
        break;

      /// PageTransitionType.rotate which is the rotate functionality for transition you can also use alignment for this transition

      case PageTransition.rotate:
        assert(alignment != null, """
                When using type "RotationTransition" you need argument: 'alignment'
                """);
        return RotationTransition(
          alignment: alignment!,
          turns: animation,
          child: ScaleTransition(
            alignment: alignment!,
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
        // ignore: dead_code
        break;

      /// PageTransitionType.size which is the rotate functionality for transition you can also use curve for this transition

      case PageTransition.size:
        assert(alignment != null, """
                When using type "size" you need argument: 'alignment'
                """);
        return Align(
          alignment: alignment!,
          child: SizeTransition(
            sizeFactor: CurvedAnimation(
              parent: animation,
              curve: curve,
            ),
            child: child,
          ),
        );
        // ignore: dead_code
        break;

      /// PageTransitionType.rightToLeftWithFade which is the fade functionality from right o left

      case PageTransition.rightToLeftWithFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
        );
        // ignore: dead_code
        break;

      /// PageTransitionType.leftToRightWithFade which is the fade functionality from left o right with curve

      case PageTransition.leftToRightWithFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: curve,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
        );
        // ignore: dead_code
        break;

      case PageTransition.rightToLeftJoined:
        assert(childCurrent != null, """
                When using type "rightToLeftJoined" you need argument: 'childCurrent'

                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-1, 0),
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: curve,
                ),
              ),
              child: childCurrent,
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: curve,
                ),
              ),
              child: child,
            )
          ],
        );
        // ignore: dead_code
        break;

      case PageTransition.leftToRightJoined:
        assert(childCurrent != null, """
                When using type "leftToRightJoined" you need argument: 'childCurrent'
                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: curve,
                ),
              ),
              child: child,
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(1, 0),
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: curve,
                ),
              ),
              child: childCurrent,
            )
          ],
        );
        // ignore: dead_code
        break;

      case PageTransition.topToBottomJoined:
        assert(childCurrent != null, """
                When using type "topToBottomJoined" you need argument: 'childCurrent'
                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: curve,
                ),
              ),
              child: child,
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0, 1),
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: curve,
                ),
              ),
              child: childCurrent,
            )
          ],
        );
        // ignore: dead_code
        break;

      case PageTransition.bottomToTopJoined:
        assert(childCurrent != null, """
                When using type "bottomToTopJoined" you need argument: 'childCurrent'
                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: curve,
                ),
              ),
              child: child,
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0, -1),
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: curve,
                ),
              ),
              child: childCurrent,
            )
          ],
        );
        // ignore: dead_code
        break;

      case PageTransition.rightToLeftPop:
        assert(childCurrent != null, """
                When using type "rightToLeftPop" you need argument: 'childCurrent'

                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            child,
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-1, 0),
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: curve,
                ),
              ),
              child: childCurrent,
            ),
          ],
        );
        // ignore: dead_code
        break;

      case PageTransition.leftToRightPop:
        assert(childCurrent != null, """
                When using type "leftToRightPop" you need argument: 'childCurrent'
                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            child,
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(1, 0),
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: curve,
                ),
              ),
              child: childCurrent,
            )
          ],
        );
        // ignore: dead_code
        break;

      case PageTransition.topToBottomPop:
        assert(childCurrent != null, """
                When using type "topToBottomPop" you need argument: 'childCurrent'
                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            child,
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0, 1),
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: curve,
                ),
              ),
              child: childCurrent,
            )
          ],
        );
        // ignore: dead_code
        break;

      case PageTransition.bottomToTopPop:
        assert(childCurrent != null, """
                When using type "bottomToTopPop" you need argument: 'childCurrent'
                example:
                  child: MyPage(),
                  childCurrent: this

                """);
        return Stack(
          children: <Widget>[
            child,
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0, -1),
              ).animate(CurvedAnimation(parent: animation, curve: curve)),
              child: childCurrent,
            )
          ],
        );
        // ignore: dead_code
        break;
    }
  }
}
