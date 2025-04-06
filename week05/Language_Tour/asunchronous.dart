// Asynchronous 비동기 함수 Future
Future<void> fetchUserOrder() {
  return Future.delayed(const Duration(seconds: 2), () => print('Large Latte'));
}

void main() {
  fetchUserOrder();
  print('Fetching user order...');
}