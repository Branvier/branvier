part of '/branvier.dart';

extension BoolExt on bool {
  R? ifTrue<R>(R set) {
    if (this) return set;
    return null;
  }

  R? ifFalse<R>(R set) {
    if (!this) return set;
    return null;
  }

  R? onTrue<R>(R run()) {
    if (this) return run();
    return null;
  }

  R? onFalse<R>(R run()) {
    if (!this) return run();
    return null;
  }
}
