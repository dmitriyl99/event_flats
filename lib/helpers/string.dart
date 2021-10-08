bool isNumeric(String? s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

String flatByCount(int count) {
  var countStr = count.toString();
  var lastChar = countStr.substring(countStr.length - 1);
  if (lastChar == '1')
    return 'квартира';
  else if (lastChar == '2' || lastChar == '3' || lastChar == '4')
    return 'квартиры';
  return 'квартир';
}
