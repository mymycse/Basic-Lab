void main() {
  var message = StringBuffer('Dart is fun');
  for ( var i = 0 ; i < 5 ; i++ ) {
    message.write('!');
  }

  print(message);   // Dart is fun!!!!!

  const iterable = ['Salad', 'Popcorn', 'Toast'];
  for ( final element in iterable ) {
    print(element);
  }
  /* 
  Salad
  Popcorn
  Toast
  */

  for ( int i = 0; i < 3; i++ ) {
    print('Hello $i');
  }
  /*
  Hello 0
  Hello 1
  Hello 2
  */

  int count = 0;
  while ( count < 3 ) {
    print('Count $count');
    count++;
  }
  /*
  Count 0
  Count 1
  Count 2
  */
}