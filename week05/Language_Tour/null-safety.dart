void main() {
  // 변수가 null 값을 가질 수 있음을 나타내려면 ?를 추가한다.
  List<String?> list = ["apple", "banana", "melon", null];

  int len = list.length;
  for ( int i = 0 ; i < len ; i++ ) {
    print(list[i]);
  }

  /* 
  < output >
  dart
  apple
  banana
  melon
  null
  */
}