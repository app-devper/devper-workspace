// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/app_colors.dart';
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/radius.dart';
import 'package:design_system/theme/spacing.dart';
import 'package:design_system/widgets/dialogs.dart';
import 'package:design_system/widgets/title_bar.dart';

// Project imports:
import 'package:sm/domain/model/system/param.dart';
import 'package:sm/domain/model/system/system.dart';

/// Add/edit form for a system. [system] null means add.
///
/// The UM API only accepts systemName and host on update, so clientId and
/// systemCode are read-only once the system exists.
void showSystemFormDialog(
  BuildContext context, {
  System? system,
  required void Function(CreateParam param) onCreate,
  required void Function(UpdateSystemParam param) onUpdate,
}) {
  showCenterDialog(
    context: context,
    minWidth: 420,
    maxWidth: 420,
    minHeight: 460,
    maxHeight: 460,
    builder: (dialogContext) => _SystemForm(
      system: system,
      onCreate: onCreate,
      onUpdate: onUpdate,
    ),
  );
}

class _SystemForm extends StatefulWidget {
  final System? system;
  final void Function(CreateParam param) onCreate;
  final void Function(UpdateSystemParam param) onUpdate;

  const _SystemForm({
    required this.system,
    required this.onCreate,
    required this.onUpdate,
  });

  @override
  State<_SystemForm> createState() => _SystemFormState();
}

class _SystemFormState extends State<_SystemForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clientId;
  late final TextEditingController _systemCode;
  late final TextEditingController _systemName;
  late final TextEditingController _host;

  bool get _isEdit => widget.system != null;

  @override
  void initState() {
    super.initState();
    final system = widget.system;
    _clientId = TextEditingController(text: system?.clientId ?? '');
    _systemCode = TextEditingController(text: system?.systemCode ?? '');
    _systemName = TextEditingController(text: system?.systemName ?? '');
    _host = TextEditingController(text: system?.host ?? '');
  }

  @override
  void dispose() {
    _clientId.dispose();
    _systemCode.dispose();
    _systemName.dispose();
    _host.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final system = widget.system;
    if (system == null) {
      widget.onCreate(CreateParam(
        clientId: _clientId.text.trim(),
        systemName: _systemName.text.trim(),
        systemCode: _systemCode.text.trim(),
        host: _host.text.trim(),
      ));
    } else {
      widget.onUpdate(UpdateSystemParam(
        systemId: system.id,
        systemName: _systemName.text.trim(),
        host: _host.text.trim(),
      ));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(
          title: _isEdit ? 'แก้ไขระบบ' : 'เพิ่มระบบ',
          onBack: () => Navigator.of(context).pop(),
          action: 'บันทึก',
          onAction: _submit,
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEdit) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: CustomColor.info.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 18, color: CustomColor.info),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Client ID และรหัสระบบแก้ไขไม่ได้หลังสร้างแล้ว',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.of(context).textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _field(
                    controller: _clientId,
                    label: 'Client ID',
                    hint: 'เช่น 000',
                    enabled: !_isEdit,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _field(
                    controller: _systemCode,
                    label: 'รหัสระบบ',
                    hint: 'เช่น POS',
                    enabled: !_isEdit,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _field(
                    controller: _systemName,
                    label: 'ชื่อระบบ',
                    hint: 'ชื่อที่แสดงให้ผู้ใช้เห็น',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _field(
                    controller: _host,
                    label: 'Host',
                    hint: 'https://api.example.com',
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: !enabled,
        fillColor: AppColors.of(context).surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? 'กรุณากรอก$label' : null,
    );
  }
}
