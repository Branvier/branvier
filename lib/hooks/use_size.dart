part of '/branvier.dart';

///Gets widget own [Size].
SizeState useSize(Size initialSize, [String key = '']) {
  final list = useState([initialSize]);
  final refKey = useRef(key);
  final context = useContext();

  useEffect(
    () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (refKey.value != key) {
          refKey.value = key;
          list.value.clear();
        }
        if (context.size == null || list.value.length > 1) return;
        list.value += [context.size!];
      });
      return null;
    },
  );

  return SizeState(list.value, initialSize);
}

Size? usePostSize() {
  final context = useContext();
  final size = useRef<Size?>(null);
  postFrame(() => size.value = context.size);
  return size.value;
}

class SizeState {
  SizeState(this.list, this.initial);
  final List<Size> list;
  final Size initial;

  Size get first => list.isEmpty ? initial : list.first;
  Size get real => list.isEmpty ? initial : list.last;
}
