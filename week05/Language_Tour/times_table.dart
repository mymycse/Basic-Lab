void main() {
  for ( int i = 2 ; i <= 9 ; i++ ) {
    for ( int j = 1 ; j <= 9 ; j++ ) {
      print('$i x $j = ${i*j}');
    }
  }
  /* < output >
  2 x 1 = 2
  2 x 2 = 4
  2 x 3 = 6
  2 x 4 = 8
  2 x 5 = 10
  ...
  */
}