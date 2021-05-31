//A-101 , BİM , ŞOK klasörleri
//Tarih ve saat bilgisi başlık olarak
//fişlerdeki toplam tutarlar toplancak

class Processor {
  int date_counter = 8;
  int time_counter = 4;
  List<String> companies = ["A101 ", "BIM ", "SOK "];
  String company_finder(String text) {
    for (var company in companies) {
      if (text.contains(company)) {
        return company;
      }
    }
  }

  String date_finder(String text) {
    date_counter = 8;
    time_counter = 4;
    int index = text.indexOf("SAAT");
    String tarih = "";
    String saat = "";
    for (int i = index; i >= 0; i--) {
      if (is_Num(text[i])) {
        tarih = tarih + text[i];
        date_counter--;
        if (date_counter == 0) {
          break;
        }
      }
    }
    tarih = new String.fromCharCodes(tarih.runes.toList().reversed);
    tarih = date_formatter(tarih);

    for (int i = index; i < text.length; i++) {
      if (is_Num(text[i])) {
        saat = saat + text[i];
        time_counter--;
        if (time_counter == 0) {
          break;
        }
      }
    }
    saat = time_formatter(saat);

    return tarih + " " + saat;
  }

  String price_finder(String text) {
    bool is_First_Num = true;
    bool is_First_Enter = true;
    String price = "";


    int index = text.indexOf("TOPLAM");
    for (int i = index; i < text.length; i++) {
      if(is_Num(text[i]) && (is_First_Num == false)){
        price = price + text[i];
      }
      else if(text[i] == '\n'){
        if(is_First_Enter){
          is_First_Enter = false;
        }
        else if ((is_First_Enter == false) && is_First_Num){
          is_First_Num = false;
        }
        else if ((is_First_Enter == false) && (is_First_Num==false)){
          break;
        }
      }
    }
    price = price_formatter(price);
    return price;
  }


  String time_formatter(String text) {
    return text.substring(0, 2) + "." + text.substring(2);
  }

  String price_formatter(String text) {
    return text.substring(0, (text.length -2))+ "." + text.substring((text.length -2));
  }
  

  String date_formatter(String text) {
    return text.substring(0, 2) +
        "." +
        text.substring(2, 4) +
        "." +
        text.substring(4);
  }

  bool is_Num(String string) {
    if (string == null || string.isEmpty) {
      return false;
    }
    final number = num.tryParse(string);
    if (number == null) {
      return false;
    }
    return true;
  }
}
