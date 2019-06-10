import 'package:flutter/material.dart';

typedef FilterResult(Map<String, dynamic> result);

class FilterPanel extends StatefulWidget {
  final List<String> categories;
  final FilterResult onResult;
  final Map<String, dynamic> initialValues;

  const FilterPanel(
      {Key key,
      @required this.categories,
      @required this.onResult,
      @required this.initialValues})
      : super(key: key);
  @override
  _FilterPanelState createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  String _authOption;
  bool _httpsOnlyOption = false;
  String _corsOption;
  String _catergoryOption;

  TextEditingController _searchTermController = TextEditingController(text: "");

  @override
  initState() {
    super.initState();
    final filterOptions = widget.initialValues;
    if (filterOptions.containsKey("title")) {
      _searchTermController.text = filterOptions["title"];
    }
    if (filterOptions.containsKey("auth")) {
      _authOption = filterOptions["auth"];
    }
    if (filterOptions.containsKey("cors")) {
      _corsOption = filterOptions["cors"];
    }
    if (filterOptions.containsKey("category")) {
      _catergoryOption = filterOptions["category"];
    }
    if (filterOptions.containsKey("https")) {
      _httpsOnlyOption = filterOptions["https"];
    }
  }

  _submitResult() {
    Map<String, dynamic> result = Map();
    if (_searchTermController.text.isNotEmpty) {
      result["title"] = _searchTermController.text;
    }
    if (_authOption != null) {
      result["auth"] = _authOption;
    }
    if (_httpsOnlyOption) {
      result["https"] = true;
    }
    if (_corsOption != null) {
      result["cors"] = _corsOption;
    }
    if (_catergoryOption != null) {
      result["category"] = _catergoryOption;
    }
    setState(() {
      _isExpanded = false;
    });
    widget.onResult(result);
  }

  Widget _buildFilterOption({Widget title, Widget body, bool isDropdown}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        title,
        isDropdown ? DropdownButtonHideUnderline(child: body) : body,
      ],
    );
  }

  List<Widget> _buildFilterOptions() {
    return <Widget>[
      _buildFilterOption(
        isDropdown: true,
        title: Text('Auth'),
        body: DropdownButton<String>(
          value: _authOption,
          items: <DropdownMenuItem<String>>[
            DropdownMenuItem(
              value: null,
              child: Text("-"),
            ),
            DropdownMenuItem(
              value: "none",
              child: Text("none"),
            ),
            DropdownMenuItem(
              value: "apiKey",
              child: Text("API key"),
            ),
            DropdownMenuItem(
              value: "OAuth",
              child: Text("OAUTH"),
            ),
            DropdownMenuItem(
              value: "X-Mashape-Key",
              child: Text("X Mashape key"),
            ),
          ],
          onChanged: (String authOption) {
            setState(() {
              _authOption = authOption;
            });
          },
        ),
      ),
      _buildFilterOption(
        isDropdown: false,
        title: Text('Https Only'),
        body: Checkbox(
          value: _httpsOnlyOption,
          onChanged: (newValue) {
            setState(() {
              _httpsOnlyOption = newValue;
            });
          },
        ),
      ),
      _buildFilterOption(
        isDropdown: true,
        title: Text('CORS'),
        body: DropdownButton<String>(
          value: _corsOption,
          items: <DropdownMenuItem<String>>[
            DropdownMenuItem(
              value: null,
              child: Text("-"),
            ),
            DropdownMenuItem(
              value: "yes",
              child: Text("Yes"),
            ),
            DropdownMenuItem(
              value: "no",
              child: Text("No"),
            ),
            DropdownMenuItem(
              value: "unknown",
              child: Text("Unknown"),
            ),
          ],
          onChanged: (String newValue) {
            setState(() {
              _corsOption = newValue;
            });
          },
        ),
      ),
      _buildFilterOption(
        isDropdown: true,
        title: Text('Category'),
        body: DropdownButton<String>(
          value: _catergoryOption,
          items: widget.categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (newCategory) {
            setState(() {
              _catergoryOption = newCategory;
            });
          },
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> filterOptions = _buildFilterOptions();
    return Column(
      children: <Widget>[
        Card(
          margin: EdgeInsets.all(0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Filters'),
                IconButton(
                  icon: _isExpanded
                      ? Icon(Icons.arrow_drop_up)
                      : Icon(Icons.arrow_drop_down),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                )
              ],
            ),
          ),
        ),
        Card(
          child: AnimatedSize(
            child: Container(
              padding: _isExpanded ? EdgeInsets.all(16.0) : EdgeInsets.all(0),
              child: _isExpanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: _searchTermController,
                          decoration: InputDecoration(
                              border:
                                  OutlineInputBorder(borderSide: BorderSide()),
                              labelText: "Search term"),
                        )
                      ]
                        ..addAll(filterOptions)
                        ..addAll([
                          Container(
                            alignment: Alignment.centerRight,
                            child: FlatButton(
                              onPressed: _submitResult,
                              child: Text('Apply'),
                            ),
                          )
                        ]),
                    )
                  : Container(),
            ),
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 500),
            vsync: this,
          ),
        ),
      ],
    );
  }
}
