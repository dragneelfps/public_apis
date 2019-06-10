import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:public_apis/filter_panel.dart';
import 'package:public_apis/tags.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

CustomTabsOption _customTabOptions(BuildContext context) => CustomTabsOption(
    toolbarColor: Theme.of(context).primaryColor,
    enableDefaultShare: true,
    enableUrlBarHiding: true,
    showPageTitle: true);

class Home extends StatefulWidget {
  final Dio dio;

  const Home({Key key, @required this.dio})
      : assert(dio != null),
        super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> _categories = List();
  Map<String, dynamic> filterOptions = Map();
  List<Map<String, dynamic>> resultList = List();
  Map<String, List<Map<String, dynamic>>> apisByCategory = Map();
  bool _isLoading = false;

  @override
  initState() {
    super.initState();
    _loadCategories();
    _loadResult();
  }

  _loadCategories() async {
    Response response = await widget.dio.request("/categories");
    setState(() {
      _categories = List<String>.from(response.data);
    });
  }

  _loadResult() async {
    setState(() {
      _isLoading = true;
    });
    Response response =
        await widget.dio.request("/entries", queryParameters: filterOptions);
    // print(response.realUri);
    print(response.request.uri);
    // print(response.data.toString());
    if (response.data["count"] > 0) {
      final entries = List<Map<String, dynamic>>.from(response.data["entries"]);
      final entriesByCategory = Map<String, List<Map<String, dynamic>>>();
      entries.forEach((entry) {
        final category = entry["Category"];
        if (!entriesByCategory.containsKey(category)) {
          entriesByCategory[category] = List();
        }
        entriesByCategory[category].add(entry);
      });
      setState(() {
        resultList = entries;
        apisByCategory = entriesByCategory;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  _handleResult(Map<String, dynamic> result) {
    setState(() {
      filterOptions = result;
    });
    _loadResult();
  }

  bool get _validSearchTerm =>
      filterOptions["title"] != null && filterOptions["title"].isNotEmpty;

  Widget get _searchTermHint => _validSearchTerm
      ? RichText(
          text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: <TextSpan>[
                TextSpan(text: "Results for "),
                TextSpan(
                  text: filterOptions["title"],
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.blue),
                ),
              ]),
        )
      : Container();

  Widget _selectedFilters() {
    if (filterOptions.isEmpty) {
      return Container();
    }
    Map<String, dynamic> filters = Map();
    if (filterOptions.containsKey("auth")) {
      filters["auth"] = ("Auth: ${filterOptions["authOption"]}");
    }
    if (filterOptions.containsKey("cors")) {
      filters["cors"] = ("Cors: ${filterOptions["cors"]}");
    }
    if (filterOptions.containsKey("category")) {
      filters["category"] = ("Category: ${filterOptions["category"]}");
    }
    if (filterOptions.containsKey("https")) {
      filters["https"] = ("Http only");
    }
    return Tags(
        data: filters,
        onDelete: (key) {
          setState(() {
            filterOptions.remove(key);
          });
          _loadResult();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Public APIs"),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            FilterPanel(
              key: UniqueKey(),
              categories: _categories,
              onResult: _handleResult,
              initialValues: filterOptions,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: _searchTermHint,
            ),
            _selectedFilters(),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView(
                    children: apisByCategory.keys.map(
                      (category) {
                        final apis = apisByCategory[category];
                        return Column(
                          children: <Widget>[
                            Container(
                              color: Colors.grey,
                              child: ListTile(
                                title: Text(
                                  category,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          ]..addAll(apis.map((api) => ListTile(
                                title: Text(api["API"]),
                                trailing: IconButton(
                                  icon: Icon(Icons.open_in_new),
                                  onPressed: () {
                                    launch(api["Link"],
                                        option: _customTabOptions(context));
                                  },
                                ),
                              ))),
                        );
                        // return ListTile(
                        //   title: Text(item["API"]),
                        //   trailing: IconButton(
                        //     icon: Icon(Icons.open_in_new),
                        //     onPressed: () {
                        //       launch(item["Link"],
                        //           option: _customTabOptions(context));
                        //     },
                        //   ),
                        // );
                      },
                    ).toList(),
                  ))
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Public APIs',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
            ListTile(
              title: Text("API Used"),
              trailing: Icon(Icons.open_in_new),
              onTap: () {
                Navigator.of(context).pop();
                launch("https://github.com/davemachado/public-api",
                    option: _customTabOptions(context));
              },
            ),
            ListTile(
              title: Text("About"),
              trailing: Icon(Icons.open_in_new),
              onTap: () {
                Navigator.of(context).pop();
                launch("https://github.com/",
                    option: _customTabOptions(context));
              },
            )
          ],
        ),
      ),
    );
  }
}
