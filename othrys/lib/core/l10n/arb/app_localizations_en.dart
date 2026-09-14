// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Othrys';

  @override
  String get navServers => 'Servers';

  @override
  String get navTerminal => 'Terminal';

  @override
  String get navFiles => 'Files';

  @override
  String get navMonitoring => 'Monitoring';

  @override
  String get navDocker => 'Docker';

  @override
  String get navServices => 'Services';

  @override
  String get navTunnels => 'Tunnels';

  @override
  String get navActivity => 'Audit Log';

  @override
  String get navSettings => 'Settings';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonConnect => 'Connect';

  @override
  String get commonDisconnect => 'Disconnect';

  @override
  String get commonConnected => 'Connected';

  @override
  String get commonDisconnected => 'Disconnected';

  @override
  String get commonConnecting => 'Connecting...';

  @override
  String get commonReconnecting => 'Reconnecting...';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSearch => 'Search...';

  @override
  String get commonFilter => 'Filter';

  @override
  String get commonName => 'Name';

  @override
  String get commonStatus => 'Status';

  @override
  String get commonActions => 'Actions';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonCopied => 'Copied to clipboard';

  @override
  String get commonFieldRequired => 'Please fill in all required fields.';

  @override
  String get commonEmpty => 'No items found.';

  @override
  String get windowExitConfirmTitle => 'Confirm Application Exit';

  @override
  String windowExitConfirmMessage(int count) {
    return '$count active SSH session(s) currently open. Exiting will terminate all remote sessions. Are you sure?';
  }

  @override
  String get windowExitDisconnect => 'Disconnect & Exit';

  @override
  String get windowSearchActions => 'Search actions...';

  @override
  String windowActiveCount(int count) {
    return '$count connected';
  }

  @override
  String tabErrorTitle(String tabName) {
    return 'An unexpected error occurred in $tabName';
  }

  @override
  String get tabErrorReload => 'Reload Tab';

  @override
  String get serversTitle => 'Servers & Environments';

  @override
  String get serversFilterPlaceholder => 'Filter servers...';

  @override
  String get serversAdd => 'Add Server';

  @override
  String get serversEdit => 'Edit Server';

  @override
  String get serversEmptyTitle => 'No servers registered';

  @override
  String get serversEmptySubtitle =>
      'Add your remote VPS or cloud instances to start managing DevOps resources.';

  @override
  String get serversAddFirst => 'Add Your First Server';

  @override
  String get serversNeverConnected => 'Never connected';

  @override
  String serversSeen(String time) {
    return 'Seen $time';
  }

  @override
  String get serversDeleteConfirmTitle => 'Delete Server Profile';

  @override
  String serversDeleteConfirmMessage(String name) {
    return 'Are you sure you want to remove \"$name\"? Credentials and connection settings will be safely wiped.';
  }

  @override
  String get serversTestConnection => 'Test Connection';

  @override
  String get serversTesting => 'Testing connection...';

  @override
  String get serversTestSuccess => 'Connection successful!';

  @override
  String serversTestFailed(String reason) {
    return 'Connection failed: $reason';
  }

  @override
  String get serversFieldHost => 'Host / IP Address';

  @override
  String get serversFieldPort => 'SSH Port';

  @override
  String get serversFieldUsername => 'Username';

  @override
  String get serversFieldAuthType => 'Authentication Method';

  @override
  String get serversAuthPassword => 'Password';

  @override
  String get serversAuthKey => 'Private Key';

  @override
  String get serversFieldPassword => 'Password';

  @override
  String get serversFieldPrivateKey => 'Private Key (PEM/OpenSSH)';

  @override
  String get serversFieldPassphrase => 'Key Passphrase (optional)';

  @override
  String get serversSelectKeyFile => 'Pick Key File';

  @override
  String get serversShowPassword => 'Show password';

  @override
  String get terminalNewTab => 'New Tab';

  @override
  String get terminalCloseTab => 'Close Tab';

  @override
  String get terminalActiveTabs => 'Active Shells';

  @override
  String get terminalClearBuffer => 'Clear Screen';

  @override
  String get terminalCopy => 'Copy';

  @override
  String get terminalPaste => 'Paste';

  @override
  String get terminalSelectAll => 'Select All';

  @override
  String get terminalOpenSession => 'Open Terminal Session';

  @override
  String get terminalGuardMessage =>
      'Connect to a server from the Servers tab to open an interactive terminal.';

  @override
  String monitoringTitle(String serverName) {
    return '$serverName — System Metrics';
  }

  @override
  String monitoringUptimeLabel(String uptime) {
    return 'Uptime: $uptime';
  }

  @override
  String get monitoringWarning => 'Monitoring Warning';

  @override
  String get monitoringCpuTitle => 'CPU Usage';

  @override
  String monitoringCpuKernel(String kernel) {
    return 'Kernel: $kernel';
  }

  @override
  String get monitoringRamTitle => 'RAM Memory';

  @override
  String get monitoringDiskTitle => 'Disk Storage (Root)';

  @override
  String get monitoringCpuTrend => 'CPU Load Trend (Last 60 Seconds)';

  @override
  String get monitoringCollecting => 'Collecting metrics...';

  @override
  String get monitoringGuardMessage =>
      'Connect to a server from the Servers tab to inspect real-time performance telemetry.';

  @override
  String get dockerTitle => 'Container Management';

  @override
  String get dockerContainers => 'Containers';

  @override
  String get dockerCompose => 'Docker Compose';

  @override
  String get dockerStart => 'Start';

  @override
  String get dockerStop => 'Stop';

  @override
  String get dockerRestart => 'Restart';

  @override
  String get dockerRemove => 'Remove';

  @override
  String get dockerLogs => 'View Logs';

  @override
  String get dockerNoContainers =>
      'No Docker containers detected on this host.';

  @override
  String dockerConfirmRemove(String name) {
    return 'Are you sure you want to remove container \'$name\'?';
  }

  @override
  String dockerConfirmStop(String name) {
    return 'Are you sure you want to stop running container \'$name\'?';
  }

  @override
  String get dockerGuardMessage =>
      'Connect to a server to discover and manage Docker containers.';

  @override
  String get dockerNotInstalledTitle => 'Docker is not installed';

  @override
  String get dockerNotInstalledSubtitle =>
      'Docker was not found on this server. Run the official automated install script to configure the Docker runtime engine.';

  @override
  String get dockerInstallCommand => 'curl -fsSL https://get.docker.com | sh';

  @override
  String get dockerCopyCommand => 'Copy Install Command';

  @override
  String get dockerComposePath => 'Compose Directory Path';

  @override
  String get dockerComposeUp => 'Compose Up';

  @override
  String get dockerComposeDown => 'Compose Down';

  @override
  String get dockerComposeLogs => 'Compose Logs';

  @override
  String get dockerLogsStreaming => 'Streaming Logs';

  @override
  String get dockerLogsPause => 'Pause Stream';

  @override
  String get dockerLogsResume => 'Resume Stream';

  @override
  String get dockerLogsCopy => 'Copy Logs';

  @override
  String get servicesTitle => 'Systemd Services';

  @override
  String get servicesSearchPlaceholder => 'Filter services by unit name...';

  @override
  String get servicesStart => 'Start';

  @override
  String get servicesStop => 'Stop';

  @override
  String get servicesRestart => 'Restart';

  @override
  String get servicesReload => 'Reload';

  @override
  String get servicesLogs => 'View Journals';

  @override
  String get servicesNoServices =>
      'No services found matching current criteria.';

  @override
  String servicesConfirmStopCritical(String unit) {
    return 'Warning: \'$unit\' is a critical system service. Stopping it may disconnect your SSH session or degrade server operation. Are you sure you want to proceed?';
  }

  @override
  String servicesConfirmStop(String unit) {
    return 'Are you sure you want to stop service \"$unit\"?';
  }

  @override
  String get servicesEnable => 'Enable';

  @override
  String get servicesDisable => 'Disable';

  @override
  String get servicesEnabledBadge => 'Enabled on boot';

  @override
  String get servicesDisabledBadge => 'Disabled on boot';

  @override
  String get servicesGuardMessage =>
      'Connect to a server to inspect systemd services and units.';

  @override
  String get filesTitle => 'SFTP File Explorer';

  @override
  String get filesNewFolder => 'New Folder';

  @override
  String get filesNewFile => 'New File';

  @override
  String get filesUpload => 'Upload';

  @override
  String get filesDownload => 'Download';

  @override
  String get filesRename => 'Rename';

  @override
  String get filesDelete => 'Delete';

  @override
  String get filesEdit => 'Edit File';

  @override
  String get filesSaveContent => 'Save Content';

  @override
  String filesDeleteConfirm(String name) {
    return 'Are you sure you want to delete \'$name\'?';
  }

  @override
  String get filesTooLarge => 'File size exceeds 1 MB limit for inline editor.';

  @override
  String get filesBinaryWarning =>
      'Binary files cannot be opened in text editor.';

  @override
  String get filesGuardMessage =>
      'Connect to a server to browse and manage remote files via SFTP.';

  @override
  String filesUploadSuccess(String name) {
    return 'File uploaded successfully: $name';
  }

  @override
  String filesDownloadSuccess(String name) {
    return 'File downloaded successfully: $name';
  }

  @override
  String filesRenameTitle(String name) {
    return 'Rename: $name';
  }

  @override
  String get filesRenamePlaceholder => 'Enter new file or folder name...';

  @override
  String get filesUploadLimitExceeded =>
      'File size exceeds 100 MB upload limit.';

  @override
  String get filesDownloadLimitExceeded =>
      'File size exceeds 100 MB download limit.';

  @override
  String get filesRootDirectory => 'Root';

  @override
  String get tunnelsTitle => 'SSH Tunnels';

  @override
  String get tunnelsNew => 'New Tunnel';

  @override
  String get tunnelsActive => 'Active Tunnels';

  @override
  String get tunnelsNoTunnels => 'No port forwarding tunnels configured.';

  @override
  String get tunnelsTypeLocal => 'Local Forwarding';

  @override
  String get tunnelsTypeRemote => 'Remote Forwarding';

  @override
  String get tunnelsTypeDynamic => 'Dynamic SOCKS5';

  @override
  String get tunnelsLocalPort => 'Local Port';

  @override
  String get tunnelsRemoteHost => 'Remote Target Host';

  @override
  String get tunnelsRemotePort => 'Remote Port';

  @override
  String get tunnelsGuardMessage =>
      'Connect to a server to manage port forwarding tunnels.';

  @override
  String get activityTitle => 'Security & Action Audit Log';

  @override
  String get activityClear => 'Clear History';

  @override
  String get activityFilterAll => 'All Categories';

  @override
  String get activityFilterSsh => 'SSH Connections';

  @override
  String get activityFilterDocker => 'Docker Commands';

  @override
  String get activityFilterServices => 'System Services';

  @override
  String get activityFilterFiles => 'File Changes';

  @override
  String get activityFilterSecurity => 'Security Warnings';

  @override
  String get activityNoLogs => 'No activity logs recorded yet.';

  @override
  String filesHeader(String serverName) {
    return '$serverName — SFTP Files';
  }

  @override
  String filesEditorTitle(String name) {
    return 'Editing: $name';
  }

  @override
  String get filesSaveFile => 'Save File';

  @override
  String get filesCreateFolderTitle => 'Create New Folder';

  @override
  String get filesCreateFileTitle => 'Create New File';

  @override
  String get filesCreate => 'Create';

  @override
  String get filesFolderPlaceholder => 'folder_name';

  @override
  String get filesFilePlaceholder => 'filename.txt';

  @override
  String get filesDeleteConfirmTitle => 'Confirm Deletion';

  @override
  String get filesEmpty => 'Directory is empty';

  @override
  String get filesFolderType => 'Folder';

  @override
  String get filesErrorTitle => 'SFTP Error';

  @override
  String get filesCannotOpen => 'Cannot Open File';

  @override
  String get filesSaveFailed => 'Save Failed';

  @override
  String get filesCreationFailed => 'Creation Failed';

  @override
  String get filesDeletionFailed => 'Deletion Failed';

  @override
  String get filesLocation => 'Location:';

  @override
  String get filesNameLabel => 'Name';

  @override
  String get filesInvalidName => 'Name contains invalid characters (/ \\  )';

  @override
  String get filesNameAlreadyExists => 'An item with this name already exists';

  @override
  String get tunnelsDialogTitle => 'New SSH Port Forwarding Tunnel';

  @override
  String get tunnelsNameLabel => 'Tunnel Name';

  @override
  String get tunnelsLocalPortLabel => 'Local Port on Windows PC';

  @override
  String get tunnelsRemotePortLabel => 'Remote Destination Port';

  @override
  String get tunnelsRemoteHostLabel => 'Destination Host (relative to VPS)';

  @override
  String get tunnelsStart => 'Start Tunnel';

  @override
  String get tunnelsClose => 'Close';

  @override
  String get tunnelsErrorFailed => 'Failed to establish tunnel';

  @override
  String get tunnelsEmptySubtitle =>
      'Forward local ports securely through your active SSH connection.';

  @override
  String get activityFilterTunnels => 'SSH Tunnels';

  @override
  String get activityFilterSystem => 'System Events';

  @override
  String get cmdPalettePlaceholder => 'Type a command, server, or action...';

  @override
  String get cmdPaletteEscToClose => 'ESC to close';

  @override
  String get cmdPaletteSectionServers => 'SERVERS';

  @override
  String get cmdPaletteSectionNavigation => 'NAVIGATION';

  @override
  String get cmdPaletteSectionActions => 'ACTIONS';

  @override
  String get cmdPaletteNoResults => 'No matching commands or servers found.';

  @override
  String get cmdPaletteDisconnect => 'Disconnect Active Session';

  @override
  String get serversAddTitle => 'Add Server Profile';

  @override
  String get serversEditTitle => 'Edit Server Profile';

  @override
  String get serversFieldName => 'Display Name';

  @override
  String get serversFieldNamePlaceholder => 'e.g. Production Web Server';

  @override
  String get serversFieldHostPlaceholder => '192.168.1.10 or server.com';

  @override
  String get serversFieldGroup => 'Group / Category';

  @override
  String get serversFieldGroupPlaceholder => 'e.g. Production, Clients';

  @override
  String get serversFieldPasswordPlaceholder => 'Enter remote user password';

  @override
  String get serversFieldPassphrasePlaceholder =>
      'Key decryption passphrase if encrypted';

  @override
  String get serversFieldBastion => 'Jump Host / Bastion (Optional)';

  @override
  String get serversBastionDirect => 'Direct Connection (No Bastion)';

  @override
  String get serversAddSubmit => 'Add Server';

  @override
  String get serversEditSubmit => 'Save Changes';

  @override
  String get settingsTitle => 'Application Settings';

  @override
  String get settingsTheme => 'Interface Theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System Default';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLangFr => 'Français';

  @override
  String get settingsLangEn => 'English';

  @override
  String settingsTerminalFontSize(int size) {
    return 'Terminal Font Size (${size}px)';
  }

  @override
  String settingsMonitoringInterval(int seconds) {
    return 'Monitoring Polling Interval (${seconds}s)';
  }

  @override
  String get settingsBackup => 'Configuration Backup & Restore';

  @override
  String get settingsExport => 'Export Configuration';

  @override
  String get settingsExportDesc =>
      'Export encrypted server and tunnel configurations as backup.';

  @override
  String get settingsExportSuccess => 'Configurations successfully exported.';

  @override
  String get settingsImport => 'Import Configuration';

  @override
  String get settingsImportDesc =>
      'Restore server profiles and tunnels from an exported backup file.';

  @override
  String get settingsImportSuccess => 'Configurations successfully imported.';

  @override
  String get settingsLicense => 'License: MIT Open Source';

  @override
  String get settingsGitHub => 'GitHub Repository';

  @override
  String get settingsAbout => 'About Othrys';

  @override
  String get settingsVersion => 'Version';

  @override
  String get onboardingWelcome => 'Welcome to Othrys';

  @override
  String get onboardingSubtitle => 'Linux server administration.';

  @override
  String get onboardingAddServer => 'Add Your First Server';

  @override
  String get onboardingExplore => 'Explore Dashboard';

  @override
  String get guardNoConnectionTitle => 'No Active SSH Connection';

  @override
  String get guardNoConnectionSubtitle =>
      'Select a server and click \'Connect\' to enable this feature.';

  @override
  String get guardSelectServer => 'Go to Servers';

  @override
  String get tunnelsEmptyTitle => 'No Active Tunnels';

  @override
  String get tunnelsDeleteConfirmTitle => 'Delete Tunnel';

  @override
  String tunnelsDeleteConfirmMessage(String name) {
    return 'Are you sure you want to delete the tunnel \'$name\'?';
  }

  @override
  String get roleRoot => 'Root (Superuser)';

  @override
  String get roleSudoer => 'Admin (sudo)';

  @override
  String get roleStandard => 'Standard (Restricted)';

  @override
  String servicesPermissionRestricted(String username) {
    return 'Read-only mode: connected account ($username) does not have root or sudo privileges to modify services.';
  }

  @override
  String dockerPermissionRestricted(String username) {
    return 'Restricted access: connected account ($username) does not have access to the Docker daemon (not in docker group and no sudo).';
  }

  @override
  String filesPermissionNotice(String username) {
    return 'System directory: account ($username) has restricted privileges outside home directory.';
  }

  @override
  String get filesOpenTerminal => 'Open Terminal Here';

  @override
  String get filesCloseTerminal => 'Close Terminal';

  @override
  String filesTerminalTitle(String path) {
    return 'Terminal — $path';
  }

  @override
  String get filesCopyPath => 'Copy Path';

  @override
  String get filesPathCopied => 'Path copied to clipboard';

  @override
  String get filesCdHere => 'Sync Terminal (cd)';

  @override
  String get filesNavigateBack => 'Back';

  @override
  String get filesNavigateForward => 'Forward';

  @override
  String get filesNavigateUp => 'Up';

  @override
  String get filesEditPath => 'Edit Path';

  @override
  String get commonExpand => 'Expand';

  @override
  String get commonCollapse => 'Collapse';

  @override
  String get terminalNoConnection => 'No active SSH connection';

  @override
  String get navDatabases => 'Databases';

  @override
  String get navWebSites => 'Web Sites & SSL';

  @override
  String get servicesCreate => 'New Service';

  @override
  String get servicesCreateTitle => 'Create Systemd Service';

  @override
  String get servicesNameLabel => 'Service Name';

  @override
  String get servicesNamePlaceholder => 'e.g. my-api';

  @override
  String get servicesDescLabel => 'Description';

  @override
  String get servicesDescPlaceholder => 'e.g. My Backend API Service';

  @override
  String get servicesExecStartLabel => 'ExecStart Command';

  @override
  String get servicesExecStartPlaceholder =>
      '/usr/bin/node /var/www/my-api/index.js';

  @override
  String get servicesWorkDirLabel => 'Working Directory';

  @override
  String get servicesWorkDirPlaceholder => '/var/www/my-api';

  @override
  String get servicesUserLabel => 'Run as User';

  @override
  String get servicesRestartPolicy => 'Restart Policy';

  @override
  String get servicesEnvLabel => 'Environment Variables (KEY=VALUE)';

  @override
  String get servicesEnableBoot => 'Enable at boot';

  @override
  String get servicesStartNow => 'Start immediately';

  @override
  String get servicesPreview => 'Unit File Preview';

  @override
  String servicesCreateSuccess(String name) {
    return 'Service \'$name\' created and deployed successfully';
  }

  @override
  String servicesCreateError(String error) {
    return 'Failed to create service: $error';
  }

  @override
  String get dbTitle => 'Databases';

  @override
  String get dbEngineSelect => 'Database Engine';

  @override
  String get dbMysql => 'MySQL / MariaDB';

  @override
  String get dbPostgres => 'PostgreSQL';

  @override
  String dbNotInstalled(String engine) {
    return '$engine is not installed or running on this server';
  }

  @override
  String get dbTabDatabases => 'Databases';

  @override
  String get dbTabUsers => 'Users & Privileges';

  @override
  String get dbTabQuery => 'SQL Console';

  @override
  String get dbCreate => 'New Database';

  @override
  String get dbCreateTitle => 'Create Database';

  @override
  String get dbName => 'Database Name';

  @override
  String get dbCollation => 'Charset / Collation';

  @override
  String dbDeleteConfirm(String name) {
    return 'Are you sure you want to drop database \'$name\'? This action cannot be undone.';
  }

  @override
  String get dbUserCreate => 'New User';

  @override
  String get dbUserCreateTitle => 'Create Database User';

  @override
  String get dbUsername => 'Username';

  @override
  String get dbPassword => 'Password';

  @override
  String get dbHost => 'Host';

  @override
  String get dbPrivileges => 'Privileges';

  @override
  String dbUserDeleteConfirm(String name) {
    return 'Are you sure you want to delete user \'$name\'?';
  }

  @override
  String get dbQueryRun => 'Execute Query';

  @override
  String get dbQueryPlaceholder =>
      'Write SQL query (e.g. SELECT * FROM table LIMIT 50;)...';

  @override
  String get dbQueryResults => 'Results';

  @override
  String get dbQueryEmpty => 'Query executed successfully, no rows returned.';

  @override
  String get dbExport => 'Export SQL Dump';

  @override
  String get dbImport => 'Import SQL File';

  @override
  String get webSitesTitle => 'Web Sites & SSL';

  @override
  String get webSitesNginxNotInstalled =>
      'Nginx is not installed on this server. Install it to manage web sites and reverse proxies.';

  @override
  String get webSitesInstallNginx => 'Install Nginx';

  @override
  String get webSitesCreate => 'New Site';

  @override
  String get webSitesCreateTitle => 'Configure New Web Site';

  @override
  String get webSitesDomain => 'Domain / Subdomain Name';

  @override
  String get webSitesDomainPlaceholder =>
      'e.g. api.example.com or app.example.com';

  @override
  String get webSitesType => 'Site Type';

  @override
  String get webSitesTypeProxy => 'Reverse Proxy (API / Backend / Docker)';

  @override
  String get webSitesTypeStatic => 'Static Website (HTML / SPA / Frontend)';

  @override
  String get webSitesTargetPort => 'Local Port / Target URL';

  @override
  String get webSitesTargetPortPlaceholder =>
      'e.g. 3000 or http://127.0.0.1:8080';

  @override
  String get webSitesStaticRoot => 'Document Root Path';

  @override
  String get webSitesStaticRootPlaceholder => '/var/www/my-site/dist';

  @override
  String get webSitesEnableSsl => 'Enable HTTPS with Let\'s Encrypt (Certbot)';

  @override
  String get webSitesEmail => 'Let\'s Encrypt Email (for renewal notices)';

  @override
  String get webSitesStatusEnabled => 'Enabled';

  @override
  String get webSitesStatusDisabled => 'Disabled';

  @override
  String get webSitesEnable => 'Enable Site';

  @override
  String get webSitesDisable => 'Disable Site';

  @override
  String webSitesDeleteConfirm(String domain) {
    return 'Are you sure you want to delete site \'$domain\'?';
  }

  @override
  String get webSitesProvisionSsl => 'Provision SSL (HTTPS)';

  @override
  String get webSitesRenewSsl => 'Test SSL Renewal';

  @override
  String get webSitesSslActive => 'HTTPS Secured';

  @override
  String get webSitesSslInactive => 'HTTP Only';

  @override
  String get navSecurity => 'Security & Admin';

  @override
  String get adminTitle => 'Server Administration & Security';

  @override
  String get adminTabFirewall => 'Firewall (UFW)';

  @override
  String get adminTabPorts => 'Listening Ports';

  @override
  String get adminTabUsers => 'System Users';

  @override
  String get adminTabMaintenance => 'Maintenance & Settings';

  @override
  String get adminFirewallStatus => 'Firewall Status';

  @override
  String get adminFirewallActive => 'Firewall is ACTIVE';

  @override
  String get adminFirewallInactive => 'Firewall is INACTIVE';

  @override
  String get adminFirewallEnable => 'Enable Firewall';

  @override
  String get adminFirewallDisable => 'Disable Firewall';

  @override
  String get adminFirewallConfirmEnable =>
      'Enabling the firewall without an active SSH rule may disconnect you. Ensure port 22 or your custom SSH port is allowed. Continue?';

  @override
  String get adminFirewallAddRule => 'Add Rule';

  @override
  String get adminFirewallAddRuleTitle => 'Add Firewall Rule';

  @override
  String get adminFirewallRulePort => 'Port / Range / Service';

  @override
  String get adminFirewallRulePortPlaceholder => 'e.g. 22 or 8080 or 8000:8010';

  @override
  String get adminFirewallRuleProto => 'Protocol';

  @override
  String get adminFirewallRuleAction => 'Action';

  @override
  String get adminFirewallRuleSource => 'Source IP / Subnet (Optional)';

  @override
  String get adminFirewallRuleSourcePlaceholder =>
      'e.g. Anywhere or 192.168.1.0/24';

  @override
  String get adminFirewallPreset => 'Preset Service';

  @override
  String adminFirewallDeleteConfirm(int ruleNumber, String target) {
    return 'Delete firewall rule #$ruleNumber ($target)?';
  }

  @override
  String get adminPortsTitle => 'Open Ports & Sockets';

  @override
  String get adminPortsProcess => 'Process / Service';

  @override
  String get adminPortsAddress => 'Local Address';

  @override
  String get adminPortsPublic => 'Publicly Exposed';

  @override
  String get adminPortsLocal => 'Localhost Only';

  @override
  String get adminPortsAllowInFirewall => 'Allow in Firewall';

  @override
  String get adminUsersTitle => 'Linux System Accounts';

  @override
  String get adminUsersAdd => 'New User';

  @override
  String get adminUsersAddTitle => 'Create System User';

  @override
  String get adminUsersUsername => 'Username';

  @override
  String get adminUsersUsernamePlaceholder => 'e.g. deployer';

  @override
  String get adminUsersPassword => 'Initial Password';

  @override
  String get adminUsersPasswordPlaceholder => 'Strong password';

  @override
  String get adminUsersShell => 'Login Shell';

  @override
  String get adminUsersGrantSudo => 'Grant Administrator Privileges (sudo)';

  @override
  String get adminUsersSshKeys => 'Authorized SSH Keys';

  @override
  String get adminUsersAddKey => 'Add SSH Key';

  @override
  String get adminUsersAddKeyTitle => 'Add Authorized Public Key';

  @override
  String get adminUsersKeyPlaceholder =>
      'Paste public key (ssh-ed25519 or ssh-rsa)...';

  @override
  String get adminMaintenanceUpdates => 'Operating System Updates';

  @override
  String adminMaintenanceUpdatesAvailable(int count) {
    return '$count package(s) can be upgraded.';
  }

  @override
  String get adminMaintenanceUpdatesNone =>
      'Your operating system is up to date.';

  @override
  String get adminMaintenanceApplyUpdates => 'Upgrade System Packages';

  @override
  String get adminMaintenanceHostname => 'Server Hostname';

  @override
  String get adminMaintenanceChangeHostname => 'Update Hostname';

  @override
  String get adminMaintenanceReboot => 'Reboot Server';

  @override
  String get adminMaintenanceRebootConfirm =>
      'Rebooting will terminate all active connections and services. Are you sure you want to reboot the remote server?';

  @override
  String get navGit => 'Git Repositories';

  @override
  String get gitTitle => 'Git Repositories';

  @override
  String get gitSubtitle =>
      'Manage, clone, pull, and monitor Git projects on your server.';

  @override
  String get gitNotInstalledTitle => 'Git is Not Installed';

  @override
  String get gitNotInstalledDesc =>
      'The Git version control binary was not found on this server. Install it to manage your repositories.';

  @override
  String get gitInstallBtn => 'Install Git';

  @override
  String get gitInstalling => 'Installing Git...';

  @override
  String get gitInstalledSuccessTitle => 'Git Installed';

  @override
  String get gitInstalledSuccessDesc =>
      'Git was successfully installed on the remote server.';

  @override
  String get gitNoReposTitle => 'No Repositories Tracked';

  @override
  String get gitNoReposDesc =>
      'Scan your server for existing Git projects or clone a new repository.';

  @override
  String get gitScanServer => 'Scan Server';

  @override
  String get gitScanning => 'Scanning for repositories...';

  @override
  String gitScanFound(int count) {
    return '$count repository(ies) discovered!';
  }

  @override
  String get gitAddRepoPath => 'Add Existing Path';

  @override
  String get gitAddRepoPathTitle => 'Track Existing Repository';

  @override
  String get gitAddRepoPathPlaceholder => 'e.g. /var/www/my-app';

  @override
  String get gitClone => 'Clone Repository';

  @override
  String get gitCloneTitle => 'Clone Git Repository';

  @override
  String get gitCloneUrl => 'Repository URL (HTTPS or SSH)';

  @override
  String get gitCloneUrlPlaceholder =>
      'e.g. https://github.com/org/repo.git or git@github.com:org/repo.git';

  @override
  String get gitCloneDest => 'Destination Directory';

  @override
  String get gitCloneDestPlaceholder => 'e.g. /var/www/my-app';

  @override
  String get gitCloneBranch => 'Initial Branch (Optional)';

  @override
  String get gitCloneBranchPlaceholder => 'e.g. main or production';

  @override
  String get gitCloneShallow =>
      'Shallow clone (--depth 1, faster for deployments)';

  @override
  String get gitCloneSubmodules => 'Recurse submodules';

  @override
  String get gitCloneSshNotice =>
      'If cloning a private SSH repository, ensure this server\'s public Deploy Key is added to GitHub / GitLab.';

  @override
  String get gitSelectRepo => 'Select Repository';

  @override
  String get gitRemoveTracked => 'Untrack Repository';

  @override
  String gitRemoveTrackedConfirm(String name) {
    return 'Remove \'$name\' from tracked repositories? (Remote files will not be deleted)';
  }

  @override
  String get gitPull => 'Pull';

  @override
  String get gitPulling => 'Pulling changes...';

  @override
  String get gitPullSuccess => 'Successfully pulled latest changes.';

  @override
  String get gitFetch => 'Fetch';

  @override
  String get gitFetching => 'Fetching remote refs...';

  @override
  String get gitFetchSuccess => 'Successfully fetched remote refs.';

  @override
  String get gitTerminalHere => 'Terminal Here';

  @override
  String get gitExploreFiles => 'Explore Files';

  @override
  String get gitStatusClean => 'Working tree is clean';

  @override
  String gitStatusDirty(int count) {
    return 'Uncommitted changes ($count)';
  }

  @override
  String gitStatusAhead(int count) {
    return '$count commit(s) ahead';
  }

  @override
  String gitStatusBehind(int count) {
    return '$count commit(s) behind';
  }

  @override
  String get gitStatusUpToDate => 'Up to date with origin';

  @override
  String get gitStatusDetached => 'Detached HEAD';

  @override
  String get gitTabStatus => 'Status & Changes';

  @override
  String get gitTabBranches => 'Branches';

  @override
  String get gitTabHistory => 'Commit History';

  @override
  String get gitTabDeployKey => 'Deploy Keys & Config';

  @override
  String get gitDiscardChanges => 'Discard Changes';

  @override
  String get gitDiscardConfirm =>
      'Discard all local modifications and untracked files? This action cannot be undone.';

  @override
  String get gitStash => 'Stash Changes';

  @override
  String get gitStashPop => 'Apply Stash (Pop)';

  @override
  String get gitCommit => 'Commit & Push';

  @override
  String get gitCommitTitle => 'Commit & Push Changes';

  @override
  String get gitCommitMessage => 'Commit Message';

  @override
  String get gitCommitMessagePlaceholder => 'Describe the changes...';

  @override
  String get gitPushAlso => 'Push to remote immediately';

  @override
  String get gitBranchCurrent => 'Current Branch';

  @override
  String get gitBranchSwitch => 'Switch Branch';

  @override
  String get gitBranchNew => 'New Branch';

  @override
  String get gitBranchNewTitle => 'Create & Checkout Branch';

  @override
  String get gitBranchNamePlaceholder => 'e.g. feature/api-auth';

  @override
  String get gitDeployKeyTitle => 'Server Deploy Key (SSH)';

  @override
  String get gitDeployKeyDesc =>
      'Copy this public key and add it as a Deploy Key in GitHub / GitLab to clone and pull private repositories without credentials.';

  @override
  String get gitDeployKeyGenerate => 'Generate Deploy Key (ED25519)';

  @override
  String get gitDeployKeyCopy => 'Copy Public Key';

  @override
  String get gitDeployKeyCopied => 'Deploy key copied to clipboard!';

  @override
  String get gitDeployKeyNone =>
      'No SSH key pair found on this server. Generate one to enable private repo cloning.';

  @override
  String get gitConfigTitle => 'Git Committer Identity';

  @override
  String get gitConfigName => 'Git User Name';

  @override
  String get gitConfigEmail => 'Git User Email';

  @override
  String get gitConfigSave => 'Save Git Identity';

  @override
  String get gitOpenFileInManager => 'Open in Git';

  @override
  String gitLocalBranchesCount(Object count) {
    return 'Local Branches ($count)';
  }

  @override
  String gitRemoteBranchesCount(Object count) {
    return 'Remote Tracking Branches ($count)';
  }

  @override
  String gitHistoryCount(Object count) {
    return 'Commit History ($count)';
  }

  @override
  String get gitNoCommits => 'No commits found.';

  @override
  String gitCommitCopied(Object hash) {
    return 'Commit $hash copied to clipboard.';
  }

  @override
  String dockerComposeDownConfirm(String path) {
    return 'Are you sure you want to stop and remove all containers and networks for Compose project \'$path\'?';
  }

  @override
  String servicesConfirmDisable(String unit) {
    return 'Are you sure you want to disable service \"$unit\"? It will no longer start automatically on system boot.';
  }

  @override
  String servicesConfirmDisableCritical(String unit) {
    return 'Warning: \"$unit\" is a critical system service. Disabling it may render the remote server unreachable on reboot. Continue?';
  }

  @override
  String get adminFirewallConfirmDisable =>
      'Disabling the firewall exposes all open ports on your server to the Internet. Are you sure you want to disable the firewall?';

  @override
  String get adminUserDeleteTitle => 'Delete User';

  @override
  String adminUserDeleteConfirm(String username) {
    return 'Are you sure you want to permanently delete system user \'$username\' and their home directory?';
  }

  @override
  String get adminMaintenanceUpgradeConfirmTitle => 'Upgrade System Packages';

  @override
  String adminMaintenanceUpgradeConfirm(int count) {
    return 'This will install updates for $count system package(s) via APT. Essential services may restart. Continue?';
  }

  @override
  String get adminMaintenanceRebootDesc =>
      'Send ACPI reboot signal to restart the remote VPS machine.';

  @override
  String get gitDeployKeyOverwriteTitle => 'Overwrite Deploy Key';

  @override
  String get gitDeployKeyOverwriteConfirm =>
      'An SSH deploy key already exists on this server. Generating a new one will replace the existing key and break access for repositories using the old key. Do you want to continue?';

  @override
  String get gitConfigSavedTitle => 'Configuration Saved';

  @override
  String get gitConfigSavedDesc =>
      'Git committer name and email updated successfully.';
}
