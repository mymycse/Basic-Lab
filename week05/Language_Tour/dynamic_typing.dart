void main() {
  var x = 10;
  // x = 'Hello'; // 오류 발생 ( var는 최초 할당된 타입 유지 );

  dynamic y = 10; // 동적 타입
  y = 'Hello';    // 정상 작동

  var name = 'John';      // 타입 추론
  String city = 'Seoul';  // 명시적 타입 선언
  int age = 30;
  double height = 175.5;
  bool isStudent = false;

  print('$name, $city, $age, $height, $isStudent');
  // John, Seoul, 30, 175.5, false
}