import 'package:fluent_ui/fluent_ui.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/server_entity.dart';

/// Form section managing SSH authentication mode selection (Password vs Private Key),
/// password visibility toggle, and SSH key file picker.
class ServerAuthFields extends StatelessWidget {
  final SSHAuthType authType;
  final ValueChanged<SSHAuthType> onAuthTypeChanged;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscurePassword;
  final TextEditingController privateKeyController;
  final TextEditingController passphraseController;
  final VoidCallback onPickKeyFile;

  const ServerAuthFields({
    super.key,
    required this.authType,
    required this.onAuthTypeChanged,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscurePassword,
    required this.privateKeyController,
    required this.passphraseController,
    required this.onPickKeyFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoLabel(
          label: context.l10n.serversFieldAuthType,
          child: RadioGroup<SSHAuthType>(
            groupValue: authType,
            onChanged: (val) {
              if (val != null) onAuthTypeChanged(val);
            },
            child: Wrap(
              spacing: AppSpacing.xl,
              children: [
                RadioButton<SSHAuthType>(
                  value: SSHAuthType.password,
                  content: Text(context.l10n.serversAuthPassword),
                ),
                RadioButton<SSHAuthType>(
                  value: SSHAuthType.privateKey,
                  content: Text(context.l10n.serversAuthKey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        if (authType == SSHAuthType.password)
          InfoLabel(
            label: context.l10n.serversFieldPassword,
            child: TextBox(
              controller: passwordController,
              obscureText: obscurePassword,
              placeholder: context.l10n.serversFieldPasswordPlaceholder,
              suffix: IconButton(
                icon: Icon(
                  obscurePassword ? FluentIcons.view : FluentIcons.hide3,
                  size: AppIconSize.md,
                ),
                onPressed: onToggleObscurePassword,
              ),
            ),
          )
        else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.serversFieldPrivateKey,
                style: AppTypo.caption(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                ),
              ),
              Button(
                onPressed: onPickKeyFile,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.open_file, size: AppIconSize.sm),
                    const SizedBox(width: AppSpacing.xs),
                    Text(context.l10n.serversSelectKeyFile),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TextBox(
            controller: privateKeyController,
            maxLines: 4,
            placeholder: '-----BEGIN OPENSSH PRIVATE KEY-----\n...',
          ),
          const SizedBox(height: AppSpacing.sm),
          InfoLabel(
            label: context.l10n.serversFieldPassphrase,
            child: TextBox(
              controller: passphraseController,
              obscureText: true,
              placeholder: context.l10n.serversFieldPassphrasePlaceholder,
            ),
          ),
        ],
      ],
    );
  }
}

