import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'utils.dart' as utils;

class Klimatic extends StatefulWidget {


  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {

  String _cityEntered;

  Future _goToNextScreen (BuildContext context) async {
    Map results = await Navigator.of(context).push(
      new MaterialPageRoute<Map>(
          builder: (BuildContext context){
            return new ChangeCity();
          }));

    if (results != null && results.containsKey('enter')){
      //print(results['enter'].toString());
      _cityEntered = results['enter'];
    }
  }

  void showStuff() async {
   Map data = await getWeather(utils.apiId, utils.defaultCity);
   print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Klimatic'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.menu),
              onPressed: (){_goToNextScreen(context);})
        ],
      ),

      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset('images/umbrella.png',
            width: 490.0,
            height: 1200.0,
            fit: BoxFit.fill,),
          ),
          new Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 15.0, 21.0, 0.0),
            child: new Text('${_cityEntered == null ? utils.defaultCity : _cityEntered}',
            style: cityStyle(),
            ),
          ),
          new Container(
            alignment: Alignment.center,
            child: new Image.asset('images/light_rain.png'),
          ),

          //Container which will have our weather data
          new Container(
            margin: const EdgeInsets.fromLTRB(30.0, 350.0, 0.0, 0.0),
            child: updateTempWidget(_cityEntered),
          )
        ],
      ),
    );
  }
  Future<Map>getWeather(String apiId, String city) async {
    String apiUrl = "http://api.openweathermap.org/data/2.5/weather?q=$city&appid=${utils.apiId}&units=imperial";

    http.Response response = await http.get(apiUrl);

    return json.decode(response.body);
  }

  Widget updateTempWidget(String city){
    return new FutureBuilder(
        future: getWeather(utils.apiId, city == null ? utils.defaultCity : city),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot){
          //where we get all of the json data, we setup widgets etc
          if (snapshot.hasData){
            Map content = snapshot.data;
            return new Container(
              //margin: const EdgeInsets.fromLTRB(left, top, right, bottom),
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(content['main']['temp'].toString() + " F",
                    style: new TextStyle(
                      fontStyle: FontStyle.normal,
                      fontSize: 40.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w500
                    ),),
                    subtitle: new ListTile(
                      title: new Text(
                        "Humidity: ${content['main']['humidity'].toString()}\n"
                            "Min: ${content['main']['temp_min'].toString()}\n"
                            "Max: ${content['main']['temp_max'].toString()}\n",
                        style: extraData(),
                      ),
                    ),
                  ),

                ],
              ),
            );
          }else {
            return new Container();
          }
    });
  }
}

class ChangeCity extends StatelessWidget {

  var _cityFieldController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.greenAccent,
        title: new Text('Change City'),
        centerTitle: true,
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset('images/white_snow.png',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,),
          ),

          new ListView(
            children: <Widget>[
              new ListTile(
                title: new TextField(
                  decoration: new InputDecoration(
                    hintText: 'Enter City',
                  ),
                  controller: _cityFieldController,
                  keyboardType:TextInputType.text,
                ),
              ),

              new ListTile(
                title: new FlatButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'enter': _cityFieldController.text
                      });
                    },
                    textColor: Colors.grey,
                    color: Colors.white,
                    child: new Text('Get Weather')),
              )
            ],
          )

        ],
      ),
    );
  }
}


TextStyle cityStyle(){
  return new TextStyle(
    color: Colors.white,
    fontSize: 50.0,
    fontStyle: FontStyle.italic
  );
}

TextStyle extraData(){
  return new TextStyle(
      color: Colors.white,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      fontSize: 20.0
  );
}
TextStyle tempStyle(){
  return new TextStyle(
    color: Colors.white,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
    fontSize: 49.0
  );
}
