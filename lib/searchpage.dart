import 'package:flutter/material.dart';
import 'package:havadurumu/ForecastWeather.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String textFieldValue = "";

  // Show dialog donduren method
  void alerDialogFunction() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Uyari Perceresi"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text("Burasi bos birakilamaz "
                      "Lutfen bir sehir giriniz")
                ],
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Kapat")),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/search.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Burada AutoComplete widgeti kullanacagim.
            TextField(textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontSize: 40, color: Colors.white),
              onChanged:
                  (newValue) {
                textFieldValue = newValue;
              },
              decoration: InputDecoration(
                hintText: "Şehir giriniz",
                hintStyle: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            SizedBox(height: 10,),
            TextButton(onPressed: () {
                  setState(() {
                    if (textFieldValue.isEmpty) {
                      alerDialogFunction();
                    } else {
                      Navigator.pop(context, textFieldValue);
                    }
                  });
                },
                child: Text(
                  "Güncel Hava Durumu",
                  style: TextStyle(fontSize: 27, color: Colors.white),
                ),
              ),
            FlatButton(
                onPressed: () {
                  setState(() {
                    if (textFieldValue.isEmpty) {
                      alerDialogFunction();
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForecastWeather(
                                    secilenSehirBilgisi: textFieldValue,
                                  )));
                    }
                  });
                },
                child: Text(
                  "5 Günlük Hava Durumu",
                  style: TextStyle(fontSize: 27, color: Colors.white),
                )),
          ],
        ),
      ),
    );
  }
}
