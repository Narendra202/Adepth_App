
import 'dart:math';

import 'package:expedition_poc/screens/application/expeditions/areas/areas.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
class TestScreenData extends StatefulWidget {
  TestScreenData({super.key, this.expeditionList, this.initialize});

  List? expeditionList = [];
  Function()? initialize;

  @override
  State<TestScreenData> createState() => _TestScreenDataState();
}

class _TestScreenDataState extends State<TestScreenData> {

  List expeditionList = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    expeditionList = widget.expeditionList!;
    print(expeditionList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: expeditionList.length,
          itemBuilder: (context, index) {

          var expeditionId = expeditionList[index]['_key'];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Card(
                // color: Colors.blue.shade100,
                elevation: 2,
                shadowColor: Colors.grey,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(expeditionList[index]['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                      subtitle: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(child: Text('Company', style: TextStyle(fontWeight: FontWeight.w500),)),
                              Expanded(child: Text(expeditionList[index]['company'])),
                            ],
                          ),
                          Row(
                            children: [
                              const Expanded(child: Text('Vessel', style: TextStyle(fontWeight: FontWeight.w500),)),
                              Expanded(child: Text(expeditionList[index]['vessel'])),
                            ],
                          ),
                          Row(
                            children: [
                              const Expanded(child: Text('Date', style: TextStyle(fontWeight: FontWeight.w500),)),
                              Expanded(child: Text(expeditionList[index]['startDate'] + ' - ' + expeditionList[index]['endDate'])),
                            ],
                          )
                        ]
                      )
                    ),
                     ExpansionTile(
                        title: Text('Area Card'),
                        children: [
                          Text('hello '),
                          //    Areas(arguments: expeditionId);
                         ]
                    )
                  ],
                ),
              ),
            );
          },
      )
    );
  }
}
