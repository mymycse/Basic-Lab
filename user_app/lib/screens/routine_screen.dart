import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RoutineScreen extends StatelessWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
    final routineRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('routines');

    final now = DateTime.now();
    final formattedDate = DateFormat('M/d EEEE', 'ko_KR').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xCC1ea698),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          formattedDate,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1ea698),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddRoutineDialog(routineRef: routineRef),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: routineRef.orderBy('sortKey').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final id = docs[index].id;
                      final time = data['time'] ?? '';
                      final title = data['title'] ?? '';
                      final completed = data['completed'] ?? false;
                      final by = data['by'] ?? 'guardian';
                      final pinned = data['pinned'] ?? false;
                      final ampm = data['ampm'] ?? '';

                      final backgroundColor = completed
                          ? const Color(0xFFB0B0B0)
                          : pinned
                          ? const Color(0xFF1ea698)
                          : const Color(0xFFEDEDED);

                      final textColor = pinned ? Colors.white : Colors.black87;
                      final titleStyle = TextStyle(
                        fontSize: 25,
                        color: completed ? Colors.grey : textColor,
                        decoration: completed ? TextDecoration.lineThrough : TextDecoration.none,
                      );

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$ampm $time  $title', style: titleStyle),
                              Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor: pinned ? Colors.white : Colors.grey,
                                  checkboxTheme: CheckboxThemeData(
                                    checkColor: MaterialStateProperty.all(pinned ? Colors.white : Colors.white),
                                    fillColor: MaterialStateProperty.resolveWith((states) {
                                      if (states.contains(MaterialState.selected)) {
                                        return const Color(0xFF1ea698);
                                      }
                                      return pinned ? Colors.white : Colors.white;
                                    }),
                                  ),
                                ),
                                child: Checkbox(
                                  value: completed,
                                  onChanged: (val) {
                                    routineRef.doc(id).update({'completed': val});
                                  },
                                ),
                              ),
                            ],
                          ),
                          subtitle: by == 'guardian'
                              ? Text('보호자에게 알림 보내기', style: TextStyle(fontSize: 20, color: textColor))
                              : null,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => EditRoutineDialog(
                                routineRef: routineRef,
                                docId: id,
                                existingData: data,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AddRoutineDialog extends StatefulWidget {
  final CollectionReference routineRef;
  const AddRoutineDialog({super.key, required this.routineRef});

  @override
  State<AddRoutineDialog> createState() => _AddRoutineDialogState();
}

class _AddRoutineDialogState extends State<AddRoutineDialog> {
  final TextEditingController _titleController = TextEditingController();
  final List<bool> _selectedDays = List.generate(7, (_) => false);
  bool _isPinned = false;
  String _selectedAmPm = '오전';
  int _selectedHour = 9;
  int _selectedMinute = 0;

  String _getSelectedDaysText() {
    const dayNames = ['일', '월', '화', '수', '목', '금', '토'];
    final selected = <String>[];
    for (int i = 0; i < 7; i++) {
      if (_selectedDays[i]) selected.add(dayNames[i]);
    }
    if (selected.length == 7) return '매일';
    if (selected.length == 5 && _selectedDays.sublist(1, 6).every((e) => e)) return '주중';
    if (_selectedDays[0] && _selectedDays[6] && selected.length == 2) return '주말';
    return selected.join(', ');
  }

  void _showDaySelector() {
    final fullNames = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: const Color(0xFFF6F7F9),
            title: const Text('요일 선택', style: TextStyle(fontSize: 25, color: Colors.black87)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 주중 / 주말 먼저
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('주중', style: TextStyle(fontSize: 20, color: Colors.black)),
                        value: _selectedDays.sublist(1, 6).every((e) => e),
                        onChanged: (val) {
                          for (int i = 1; i <= 5; i++) {
                            _selectedDays[i] = val ?? false;
                          }
                          setState(() {});
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: const Color(0xFF1ea698),
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('주말', style: TextStyle(fontSize: 20, color: Colors.black)),
                        value: _selectedDays[0] && _selectedDays[6],
                        onChanged: (val) {
                          _selectedDays[0] = val ?? false;
                          _selectedDays[6] = val ?? false;
                          setState(() {});
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: const Color(0xFF1ea698),
                      ),
                    ),
                  ],
                ),

                const Divider(thickness: 1, color: Colors.black26),

                // 일반 요일
                ...List.generate(7, (i) {
                  return CheckboxListTile(
                    title: Text(fullNames[i], style: const TextStyle(fontSize: 20, color: Colors.black)),
                    value: _selectedDays[i],
                    onChanged: (val) {
                      setState(() => _selectedDays[i] = val ?? false);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF1ea698),
                  );
                }),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1ea698),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('확인', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF6F7F9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('습관 추가', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: _selectedAmPm == '오전' ? 0 : 1),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedAmPm = index == 0 ? '오전' : '오후';
                        });
                      },
                      children: const [
                        Center(child: Text('오전', style: TextStyle(fontSize: 25))),
                        Center(child: Text('오후', style: TextStyle(fontSize: 25))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: _selectedHour - 1),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedHour = index + 1;
                        });
                      },
                      children: List.generate(12, (i) => Center(child: Text('${i + 1}시', style: const TextStyle(fontSize: 25)))),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: _selectedMinute),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMinute = index;
                        });
                      },
                      children: List.generate(60, (i) => Center(child: Text('${i.toString().padLeft(2, '0')}분', style: const TextStyle(fontSize: 25)))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 25),
              decoration: const InputDecoration(labelText: '할 일', labelStyle: TextStyle(fontSize: 25)),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: _showDaySelector,
              title: const Text('반복', style: TextStyle(fontSize: 25)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getSelectedDaysText(), style: const TextStyle(fontSize: 20, color: Colors.black54)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('중요한 습관', style: TextStyle(fontSize: 25)),
                Checkbox(
                  value: _isPinned,
                  onChanged: (val) {
                    setState(() => _isPinned = val ?? false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소', style: TextStyle(fontSize: 25, color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty) {
                      final timeStr = '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';
                      final totalHour = (_selectedAmPm == '오후' && _selectedHour != 12)
                          ? _selectedHour + 12
                          : (_selectedAmPm == '오전' && _selectedHour == 12) ? 0 : _selectedHour;
                      final sortKey = totalHour * 60 + _selectedMinute;

                      widget.routineRef.add({
                        'title': _titleController.text,
                        'time': timeStr,
                        'completed': false,
                        'by': 'user',
                        'pinned': _isPinned,
                        'days': _selectedDays,
                        'ampm': _selectedAmPm,
                        'sortKey': sortKey,
                      });

                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1ea698)),
                  child: const Text('추가', style: TextStyle(fontSize: 25, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

class EditRoutineDialog extends StatefulWidget {
  final CollectionReference routineRef;
  final String docId;
  final Map<String, dynamic> existingData;

  const EditRoutineDialog({
    super.key,
    required this.routineRef,
    required this.docId,
    required this.existingData,
  });

  @override
  State<EditRoutineDialog> createState() => _EditRoutineDialogState();
}

class _EditRoutineDialogState extends State<EditRoutineDialog> {
  late TextEditingController _titleController;
  late List<bool> _selectedDays;
  late bool _isPinned;
  late String _selectedAmPm;
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    final data = widget.existingData;
    _titleController = TextEditingController(text: data['title'] ?? '');
    _selectedDays = List<bool>.from(data['days'] ?? List.generate(7, (_) => false));
    _isPinned = data['pinned'] ?? false;
    _selectedAmPm = data['ampm'] ?? '오전';

    final timeParts = (data['time'] as String?)?.split(':') ?? ['09', '00'];
    _selectedHour = int.tryParse(timeParts[0]) ?? 9;
    _selectedMinute = int.tryParse(timeParts[1]) ?? 0;
  }

  String _getSelectedDaysText() {
    const dayNames = ['일', '월', '화', '수', '목', '금', '토'];
    final selected = <String>[];
    for (int i = 0; i < 7; i++) {
      if (_selectedDays[i]) selected.add(dayNames[i]);
    }
    if (selected.length == 7) return '매일';
    if (selected.length == 5 && _selectedDays.sublist(1, 6).every((e) => e)) return '주중';
    if (_selectedDays[0] && _selectedDays[6] && selected.length == 2) return '주말';
    return selected.join(', ');
  }

  void _showDaySelector() {
    final fullNames = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: const Color(0xFFF6F7F9),
            title: const Text('요일 선택', style: TextStyle(fontSize: 25, color: Colors.black87)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('주중', style: TextStyle(fontSize: 20, color: Colors.black)),
                        value: _selectedDays.sublist(1, 6).every((e) => e),
                        onChanged: (val) {
                          for (int i = 1; i <= 5; i++) {
                            _selectedDays[i] = val ?? false;
                          }
                          setState(() {});
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: const Color(0xFF1ea698),
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('주말', style: TextStyle(fontSize: 20, color: Colors.black)),
                        value: _selectedDays[0] && _selectedDays[6],
                        onChanged: (val) {
                          _selectedDays[0] = val ?? false;
                          _selectedDays[6] = val ?? false;
                          setState(() {});
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: const Color(0xFF1ea698),
                      ),
                    ),
                  ],
                ),
                const Divider(thickness: 1, color: Colors.black26),
                ...List.generate(7, (i) {
                  return CheckboxListTile(
                    title: Text(fullNames[i], style: const TextStyle(fontSize: 20, color: Colors.black)),
                    value: _selectedDays[i],
                    onChanged: (val) {
                      setState(() => _selectedDays[i] = val ?? false);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF1ea698),
                  );
                }),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1ea698),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('확인', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveChanges() {
    final timeStr = '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';

    final totalHour = (_selectedAmPm == '오후' && _selectedHour != 12)
        ? _selectedHour + 12
        : (_selectedAmPm == '오전' && _selectedHour == 12) ? 0 : _selectedHour;

    final sortKey = totalHour * 60 + _selectedMinute;

    widget.routineRef.doc(widget.docId).update({
      'title': _titleController.text,
      'time': timeStr,
      'ampm': _selectedAmPm,
      'pinned': _isPinned,
      'days': _selectedDays,
      'sortKey': sortKey,
    });

    Navigator.pop(context);
  }

  void _deleteRoutine() {
    widget.routineRef.doc(widget.docId).delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF6F7F9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('습관 수정', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: _selectedAmPm == '오전' ? 0 : 1),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) => setState(() => _selectedAmPm = index == 0 ? '오전' : '오후'),
                      children: const [
                        Center(child: Text('오전', style: TextStyle(fontSize: 25))),
                        Center(child: Text('오후', style: TextStyle(fontSize: 25))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: _selectedHour - 1),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) => setState(() => _selectedHour = index + 1),
                      children: List.generate(12, (i) => Center(child: Text('${i + 1}시', style: const TextStyle(fontSize: 25)))),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: _selectedMinute),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) => setState(() => _selectedMinute = index),
                      children: List.generate(60, (i) => Center(child: Text('${i.toString().padLeft(2, '0')}분', style: const TextStyle(fontSize: 25)))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 25),
              decoration: const InputDecoration(labelText: '할 일', labelStyle: TextStyle(fontSize: 25)),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: _showDaySelector,
              title: const Text('반복', style: TextStyle(fontSize: 25)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getSelectedDaysText(), style: const TextStyle(fontSize: 20, color: Colors.black54)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('중요한 습관', style: TextStyle(fontSize: 25)),
                Checkbox(
                  value: _isPinned,
                  onChanged: (val) => setState(() => _isPinned = val ?? false),
                  activeColor: const Color(0xFF1ea698),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _deleteRoutine,
                  child: const Text('삭제', style: TextStyle(fontSize: 25, color: Colors.red)),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소', style: TextStyle(fontSize: 25, color: Colors.black)),
                    ),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1ea698)),
                      child: const Text('저장', style: TextStyle(fontSize: 25, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}