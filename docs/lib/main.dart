import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const FocusTodayApp());

const ink = Color(0xFF1D2944);
const teal = Color(0xFF087F83);
const canvas = Color(0xFFF7F9FC);
const violet = Color(0xFF8068B6);

class TaskData {
  TaskData({required this.id, required this.title, required this.category,
    required this.priority, required this.dueDate, required this.completed,
    required this.note});

  final String id, title, category, priority, dueDate, note;
  bool completed;

  factory TaskData.fromJson(Map<String, dynamic> json) => TaskData(
    id: json['id'].toString(),
    title: json['title'] as String? ?? '',
    category: json['category'] as String? ?? '개인',
    priority: json['priority'] as String? ?? 'medium',
    dueDate: json['dueDate'] as String? ?? '',
    completed: json['completed'] as bool? ?? false,
    note: json['note'] as String? ?? '',
  );
}

String dateCode(DateTime d) => d.year.toString() + '-' +
  d.month.toString().padLeft(2, '0') + '-' + d.day.toString().padLeft(2, '0');
String koreanDate(DateTime d) => d.month.toString() + '월 ' + d.day.toString() + '일';
String priorityText(String p) => p == 'high' ? '높음' : p == 'low' ? '낮음' : '보통';
Color priorityColor(String p) => p == 'high'
    ? const Color(0xFFD85D58) : p == 'low'
    ? const Color(0xFF648C81) : const Color(0xFFB37A2D);
Color categoryColor(String c) => c == '학교' ? teal
    : c == '생활' ? violet : const Color(0xFFCC7956);

String mockBaseUrl() {
  const custom = String.fromEnvironment('MOCK_BASE_URL');
  if (custom.isNotEmpty) return custom;
  if (kIsWeb) return 'http://localhost:3000';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000';
  return 'http://localhost:3000';
}

class TaskRepository {
  const TaskRepository();
  Future<List<TaskData>> getTasks() async {
    // Required local json-server GET. No POST/PUT/DELETE or permanent write.
    final response = await http.get(Uri.parse(mockBaseUrl() + '/tasks'))
        .timeout(const Duration(seconds: 6));
    if (response.statusCode != 200) {
      throw Exception('HTTP ' + response.statusCode.toString());
    }
    final payload = jsonDecode(utf8.decode(response.bodyBytes));
    if (payload is! List) throw const FormatException('JSON array required');
    return payload.map((v) => TaskData.fromJson(v as Map<String, dynamic>)).toList();
  }
}

class FocusTodayApp extends StatelessWidget {
  const FocusTodayApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: '오늘한눈',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      colorScheme: ColorScheme.fromSeed(seedColor: teal, primary: teal,
          surface: Colors.white),
      appBarTheme: const AppBarTheme(backgroundColor: canvas, foregroundColor: ink),
      cardTheme: CardThemeData(
        color: Colors.white, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskRepository repository = const TaskRepository();
  List<TaskData> tasks = [];
  int tab = 0;
  String filter = '전체';
  String? demoState;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    setState(() { loading = true; error = null; demoState = null; });
    try {
      final result = await repository.getTasks();
      if (!mounted) return;
      setState(() { tasks = result; loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = '로컬 json-server 연결 실패. 서버 실행 상태를 확인해 주세요.\n$e';
        loading = false;
      });
    }
  }

  void toggle(TaskData task) {
    setState(() => task.completed = !task.completed);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(task.completed ? '완료함에서 다시 확인할 수 있어요' : '할 일로 되돌렸어요'),
      action: SnackBarAction(label: '실행 취소',
        onPressed: () => setState(() => task.completed = !task.completed)),
    ));
  }

  void detail(TaskData task) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) =>
      TaskDetail(task: task, onToggle: () => toggle(task))));

  Future<void> addTask() async {
    final controller = TextEditingController();
    String category = '학교', priority = 'medium';
    DateTime due = DateTime.now();
    await showModalBottomSheet<void>(
      context: context, showDragHandle: true, isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheet) => StatefulBuilder(builder: (sheet, change) => Padding(
        padding: EdgeInsets.fromLTRB(22, 6, 22,
          MediaQuery.of(sheet).viewInsets.bottom + 24),
        child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('빠른 할 일 추가', style: TextStyle(
              fontSize: 23, fontWeight: FontWeight.w800, color: ink)),
            const SizedBox(height: 8),
            const Text('제목과 중요한 정보를 한 화면에서 정합니다.',
              style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            TextField(
              autofocus: true, controller: controller, maxLength: 60,
              decoration: InputDecoration(
                hintText: '무엇을 해야 하나요?', filled: true, fillColor: canvas,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none))),
            const Text('카테고리', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(spacing: 8, children: [
              for (final c in ['학교', '생활', '개인'])
                ChoiceChip(label: Text(c), selected: category == c,
                  onSelected: (_) => change(() => category = c))
            ]),
            const SizedBox(height: 12),
            const Text('우선순위', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(spacing: 8, children: [
              for (final p in ['high', 'medium', 'low'])
                ChoiceChip(label: Text(priorityText(p)), selected: priority == p,
                  onSelected: (_) => change(() => priority = p))
            ]),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined, color: teal),
              title: Text('마감일  ' + dateCode(due)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final selected = await showDatePicker(context: sheet,
                  initialDate: due, firstDate: DateTime(2020),
                  lastDate: DateTime(2035));
                if (selected != null) change(() => due = selected);
              },
            ),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: FilledButton.icon(
              icon: const Icon(Icons.add), label: const Text('화면에 추가'),
              onPressed: () {
                final title = controller.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('할 일을 입력해 주세요')));
                  return;
                }
                setState(() {
                  tasks.insert(0, TaskData(
                    id: 'local-' + DateTime.now().microsecondsSinceEpoch.toString(),
                    title: title, category: category, priority: priority,
                    dueDate: dateCode(due), completed: false,
                    note: 'UI에서만 추가했습니다. 서버에는 저장되지 않습니다.'));
                  tab = 0;
                });
                Navigator.pop(sheet);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('UI에만 추가했습니다 (영구 저장 없음).')));
              },
            )),
          ],
        )),
      )),
    );
    controller.dispose();
  }

  void openFilter() => showModalBottomSheet<void>(
    context: context, showDragHandle: true,
    builder: (sheet) => SafeArea(child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('카테고리 필터',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          for (final c in ['전체', '학교', '생활', '개인'])
            ListTile(
              leading: Icon(filter == c ? Icons.check_circle : Icons.circle_outlined,
                color: filter == c ? teal : Colors.black38),
              title: Text(c),
              onTap: () { setState(() => filter = c); Navigator.pop(sheet); },
            ),
        ],
      ),
    )),
  );

  List<TaskData> get visible {
    final now = dateCode(DateTime.now());
    final items = tasks.where((t) {
      if (filter != '전체' && filter != t.category) return false;
      if (tab == 3) return t.completed;
      if (t.completed) return false;
      if (tab == 2) return t.dueDate.compareTo(now) > 0;
      return true;
    }).toList();
    const order = {'high': 0, 'medium': 1, 'low': 2};
    items.sort((a, b) {
      final priorityDiff = (order[a.priority] ?? 3).compareTo(order[b.priority] ?? 3);
      return priorityDiff == 0
          ? a.dueDate.compareTo(b.dueDate) : priorityDiff;
    });
    return items;
  }

  Widget stateView(IconData icon, String title, String caption,
      {String? button, VoidCallback? action}) => Center(
    child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 380),
      child: Padding(padding: const EdgeInsets.all(25),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(radius: 35, backgroundColor: const Color(0xFFDCEFEF),
            child: Icon(icon, color: teal, size: 34)),
          const SizedBox(height: 18),
          Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22,
              fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 9),
          Text(caption, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, height: 1.5)),
          if (button != null && action != null) ...[
            const SizedBox(height: 18),
            FilledButton(onPressed: action, child: Text(button)),
          ]
        ]),
      ),
    ),
  );

  Widget taskTile(TaskData t) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      borderRadius: BorderRadius.circular(20), onTap: () => detail(t),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        child: Row(children: [
          Checkbox(value: t.completed, activeColor: teal,
            onChanged: (_) => toggle(t)),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: ink, fontWeight: FontWeight.w700,
                  decoration: t.completed ? TextDecoration.lineThrough : null)),
              const SizedBox(height: 6),
              Wrap(spacing: 9, runSpacing: 3, children: [
                Text('● ' + t.category, style: TextStyle(fontSize: 12,
                  color: categoryColor(t.category))),
                Text(t.dueDate, style: const TextStyle(fontSize: 12,
                  color: Colors.black54)),
                Text(priorityText(t.priority),
                  style: TextStyle(fontSize: 12,
                    color: priorityColor(t.priority), fontWeight: FontWeight.bold)),
              ]),
            ],
          )),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ]),
      ),
    ),
  );

  Widget taskList() {
    final items = visible;
    final completed = tasks.where((t) => t.completed).length;
    final remaining = tasks.where((t) => !t.completed).length;
    final fraction = tasks.isEmpty ? 0.0 : completed / tasks.length;
    return Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 790),
      child: ListView(padding: const EdgeInsets.fromLTRB(18, 10, 18, 106),
        children: [
          if (tab == 0) ...[
            Card(color: ink, child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(koreanDate(DateTime.now()) + '의 집중',
                  style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                const Text('오늘 할 일을\n한눈에 확인해요',
                  style: TextStyle(fontSize: 29, height: 1.25,
                    fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 22),
                Row(children: [
                  Text('완료 ' + completed.toString() + '/' + tasks.length.toString(),
                    style: const TextStyle(color: Colors.white)),
                  const Spacer(),
                  Text('남은 일 ' + remaining.toString() + '개',
                    style: const TextStyle(color: Colors.white70)),
                ]),
                const SizedBox(height: 9),
                LinearProgressIndicator(value: fraction, minHeight: 7,
                  backgroundColor: Colors.white24,
                  color: const Color(0xFF8DDFD3),
                  borderRadius: BorderRadius.circular(6)),
              ]),
            )),
            const SizedBox(height: 18),
            const Text('우선순위별 할 일',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: ink)),
            const SizedBox(height: 5),
            const Text('색과 글자로 중요도를 함께 표시합니다.',
              style: TextStyle(color: Colors.black54, fontSize: 13)),
          ] else ...[
            Text(['오늘', '전체 할 일', '다가오는 일정', '완료함'][tab],
              style: const TextStyle(fontWeight: FontWeight.w800,
                fontSize: 27, color: ink)),
            const SizedBox(height: 5),
            Text(tab == 3
                ? '완료한 작업도 목록에서 다시 확인할 수 있어요.'
                : '우선순위가 높은 작업을 위에 배치합니다.',
                style: const TextStyle(color: Colors.black54)),
          ],
          const SizedBox(height: 14),
          Row(children: [
            ActionChip(
              avatar: const Icon(Icons.tune, size: 16),
              label: Text(filter + ' 필터'), onPressed: openFilter),
            const Spacer(),
            Text(items.length.toString() + '개 항목',
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ]),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Padding(padding: const EdgeInsets.only(top: 65),
              child: stateView(Icons.inbox_outlined, '표시할 할 일이 없어요',
                '필터를 바꾸거나 새 할 일을 추가해 보세요.',
                button: '필터 초기화',
                action: () => setState(() => filter = '전체')))
          else
            ...items.map(taskTile),
          if (tab == 3)
            const Padding(padding: EdgeInsets.only(top: 12),
              child: Text('완료 변경은 로컬 UI 상태로만 동작합니다.',
                style: TextStyle(fontSize: 12, color: Colors.black45))),
        ],
      ),
    ));
  }

  Widget pageBody() {
    if (demoState == 'loading' || (loading && demoState == null)) {
      return stateView(Icons.hourglass_top, '할 일을 불러오는 중',
        '잠시만 기다려 주세요.',
        button: demoState == 'loading' ? '실제 GET으로 돌아가기' : null,
        action: demoState == 'loading' ? reload : null);
    }
    if (demoState == 'error' || error != null) {
      return stateView(Icons.wifi_off_rounded, '데이터를 불러올 수 없어요',
        error ?? '오류 상태 시연입니다. 재시도로 GET 요청을 보낼 수 있습니다.',
        button: '다시 시도', action: reload);
    }
    if (demoState == 'empty') {
      return stateView(Icons.inbox_outlined, '아직 할 일이 없어요',
        '빈 상태에서도 다음 행동을 알려 줍니다.',
        button: '정상 상태로', action: reload);
    }
    return taskList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.check_circle_rounded, color: teal),
        SizedBox(width: 8),
        Text('오늘한눈', style: TextStyle(fontWeight: FontWeight.w900)),
      ]),
      actions: [
        IconButton(onPressed: reload, icon: const Icon(Icons.refresh),
          tooltip: 'json-server GET 새로고침'),
        PopupMenuButton<String>(
          tooltip: '상태 시연', icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'normal') { reload(); }
            else { setState(() {
              demoState = value; loading = false; error = null;
            }); }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'normal', child: Text('실제 데이터 GET')),
            PopupMenuItem(value: 'loading', child: Text('로딩 상태')),
            PopupMenuItem(value: 'error', child: Text('오류 상태')),
            PopupMenuItem(value: 'empty', child: Text('빈 상태')),
          ],
        ),
      ],
    ),
    body: pageBody(),
    floatingActionButton: demoState == null && !loading && error == null
      ? FloatingActionButton.extended(
        onPressed: addTask, icon: const Icon(Icons.add),
        label: const Text('빠른 추가')) : null,
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (v) => setState(() {tab = v; filter = '전체';}),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.today_outlined), label: '오늘'),
        NavigationDestination(icon: Icon(Icons.checklist), label: '전체'),
        NavigationDestination(icon: Icon(Icons.event_note_outlined), label: '예정'),
        NavigationDestination(icon: Icon(Icons.task_alt), label: '완료함'),
      ],
    ),
  );
}

class TaskDetail extends StatefulWidget {
  const TaskDetail({super.key, required this.task, required this.onToggle});
  final TaskData task;
  final VoidCallback onToggle;
  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    return Scaffold(
      appBar: AppBar(title: const Text('할 일 상세')),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Card(child: Padding(padding: const EdgeInsets.all(23),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.title, style: const TextStyle(fontSize: 25,
                fontWeight: FontWeight.w800, color: ink)),
              const SizedBox(height: 22),
              line(Icons.label, '카테고리', t.category),
              line(Icons.flag_outlined, '우선순위', priorityText(t.priority)),
              line(Icons.event, '마감일', t.dueDate),
              const Divider(height: 28),
              Text(t.note.isEmpty ? '메모 없음' : t.note,
                style: const TextStyle(height: 1.6)),
              const SizedBox(height: 25),
              SizedBox(width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {widget.onToggle(); setState(() {});},
                  icon: Icon(t.completed ? Icons.undo : Icons.check),
                  label: Text(t.completed ? '완료 취소'
                    : '완료 표시 (언제든 취소 가능)'))),
            ]),
          )),
          const SizedBox(height: 15),
          const Text('프로토타입: 실제 서버에는 변경 사항을 저장하지 않습니다.',
            style: TextStyle(color: Colors.black54, fontSize: 12)),
        ]),
      )),
    );
  }

  Widget line(IconData icon, String name, String content) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Icon(icon, size: 19, color: teal),
      const SizedBox(width: 10),
      SizedBox(width: 84, child: Text(name,
        style: const TextStyle(color: Colors.black54))),
      Expanded(child: Text(content,
        style: const TextStyle(fontWeight: FontWeight.w700))),
    ]),
  );
}
