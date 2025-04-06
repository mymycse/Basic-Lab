void main() {
  List<String> fruits = ['Apple', 'Banana'];
  Map<String, int> scores = {'Math':90, 'English':85};

  dynamic anything = 'Hello';
  anything = 42;

  print(fruits);    // [Apple, Banana]
  print(scores);    // {Math: 90, English: 85}
  print(anything);  // 42
}