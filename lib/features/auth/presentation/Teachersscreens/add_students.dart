// ignore_for_file: deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace, camel_case_types

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../data/classroom_models.dart';
import '../../data/classroom_repository.dart';
import '../../domain/class_creation_draft.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../core/l10n/app_language_controller.dart';

class addStudentsScreen extends StatefulWidget {
  const addStudentsScreen({super.key, this.draft});

  final ClassCreationDraft? draft;

  @override
  State<addStudentsScreen> createState() => _addStudentsScreenState();
}

class _addStudentsScreenState extends State<addStudentsScreen> {
  final _repo = ClassroomRepository();
  final List<PendingClassStudent> _pendingStudents = [];
  List<ClassRosterStudent> _existingStudents = [];
  bool _submitting = false;
  bool _loadingExisting = false;

  ClassCreationDraft? get _draft => widget.draft;
  bool get _isWizardMode => _draft?.classId == null;

  @override
  void initState() {
    super.initState();
    if (_draft == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Please complete class setup first.'))),
        );
        Navigator.pop(context);
      });
      return;
    }
    if (!_isWizardMode) {
      _loadExistingStudents();
    }
  }

  Future<void> _loadExistingStudents() async {
    final classId = _draft?.classId;
    if (classId == null) return;
    setState(() => _loadingExisting = true);
    try {
      final payload = await _repo.listStudents(classId);
      if (!mounted) return;
      setState(() {
        _existingStudents = payload.students;
        _loadingExisting = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loadingExisting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  int get _rosterCount => _isWizardMode ? _pendingStudents.length : _existingStudents.length;

  Future<void> _showAddStudentDialog() async {
    final existingEmails = {
      ..._pendingStudents.map((s) => s.email.toLowerCase()),
      ..._existingStudents
          .where((s) => (s.email ?? '').isNotEmpty)
          .map((s) => s.email!.toLowerCase()),
    };

    final created = await showDialog<PendingClassStudent>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _AddStudentDialog(existingEmails: existingEmails),
    );

    if (created == null || !mounted) return;

    if (_isWizardMode) {
      setState(() => _submitting = true);
      try {
        final saved = await _repo.createStudentAccount(created);
        if (!mounted) return;
        setState(() {
          _pendingStudents.add(saved);
          _submitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${saved.displayName} added to roster')),
        );
      } on ApiException catch (e) {
        if (!mounted) return;
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
        );
      } catch (_) {
        if (!mounted) return;
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Could not create student account.')),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
      return;
    }

    final classId = _draft?.classId;
    if (classId == null) return;

    setState(() => _submitting = true);
    try {
      final payload = await _repo.registerStudentInClass(classId: classId, student: created);
      if (!mounted) return;
      setState(() => _existingStudents = payload.students);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Could not add student.')),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _removeStudentAt(int index) async {
    if (_isWizardMode) {
      setState(() => _pendingStudents.removeAt(index));
      return;
    }

    final classId = _draft?.classId;
    if (classId == null || index < 0 || index >= _existingStudents.length) return;
    final student = _existingStudents[index];
    final studentId = student.id;
    if (studentId == null) {
      setState(() => _existingStudents.removeAt(index));
      return;
    }

    setState(() => _submitting = true);
    try {
      final updated = await _repo.removeStudent(classId: classId, studentId: studentId);
      if (!mounted) return;
      setState(() => _existingStudents = updated);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _finishClass() async {
    final draft = _draft;
    if (draft == null) return;

    if (!_isWizardMode) {
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    if (_pendingStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Add at least one student to continue.'))),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final created = await _repo.createClassWithStudents(
        name: draft.name,
        gradeLevel: draft.gradeLevel,
        mascotCode: draft.mascotCode,
        students: _pendingStudents,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRouter.classcreated,
        arguments: draft.copyWith(classId: created.id),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Could not create class. Please try again.')),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final draft = _draft;
    if (draft == null) {
      return const AppScaffold(
        title: '',
        showAppBar: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(50, 10, 50, 14),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _submitting ? null : _finishClass,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43C2BD),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _submitting
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1C1C)),
                    )
                  : Text(
                      _isWizardMode ? 'CREATE MY CLASS' : 'DONE',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1C1C),
                        letterSpacing: .6,
                      ),
                    ),
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF47495),
                      ),
                      child: const Icon(Icons.arrow_back, size: 18, color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(context.tr('Step 3 of 3'),
                          style: textTheme.labelMedium?.copyWith(
                            color: const Color(0xFFF47495),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 6),
                        SizedBox(
                          width: 140,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF47495),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF47495),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF47495),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 34),
                ],
              ),
              SizedBox(height: 18),
              Text(context.tr('Add Students'),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1C1C),
                ),
              ),
              SizedBox(height: 8),
              Text(context.tr('Who is joining this class? Tap Add to create student accounts,\nthen create the class when your roster is ready.'),
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF717786),
                  height: 1.25,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 14,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('Quick Add'),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1C1C),
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: (_submitting || _loadingExisting) ? null : _showAddStudentDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF47495),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add, size: 18, color: Colors.black),
                            SizedBox(width: 8),
                            Text(context.tr('ADD'),
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: .6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 14,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Class Roster ($_rosterCount)',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1A1C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (_loadingExisting)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else if (_rosterCount == 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(context.tr('No students yet. Tap Add above.'),
                          style: textTheme.bodySmall?.copyWith(color: const Color(0xFF717786)),
                        ),
                      )
                    else if (_isWizardMode)
                      ...List.generate(_pendingStudents.length, (i) {
                        final student = _pendingStudents[i];
                        return _rosterTile(
                          textTheme: textTheme,
                          name: student.displayName,
                          subtitle: student.email,
                          onRemove: _submitting ? null : () => _removeStudentAt(i),
                          isLast: i == _pendingStudents.length - 1,
                        );
                      })
                    else
                      ...List.generate(_existingStudents.length, (i) {
                        final student = _existingStudents[i];
                        return _rosterTile(
                          textTheme: textTheme,
                          name: student.displayName,
                          subtitle: student.email ?? '',
                          onRemove: _submitting ? null : () => _removeStudentAt(i),
                          isLast: i == _existingStudents.length - 1,
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rosterTile({
    required TextTheme textTheme,
    required String name,
    required String subtitle,
    required VoidCallback? onRemove,
    required bool isLast,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _initialAvatar(name),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(color: const Color(0xFF717786)),
                    ),
                  ],
                ],
              ),
            ),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  AppAssets.deleteimage,
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initialAvatar(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letter = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
    final colors = [
      const Color(0xFFF7B500),
      const Color(0xFF22C55E),
      const Color(0xFF93C5FD),
      const Color(0xFFFCA5A5),
      const Color(0xFFA7F3D0),
    ];
    final bg = colors[name.hashCode.abs() % colors.length];

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
      ),
    );
  }
}

/// Owns [TextEditingController]s for the add-student dialog lifecycle.
class _AddStudentDialog extends StatefulWidget {
  const _AddStudentDialog({required this.existingEmails});

  final Set<String> existingEmails;

  @override
  State<_AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<_AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final student = PendingClassStudent(
      displayName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    Navigator.pop(context, student);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(context.tr('Add Student'),
        style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1A1C1C)),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(
                controller: _nameController,
                label: 'Name',
                hint: 'Student full name',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  return null;
                },
              ),
              SizedBox(height: 12),
              _dialogField(
                controller: _emailController,
                label: 'Email',
                hint: 'student@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Email is required';
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Enter a valid email';
                  }
                  if (widget.existingEmails.contains(value.toLowerCase())) {
                    return 'This email is already in the roster';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              _dialogField(
                controller: _passwordController,
                label: 'Password',
                hint: 'At least 6 characters',
                obscureText: true,
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('Cancel')),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF47495),
            foregroundColor: Colors.black,
          ),
          child: Text(context.tr('ADD'), style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF3F5F7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
    );
  }
}
