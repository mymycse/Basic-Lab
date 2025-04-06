class Point {
  int x, y;
  Point(this.x, this.y);
}

void swap(Point pnt1, Point pnt2) {
  int tempX = pnt1.x;
  int tempY = pnt1.y;

  pnt1.x = pnt2.x;
  pnt1.y = pnt2.y;
  pnt2.x = tempX;
  pnt2.y = tempY;
}

void main() {
  Point p1 = Point(10, 20);
  Point p2 = Point(30, 40);
  swap(p1, p2);
  print('p1 = (${p1.x}, ${p1.y}), p2 = (${p2.x}, ${p2.y})');
  // p1 = (30, 40), p2 = (10, 20)
}

/*
swap 함수에 p1과 p2를 인자로 넘겨주었고, 
함수 내부에서 p1과 p2의 x와 y값을 바꿨다.
이 경우에는 함수 외부의 p1과 p2의 값도 바뀌었다.class
이는 p1과 p2가 가리키는 객체의 참조값이 복사되어 전달되기 때문이다.
따라서 함수 내부에서 객체의 속성을 변경하려면 원본 객체에도 영향을 준다.
*/