import 'dart:io';

void main() {
  stdout.writeln('==== 양의 정수의 각 자리 합 구하기 ====');
  stdout.write('양의 정수를 입력하세요 > ');
  
  int num = int.parse(stdin.readLineSync().toString());
  int sum = 0;

  if ( num <= 0 ) {
    stdout.write(num);
  }
  else {
    while ( num != 0 ) {
      sum += num % 10;
      num = num ~/ 10;
    }

    stdout.write('sum = $sum');
  }
}