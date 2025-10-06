import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/html.dart';
import 'dart:html' as html;
import 'package:wysiwyg/provider/global.dart';
import 'package:wysiwyg/widgets/button.dart';

//Widgets
import 'package:wysiwyg/widgets/avatar.dart';
import 'package:wysiwyg/widgets/checkbox.dart';
import 'package:wysiwyg/widgets/chip.dart';
import 'package:wysiwyg/widgets/datepicker.dart';
import 'package:wysiwyg/widgets/dropdown.dart';
import 'package:wysiwyg/widgets/icon.dart';
import 'package:wysiwyg/widgets/image.dart';
import 'package:wysiwyg/widgets/progressbar.dart';
import 'package:wysiwyg/widgets/radio.dart';
import 'package:wysiwyg/widgets/slider.dart';
import 'package:wysiwyg/widgets/switch.dart';
import 'package:wysiwyg/widgets/text.dart';
import 'package:wysiwyg/widgets/textarea.dart';
import 'package:wysiwyg/widgets/textinput.dart';
import 'package:wysiwyg/widgets/timepicker.dart';
 

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({super.key});

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  List<Map<String, dynamic>> widgets = [];
  late HtmlWebSocketChannel channel;
  double gridSize = 20.0;
  OverlayEntry? _contextMenuOverlay;
  double rowHeight = 100.0;
  final int columnCount = 12;
  double columnWidth = 1440 / 12;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        columnWidth = screenSize.width / columnCount;
        gridSize = (columnWidth / 6).clamp(10.0, 30.0);
        rowHeight = gridSize * 5;
      });
      print('Flutter: Initialized canvas - columnWidth: $columnWidth, gridSize: $gridSize, rowHeight: $rowHeight');
    });

    html.window.onContextMenu.listen((event) {
      event.preventDefault();
    });

    final sessionId = Uri.base.queryParameters['sessionId'] ?? 'default';
    channel = HtmlWebSocketChannel.connect('ws://192.168.2.95:8080');

    channel.sink.add(jsonEncode({'action': 'CONNECT', 'sessionId': sessionId}));
    print('Flutter: Sent CONNECT message with sessionId: $sessionId');

    channel.stream.listen(
      (message) {
        String msgString;
        if (message is Uint8List) {
          msgString = utf8.decode(message);
        } else if (message is String) {
          msgString = message;
        } else {
          print('Flutter: Invalid message type: $message');
          return;
        }

        try {
          final data = jsonDecode(msgString) as Map<String, dynamic>?;
          if (data == null || data['action'] == null) {
            print('Flutter: Invalid or missing action in message: $msgString');
            return;
          }
          final action = data['action'] as String;

          setState(() {
            if (action == 'INIT') {
              widgets = [];
              final jsonData = data['data'] as Map<String, dynamic>?;
              if (jsonData == null || !jsonData.containsKey('root') || jsonData.isEmpty) {
                print('Flutter: Empty or invalid INIT data, requesting JSON');
                channel.sink.add(jsonEncode({
                  'action': 'REQUEST_JSON',
                  'sessionId': sessionId,
                }));
                return;
              }

              print('Flutter: Processing INIT data: $jsonData');

              for (var key in jsonData.keys.where((k) => k != 'root')) {
                final w = jsonData[key] as Map<String, dynamic>?;
                if (w == null) {
                  print('Flutter: Skipping null widget for key: $key');
                  continue;
                }
                final propsMeta = w['property'] is Map
                    ? (w['property']['props']?['meta'] as Map<String, dynamic>?) ?? {}
                    : {};
                final row = int.tryParse(propsMeta['row']?.toString() ?? '1') ?? 1;
                final col = int.tryParse(propsMeta['col']?.toString() ?? '1') ?? 1;
                final rowSpan = int.tryParse(propsMeta['rowSpan']?.toString() ?? '1') ?? 1;
                final colSpan = int.tryParse(propsMeta['colSpan']?.toString() ?? '1') ?? 1;

                final x = (col - 1) * columnWidth;
                final y = (row - 1) * rowHeight;
                final width = colSpan * columnWidth;
                final height = rowSpan * rowHeight;

                final nodeProperty = (w['data']?['nodeProperty'] as Map<String, dynamic>?) ?? {
                  'nodeId': w['id']?.toString() ?? key,
                  'nodeName': w['property']?['name']?.toString() ?? w['type']?.toString().toLowerCase() ?? 'unknown',
                  'nodeType': w['type']?.toString().toLowerCase() ?? 'unknown',
                  'nodeVersion': 'v1',
                  'elementInfo': {},
                };

                widgets.add({
                  'id': w['id']?.toString() ?? key,
                  'type': w['type']?.toString().toLowerCase() ?? 'unknown',
                  'pos': Offset(
                    snap(x).toDouble(),
                    snap(y).toDouble(),
                  ),
                  'size': Size(
                    snap(width).toDouble(),
                    snap(height).toDouble(),
                  ),
                  'parentId': w['parent']?.toString() ?? w['T_parentId']?.toString() ?? 'root',
                  'name': w['property'] is Map
                      ? (w['property']['name']?.toString() ?? w['type']?.toString().toLowerCase() ?? 'unknown')
                      : 'unknown',
                  'label': w['data'] is Map
                      ? (w['data']['label']?.toString() ?? w['type']?.toString().toLowerCase() ?? 'unknown')
                      : 'unknown',
                  'row': row,
                  'col': col,
                  'rowSpan': rowSpan,
                  'colSpan': colSpan,
                  'nodeProperty': nodeProperty,
                });
              }
              print('Flutter: Initialized widgets from JSON: $widgets');
              emitJson();
            } else if (action == 'DROP') {
              final type = data['type']?.toString();
              if (type == null) {
                print('Flutter: Missing type in DROP action');
                return;
              }
              if (type == 'appbar' && widgets.any((w) => w['type'] == 'appbar')) {
                print('Flutter: AppBar already exists, ignoring DROP');
                return;
              }
              if (type == 'floatingactionbutton' && widgets.any((w) => w['type'] == 'floatingactionbutton')) {
                print('Flutter: FloatingActionButton already exists, ignoring DROP');
                return;
              }
              if (!widgets.any((w) => w['id'] == data['id']?.toString())) {
                final defaultSize = type == 'group'
                    ? const Size(200.0, 100.0)
                    : Size(
                        (data['width'] as num?)?.toDouble() ?? 120.0,
                        (data['height'] as num?)?.toDouble() ?? 50.0,
                      );
                final snappedSize = snapSize(defaultSize);
                final snappedPos = snapToGrid(Offset(
                  (data['x'] as num?)?.toDouble() ?? 0.0,
                  (data['y'] as num?)?.toDouble() ?? 0.0,
                ));

                Offset finalPos = snappedPos;
                int offsetCount = 0;
                final id = data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
                while (widgets.any((w) => w['pos'] == finalPos && w['id'] != id)) {
                  offsetCount++;
                  finalPos = Offset(
                    snappedPos.dx + offsetCount * gridSize,
                    snappedPos.dy + offsetCount * gridSize,
                  );
                }

                final row = (finalPos.dy / rowHeight).floor() + 1;
                final col = (finalPos.dx / columnWidth).floor() + 1;
                final rowSpan = (snappedSize.height / rowHeight).ceil();
                final colSpan = (snappedSize.width / columnWidth).ceil();

                final nodeProperty = (data['data']?['nodeProperty'] as Map<String, dynamic>?) ?? {
                  'nodeId': id,
                  'nodeName': data['name']?.toString() ?? type.toLowerCase(),
                  'nodeType': type.toLowerCase(),
                  'nodeVersion': 'v1',
                  'elementInfo': {},
                };

                widgets.add({
                  'id': id,
                  'type': type.toLowerCase(),
                  'pos': finalPos,
                  'size': snappedSize,
                  'parentId': data['parentId']?.toString() ?? 'root',
                  'name': data['name']?.toString() ?? type.toLowerCase(),
                  'label': data['label']?.toString() ?? type.toLowerCase(),
                  'row': data['row'] as int? ?? row,
                  'col': data['col'] as int? ?? col,
                  'rowSpan': data['rowSpan'] as int? ?? rowSpan,
                  'colSpan': data['colSpan'] as int? ?? colSpan,
                  'nodeProperty': nodeProperty,
                });
                print('Flutter: Added widget from DROP: $id');
                emitJson();
              }
            } else if (action == 'RESIZE') {
              final id = data['id']?.toString();
              if (id == null) {
                print('Flutter: Missing id in RESIZE action');
                return;
              }
              final idx = widgets.indexWhere((w) => w['id'] == id);
              if (idx != -1) {
                final newSize = snapSize(Size(
                  (data['width'] as num?)?.toDouble() ?? widgets[idx]['size'].width,
                  (data['height'] as num?)?.toDouble() ?? widgets[idx]['size'].height,
                ));
                final rowSpan = (newSize.height / rowHeight).ceil();
                final colSpan = (newSize.width / columnWidth).ceil();
                widgets[idx]['size'] = newSize;
                widgets[idx]['rowSpan'] = rowSpan;
                widgets[idx]['colSpan'] = colSpan;
                print('Flutter: Resized widget: $id');
                emitJson();
              }
            } else if (action == 'MOVE') {
              final id = data['id']?.toString();
              if (id == null) {
                print('Flutter: Missing id in MOVE action');
                return;
              }
              final idx = widgets.indexWhere((w) => w['id'] == id);
              if (idx != -1) {
                final newPos = snapToGrid(Offset(
                  (data['x'] as num?)?.toDouble() ?? widgets[idx]['pos'].dx,
                  (data['y'] as num?)?.toDouble() ?? widgets[idx]['pos'].dy,
                ));
                final row = (newPos.dy / rowHeight).floor() + 1;
                final col = (newPos.dx / columnWidth).floor() + 1;
                widgets[idx]['pos'] = newPos;
                widgets[idx]['parentId'] = data['parentId']?.toString() ?? widgets[idx]['parentId'];
                widgets[idx]['row'] = row;
                widgets[idx]['col'] = col;
                print('Flutter: Moved widget: $id');
                emitJson();
              }
            } else if (action == 'DELETE') {
              final id = data['id']?.toString();
              if (id == null) {
                print('Flutter: Missing id in DELETE action');
                return;
              }
              widgets.removeWhere((w) => w['id'] == id);
              print('Flutter: Deleted widget: $id');
              emitJson();
            } else if (action == 'UPDATE_CURRENT_NODE') {
              final id = data['id']?.toString();
              if (id == null) {
                print('Flutter: Missing id in UPDATE_CURRENT_NODE action');
                return;
              }
              final path = data['path']?.toString();
              final value = data['value'];
              if (path == null) {
                print('Flutter: Missing path in UPDATE_CURRENT_NODE action');
                return;
              }
              final pathParts = path.split('.');
              try {
                Provider.of<GlobalProvider>(context, listen: false)
                    .currentNode['nodeProperty']['elementInfo'][pathParts[0]]
                    [int.tryParse(pathParts[1])][pathParts[2]] = value;
                print('Flutter: Updated node property for id: $id, path: $path');
              } catch (e) {
                print('Flutter: Error updating node property at path $path: $e');
              }
              emitJson();
            }
          });
        } catch (err) {
          print('Flutter: Error parsing WebSocket message: $err');
        }
      },
      onError: (error) {
        print('Flutter: WebSocket error: $error');
      },
      onDone: () {
        print('Flutter: WebSocket closed, attempting to reconnect...');
        Future.delayed(Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            channel = HtmlWebSocketChannel.connect('ws://192.168.2.95:8080');
            channel.sink.add(jsonEncode({'action': 'CONNECT', 'sessionId': sessionId}));
          });
        });
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      channel.sink.add(jsonEncode({
        'action': 'REQUEST_JSON',
        'sessionId': sessionId,
      }));
      print('Flutter: Sent REQUEST_JSON on init');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    emitJson();
    print('Flutter: didChangeDependencies called, widgets: ${widgets.length}');
  }

  double snap(double val) {
    return (val / gridSize).round() * gridSize;
  }

  Offset snapToGrid(Offset pos) {
    return Offset(
      snap(pos.dx),
      snap(pos.dy),
    );
  }

  Size snapSize(Size size) {
    return Size(
      snap(size.width),
      snap(size.height),
    );
  }

  void emitJson() {
    final jsonOutput = {
      'root': {
        'id': 'root',
        'Parent': 'root',
        'type': 'Canvas',
        'T_parentId': 'root',
        'children': widgets
            .where((w) => w['parentId'] == 'root')
            .map((w) => w['id']?.toString())
            .where((id) => id != null)
            .toList(),
        'data': {
          'label': 'Root',
          'nodeProperty': {
            'nodeId': 'root',
            'nodeName': 'Root',
            'nodeType': 'Canvas',
            'nodeVersion': 'v1',
            'elementInfo': {},
          },
        },
        'grid': {
          'style': {},
        },
        'property': {
          'name': '',
          'nodeType': 'Canvas',
          'description': '',
          'backgroundColor': '#ffffff',
          'rowHeight': '100px',
          'rowGap': '10px',
          'columnGap': '10px',
          'props': {
            'meta': {
              'row': 1,
              'col': 1,
              'rowSpan': 12,
              'colSpan': 12,
            },
          },
          'rowCount': 100,
          'columnCount': 12,
          'width': 1440,
          'height': 900,
        },
        'groupType': 'group',
      },
    };

    for (var widget in widgets) {
      final widgetType = widget['type']?.toString().toLowerCase() ?? 'unknown';
      String category = 'Defaults';

      if (['button', 'textinput', 'checkbox', 'radio', 'toggle', 'switch', 'counterbutton'].contains(widgetType)) {
        category = 'Inputs';
      } else if (['image', 'card', 'chip', 'icon', 'avatar', 'qrcode'].contains(widgetType)) {
        category = 'DataDisplay';
      } else if (widgetType == 'tabs') {
        category = 'Navigation';
      }

      final isGroup = widgetType == 'group';
      final widgetId = widget['id']?.toString();
      if (widgetId == null) {
        print('Flutter: Skipping widget with null id in emitJson');
        continue;
      }

      final nodeProperty = widget['nodeProperty'] as Map<String, dynamic>? ?? {
        'nodeId': widgetId,
        'nodeName': widget['name']?.toString() ?? widgetType,
        'nodeType': widgetType,
        'nodeVersion': 'v1',
        'elementInfo': {},
      };

      jsonOutput[widgetId] = {
        'id': widgetId,
        'parent': widget['parentId']?.toString() ?? 'root',
        'type': widgetType,
        'T_parentId': widget['parentId']?.toString() ?? 'root',
        'children': widgets
            .where((w) => w['parentId'] == widgetId)
            .map((w) => w['id']?.toString())
            .where((id) => id != null)
            .toList(),
        'property': {
          'props': {
            'meta': {
              'row': widget['row'] as int? ?? 1,
              'col': widget['col'] as int? ?? 1,
              'rowSpan': widget['rowSpan'] as int? ?? 1,
              'colSpan': widget['colSpan'] as int? ?? 1,
            },
          },
          'name': widget['name']?.toString() ?? widgetType,
          'nodeType': widgetType,
          'description': '',
          if (isGroup) ...{
            'columnCount': 12,
            'rowCount': 4,
          } else ...{
            'rowCount': widget['rowSpan'] as int? ?? 1,
          },
        },
        'grid': {
          'style': {
            'styles': '',
          },
        },
        'groupType': 'group',
        't_parentId': widget['parentId']?.toString() ?? 'root',
        'data': {
          'label': widget['label']?.toString() ?? widgetType,
          'nodeAppearance': {
            'icon': 'https://varnishdev.gsstvl.com/files/torus/9.1/resources/nodeicons/UF-UFM/$widgetType.svg',
            'label': widgetType,
            'color': '#0736C4',
            'shape': 'square',
            if (widgetType == 'button') 'size': 45,
          },
          'nodeProperty': nodeProperty,
        },
        'version': 'TRL:AFR:UF-UFM:Flutter:$category:$widgetType:v1',
      };
    }

    channel.sink.add(jsonEncode({
      'action': 'JSON',
      'json': jsonOutput,
      'sessionId': Uri.base.queryParameters['sessionId'] ?? 'default',
    }));
    print('Flutter: Emitted JSON to React: $jsonOutput');
  }

  bool isPointInWidget(Offset point, Map<String, dynamic> group) {
    final groupPos = group['pos'] as Offset?;
    final groupSize = group['size'] as Size?;
    if (groupPos == null || groupSize == null) {
      print('Flutter: Invalid group pos or size for ${group['id']}');
      return false;
    }
    return point.dx >= groupPos.dx &&
        point.dx < groupPos.dx + groupSize.width &&
        point.dy >= groupPos.dy &&
        point.dy < groupPos.dy + groupSize.height;
  }

  String? findGroupAtPosition(Offset pos, String? excludeId) {
    for (var group in widgets.where((w) => w['type'] == 'group' && w['id'] != excludeId)) {
      if (isPointInWidget(pos, group)) {
        print('Flutter: Found group at position $pos: ${group['id']}');
        return group['id']?.toString();
      }
    }
    return null;
  }

  List<String> _getDescendantIds(String? parentId) {
    if (parentId == null) return [];
    final descendantIds = <String>[];
    final children = widgets.where((w) => w['parentId'] == parentId).toList();
    for (var child in children) {
      final childId = child['id']?.toString();
      if (childId != null) {
        descendantIds.add(childId);
        if (child['type'] == 'group') {
          descendantIds.addAll(_getDescendantIds(childId));
        }
      }
    }
    print('Flutter: Descendant IDs for parent $parentId: $descendantIds');
    return descendantIds;
  }

  void _showContextMenu(Offset position, Map<String, dynamic> widget) {
    final widgetId = widget['id']?.toString();
    if (widgetId == null) {
      print('Flutter: Cannot show context menu for widget with null id');
      return;
    }
    _hideContextMenu();

    final adjustedPosition = Offset(
      position.dx.clamp(0, 320 - 150),
      position.dy.clamp(0, 651 - 120),
    );

    _contextMenuOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _hideContextMenu,
        child: Stack(
          children: [
            Positioned(
              left: adjustedPosition.dx,
              top: adjustedPosition.dy,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Edit Node'),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        onTap: () {
                          _hideContextMenu();
                          setState(() {
                            _editNode(widget);
                          });
                        },
                      ),
                      if (widget['type']?.toString().toLowerCase() != 'appbar')
                        ListTile(
                          title: const Text('Duplicate'),
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          onTap: () {
                            _hideContextMenu();
                            _duplicateWidget(widget);
                          },
                        ),
                      ListTile(
                        title: const Text('Delete'),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        onTap: () {
                          _hideContextMenu();
                          setState(() {
                            final deleteIds = [widgetId];
                            if (widget['type'] == 'group') {
                              final descendantIds = _getDescendantIds(widgetId);
                              deleteIds.addAll(descendantIds);
                            }
                            widgets.removeWhere((w) => deleteIds.contains(w['id']));
                            for (var id in deleteIds) {
                              channel.sink.add(jsonEncode({
                                'action': 'DELETE',
                                'id': id,
                                'sessionId': Uri.base.queryParameters['sessionId'] ?? 'default',
                              }));
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_contextMenuOverlay!);
    print('Flutter: Showing context menu for widget $widgetId at $adjustedPosition');
  }

  void _hideContextMenu() {
    if (_contextMenuOverlay != null) {
      _contextMenuOverlay?.remove();
      _contextMenuOverlay = null;
      print('Flutter: Hid context menu');
    }
  }

  void _editNode(Map<String, dynamic> widget) {
    final widgetId = widget['id']?.toString();
    if (widgetId == null) {
      print('Flutter: Cannot edit node with null id');
      return;
    }

    final nodeData = Map<String, dynamic>.from(widget);
    Provider.of<GlobalProvider>(context, listen: false).setCurrentNode(nodeData);
    print('Flutter: Updated currentNode: ${Provider.of<GlobalProvider>(context, listen: false).currentNode}');

    channel.sink.add(jsonEncode({
      'action': 'SET_NODE_PROPERTY',
      'id': widgetId,
      'data': {
        'label': widget['label'],
        'nodeProperty': widget['nodeProperty'] ?? {
          'nodeId': widgetId,
          'nodeName': widget['name'],
          'nodeType': widget['type']?.toString() ?? 'unknown',
          'nodeVersion': 'v1',
          'elementInfo': {},
        },
      },
      'sessionId': Uri.base.queryParameters['sessionId'] ?? 'default',
    }));

    emitJson();
  }

  void _duplicateWidget(Map<String, dynamic> widget) {
    final widgetId = widget['id']?.toString();
    final widgetType = widget['type']?.toString().toLowerCase() ?? 'unknown';
    if (widgetId == null) {
      print('Flutter: Cannot duplicate widget with null id');
      return;
    }
    if (widgetType == 'appbar') {
      print('Flutter: Cannot duplicate AppBar');
      return;
    }
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final pos = widget['pos'] as Offset? ?? const Offset(0, 0);
    Offset newPos = pos + const Offset(20, 20);
    int offsetCount = 0;
    while (widgets.any((w) => w['pos'] == newPos && w['id'] != newId)) {
      offsetCount++;
      newPos = pos + Offset(offsetCount * gridSize, offsetCount * gridSize);
    }
    final snappedPos = snapToGrid(newPos);
    final newParentId = findGroupAtPosition(snappedPos, newId) ?? 'root';
    final row = (snappedPos.dy / rowHeight).floor() + 1;
    final col = (snappedPos.dx / columnWidth).floor() + 1;
    final rowSpan = (widget['rowSpan'] as int?) ?? ((widget['size'] as Size?)?.height ?? rowHeight / rowHeight).ceil();
    final colSpan = (widget['colSpan'] as int?) ?? ((widget['size'] as Size?)?.width ?? columnWidth / columnWidth).ceil();

    setState(() {
      widgets.add({
        'id': newId,
        'type': widgetType,
        'pos': snappedPos,
        'size': widget['size'] as Size? ?? const Size(120, 50),
        'parentId': newParentId,
        'name': '${widget['name']?.toString() ?? widgetType}_copy',
        'label': '${widget['label']?.toString() ?? widgetType}_copy',
        'row': row,
        'col': col,
        'rowSpan': rowSpan,
        'colSpan': colSpan,
        'nodeProperty': widget['nodeProperty'] ?? {
          'nodeId': newId,
          'nodeName': '${widget['name']?.toString() ?? widgetType}_copy',
          'nodeType': widgetType,
          'nodeVersion': 'v1',
          'elementInfo': {},
        },
      });
      print('Flutter: Duplicated widget $widgetId to $newId');
    });

    channel.sink.add(jsonEncode({
      'action': 'DROP',
      'id': newId,
      'type': widgetType,
      'x': snappedPos.dx,
      'y': snappedPos.dy,
      'width': (widget['size'] as Size?)?.width ?? 120.0,
      'height': (widget['size'] as Size?)?.height ?? 50.0,
      'parentId': newParentId,
      'name': '${widget['name']?.toString() ?? widgetType}_copy',
      'label': '${widget['label']?.toString() ?? widgetType}_copy',
      'row': row,
      'col': col,
      'rowSpan': rowSpan,
      'colSpan': colSpan,
      'sessionId': Uri.base.queryParameters['sessionId'] ?? 'default',
      'data': {
        'label': '${widget['label']?.toString() ?? widgetType}_copy',
        'nodeProperty': widget['nodeProperty'] ?? {
          'nodeId': newId,
          'nodeName': '${widget['name']?.toString() ?? widgetType}_copy',
          'nodeType': widgetType,
          'nodeVersion': 'v1',
          'elementInfo': {},
        },
      },
    }));
  }

  Widget interactiveWrapper(Map<String, dynamic> w, Widget child) {
    final id = w['id']?.toString();
    if (id == null) {
      print('Flutter: Cannot wrap widget with null id');
      return const SizedBox.shrink();
    }

    final pos = w['pos'] as Offset? ?? const Offset(0, 0);
    final size = w['size'] as Size? ?? const Size(120, 50);
    print('Flutter: Rendering interactive wrapper for widget $id at $pos with size $size');

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onSecondaryTapDown: (details) {
          _showContextMenu(details.globalPosition, w);
        },
        child: ResizableWidget(
          size: size,
          pos: pos,
          onResize: (newSize) {
            final snapped = snapSize(newSize);
            final rowSpan = (snapped.height / rowHeight).ceil();
            final colSpan = (snapped.width / columnWidth).ceil();
            setState(() {
              w['size'] = snapped;
              w['rowSpan'] = rowSpan;
              w['colSpan'] = colSpan;
              print('Flutter: Resized widget $id to $snapped');
            });

            channel.sink.add(jsonEncode({
              'action': 'RESIZE',
              'id': id,
              'width': snapped.width,
              'height': snapped.height,
              'rowSpan': rowSpan,
              'colSpan': colSpan,
              'sessionId': Uri.base.queryParameters['sessionId'] ?? 'default',
            }));
          },
          onMove: (newPos) {
            final delta = newPos - pos;
            final snapped = snapToGrid(newPos);
            final row = (snapped.dy / rowHeight).floor() + 1;
            final col = (snapped.dx / columnWidth).floor() + 1;
            setState(() {
              w['pos'] = snapped;
              w['row'] = row;
              w['col'] = col;

              final newParentId = findGroupAtPosition(snapped, id) ?? 'root';
              if (w['parentId'] != newParentId) {
                w['parentId'] = newParentId;
                print('Flutter: Updated parentId for $id to $newParentId');
              }

              if (w['type'] == 'group') {
                final children = widgets.where((child) => child['parentId'] == id).toList();
                for (var child in children) {
                  final childPos = child['pos'] as Offset? ?? const Offset(0, 0);
                  final newChildPos = childPos + delta;
                  final snappedChildPos = snapToGrid(newChildPos);
                  final childRow = (snappedChildPos.dy / rowHeight).floor() + 1;
                  final childCol = (snappedChildPos.dx / columnWidth).floor() + 1;
                  child['pos'] = snappedChildPos;
                  child['row'] = childRow;
                  child['col'] = childCol;
                  print('Flutter: Moved child ${child['id']} to $snappedChildPos');
                }
              }
            });

            channel.sink.add(jsonEncode({
              'action': 'MOVE',
              'id': id,
              'x': snapped.dx,
              'y': snapped.dy,
              'row': row,
              'col': col,
              'parentId': w['parentId']?.toString() ?? 'root',
              'sessionId': Uri.base.queryParameters['sessionId'] ?? 'default',
            }));

            if (w['type'] == 'group') {
              final children = widgets.where((child) => child['parentId'] == id).toList();
              for (var child in children) {
                final childId = child['id']?.toString();
                if (childId == null) continue;
                final snappedChildPos = snapToGrid(child['pos'] as Offset? ?? const Offset(0, 0));
                final childRow = (snappedChildPos.dy / rowHeight).floor() + 1;
                final childCol = (snappedChildPos.dx / columnWidth).floor() + 1;
                channel.sink.add(jsonEncode({
                  'action': 'MOVE',
                  'id': childId,
                  'x': snappedChildPos.dx,
                  'y': snappedChildPos.dy,
                  'row': childRow,
                  'col': childCol,
                  'parentId': child['parentId']?.toString() ?? 'root',
                  'sessionId': Uri.base.queryParameters['sessionId'] ?? 'default',
                }));
              }
            }
          },
          child: child,
        ),
      ),
    );
  }

  PreferredSizeWidget? buildAppBarWidget(Map<String, dynamic> w) {
    final type = w['type']?.toString().toLowerCase() ?? 'unknown';
    final size = w['size'] as Size? ?? const Size(120, 50);
    if (type != 'appbar') {
      return null;
    }
    print('Flutter: Rendering AppBar widget ${w['id']}');
    return PreferredSize(
      preferredSize: Size(size.width, size.height),
      child: AppBar(
        title: Text(w['label']?.toString() ?? 'AppBar'),
        automaticallyImplyLeading: false,
      ),
    );
  }

  Widget buildWidget(Map<String, dynamic> w, bool isEdit) {
    final size = w['size'] as Size? ?? const Size(120, 50);
    final type = w['type']?.toString().toLowerCase() ?? 'unknown';
    Widget base;

    print('Flutter: Building widget ${w['id']} of type $type with size $size at ${w['pos']}');

 switch (type) {
      case 'appbar':
        base = PreferredSize(
          preferredSize: Size(size.width, size.height),
          child: AppBar(
            title: Text(w['label']?.toString() ?? 'AppBar'),
            automaticallyImplyLeading: false,
          ),
        );
        break;
      case 'floatingactionbutton':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: FloatingActionButton(
            onPressed: () {},
            tooltip: 'Save',
            child: const Icon(Icons.save),
          ),
        );
        break;
      case 'button':
        base = SizedBox(
            width: size.width,
            height: size.height,
            child: TorusButton(
              text: w['label']?.toString() ?? 'Click Me',
              varient: (Provider.of<GlobalProvider>(context, listen: false).currentNode['nodeProperty']
                          ?['elementInfo']?['props'] is List &&
                      (Provider.of<GlobalProvider>(context, listen: false).currentNode['nodeProperty']
                                  ?['elementInfo']?['props'] as List)
                              .length >
                          1 &&
                      (Provider.of<GlobalProvider>(context, listen: false).currentNode['nodeProperty']
                          ?['elementInfo']?['props'] as List)[1] is Map)
                  ? (Provider.of<GlobalProvider>(context, listen: false).currentNode['nodeProperty']
                              ?['elementInfo']?['props'] as List)[1]['value']
                          ?.toString() ??
                      'secondary'
                  : 'secondary',
            ));
        break;
      case 'textinput':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TTextField(),
        );
        break;
      case 'group':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2.0),
              color: Colors.grey.withOpacity(0.1),
            ),
            child: Center(
                child: Text(w['label']?.toString() ?? 'group',
                    style: const TextStyle(fontSize: 16))),
          ),
        );
        break;
      case 'dropdown':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TDropdown(),
        );
        break;
      case 'textarea':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TTextArea(),
        );
        break;
      case 'timepicker':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TTimePicker(),
        );
        break;
      case 'radio':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TRadio(),
        );
        break;
      case 'datepicker':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TDatePicker(),
        );
        break;
      case 'checkbox':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TCheckbox(),
        );
        break;
      case 'slider':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TSlider(value: 0, onChanged: (value) {},),
        );
        break;
      case 'switch':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TSwitch(),
        );
        break;
      case 'avatar':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TAvatar(),
        );
        break;
      case 'chip':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TChip(),
        );
        break;
      case 'image':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TImage(),
        );
        break;
      case 'text':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TextWidget(text: '',),
        );
        break;
      case 'icon':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TIcon(),
         
        );
        break;
      case 'progressbar':
        base = SizedBox(
          width: size.width,
          height: size.height,
          child: TProgressbar(),
        );
        break;
      default:
        base = const SizedBox.shrink();
    }
 
    if (type == 'appbar') {
      return Positioned(
        left: 0,
        top: 0,
        child: base,
      );
    }

    return interactiveWrapper(w, base);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final appBarWidget = widgets.firstWhere(
      (w) => w['type']?.toString() == 'appbar',
      orElse: () => <String, dynamic>{},
    );
    final otherWidgets = widgets.where((w) => w['type']?.toString() != 'appbar' && w['parentId'] == 'root').toList();

    print('Flutter: Building canvas with ${otherWidgets.length} root-level widgets, screenSize: $screenSize');

    return Scaffold(
      appBar: appBarWidget.isNotEmpty ? buildAppBarWidget(appBarWidget) : null,
      body: Container(
        color: Colors.white,
        width: screenSize.width,
        height: double.infinity,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(screenSize.width, screenSize.height),
              painter: GridPainter(gridSize: gridSize),
            ),
            ...otherWidgets.map((w) => buildWidget(w, false)).toList(),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final double gridSize;
  GridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ResizableWidget extends StatefulWidget {
  final Widget child;
  final Size size;
  final Offset pos;
  final Function(Size) onResize;
  final Function(Offset) onMove;
  final bool dev;

  const ResizableWidget({
    super.key,
    required this.child,
    required this.size,
    required this.pos,
    required this.onResize,
    required this.onMove,
    this.dev = true,
  });

  @override
  State<ResizableWidget> createState() => _ResizableWidgetState();
}

class _ResizableWidgetState extends State<ResizableWidget> {
  late double width;
  late double height;
  late Offset pos;
  bool _isResizing = false;
  bool _isDragging = false;
  bool _isHovered = false;
  String? _activeHandle;

  @override
  void initState() {
    super.initState();
    width = widget.size.width;
    height = widget.size.height;
    pos = widget.pos;
    print('Flutter: Initialized ResizableWidget at $pos with size $width x $height');
  }

  @override
  void didUpdateWidget(covariant ResizableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size) {
      setState(() {
        width = widget.size.width;
        height = widget.size.height;
        print('Flutter: Updated ResizableWidget size to $width x $height');
      });
    }
    if (oldWidget.pos != widget.pos) {
      setState(() {
        pos = widget.pos;
        print('Flutter: Updated ResizableWidget pos to $pos');
      });
    }
  }

  Widget _buildHandle({
    required String position,
    required Function(DragUpdateDetails) onPanUpdate,
  }) {
    const double handleSize = 12.0;
    const double offset = handleSize / 2;

    double? left, top, right, bottom;
    MouseCursor cursor;
    switch (position) {
      case 'top':
        left = (width - handleSize) / 2;
        top = -offset;
        cursor = SystemMouseCursors.resizeUpDown;
        break;
      case 'bottom':
        left = (width - handleSize) / 2;
        bottom = -offset;
        cursor = SystemMouseCursors.resizeUpDown;
        break;
      case 'left':
        left = -offset;
        top = (height - handleSize) / 2;
        cursor = SystemMouseCursors.resizeLeftRight;
        break;
      case 'right':
        right = -offset;
        top = (height - handleSize) / 2;
        cursor = SystemMouseCursors.resizeLeftRight;
        break;
      default:
        cursor = SystemMouseCursors.basic;
    }

    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) {
            setState(() {
              _isResizing = true;
              _activeHandle = position;
              print('Flutter: Started resizing at $position');
            });
          },
          onPanUpdate: onPanUpdate,
          onPanEnd: (_) {
            setState(() {
              _isResizing = false;
              _activeHandle = null;
              print('Flutter: Ended resizing, new size: $width x $height');
            });
            widget.onResize(Size(width, height));
            widget.onMove(pos);
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _activeHandle == position ? Colors.blue : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.dev) {
      return SizedBox(
        width: width,
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: widget.child,
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          print('Flutter: Hovered over ResizableWidget');
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          print('Flutter: Exited ResizableWidget');
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {
          if (!_isResizing) {
            setState(() => _isDragging = true);
            print('Flutter: Started dragging');
          }
        },
        onPanUpdate: (details) {
          if (_isDragging && !_isResizing) {
            setState(() {
              pos += details.delta;
              print('Flutter: Dragging to $pos');
            });
            widget.onMove(pos);
          }
        },
        onPanEnd: (_) {
          if (_isDragging && !_isResizing) {
            setState(() => _isDragging = false);
            print('Flutter: Ended dragging at $pos');
            widget.onMove(pos);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _isResizing || _isDragging ? Colors.blue : Colors.grey.shade200,
              width: _isResizing || _isDragging ? 1.0 : 0.5,
            ),
          ),
          child: Stack(
            children: [
              SizedBox(
                width: width,
                height: height,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: widget.child,
                ),
              ),
              if (_isHovered || _isResizing || _isDragging) ...[
                _buildHandle(
                  position: 'top',
                  onPanUpdate: (details) {
                    setState(() {
                      double newHeight = (height - details.delta.dy).clamp(20.0, double.infinity);
                      double deltaY = height - newHeight;
                      pos = Offset(pos.dx, pos.dy + deltaY);
                      height = newHeight;
                    });
                  },
                ),
                _buildHandle(
                  position: 'bottom',
                  onPanUpdate: (details) {
                    setState(() {
                      height = (height + details.delta.dy).clamp(20.0, double.infinity);
                    });
                  },
                ),
                _buildHandle(
                  position: 'left',
                  onPanUpdate: (details) {
                    setState(() {
                      double newWidth = (width - details.delta.dx).clamp(20.0, double.infinity);
                      double deltaX = width - newWidth;
                      pos = Offset(pos.dx + deltaX, pos.dy);
                      width = newWidth;
                    });
                  },
                ),
                _buildHandle(
                  position: 'right',
                  onPanUpdate: (details) {
                    setState(() {
                      width = (width + details.delta.dx).clamp(20.0, double.infinity);
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}