import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smsretriever/data/retrieve_sms.dart';
import 'package:smsretriever/models/custom_message.dart';
import 'package:smsretriever/views/helper_widgets/bottom_Sheet.dart';

class ListMessages extends StatefulWidget {
  const ListMessages({Key key, this.messages, this.refreshCallback})
      : super(key: key);

  final List<CustomMessage> messages;
  final VoidCallback refreshCallback;

  @override
  _ListMessagesState createState() => _ListMessagesState();
}

class _ListMessagesState extends State<ListMessages> {
  void showBottomModalSheet(
      BuildContext context, CustomMessage displayMessage) {
    bool _showText = !(displayMessage.tag == null);
    bool isChanged = false;
    final TextEditingController _tagController =
        TextEditingController(text: displayMessage.tag ?? '');

    showModBottomSheet<dynamic>(
        context: context,
        dismissOnTap: false,
        resizeToAvoidBottomPadding: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return InkWell(
              onTap: () {
                setState(() {
                  _showText = false;
                  _tagController.text = '';
                  FocusScope.of(context).unfocus();
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displayMessage.contactName,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headline6
                            .copyWith(
                              color: Colors.black,
                            ),
                      ),
                      if (displayMessage.tag != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.label,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            Text(
                              displayMessage.tag,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .subtitle2
                                  .copyWith(
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                            ),
                          ],
                        )
                    ],
                  ),
                  Text(displayMessage.smsMessage.body),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        DateFormat('E MMM d')
                            .format(displayMessage.smsMessage.date)
                            .toString(),
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _showText
                              ? Icons.done
                              : displayMessage.tag == null
                                  ? Icons.bookmark_border
                                  : Icons.bookmark,
                        ),
                        onPressed: () async {
                          if (!_showText) {
                            setModalState(() {
                              _showText = true;
                              _tagController.text = displayMessage.tag;
                            });
                          } else {
                            setState(() {
                              _showText = false;
                              FocusScope.of(context).unfocus();
                              displayMessage = displayMessage.copyWith(
                                  tag: _tagController.text);
                              _tagController.text = displayMessage.tag;
                            });
                            _saveTag(displayMessage);
                            isChanged = true;
                          }
                        },
                      ),
                    ],
                  ),
                  if (_showText)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: TextField(
                        controller: _tagController,
                        autofocus: displayMessage.tag == null,
                        maxLength: 10,
                        maxLines: 1,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          helperText: 'Tap to edit',
                          border: InputBorder.none,
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                            borderSide: const BorderSide(
                              color: Color(0xFFF3F1F1),
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(
                            20,
                          ),
                          fillColor: const Color(0xFFF3F1F1),
                          filled: true,
                          hintText: 'Enter tag name',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                ]
                    .map(
                      (Widget child) => Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: child,
                      ),
                    )
                    .toList(),
              ),
            );
          });
        }).whenComplete(
      () {
        if (isChanged) {
          widget.refreshCallback?.call();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, left: 2),
      child: Scrollbar(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.messages.length,
          itemBuilder: (BuildContext context, int index) {
            final displayMessage = widget.messages[index];
            return InkWell(
              onTap: () {
                print(displayMessage.toJson());
                showBottomModalSheet(context, displayMessage);
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.withOpacity(0.25),
                  child: FittedBox(
                    child: Text(
                      displayMessage.contactName[0] == '+'
                          ? 'UK'
                          : displayMessage.contactName[0],
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
                title: Text(displayMessage.contactName),
                trailing: displayMessage.tag != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(
                            Icons.label,
                            size: 14,
                            color: Colors.black.withOpacity(0.25),
                          ),
                          FittedBox(
                            child: Text(
                              displayMessage.tag,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyText1
                                  .copyWith(
                                    color: Colors.black.withOpacity(0.25),
                                  ),
                            ),
                          )
                        ],
                      )
                    : Text(''),
                subtitle: Text(
                  displayMessage.smsMessage.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _saveTag(CustomMessage displayMessage) async {
    await SmsRetriever().saveTaggedInboxImage(displayMessage);
  }
}
