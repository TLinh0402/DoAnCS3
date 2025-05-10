import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:awesome_notifications/awesome_notifications.dart';



class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];

  final String openAiApiKey = 'Open_Ai';

  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.initState();
    loadChatHistory();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': message});
    });
    //xóa
    // ==== XÓA CHI TIÊU ====
    if (message.toLowerCase().contains('xóa chi tiêu mới nhất')) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ref = FirebaseDatabase.instance.ref().child('users/${user.uid}/khoanthuchi');
        final snapshot = await ref.orderByChild('date').limitToLast(1).once();
        if (snapshot.snapshot.value != null) {
          final last = (snapshot.snapshot.value as Map).entries.first;
          await ref.child(last.key).remove();
          setState(() => _messages.add({'role': 'assistant', 'content': '🗑️ Đã xóa chi tiêu mới nhất.'}));
        } else {
          setState(() => _messages.add({'role': 'assistant', 'content': 'Không có chi tiêu nào để xóa.'}));
        }
      }
      return;
    }

    if (message.toLowerCase().contains('xóa chi tiêu hôm nay')) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
        final ref = FirebaseDatabase.instance.ref().child('users/${user.uid}/khoanthuchi');
        final snapshot = await ref.orderByChild('date').equalTo(today).once();
        final data = snapshot.snapshot.value as Map?;
        if (data != null) {
          for (var key in data.keys) {
            await ref.child(key).remove();
          }
          setState(() => _messages.add({'role': 'assistant', 'content': '🗑️ Đã xóa toàn bộ chi tiêu hôm nay.'}));
        } else {
          setState(() => _messages.add({'role': 'assistant', 'content': 'Không có chi tiêu nào hôm nay để xóa.'}));
        }
      }
      return;
    }

    if (message.toLowerCase().contains('xóa chi tiêu tháng')) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final now = DateTime.now();
        final month = DateFormat('MM/yyyy').format(now);
        final ref = FirebaseDatabase.instance.ref().child('users/${user.uid}/khoanthuchi');
        final snapshot = await ref.once();
        final data = snapshot.snapshot.value as Map?;
        if (data != null) {
          for (var entry in data.entries) {
            final item = entry.value;
            if ((item['date'] ?? '').toString().endsWith(month)) {
              await ref.child(entry.key).remove();
            }
          }
          setState(() => _messages.add({'role': 'assistant', 'content': '🗑️ Đã xóa chi tiêu trong tháng này.'}));
        } else {
          setState(() => _messages.add({'role': 'assistant', 'content': 'Không có chi tiêu nào trong tháng để xóa.'}));
        }
      }
      return;
    }

    if (message.toLowerCase().contains('xóa tất cả chi tiêu')) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ref = FirebaseDatabase.instance.ref().child('users/${user.uid}/khoanthuchi');
        await ref.remove();
        setState(() => _messages.add({'role': 'assistant', 'content': '🗑️ Đã xóa toàn bộ chi tiêu.'}));
      }
      return;
    }

    await saveMessageToFirebase(role: 'user', content: message);
    _controller.clear();
    _scrollToBottom();



    // Xử lý chi tiêu
    RegExp chiTieuRegex = RegExp(
      r'(chi|tiêu|mua).*?(\d+)(tr|trieu|triệu|k)?\s*(.*)',
      caseSensitive: false,
    );

    if (chiTieuRegex.hasMatch(message)) {
      final match = chiTieuRegex.firstMatch(message);
      int amount = int.parse(match?.group(2) ?? '0');
      final unit = match?.group(3)?.toLowerCase();
      if (unit == 'tr' || unit == 'trieu' || unit == 'triệu') amount *= 1000000;
      else if (unit == 'k') amount *= 1000;

      String fullDetail = match?.group(4)?.trim() ?? 'Chi tiêu không rõ';
      String name = fullDetail;
      String categoryName = '';

      // ✅ Tách “trong mục …”
      final RegExp categoryExtract = RegExp(r'(.+?)\s*(?:trong|ở|thuộc)?\s*mục\s+(.+)', caseSensitive: false);
      final matchCat = categoryExtract.firstMatch(fullDetail);
      if (matchCat != null) {
        name = matchCat.group(1)!.trim();           // "bánh báo"
        categoryName = matchCat.group(2)!.trim();   // "food"
      }

      if (categoryName == '') categoryName = name;

      try {
        await saveTransaction(
          name: name,
          amount: amount,
          categoryName: categoryName,
          type: 'Expense',
        );

        final content = '✅ Đã ghi chi ${NumberFormat("#,###", "vi_VN").format(amount)}đ cho: $name (mục: $categoryName).';
        setState(() => _messages.add({'role': 'assistant', 'content': content}));
        await saveMessageToFirebase(role: 'assistant', content: content);
      } catch (e) {
        final err = '❌ Không thể ghi chi tiêu. Lý do: $e';
        setState(() => _messages.add({'role': 'assistant', 'content': err}));
        await saveMessageToFirebase(role: 'assistant', content: err);
      }
      return;
    }


    // RegExp chiTieuRegex = RegExp(r'(chi|tiêu|mua).*?(\d+)[kK]?\s*(.*)', caseSensitive: false);
    // if (chiTieuRegex.hasMatch(message)) {
    //   final match = chiTieuRegex.firstMatch(message);
    //   final int amount = int.parse(match?.group(2) ?? '0') * (message.contains('k') ? 1000 : 1);
    //   final String detail = (match?.group(3)?.trim().isNotEmpty ?? false) ? match!.group(3)!.trim() : 'Chi tiêu không rõ';
    //
    //   try {
    //         await saveTransaction(name: detail, amount: amount, categoryName: detail, type: 'Expense');
    //         final content = '✅ Đã ghi chi ${NumberFormat("#,###", "vi_VN").format(amount)}đ cho: $detail.';
    //         setState(() => _messages.add({'role': 'assistant', 'content': content}));
    //         await saveMessageToFirebase(role: 'assistant', content: content);
    //       } catch (e) {
    //         final err = '❌ Không thể ghi chi tiêu. Lý do: $e';
    //         setState(() => _messages.add({'role': 'assistant', 'content': err}));
    //         await saveMessageToFirebase(role: 'assistant', content: err);
    //       }
    //       return;
    //     }

    // xoa theo ten
    RegExp xoaTheoTen = RegExp(r'xóa\s+(chi tiêu|thu nhập)\s+(.+)', caseSensitive: false);
    if (xoaTheoTen.hasMatch(message)) {
      final match = xoaTheoTen.firstMatch(message)!;
      final loai = match.group(1)!.toLowerCase(); // 'chi tiêu' hoặc 'thu nhập'
      final ten = match.group(2)!.trim().toLowerCase(); // ví dụ: 'bánh báo'

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ref = FirebaseDatabase.instance.ref().child('users/${user.uid}/khoanthuchi');
        final snapshot = await ref.once();
        final data = snapshot.snapshot.value as Map?;

        if (data != null) {
          bool found = false;
          for (var entry in data.entries) {
            final item = entry.value as Map;
            final name = (item['name'] ?? '').toString().toLowerCase();
            final type = (item['type'] ?? '').toString().toLowerCase();
            if (name.contains(ten) && ((loai == 'chi tiêu' && type == 'expense') || (loai == 'thu nhập' && type == 'income'))) {
              await ref.child(entry.key).remove();
              setState(() => _messages.add({
                'role': 'assistant',
                'content': '🗑️ Đã xóa $loai có tên chứa "$ten".'
              }));
              await saveMessageToFirebase(role: 'assistant', content: '🗑️ Đã xóa $loai có tên chứa "$ten".');
              found = true;
              break; // chỉ xóa 1 cái đầu tiên tìm thấy
            }
          }
          if (!found) {
            final msg = 'Không tìm thấy $loai nào tên chứa "$ten".';
            setState(() => _messages.add({'role': 'assistant', 'content': msg}));
            await saveMessageToFirebase(role: 'assistant', content: msg);
          }
        }
      }
      return;
    }

// Trước khi gọi OpenAI API, chèn đoạn này:
    RegExp remindRegex = RegExp(
      r'nhắc.*?(?:tôi|mình)?.*?tiền\s*(.*?)\s*ngày\s*(\d{1,2})(?:[\/\-](\d{1,2}))?',
      caseSensitive: false,
    );

    if (remindRegex.hasMatch(message)) {
      final match = remindRegex.firstMatch(message);
      final content = match?.group(1)?.trim() ?? 'Nội dung nhắc nhở';
      final day = int.tryParse(match?.group(2) ?? '') ?? DateTime.now().day;
      final month = int.tryParse(match?.group(3) ?? '') ?? DateTime.now().month;
      final isMonthly = message.toLowerCase().contains('hàng tháng');

      await saveReminder(content: content, day: day, month: month, monthly: isMonthly);

      final reply = '🔔 Tôi đã đặt lịch nhắc bạn: "$content" vào ngày $day/${isMonthly ? 'hàng tháng' : month}.';
      setState(() => _messages.add({'role': 'assistant', 'content': reply}));
      await saveMessageToFirebase(role: 'assistant', content: reply);
      return;
    }


    // Xử lý thu nhập
    RegExp thuNhapRegex = RegExp(r'(thu|nhận|có|được).*?(\d+)(tr|trieu|triệu|k)?\s*(.*)', caseSensitive: false);
    if (thuNhapRegex.hasMatch(message)) {
      final match = thuNhapRegex.firstMatch(message);
      int amount = int.parse(match?.group(2) ?? '0');
      final unit = match?.group(3)?.toLowerCase();
      if (unit == 'tr' || unit == 'trieu' || unit == 'triệu') amount *= 1000000;
      else if (unit == 'k') amount *= 1000;
      String detail = (match?.group(4)?.trim().isNotEmpty ?? false) ? match!.group(4)!.trim() : 'Chi tiêu không rõ';
      String categoryName = detail;

// Nếu có “trong mục …” thì tách ra
      final RegExp categoryExtract = RegExp(r'(.+?)\s*(?:trong|ở|thuộc)?\s*mục\s+(.+)', caseSensitive: false);
      final matchCat = categoryExtract.firstMatch(detail);
      if (matchCat != null) {
        detail = matchCat.group(1)!.trim(); // "lương t5"
        categoryName = matchCat.group(2)!.trim(); // "lương"
      }

      try {
        await saveTransaction(
          name: detail,
          amount: amount,
          categoryName: categoryName, // ✅ đã sửa đúng
          type: 'Income',
        );
        final content = '💵 Đã ghi thu ${NumberFormat("#,###", "vi_VN").format(amount)}đ từ: $detail (mục: $categoryName).';
        setState(() => _messages.add({'role': 'assistant', 'content': content}));
        await saveMessageToFirebase(role: 'assistant', content: content);
      } catch (e) {
        final err = '❌ Không thể ghi thu nhập. Lý do: $e';
        setState(() => _messages.add({'role': 'assistant', 'content': err}));
        await saveMessageToFirebase(role: 'assistant', content: err);
      }
      return;
    }

    // Xin chào / tạm biệt
    final greetings = ['xin chào', 'chào', 'tạm biệt', 'bye'];
    if (greetings.any((g) => message.toLowerCase().contains(g))) {
      final reply = message.toLowerCase().contains('chào') ? 'Chào bạn 👋' : 'Tạm biệt bạn 👋';
      setState(() => _messages.add({'role': 'assistant', 'content': reply}));
      await saveMessageToFirebase(role: 'assistant', content: reply);
      return;
    }

    // Không liên quan tài chính
    if (!isFinanceRelated(message)) {
      final msg = 'Xin lỗi, tôi chỉ hỗ trợ về tài chính cá nhân như chi tiêu, thu nhập, tiết kiệm.';
      setState(() => _messages.add({'role': 'assistant', 'content': msg}));
      await saveMessageToFirebase(role: 'assistant', content: msg);
      return;
    }

    // Gọi OpenAI
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $openAiApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {"role": "user", "content": message}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final reply = data['choices'][0]['message']['content'];
      setState(() => _messages.add({'role': 'assistant', 'content': reply}));
      await saveMessageToFirebase(role: 'assistant', content: reply);
    } else {
      const msg = 'Lỗi khi gọi API 😢';
      setState(() => _messages.add({'role': 'assistant', 'content': msg}));
      await saveMessageToFirebase(role: 'assistant', content: msg);
    }

    _scrollToBottom();
  }

  bool isFinanceRelated(String message) {
    final keywords = [
      'chi', 'tiêu', 'thu', 'tiết kiệm', 'ngân sách', 'lương', 'tiền', 'mua', 'nhận', 'được'
    ];
    return keywords.any((k) => message.toLowerCase().contains(k));
  }

  Future<void> saveTransaction({required String name, required int amount, required String categoryName, required String type}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw 'Chưa đăng nhập';
    final refType = FirebaseDatabase.instance.ref().child('users/${user.uid}/typecategorys');
    final snapshot = await refType.orderByChild('name').equalTo(categoryName).once();
    Map<dynamic, dynamic>? value = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    String categoryId;
    if (value == null) {
      final newRef = refType.push();
      categoryId = newRef.key!;

      // Gán icon đúng nếu có sẵn
      String iconName = 'default';
      final knownIcons = {
        'lương': 'salary',
        'ăn uống': 'food',
        'nhà': 'home',
        'thú cưng': 'pet',
        'mua sắm': 'shopping',
        'công nghệ': 'tech',
        'du lịch': 'travel',
        'hóa đơn': 'bill',
      };

      knownIcons.forEach((key, val) {
        if (categoryName.toLowerCase().contains(key)) {
          iconName = val;
        }
      });

      await newRef.set({
        'id': categoryId,
        'name': categoryName,
        'icon': iconName,
      });
    } else {
      categoryId = value.keys.first;
    }

    final ref = FirebaseDatabase.instance.ref().child('users/${user.uid}/khoanthuchi').push();
    await ref.set({
      'id': ref.key,
      'name': name,
      'price': amount.toString(),
      'category_id': categoryId,
      'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
      'type': type,
    });
  }


  Future<void> saveMessageToFirebase({required String role, required String content}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref().child('users/${user.uid}/chat_history').push();
    await ref.set({
      'role': role,
      'content': content,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  // nhắc hẹn
  Future<void> saveReminder({required String content, required int day, required int month, required bool monthly}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref().child('users/${user.uid}/reminders').push();
    await ref.set({
      'content': content,
      'day': day,
      'month': month,
      'monthly': monthly,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });

    // ✅ Tạo notification
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000); // random id
    final scheduledDate = DateTime(DateTime.now().year, month, day, 9); // 9h sáng

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'reminder_channel',
        title: '🔔 Nhắc nhở',
        body: content,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: monthly ? null : scheduledDate.year,
        month: monthly ? null : scheduledDate.month,
        day: scheduledDate.day,
        hour: 11,
        minute: 56,
        second: 0,
        repeats: monthly,
      ),
    );
  }


  Future<void> loadChatHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('users/${user.uid}/chat_history')
        .orderByChild('timestamp')
        .once();

    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      final List<Map<String, dynamic>> sorted = data.entries.map((entry) {
        final item = entry.value as Map;
        return {
          'role': item['role'] ?? '',
          'content': item['content'] ?? '',
          'timestamp': item['timestamp'] ?? 0,
        };
      }).toList();

      sorted.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));

      final loaded = sorted.map<Map<String, String>>((item) {
        return {
          'role': item['role'],
          'content': item['content'],
        };
      }).toList();

      setState(() => _messages.addAll(loaded));
      _scrollToBottom();
    }
  }


  Future<void> clearChatHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseDatabase.instance.ref().child('users/${user.uid}/chat_history').remove();
    setState(() => _messages.clear());
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
//xóa chi tiêu
  // Add this into your ChatBotPage class

  Future<void> deleteLatestTransaction() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref('users/${user.uid}/khoanthuchi');
    final snapshot = await ref.orderByChild('date').limitToLast(1).once();
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map;
      final latestKey = data.keys.first;
      await ref.child(latestKey).remove();
    }
  }

  Future<void> deleteTransactionByDay(String day, String month, String year) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref('users/${user.uid}/khoanthuchi');
    final snapshot = await ref.once();
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map;
      for (final entry in data.entries) {
        final item = entry.value;
        if (item['date'] == "$day/$month/$year") {
          await ref.child(entry.key).remove();
        }
      }
    }
  }

  Future<void> deleteTransactionByMonth(String month, String year) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref('users/${user.uid}/khoanthuchi');
    final snapshot = await ref.once();
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map;
      for (final entry in data.entries) {
        final item = entry.value;
        final date = item['date'] ?? '';
        if (date.endsWith("/$month/$year")) {
          await ref.child(entry.key).remove();
        }
      }
    }
  }

  Future<void> deleteAllTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref('users/${user.uid}/khoanthuchi');
    await ref.remove();
  }



  Widget _buildMessage(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser ? Colors.lightBlueAccent[100] : Colors.grey[300];
    final border = isUser
        ? BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(4), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))
        : BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16));
    return Container(
      alignment: align,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        padding: EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(color: color, borderRadius: border),
        child: Text(msg['content'] ?? '', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text("Chat 2L"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Xóa lịch sử?'),
                  content: Text('Bạn chắc muốn xóa toàn bộ lịch sử trò chuyện?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Hủy')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Xóa')),
                  ],
                ),
              );
              if (confirm == true) await clearChatHistory();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Nhập tin nhắn...",
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: InputBorder.none,
                      ),
                      onSubmitted: sendMessage,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => sendMessage(_controller.text),
                  child: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}