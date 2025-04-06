class Person {
  String name;
  int age;

  Person(this.name, this.age);

  void sayHello() {
    print('Hi, I\'m $name and I\'m $age years old.');
  }
}

void main() {
  var p = Person('Alice', 25);
  p.sayHello();
  // Hi, I'm Alice and I'm 25 years old.
}