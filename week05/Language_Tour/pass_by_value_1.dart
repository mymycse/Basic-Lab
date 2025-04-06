void swap(int x, int y) {
  int temp = x;
  x = y;
  y = temp;
}

void main() {
  int a = 10;
  int b = 20;
  swap(a, b);
  print('a = $a, b = $b');  // a = 10, b = 20
}

/*
swap 함수에 a와 b를 인자로 넘겨주었지만, 
함수 내부에서 x와 y의 값을 바꾸더라도 a와 b의 값에는 영향을 주지 않음.
이는 a와 b의 값이 x와 y에 복사되어 전달되기 때문이다.
*/