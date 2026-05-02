class PriorityItem<T> {
  final T item;
  final double priority;

  PriorityItem(this.item, this.priority);
}

class MinHeap<T> {
  final List<PriorityItem<T>> _heap = [];

  bool get isEmpty => _heap.isEmpty;
  int get length => _heap.length;

  void insert(T item, double priority) {
    _heap.add(PriorityItem(item, priority));
    _bubbleUp(_heap.length - 1);
  }

  T? removeMin() {
    if (isEmpty) return null;
    if (_heap.length == 1) return _heap.removeLast().item;

    final min = _heap[0].item;
    _heap[0] = _heap.removeLast();
    _bubbleDown(0);
    return min;
  }

  void _bubbleUp(int index) {
    while (index > 0) {
      int parent = (index - 1) ~/ 2;
      if (_heap[index].priority >= _heap[parent].priority) break;
      _swap(index, parent);
      index = parent;
    }
  }

  void _bubbleDown(int index) {
    while (true) {
      int left = 2 * index + 1;
      int right = 2 * index + 2;
      int smallest = index;

      if (left < _heap.length && _heap[left].priority < _heap[smallest].priority) {
        smallest = left;
      }
      if (right < _heap.length && _heap[right].priority < _heap[smallest].priority) {
        smallest = right;
      }

      if (smallest == index) break;
      _swap(index, smallest);
      index = smallest;
    }
  }

  void _swap(int i, int j) {
    final temp = _heap[i];
    _heap[i] = _heap[j];
    _heap[j] = temp;
  }

  List<T> toSortedList() {
    final List<T> sorted = [];
    final List<PriorityItem<T>> backup = List.from(_heap);
    
    while (!isEmpty) {
      sorted.add(removeMin()!);
    }
    
    _heap.addAll(backup); // Restore heap
    return sorted;
  }
}
