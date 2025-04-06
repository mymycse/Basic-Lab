import 'dart:io';

double areaFunc(double r) {
  const pi = 3.141592;
  final double result = r * r * pi;
  return result;
}

class User {
  // late 변수를 사용하면 non-nullable 변수의 초기화를 나중에 할 수 있다.
  // late 키워드는 값의 초기화를 뒤로 미루지만, 개발자가 null을 실수로 사용하는 것을 막아준다.
  late String name;
  late int age;
  User(String s, int i) {
    name = s;
    age = i;
  }
}

void main() {
  print("Hello Dart!");
  String str1 = 'Hello World!';
  String str2 = ' ~ Dart ';
  print(str1 + str2);

  // String message = stdin.readLineSync();
  // print(message);

  for (int i = 0; i < 5; i++) {
    print('hello');
    if ( i == 0 ) {
      print('hello~~~$i');
    } else if ( i == 1 ) {
      print('hello~~~$i');
    } else {
      print('');
    }
  }

  int x = 5;
  int y = 2;
  int sum = x + y;
  double d1 = x / y;
  int d2 = x ~/ y;
  double pi = 3.141592;
  double r = 10;
  double area = pi * r * r;

  var result = 'ㅋㅋㅋ';
  // result = 3.14;

  print('$sum, $d1, $d2, $area, $result');

  print(areaFunc(5));

  var list = [
    'Car',
    'Boat',
    'Plane',
  ];

  List<int> list2 = [1, 2, 3, 4, 5];

  print(list);
  print(list2);
  print(list[2]);

  var halogens = {'apple', 'banana', 'melon', 'mango', 'orange'};
  Set<String> s = {'1', '2', '3', '4', '5'};
  print(halogens);
  print(s);

  var gifts = {
    '1': 'diamond',
    '2': 'sappire',
    '3': 'gold'
  };
  print(gifts);

  Map<int, double> m = {1: 1.0, 2: 2.0, 3:3.0};
  print(m[1]);

  User u = User("cho", 22);
  print('${u.name}, ${u.age}');
}