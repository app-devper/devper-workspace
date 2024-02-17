String formatPrice(double price) => price.toStringAsFixed(2);

String convertAmountToLetter(String number) {
  if (number.isEmpty) return "";
  List<String> txtnum1 = ['ศูนย์', 'หนึ่ง', 'สอง', 'สาม', 'สี่', 'ห้า', 'หก', 'เจ็ด', 'แปด', 'เก้า', 'สิบ'];
  List<String> txtnum2 = ['', 'สิบ', 'ร้อย', 'พัน', 'หมื่น', 'แสน', 'ล้าน', 'สิบ', 'ร้อย', 'พัน', 'หมื่น', 'แสน', 'ล้าน'];

  number = number.replaceAll(",", "");
  number = number.replaceAll(" ", "");
  number = number.replaceAll("บาท", "");
  List<String> numberParts = number.split(".");

  if (numberParts.length > 2) {
    return '';
  }

  int strlen = numberParts[0].length;
  String convert = '';

  for (int i = 0; i < strlen; i++) {
    int n = int.parse(numberParts[0][i]);
    if (n != 0) {
      if (i == (strlen - 1) && n == 1) {
        convert += 'เอ็ด';
      } else if (i == (strlen - 2) && n == 2) {
        convert += 'ยี่';
      } else if (i == (strlen - 2) && n == 1) {
        convert += '';
      } else {
        convert += txtnum1[n];
      }
      convert += txtnum2[strlen - i - 1];
    }
  }

  convert += 'บาท';

  if (numberParts.length == 1) {
    convert += 'ถ้วน';
  } else {
    if (numberParts[1] == '0' || numberParts[1] == '00' || numberParts[1].isEmpty) {
      convert += 'ถ้วน';
    } else {
      numberParts[1] = numberParts[1].substring(0, 2);
      int strlen = numberParts[1].length;

      for (int i = 0; i < strlen; i++) {
        int n = int.parse(numberParts[1][i]);
        if (n != 0) {
          if (i > 0 && n == 1) {
            convert += 'เอ็ด';
          } else if (i == 0 && n == 2) {
            convert += 'ยี่';
          } else if (i == 0 && n == 1) {
            convert += '';
          } else {
            convert += txtnum1[n];
          }
          convert += i == 0 ? txtnum2[1] : '';
        }
      }

      convert += 'สตางค์';
    }
  }

  return convert;
}
