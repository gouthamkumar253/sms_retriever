import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:smsretriever/models/custom_message.dart';
import 'package:smsretriever/utils/app_constants.dart';

class TransactionStatistics extends StatefulWidget {
  const TransactionStatistics({Key key, this.statisticsData}) : super(key: key);

  final Map<String, List<CustomMessage>> statisticsData;

  @override
  _TransactionStatisticsState createState() => _TransactionStatisticsState();
}

class _TransactionStatisticsState extends State<TransactionStatistics> {
  RegExp regExp = RegExp(AppConstants.doublePattern);
  double _totalIncome = 0.00;
  double _totalExpenses = 0.00;
  static const String _all = 'All';
  static const String _month = 'Month';
  static const String _date = 'Date';
  String _selectedValue;
  Map<String, double> graphStats = <String, double>{
    AppConstants.totalExpense: 0.00,
    AppConstants.totalIncome: 0.00,
  };
  List<String> months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _formFieldController = TextEditingController();

  void _calculateTotalIncome(List<CustomMessage> messages) {
    _totalIncome = 0.0;
    if (messages.isNotEmpty) {
      for (CustomMessage message in messages) {
        if (regExp.hasMatch(message.smsMessage.body)) {
          double value =
              double.tryParse(regExp.stringMatch(message.smsMessage.body));
          if (value != null) {
            _totalIncome += value;
          }
        }
      }
    }

    graphStats[AppConstants.totalIncome] = _totalIncome;
  }

  void _calculateTotalExpense(List<CustomMessage> messages) {
    _totalExpenses = 0.0;
    if (messages.isNotEmpty) {
      for (CustomMessage message in messages) {
        if (regExp.hasMatch(message.smsMessage.body)) {
          double value =
              double.tryParse(regExp.stringMatch(message.smsMessage.body));
          if (value != null) {
            _totalExpenses += value;
          }
        }
      }
    }
    graphStats[AppConstants.totalExpense] = _totalExpenses;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _calculateTotalExpense(widget.statisticsData[AppConstants.expense]);
    _calculateTotalIncome(widget.statisticsData[AppConstants.income]);
    _selectedValue = _dropDownValues[0];
  }

  List<String> _dropDownValues = <String>[_all, _month, _date];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: <Widget>[
            PieChart(
              dataMap: graphStats,
              animationDuration: Duration(milliseconds: 800),
              chartLegendSpacing: 32.0,
              chartRadius: MediaQuery.of(context).size.width / 2.7,
              showChartValuesInPercentage: true,
              showChartValues: true,
              showChartValuesOutside: true,
              chartValueBackgroundColor: Colors.grey[200],
              showLegends: true,
              legendPosition: LegendPosition.bottom,
              decimalPlaces: 2,
              showChartValueLabel: true,
              initialAngle: 0,
              chartValueStyle: defaultChartValueStyle.copyWith(
                color: Colors.blueGrey[900].withOpacity(0.9),
              ),
              chartType: ChartType.disc,
            ),
            ListTile(
              title: Text(
                'Total Income',
              ),
              trailing: Text('\u20B9${_totalIncome.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: Text(
                'Total Expense',
              ),
              trailing: Text('\u20B9${_totalExpenses.toStringAsFixed(2)}'),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedValue,
                      items: _dropDownValues
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              child: Text(value),
                              value: value,
                            ),
                          )
                          .toList(),
                      onChanged: _onDropDownChange,
                    ),
                    if (_selectedValue == _month || _selectedValue == _date)
                      TextFormField(
                        onTap: _onDateChange,
                        readOnly: true,
                        controller: _formFieldController,
                        decoration: InputDecoration(
                          hintText: _selectedValue == _month
                              ? 'Choose a month'
                              : 'Choose a date',
                          suffixIcon: Icon(
                            Icons.calendar_today,
                          ),
                        ),
                      )
                  ].map((Widget child) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: child,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDropDownChange(String value) {
    switch (value) {
      case _all:
        return setState(() {
          _calculateTotalExpense(widget.statisticsData[AppConstants.expense]);
          _calculateTotalIncome(widget.statisticsData[AppConstants.income]);
          _selectedValue = value;
          _formFieldController.text = '';
        });
      case _month:
        return setState(() {
          _selectedValue = value;
          _formFieldController.text = '';
        });
      case _date:
        return setState(() {
          _selectedValue = value;
          _formFieldController.text = '';
        });
      default:
        return setState(() {
          _selectedValue = value;
          _formFieldController.text = '';
        });
    }
  }

  Future<void> _onDateChange() async {
    DateTime value;
    if (_selectedValue == _month) {
      value = await showMonthPicker(
        context: context,
        firstDate: DateTime(DateTime.now().year, 1, 1),
        lastDate: DateTime.now(),
        initialDate: DateTime.now(),
        locale: Locale("en"),
      );
      if (value != null) {
        setState(() {
          _formFieldController.text = months[value.month - 1];
        });
        _filterValues(mode: 1, date: value);
      }
    } else {
      value = await showDatePicker(
        context: context,
        firstDate: DateTime(DateTime.now().year, 1, 1),
        lastDate: DateTime.now(),
        initialDate: DateTime.now(),
        locale: Locale("en"),
      );
      if (value != null) {
        setState(() {
          _formFieldController.text =
              DateFormat('dd/MM/yyyy').format(value).toString();
          _filterValues(mode: 2, date: value);
        });
      }
    }
  }

  void _filterValues({int mode, DateTime date}) {
    List<CustomMessage> filteredIncomeMessages = <CustomMessage>[];
    List<CustomMessage> filteredExpenseMessages = <CustomMessage>[];
    if (mode == 1) {
      filteredIncomeMessages = widget.statisticsData[AppConstants.income]
          .where((CustomMessage element) =>
              element.smsMessage.date.month == date.month)
          .toList();
      filteredExpenseMessages = widget.statisticsData[AppConstants.expense]
          .where((CustomMessage element) =>
              element.smsMessage.date.month == date.month)
          .toList();
    } else {
      filteredIncomeMessages = widget.statisticsData[AppConstants.income]
          .where((CustomMessage element) =>
              DateTime(element.smsMessage.date.year,
                  element.smsMessage.date.month, element.smsMessage.date.day) ==
              DateTime(date.year, date.month, date.day))
          .toList();
      filteredExpenseMessages = widget.statisticsData[AppConstants.expense]
          .where((CustomMessage element) =>
              DateTime(element.smsMessage.date.year,
                  element.smsMessage.date.month, element.smsMessage.date.day) ==
              DateTime(date.year, date.month, date.day))
          .toList();
    }
    setState(() {
      _calculateTotalIncome(filteredIncomeMessages);
      _calculateTotalExpense(filteredExpenseMessages);
    });
  }
}
