import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Othrys'**
  String get appTitle;

  /// No description provided for @navServers.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get navServers;

  /// No description provided for @navTerminal.
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get navTerminal;

  /// No description provided for @navFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get navFiles;

  /// No description provided for @navMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get navMonitoring;

  /// No description provided for @navDocker.
  ///
  /// In en, this message translates to:
  /// **'Docker'**
  String get navDocker;

  /// No description provided for @navServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navServices;

  /// No description provided for @navTunnels.
  ///
  /// In en, this message translates to:
  /// **'Tunnels'**
  String get navTunnels;

  /// No description provided for @navActivity.
  ///
  /// In en, this message translates to:
  /// **'Audit Log'**
  String get navActivity;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get commonConnect;

  /// No description provided for @commonDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get commonDisconnect;

  /// No description provided for @commonConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get commonConnected;

  /// No description provided for @commonDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get commonDisconnected;

  /// No description provided for @commonConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get commonConnecting;

  /// No description provided for @commonReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting...'**
  String get commonReconnecting;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get commonSearch;

  /// No description provided for @commonFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get commonFilter;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get commonName;

  /// No description provided for @commonStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get commonStatus;

  /// No description provided for @commonActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get commonActions;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get commonCopied;

  /// No description provided for @commonFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get commonFieldRequired;

  /// No description provided for @commonEmpty.
  ///
  /// In en, this message translates to:
  /// **'No items found.'**
  String get commonEmpty;

  /// No description provided for @windowExitConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Application Exit'**
  String get windowExitConfirmTitle;

  /// No description provided for @windowExitConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} active SSH session(s) currently open. Exiting will terminate all remote sessions. Are you sure?'**
  String windowExitConfirmMessage(int count);

  /// No description provided for @windowExitDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect & Exit'**
  String get windowExitDisconnect;

  /// No description provided for @windowSearchActions.
  ///
  /// In en, this message translates to:
  /// **'Search actions...'**
  String get windowSearchActions;

  /// No description provided for @windowActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} connected'**
  String windowActiveCount(int count);

  /// No description provided for @tabErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred in {tabName}'**
  String tabErrorTitle(String tabName);

  /// No description provided for @tabErrorReload.
  ///
  /// In en, this message translates to:
  /// **'Reload Tab'**
  String get tabErrorReload;

  /// No description provided for @serversTitle.
  ///
  /// In en, this message translates to:
  /// **'Servers & Environments'**
  String get serversTitle;

  /// No description provided for @serversFilterPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Filter servers...'**
  String get serversFilterPlaceholder;

  /// No description provided for @serversAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Server'**
  String get serversAdd;

  /// No description provided for @serversEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Server'**
  String get serversEdit;

  /// No description provided for @serversEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No servers registered'**
  String get serversEmptyTitle;

  /// No description provided for @serversEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your remote VPS or cloud instances to start managing DevOps resources.'**
  String get serversEmptySubtitle;

  /// No description provided for @serversAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Server'**
  String get serversAddFirst;

  /// No description provided for @serversNeverConnected.
  ///
  /// In en, this message translates to:
  /// **'Never connected'**
  String get serversNeverConnected;

  /// No description provided for @serversSeen.
  ///
  /// In en, this message translates to:
  /// **'Seen {time}'**
  String serversSeen(String time);

  /// No description provided for @serversDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Server Profile'**
  String get serversDeleteConfirmTitle;

  /// No description provided for @serversDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{name}\"? Credentials and connection settings will be safely wiped.'**
  String serversDeleteConfirmMessage(String name);

  /// No description provided for @serversTestConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get serversTestConnection;

  /// No description provided for @serversTesting.
  ///
  /// In en, this message translates to:
  /// **'Testing connection...'**
  String get serversTesting;

  /// No description provided for @serversTestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection successful!'**
  String get serversTestSuccess;

  /// No description provided for @serversTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed: {reason}'**
  String serversTestFailed(String reason);

  /// No description provided for @serversFieldHost.
  ///
  /// In en, this message translates to:
  /// **'Host / IP Address'**
  String get serversFieldHost;

  /// No description provided for @serversFieldPort.
  ///
  /// In en, this message translates to:
  /// **'SSH Port'**
  String get serversFieldPort;

  /// No description provided for @serversFieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get serversFieldUsername;

  /// No description provided for @serversFieldAuthType.
  ///
  /// In en, this message translates to:
  /// **'Authentication Method'**
  String get serversFieldAuthType;

  /// No description provided for @serversAuthPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get serversAuthPassword;

  /// No description provided for @serversAuthKey.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get serversAuthKey;

  /// No description provided for @serversFieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get serversFieldPassword;

  /// No description provided for @serversFieldPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'Private Key (PEM/OpenSSH)'**
  String get serversFieldPrivateKey;

  /// No description provided for @serversFieldPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Key Passphrase (optional)'**
  String get serversFieldPassphrase;

  /// No description provided for @serversSelectKeyFile.
  ///
  /// In en, this message translates to:
  /// **'Pick Key File'**
  String get serversSelectKeyFile;

  /// No description provided for @serversShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get serversShowPassword;

  /// No description provided for @terminalNewTab.
  ///
  /// In en, this message translates to:
  /// **'New Tab'**
  String get terminalNewTab;

  /// No description provided for @terminalCloseTab.
  ///
  /// In en, this message translates to:
  /// **'Close Tab'**
  String get terminalCloseTab;

  /// No description provided for @terminalActiveTabs.
  ///
  /// In en, this message translates to:
  /// **'Active Shells'**
  String get terminalActiveTabs;

  /// No description provided for @terminalClearBuffer.
  ///
  /// In en, this message translates to:
  /// **'Clear Screen'**
  String get terminalClearBuffer;

  /// No description provided for @terminalCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get terminalCopy;

  /// No description provided for @terminalPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get terminalPaste;

  /// No description provided for @terminalSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get terminalSelectAll;

  /// No description provided for @terminalOpenSession.
  ///
  /// In en, this message translates to:
  /// **'Open Terminal Session'**
  String get terminalOpenSession;

  /// No description provided for @terminalGuardMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect to a server from the Servers tab to open an interactive terminal.'**
  String get terminalGuardMessage;

  /// No description provided for @monitoringTitle.
  ///
  /// In en, this message translates to:
  /// **'{serverName} — System Metrics'**
  String monitoringTitle(String serverName);

  /// No description provided for @monitoringUptimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Uptime: {uptime}'**
  String monitoringUptimeLabel(String uptime);

  /// No description provided for @monitoringWarning.
  ///
  /// In en, this message translates to:
  /// **'Monitoring Warning'**
  String get monitoringWarning;

  /// No description provided for @monitoringCpuTitle.
  ///
  /// In en, this message translates to:
  /// **'CPU Usage'**
  String get monitoringCpuTitle;

  /// No description provided for @monitoringCpuKernel.
  ///
  /// In en, this message translates to:
  /// **'Kernel: {kernel}'**
  String monitoringCpuKernel(String kernel);

  /// No description provided for @monitoringRamTitle.
  ///
  /// In en, this message translates to:
  /// **'RAM Memory'**
  String get monitoringRamTitle;

  /// No description provided for @monitoringDiskTitle.
  ///
  /// In en, this message translates to:
  /// **'Disk Storage (Root)'**
  String get monitoringDiskTitle;

  /// No description provided for @monitoringCpuTrend.
  ///
  /// In en, this message translates to:
  /// **'CPU Load Trend (Last 60 Seconds)'**
  String get monitoringCpuTrend;

  /// No description provided for @monitoringCollecting.
  ///
  /// In en, this message translates to:
  /// **'Collecting metrics...'**
  String get monitoringCollecting;

  /// No description provided for @monitoringGuardMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect to a server from the Servers tab to inspect real-time performance telemetry.'**
  String get monitoringGuardMessage;

  /// No description provided for @dockerTitle.
  ///
  /// In en, this message translates to:
  /// **'Container Management'**
  String get dockerTitle;

  /// No description provided for @dockerContainers.
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get dockerContainers;

  /// No description provided for @dockerCompose.
  ///
  /// In en, this message translates to:
  /// **'Docker Compose'**
  String get dockerCompose;

  /// No description provided for @dockerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get dockerStart;

  /// No description provided for @dockerStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get dockerStop;

  /// No description provided for @dockerRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get dockerRestart;

  /// No description provided for @dockerRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get dockerRemove;

  /// No description provided for @dockerLogs.
  ///
  /// In en, this message translates to:
  /// **'View Logs'**
  String get dockerLogs;

  /// No description provided for @dockerNoContainers.
  ///
  /// In en, this message translates to:
  /// **'No Docker containers detected on this host.'**
  String get dockerNoContainers;

  /// No description provided for @dockerConfirmRemove.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove container \'{name}\'?'**
  String dockerConfirmRemove(String name);

  /// No description provided for @dockerConfirmStop.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop running container \'{name}\'?'**
  String dockerConfirmStop(String name);

  /// No description provided for @dockerGuardMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect to a server to discover and manage Docker containers.'**
  String get dockerGuardMessage;

  /// No description provided for @dockerNotInstalledTitle.
  ///
  /// In en, this message translates to:
  /// **'Docker is not installed'**
  String get dockerNotInstalledTitle;

  /// No description provided for @dockerNotInstalledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Docker was not found on this server. Run the official automated install script to configure the Docker runtime engine.'**
  String get dockerNotInstalledSubtitle;

  /// No description provided for @dockerInstallCommand.
  ///
  /// In en, this message translates to:
  /// **'curl -fsSL https://get.docker.com | sh'**
  String get dockerInstallCommand;

  /// No description provided for @dockerCopyCommand.
  ///
  /// In en, this message translates to:
  /// **'Copy Install Command'**
  String get dockerCopyCommand;

  /// No description provided for @dockerComposePath.
  ///
  /// In en, this message translates to:
  /// **'Compose Directory Path'**
  String get dockerComposePath;

  /// No description provided for @dockerComposeUp.
  ///
  /// In en, this message translates to:
  /// **'Compose Up'**
  String get dockerComposeUp;

  /// No description provided for @dockerComposeDown.
  ///
  /// In en, this message translates to:
  /// **'Compose Down'**
  String get dockerComposeDown;

  /// No description provided for @dockerComposeLogs.
  ///
  /// In en, this message translates to:
  /// **'Compose Logs'**
  String get dockerComposeLogs;

  /// No description provided for @dockerLogsStreaming.
  ///
  /// In en, this message translates to:
  /// **'Streaming Logs'**
  String get dockerLogsStreaming;

  /// No description provided for @dockerLogsPause.
  ///
  /// In en, this message translates to:
  /// **'Pause Stream'**
  String get dockerLogsPause;

  /// No description provided for @dockerLogsResume.
  ///
  /// In en, this message translates to:
  /// **'Resume Stream'**
  String get dockerLogsResume;

  /// No description provided for @dockerLogsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy Logs'**
  String get dockerLogsCopy;

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Systemd Services'**
  String get servicesTitle;

  /// No description provided for @servicesSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Filter services by unit name...'**
  String get servicesSearchPlaceholder;

  /// No description provided for @servicesStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get servicesStart;

  /// No description provided for @servicesStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get servicesStop;

  /// No description provided for @servicesRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get servicesRestart;

  /// No description provided for @servicesReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get servicesReload;

  /// No description provided for @servicesLogs.
  ///
  /// In en, this message translates to:
  /// **'View Journals'**
  String get servicesLogs;

  /// No description provided for @servicesNoServices.
  ///
  /// In en, this message translates to:
  /// **'No services found matching current criteria.'**
  String get servicesNoServices;

  /// No description provided for @servicesConfirmStopCritical.
  ///
  /// In en, this message translates to:
  /// **'Warning: \'{unit}\' is a critical system service. Stopping it may disconnect your SSH session or degrade server operation. Are you sure you want to proceed?'**
  String servicesConfirmStopCritical(String unit);

  /// No description provided for @servicesConfirmStop.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop service \"{unit}\"?'**
  String servicesConfirmStop(String unit);

  /// No description provided for @servicesEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get servicesEnable;

  /// No description provided for @servicesDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get servicesDisable;

  /// No description provided for @servicesEnabledBadge.
  ///
  /// In en, this message translates to:
  /// **'Enabled on boot'**
  String get servicesEnabledBadge;

  /// No description provided for @servicesDisabledBadge.
  ///
  /// In en, this message translates to:
  /// **'Disabled on boot'**
  String get servicesDisabledBadge;

  /// No description provided for @servicesGuardMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect to a server to inspect systemd services and units.'**
  String get servicesGuardMessage;

  /// No description provided for @filesTitle.
  ///
  /// In en, this message translates to:
  /// **'SFTP File Explorer'**
  String get filesTitle;

  /// No description provided for @filesNewFolder.
  ///
  /// In en, this message translates to:
  /// **'New Folder'**
  String get filesNewFolder;

  /// No description provided for @filesNewFile.
  ///
  /// In en, this message translates to:
  /// **'New File'**
  String get filesNewFile;

  /// No description provided for @filesUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get filesUpload;

  /// No description provided for @filesDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get filesDownload;

  /// No description provided for @filesRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get filesRename;

  /// No description provided for @filesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get filesDelete;

  /// No description provided for @filesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit File'**
  String get filesEdit;

  /// No description provided for @filesSaveContent.
  ///
  /// In en, this message translates to:
  /// **'Save Content'**
  String get filesSaveContent;

  /// No description provided for @filesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{name}\'?'**
  String filesDeleteConfirm(String name);

  /// No description provided for @filesTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File size exceeds 1 MB limit for inline editor.'**
  String get filesTooLarge;

  /// No description provided for @filesBinaryWarning.
  ///
  /// In en, this message translates to:
  /// **'Binary files cannot be opened in text editor.'**
  String get filesBinaryWarning;

  /// No description provided for @filesGuardMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect to a server to browse and manage remote files via SFTP.'**
  String get filesGuardMessage;

  /// No description provided for @filesUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'File uploaded successfully: {name}'**
  String filesUploadSuccess(String name);

  /// No description provided for @filesDownloadSuccess.
  ///
  /// In en, this message translates to:
  /// **'File downloaded successfully: {name}'**
  String filesDownloadSuccess(String name);

  /// No description provided for @filesRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename: {name}'**
  String filesRenameTitle(String name);

  /// No description provided for @filesRenamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter new file or folder name...'**
  String get filesRenamePlaceholder;

  /// No description provided for @filesUploadLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'File size exceeds 100 MB upload limit.'**
  String get filesUploadLimitExceeded;

  /// No description provided for @filesDownloadLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'File size exceeds 100 MB download limit.'**
  String get filesDownloadLimitExceeded;

  /// No description provided for @filesRootDirectory.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get filesRootDirectory;

  /// No description provided for @tunnelsTitle.
  ///
  /// In en, this message translates to:
  /// **'SSH Tunnels'**
  String get tunnelsTitle;

  /// No description provided for @tunnelsNew.
  ///
  /// In en, this message translates to:
  /// **'New Tunnel'**
  String get tunnelsNew;

  /// No description provided for @tunnelsActive.
  ///
  /// In en, this message translates to:
  /// **'Active Tunnels'**
  String get tunnelsActive;

  /// No description provided for @tunnelsNoTunnels.
  ///
  /// In en, this message translates to:
  /// **'No port forwarding tunnels configured.'**
  String get tunnelsNoTunnels;

  /// No description provided for @tunnelsTypeLocal.
  ///
  /// In en, this message translates to:
  /// **'Local Forwarding'**
  String get tunnelsTypeLocal;

  /// No description provided for @tunnelsTypeRemote.
  ///
  /// In en, this message translates to:
  /// **'Remote Forwarding'**
  String get tunnelsTypeRemote;

  /// No description provided for @tunnelsTypeDynamic.
  ///
  /// In en, this message translates to:
  /// **'Dynamic SOCKS5'**
  String get tunnelsTypeDynamic;

  /// No description provided for @tunnelsLocalPort.
  ///
  /// In en, this message translates to:
  /// **'Local Port'**
  String get tunnelsLocalPort;

  /// No description provided for @tunnelsRemoteHost.
  ///
  /// In en, this message translates to:
  /// **'Remote Target Host'**
  String get tunnelsRemoteHost;

  /// No description provided for @tunnelsRemotePort.
  ///
  /// In en, this message translates to:
  /// **'Remote Port'**
  String get tunnelsRemotePort;

  /// No description provided for @tunnelsGuardMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect to a server to manage port forwarding tunnels.'**
  String get tunnelsGuardMessage;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security & Action Audit Log'**
  String get activityTitle;

  /// No description provided for @activityClear.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get activityClear;

  /// No description provided for @activityFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get activityFilterAll;

  /// No description provided for @activityFilterSsh.
  ///
  /// In en, this message translates to:
  /// **'SSH Connections'**
  String get activityFilterSsh;

  /// No description provided for @activityFilterDocker.
  ///
  /// In en, this message translates to:
  /// **'Docker Commands'**
  String get activityFilterDocker;

  /// No description provided for @activityFilterServices.
  ///
  /// In en, this message translates to:
  /// **'System Services'**
  String get activityFilterServices;

  /// No description provided for @activityFilterFiles.
  ///
  /// In en, this message translates to:
  /// **'File Changes'**
  String get activityFilterFiles;

  /// No description provided for @activityFilterSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security Warnings'**
  String get activityFilterSecurity;

  /// No description provided for @activityNoLogs.
  ///
  /// In en, this message translates to:
  /// **'No activity logs recorded yet.'**
  String get activityNoLogs;

  /// No description provided for @filesHeader.
  ///
  /// In en, this message translates to:
  /// **'{serverName} — SFTP Files'**
  String filesHeader(String serverName);

  /// No description provided for @filesEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Editing: {name}'**
  String filesEditorTitle(String name);

  /// No description provided for @filesSaveFile.
  ///
  /// In en, this message translates to:
  /// **'Save File'**
  String get filesSaveFile;

  /// No description provided for @filesCreateFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Folder'**
  String get filesCreateFolderTitle;

  /// No description provided for @filesCreateFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New File'**
  String get filesCreateFileTitle;

  /// No description provided for @filesCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get filesCreate;

  /// No description provided for @filesFolderPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'folder_name'**
  String get filesFolderPlaceholder;

  /// No description provided for @filesFilePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'filename.txt'**
  String get filesFilePlaceholder;

  /// No description provided for @filesDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get filesDeleteConfirmTitle;

  /// No description provided for @filesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Directory is empty'**
  String get filesEmpty;

  /// No description provided for @filesFolderType.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get filesFolderType;

  /// No description provided for @filesErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'SFTP Error'**
  String get filesErrorTitle;

  /// No description provided for @filesCannotOpen.
  ///
  /// In en, this message translates to:
  /// **'Cannot Open File'**
  String get filesCannotOpen;

  /// No description provided for @filesSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save Failed'**
  String get filesSaveFailed;

  /// No description provided for @filesCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Creation Failed'**
  String get filesCreationFailed;

  /// No description provided for @filesDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Deletion Failed'**
  String get filesDeletionFailed;

  /// No description provided for @filesLocation.
  ///
  /// In en, this message translates to:
  /// **'Location:'**
  String get filesLocation;

  /// No description provided for @filesNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get filesNameLabel;

  /// No description provided for @filesInvalidName.
  ///
  /// In en, this message translates to:
  /// **'Name contains invalid characters (/ \\  )'**
  String get filesInvalidName;

  /// No description provided for @filesNameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An item with this name already exists'**
  String get filesNameAlreadyExists;

  /// No description provided for @tunnelsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New SSH Port Forwarding Tunnel'**
  String get tunnelsDialogTitle;

  /// No description provided for @tunnelsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Tunnel Name'**
  String get tunnelsNameLabel;

  /// No description provided for @tunnelsLocalPortLabel.
  ///
  /// In en, this message translates to:
  /// **'Local Port on Windows PC'**
  String get tunnelsLocalPortLabel;

  /// No description provided for @tunnelsRemotePortLabel.
  ///
  /// In en, this message translates to:
  /// **'Remote Destination Port'**
  String get tunnelsRemotePortLabel;

  /// No description provided for @tunnelsRemoteHostLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination Host (relative to VPS)'**
  String get tunnelsRemoteHostLabel;

  /// No description provided for @tunnelsStart.
  ///
  /// In en, this message translates to:
  /// **'Start Tunnel'**
  String get tunnelsStart;

  /// No description provided for @tunnelsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get tunnelsClose;

  /// No description provided for @tunnelsErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to establish tunnel'**
  String get tunnelsErrorFailed;

  /// No description provided for @tunnelsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Forward local ports securely through your active SSH connection.'**
  String get tunnelsEmptySubtitle;

  /// No description provided for @activityFilterTunnels.
  ///
  /// In en, this message translates to:
  /// **'SSH Tunnels'**
  String get activityFilterTunnels;

  /// No description provided for @activityFilterSystem.
  ///
  /// In en, this message translates to:
  /// **'System Events'**
  String get activityFilterSystem;

  /// No description provided for @cmdPalettePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type a command, server, or action...'**
  String get cmdPalettePlaceholder;

  /// No description provided for @cmdPaletteEscToClose.
  ///
  /// In en, this message translates to:
  /// **'ESC to close'**
  String get cmdPaletteEscToClose;

  /// No description provided for @cmdPaletteSectionServers.
  ///
  /// In en, this message translates to:
  /// **'SERVERS'**
  String get cmdPaletteSectionServers;

  /// No description provided for @cmdPaletteSectionNavigation.
  ///
  /// In en, this message translates to:
  /// **'NAVIGATION'**
  String get cmdPaletteSectionNavigation;

  /// No description provided for @cmdPaletteSectionActions.
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get cmdPaletteSectionActions;

  /// No description provided for @cmdPaletteNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching commands or servers found.'**
  String get cmdPaletteNoResults;

  /// No description provided for @cmdPaletteDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Active Session'**
  String get cmdPaletteDisconnect;

  /// No description provided for @serversAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Server Profile'**
  String get serversAddTitle;

  /// No description provided for @serversEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Server Profile'**
  String get serversEditTitle;

  /// No description provided for @serversFieldName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get serversFieldName;

  /// No description provided for @serversFieldNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Production Web Server'**
  String get serversFieldNamePlaceholder;

  /// No description provided for @serversFieldHostPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'192.168.1.10 or server.com'**
  String get serversFieldHostPlaceholder;

  /// No description provided for @serversFieldGroup.
  ///
  /// In en, this message translates to:
  /// **'Group / Category'**
  String get serversFieldGroup;

  /// No description provided for @serversFieldGroupPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Production, Clients'**
  String get serversFieldGroupPlaceholder;

  /// No description provided for @serversFieldPasswordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter remote user password'**
  String get serversFieldPasswordPlaceholder;

  /// No description provided for @serversFieldPassphrasePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Key decryption passphrase if encrypted'**
  String get serversFieldPassphrasePlaceholder;

  /// No description provided for @serversFieldBastion.
  ///
  /// In en, this message translates to:
  /// **'Jump Host / Bastion (Optional)'**
  String get serversFieldBastion;

  /// No description provided for @serversBastionDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct Connection (No Bastion)'**
  String get serversBastionDirect;

  /// No description provided for @serversAddSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add Server'**
  String get serversAddSubmit;

  /// No description provided for @serversEditSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get serversEditSubmit;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Interface Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLangFr.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get settingsLangFr;

  /// No description provided for @settingsLangEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLangEn;

  /// No description provided for @settingsTerminalFontSize.
  ///
  /// In en, this message translates to:
  /// **'Terminal Font Size ({size}px)'**
  String settingsTerminalFontSize(int size);

  /// No description provided for @settingsMonitoringInterval.
  ///
  /// In en, this message translates to:
  /// **'Monitoring Polling Interval ({seconds}s)'**
  String settingsMonitoringInterval(int seconds);

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Configuration Backup & Restore'**
  String get settingsBackup;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export Configuration'**
  String get settingsExport;

  /// No description provided for @settingsExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Export encrypted server and tunnel configurations as backup.'**
  String get settingsExportDesc;

  /// No description provided for @settingsExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Configurations successfully exported.'**
  String get settingsExportSuccess;

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Import Configuration'**
  String get settingsImport;

  /// No description provided for @settingsImportDesc.
  ///
  /// In en, this message translates to:
  /// **'Restore server profiles and tunnels from an exported backup file.'**
  String get settingsImportDesc;

  /// No description provided for @settingsImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Configurations successfully imported.'**
  String get settingsImportSuccess;

  /// No description provided for @settingsLicense.
  ///
  /// In en, this message translates to:
  /// **'License: MIT Open Source'**
  String get settingsLicense;

  /// No description provided for @settingsGitHub.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository'**
  String get settingsGitHub;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Othrys'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Othrys'**
  String get onboardingWelcome;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Linux server administration.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingAddServer.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Server'**
  String get onboardingAddServer;

  /// No description provided for @onboardingExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore Dashboard'**
  String get onboardingExplore;

  /// No description provided for @guardNoConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'No Active SSH Connection'**
  String get guardNoConnectionTitle;

  /// No description provided for @guardNoConnectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a server and click \'Connect\' to enable this feature.'**
  String get guardNoConnectionSubtitle;

  /// No description provided for @guardSelectServer.
  ///
  /// In en, this message translates to:
  /// **'Go to Servers'**
  String get guardSelectServer;

  /// No description provided for @tunnelsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Active Tunnels'**
  String get tunnelsEmptyTitle;

  /// No description provided for @tunnelsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Tunnel'**
  String get tunnelsDeleteConfirmTitle;

  /// No description provided for @tunnelsDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the tunnel \'{name}\'?'**
  String tunnelsDeleteConfirmMessage(String name);

  /// No description provided for @roleRoot.
  ///
  /// In en, this message translates to:
  /// **'Root (Superuser)'**
  String get roleRoot;

  /// No description provided for @roleSudoer.
  ///
  /// In en, this message translates to:
  /// **'Admin (sudo)'**
  String get roleSudoer;

  /// No description provided for @roleStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard (Restricted)'**
  String get roleStandard;

  /// No description provided for @servicesPermissionRestricted.
  ///
  /// In en, this message translates to:
  /// **'Read-only mode: connected account ({username}) does not have root or sudo privileges to modify services.'**
  String servicesPermissionRestricted(String username);

  /// No description provided for @dockerPermissionRestricted.
  ///
  /// In en, this message translates to:
  /// **'Restricted access: connected account ({username}) does not have access to the Docker daemon (not in docker group and no sudo).'**
  String dockerPermissionRestricted(String username);

  /// No description provided for @filesPermissionNotice.
  ///
  /// In en, this message translates to:
  /// **'System directory: account ({username}) has restricted privileges outside home directory.'**
  String filesPermissionNotice(String username);

  /// No description provided for @filesOpenTerminal.
  ///
  /// In en, this message translates to:
  /// **'Open Terminal Here'**
  String get filesOpenTerminal;

  /// No description provided for @filesCloseTerminal.
  ///
  /// In en, this message translates to:
  /// **'Close Terminal'**
  String get filesCloseTerminal;

  /// No description provided for @filesTerminalTitle.
  ///
  /// In en, this message translates to:
  /// **'Terminal — {path}'**
  String filesTerminalTitle(String path);

  /// No description provided for @filesCopyPath.
  ///
  /// In en, this message translates to:
  /// **'Copy Path'**
  String get filesCopyPath;

  /// No description provided for @filesPathCopied.
  ///
  /// In en, this message translates to:
  /// **'Path copied to clipboard'**
  String get filesPathCopied;

  /// No description provided for @filesCdHere.
  ///
  /// In en, this message translates to:
  /// **'Sync Terminal (cd)'**
  String get filesCdHere;

  /// No description provided for @filesNavigateBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get filesNavigateBack;

  /// No description provided for @filesNavigateForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get filesNavigateForward;

  /// No description provided for @filesNavigateUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get filesNavigateUp;

  /// No description provided for @filesEditPath.
  ///
  /// In en, this message translates to:
  /// **'Edit Path'**
  String get filesEditPath;

  /// No description provided for @commonExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get commonExpand;

  /// No description provided for @commonCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get commonCollapse;

  /// No description provided for @terminalNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No active SSH connection'**
  String get terminalNoConnection;

  /// No description provided for @navDatabases.
  ///
  /// In en, this message translates to:
  /// **'Databases'**
  String get navDatabases;

  /// No description provided for @navWebSites.
  ///
  /// In en, this message translates to:
  /// **'Web Sites & SSL'**
  String get navWebSites;

  /// No description provided for @servicesCreate.
  ///
  /// In en, this message translates to:
  /// **'New Service'**
  String get servicesCreate;

  /// No description provided for @servicesCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Systemd Service'**
  String get servicesCreateTitle;

  /// No description provided for @servicesNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get servicesNameLabel;

  /// No description provided for @servicesNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. my-api'**
  String get servicesNamePlaceholder;

  /// No description provided for @servicesDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get servicesDescLabel;

  /// No description provided for @servicesDescPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. My Backend API Service'**
  String get servicesDescPlaceholder;

  /// No description provided for @servicesExecStartLabel.
  ///
  /// In en, this message translates to:
  /// **'ExecStart Command'**
  String get servicesExecStartLabel;

  /// No description provided for @servicesExecStartPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'/usr/bin/node /var/www/my-api/index.js'**
  String get servicesExecStartPlaceholder;

  /// No description provided for @servicesWorkDirLabel.
  ///
  /// In en, this message translates to:
  /// **'Working Directory'**
  String get servicesWorkDirLabel;

  /// No description provided for @servicesWorkDirPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'/var/www/my-api'**
  String get servicesWorkDirPlaceholder;

  /// No description provided for @servicesUserLabel.
  ///
  /// In en, this message translates to:
  /// **'Run as User'**
  String get servicesUserLabel;

  /// No description provided for @servicesRestartPolicy.
  ///
  /// In en, this message translates to:
  /// **'Restart Policy'**
  String get servicesRestartPolicy;

  /// No description provided for @servicesEnvLabel.
  ///
  /// In en, this message translates to:
  /// **'Environment Variables (KEY=VALUE)'**
  String get servicesEnvLabel;

  /// No description provided for @servicesEnableBoot.
  ///
  /// In en, this message translates to:
  /// **'Enable at boot'**
  String get servicesEnableBoot;

  /// No description provided for @servicesStartNow.
  ///
  /// In en, this message translates to:
  /// **'Start immediately'**
  String get servicesStartNow;

  /// No description provided for @servicesPreview.
  ///
  /// In en, this message translates to:
  /// **'Unit File Preview'**
  String get servicesPreview;

  /// No description provided for @servicesCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Service \'{name}\' created and deployed successfully'**
  String servicesCreateSuccess(String name);

  /// No description provided for @servicesCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create service: {error}'**
  String servicesCreateError(String error);

  /// No description provided for @dbTitle.
  ///
  /// In en, this message translates to:
  /// **'Databases'**
  String get dbTitle;

  /// No description provided for @dbEngineSelect.
  ///
  /// In en, this message translates to:
  /// **'Database Engine'**
  String get dbEngineSelect;

  /// No description provided for @dbMysql.
  ///
  /// In en, this message translates to:
  /// **'MySQL / MariaDB'**
  String get dbMysql;

  /// No description provided for @dbPostgres.
  ///
  /// In en, this message translates to:
  /// **'PostgreSQL'**
  String get dbPostgres;

  /// No description provided for @dbNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'{engine} is not installed or running on this server'**
  String dbNotInstalled(String engine);

  /// No description provided for @dbTabDatabases.
  ///
  /// In en, this message translates to:
  /// **'Databases'**
  String get dbTabDatabases;

  /// No description provided for @dbTabUsers.
  ///
  /// In en, this message translates to:
  /// **'Users & Privileges'**
  String get dbTabUsers;

  /// No description provided for @dbTabQuery.
  ///
  /// In en, this message translates to:
  /// **'SQL Console'**
  String get dbTabQuery;

  /// No description provided for @dbCreate.
  ///
  /// In en, this message translates to:
  /// **'New Database'**
  String get dbCreate;

  /// No description provided for @dbCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Database'**
  String get dbCreateTitle;

  /// No description provided for @dbName.
  ///
  /// In en, this message translates to:
  /// **'Database Name'**
  String get dbName;

  /// No description provided for @dbCollation.
  ///
  /// In en, this message translates to:
  /// **'Charset / Collation'**
  String get dbCollation;

  /// No description provided for @dbDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to drop database \'{name}\'? This action cannot be undone.'**
  String dbDeleteConfirm(String name);

  /// No description provided for @dbUserCreate.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get dbUserCreate;

  /// No description provided for @dbUserCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Database User'**
  String get dbUserCreateTitle;

  /// No description provided for @dbUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get dbUsername;

  /// No description provided for @dbPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get dbPassword;

  /// No description provided for @dbHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get dbHost;

  /// No description provided for @dbPrivileges.
  ///
  /// In en, this message translates to:
  /// **'Privileges'**
  String get dbPrivileges;

  /// No description provided for @dbUserDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete user \'{name}\'?'**
  String dbUserDeleteConfirm(String name);

  /// No description provided for @dbQueryRun.
  ///
  /// In en, this message translates to:
  /// **'Execute Query'**
  String get dbQueryRun;

  /// No description provided for @dbQueryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write SQL query (e.g. SELECT * FROM table LIMIT 50;)...'**
  String get dbQueryPlaceholder;

  /// No description provided for @dbQueryResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get dbQueryResults;

  /// No description provided for @dbQueryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Query executed successfully, no rows returned.'**
  String get dbQueryEmpty;

  /// No description provided for @dbExport.
  ///
  /// In en, this message translates to:
  /// **'Export SQL Dump'**
  String get dbExport;

  /// No description provided for @dbImport.
  ///
  /// In en, this message translates to:
  /// **'Import SQL File'**
  String get dbImport;

  /// No description provided for @webSitesTitle.
  ///
  /// In en, this message translates to:
  /// **'Web Sites & SSL'**
  String get webSitesTitle;

  /// No description provided for @webSitesNginxNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Nginx is not installed on this server. Install it to manage web sites and reverse proxies.'**
  String get webSitesNginxNotInstalled;

  /// No description provided for @webSitesInstallNginx.
  ///
  /// In en, this message translates to:
  /// **'Install Nginx'**
  String get webSitesInstallNginx;

  /// No description provided for @webSitesCreate.
  ///
  /// In en, this message translates to:
  /// **'New Site'**
  String get webSitesCreate;

  /// No description provided for @webSitesCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure New Web Site'**
  String get webSitesCreateTitle;

  /// No description provided for @webSitesDomain.
  ///
  /// In en, this message translates to:
  /// **'Domain / Subdomain Name'**
  String get webSitesDomain;

  /// No description provided for @webSitesDomainPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. api.example.com or app.example.com'**
  String get webSitesDomainPlaceholder;

  /// No description provided for @webSitesType.
  ///
  /// In en, this message translates to:
  /// **'Site Type'**
  String get webSitesType;

  /// No description provided for @webSitesTypeProxy.
  ///
  /// In en, this message translates to:
  /// **'Reverse Proxy (API / Backend / Docker)'**
  String get webSitesTypeProxy;

  /// No description provided for @webSitesTypeStatic.
  ///
  /// In en, this message translates to:
  /// **'Static Website (HTML / SPA / Frontend)'**
  String get webSitesTypeStatic;

  /// No description provided for @webSitesTargetPort.
  ///
  /// In en, this message translates to:
  /// **'Local Port / Target URL'**
  String get webSitesTargetPort;

  /// No description provided for @webSitesTargetPortPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3000 or http://127.0.0.1:8080'**
  String get webSitesTargetPortPlaceholder;

  /// No description provided for @webSitesStaticRoot.
  ///
  /// In en, this message translates to:
  /// **'Document Root Path'**
  String get webSitesStaticRoot;

  /// No description provided for @webSitesStaticRootPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'/var/www/my-site/dist'**
  String get webSitesStaticRootPlaceholder;

  /// No description provided for @webSitesEnableSsl.
  ///
  /// In en, this message translates to:
  /// **'Enable HTTPS with Let\'s Encrypt (Certbot)'**
  String get webSitesEnableSsl;

  /// No description provided for @webSitesEmail.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Encrypt Email (for renewal notices)'**
  String get webSitesEmail;

  /// No description provided for @webSitesStatusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get webSitesStatusEnabled;

  /// No description provided for @webSitesStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get webSitesStatusDisabled;

  /// No description provided for @webSitesEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Site'**
  String get webSitesEnable;

  /// No description provided for @webSitesDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable Site'**
  String get webSitesDisable;

  /// No description provided for @webSitesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete site \'{domain}\'?'**
  String webSitesDeleteConfirm(String domain);

  /// No description provided for @webSitesProvisionSsl.
  ///
  /// In en, this message translates to:
  /// **'Provision SSL (HTTPS)'**
  String get webSitesProvisionSsl;

  /// No description provided for @webSitesRenewSsl.
  ///
  /// In en, this message translates to:
  /// **'Test SSL Renewal'**
  String get webSitesRenewSsl;

  /// No description provided for @webSitesSslActive.
  ///
  /// In en, this message translates to:
  /// **'HTTPS Secured'**
  String get webSitesSslActive;

  /// No description provided for @webSitesSslInactive.
  ///
  /// In en, this message translates to:
  /// **'HTTP Only'**
  String get webSitesSslInactive;

  /// No description provided for @navSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security & Admin'**
  String get navSecurity;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Administration & Security'**
  String get adminTitle;

  /// No description provided for @adminTabFirewall.
  ///
  /// In en, this message translates to:
  /// **'Firewall (UFW)'**
  String get adminTabFirewall;

  /// No description provided for @adminTabPorts.
  ///
  /// In en, this message translates to:
  /// **'Listening Ports'**
  String get adminTabPorts;

  /// No description provided for @adminTabUsers.
  ///
  /// In en, this message translates to:
  /// **'System Users'**
  String get adminTabUsers;

  /// No description provided for @adminTabMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance & Settings'**
  String get adminTabMaintenance;

  /// No description provided for @adminFirewallStatus.
  ///
  /// In en, this message translates to:
  /// **'Firewall Status'**
  String get adminFirewallStatus;

  /// No description provided for @adminFirewallActive.
  ///
  /// In en, this message translates to:
  /// **'Firewall is ACTIVE'**
  String get adminFirewallActive;

  /// No description provided for @adminFirewallInactive.
  ///
  /// In en, this message translates to:
  /// **'Firewall is INACTIVE'**
  String get adminFirewallInactive;

  /// No description provided for @adminFirewallEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Firewall'**
  String get adminFirewallEnable;

  /// No description provided for @adminFirewallDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable Firewall'**
  String get adminFirewallDisable;

  /// No description provided for @adminFirewallConfirmEnable.
  ///
  /// In en, this message translates to:
  /// **'Enabling the firewall without an active SSH rule may disconnect you. Ensure port 22 or your custom SSH port is allowed. Continue?'**
  String get adminFirewallConfirmEnable;

  /// No description provided for @adminFirewallAddRule.
  ///
  /// In en, this message translates to:
  /// **'Add Rule'**
  String get adminFirewallAddRule;

  /// No description provided for @adminFirewallAddRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Firewall Rule'**
  String get adminFirewallAddRuleTitle;

  /// No description provided for @adminFirewallRulePort.
  ///
  /// In en, this message translates to:
  /// **'Port / Range / Service'**
  String get adminFirewallRulePort;

  /// No description provided for @adminFirewallRulePortPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. 22 or 8080 or 8000:8010'**
  String get adminFirewallRulePortPlaceholder;

  /// No description provided for @adminFirewallRuleProto.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get adminFirewallRuleProto;

  /// No description provided for @adminFirewallRuleAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get adminFirewallRuleAction;

  /// No description provided for @adminFirewallRuleSource.
  ///
  /// In en, this message translates to:
  /// **'Source IP / Subnet (Optional)'**
  String get adminFirewallRuleSource;

  /// No description provided for @adminFirewallRuleSourcePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Anywhere or 192.168.1.0/24'**
  String get adminFirewallRuleSourcePlaceholder;

  /// No description provided for @adminFirewallPreset.
  ///
  /// In en, this message translates to:
  /// **'Preset Service'**
  String get adminFirewallPreset;

  /// No description provided for @adminFirewallDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete firewall rule #{ruleNumber} ({target})?'**
  String adminFirewallDeleteConfirm(int ruleNumber, String target);

  /// No description provided for @adminPortsTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Ports & Sockets'**
  String get adminPortsTitle;

  /// No description provided for @adminPortsProcess.
  ///
  /// In en, this message translates to:
  /// **'Process / Service'**
  String get adminPortsProcess;

  /// No description provided for @adminPortsAddress.
  ///
  /// In en, this message translates to:
  /// **'Local Address'**
  String get adminPortsAddress;

  /// No description provided for @adminPortsPublic.
  ///
  /// In en, this message translates to:
  /// **'Publicly Exposed'**
  String get adminPortsPublic;

  /// No description provided for @adminPortsLocal.
  ///
  /// In en, this message translates to:
  /// **'Localhost Only'**
  String get adminPortsLocal;

  /// No description provided for @adminPortsAllowInFirewall.
  ///
  /// In en, this message translates to:
  /// **'Allow in Firewall'**
  String get adminPortsAllowInFirewall;

  /// No description provided for @adminUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Linux System Accounts'**
  String get adminUsersTitle;

  /// No description provided for @adminUsersAdd.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get adminUsersAdd;

  /// No description provided for @adminUsersAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Create System User'**
  String get adminUsersAddTitle;

  /// No description provided for @adminUsersUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get adminUsersUsername;

  /// No description provided for @adminUsersUsernamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. deployer'**
  String get adminUsersUsernamePlaceholder;

  /// No description provided for @adminUsersPassword.
  ///
  /// In en, this message translates to:
  /// **'Initial Password'**
  String get adminUsersPassword;

  /// No description provided for @adminUsersPasswordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Strong password'**
  String get adminUsersPasswordPlaceholder;

  /// No description provided for @adminUsersShell.
  ///
  /// In en, this message translates to:
  /// **'Login Shell'**
  String get adminUsersShell;

  /// No description provided for @adminUsersGrantSudo.
  ///
  /// In en, this message translates to:
  /// **'Grant Administrator Privileges (sudo)'**
  String get adminUsersGrantSudo;

  /// No description provided for @adminUsersSshKeys.
  ///
  /// In en, this message translates to:
  /// **'Authorized SSH Keys'**
  String get adminUsersSshKeys;

  /// No description provided for @adminUsersAddKey.
  ///
  /// In en, this message translates to:
  /// **'Add SSH Key'**
  String get adminUsersAddKey;

  /// No description provided for @adminUsersAddKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Authorized Public Key'**
  String get adminUsersAddKeyTitle;

  /// No description provided for @adminUsersKeyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Paste public key (ssh-ed25519 or ssh-rsa)...'**
  String get adminUsersKeyPlaceholder;

  /// No description provided for @adminMaintenanceUpdates.
  ///
  /// In en, this message translates to:
  /// **'Operating System Updates'**
  String get adminMaintenanceUpdates;

  /// No description provided for @adminMaintenanceUpdatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} package(s) can be upgraded.'**
  String adminMaintenanceUpdatesAvailable(int count);

  /// No description provided for @adminMaintenanceUpdatesNone.
  ///
  /// In en, this message translates to:
  /// **'Your operating system is up to date.'**
  String get adminMaintenanceUpdatesNone;

  /// No description provided for @adminMaintenanceApplyUpdates.
  ///
  /// In en, this message translates to:
  /// **'Upgrade System Packages'**
  String get adminMaintenanceApplyUpdates;

  /// No description provided for @adminMaintenanceHostname.
  ///
  /// In en, this message translates to:
  /// **'Server Hostname'**
  String get adminMaintenanceHostname;

  /// No description provided for @adminMaintenanceChangeHostname.
  ///
  /// In en, this message translates to:
  /// **'Update Hostname'**
  String get adminMaintenanceChangeHostname;

  /// No description provided for @adminMaintenanceReboot.
  ///
  /// In en, this message translates to:
  /// **'Reboot Server'**
  String get adminMaintenanceReboot;

  /// No description provided for @adminMaintenanceRebootConfirm.
  ///
  /// In en, this message translates to:
  /// **'Rebooting will terminate all active connections and services. Are you sure you want to reboot the remote server?'**
  String get adminMaintenanceRebootConfirm;

  /// No description provided for @navGit.
  ///
  /// In en, this message translates to:
  /// **'Git Repositories'**
  String get navGit;

  /// No description provided for @gitTitle.
  ///
  /// In en, this message translates to:
  /// **'Git Repositories'**
  String get gitTitle;

  /// No description provided for @gitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage, clone, pull, and monitor Git projects on your server.'**
  String get gitSubtitle;

  /// No description provided for @gitNotInstalledTitle.
  ///
  /// In en, this message translates to:
  /// **'Git is Not Installed'**
  String get gitNotInstalledTitle;

  /// No description provided for @gitNotInstalledDesc.
  ///
  /// In en, this message translates to:
  /// **'The Git version control binary was not found on this server. Install it to manage your repositories.'**
  String get gitNotInstalledDesc;

  /// No description provided for @gitInstallBtn.
  ///
  /// In en, this message translates to:
  /// **'Install Git'**
  String get gitInstallBtn;

  /// No description provided for @gitInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing Git...'**
  String get gitInstalling;

  /// No description provided for @gitInstalledSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Git Installed'**
  String get gitInstalledSuccessTitle;

  /// No description provided for @gitInstalledSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Git was successfully installed on the remote server.'**
  String get gitInstalledSuccessDesc;

  /// No description provided for @gitNoReposTitle.
  ///
  /// In en, this message translates to:
  /// **'No Repositories Tracked'**
  String get gitNoReposTitle;

  /// No description provided for @gitNoReposDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan your server for existing Git projects or clone a new repository.'**
  String get gitNoReposDesc;

  /// No description provided for @gitScanServer.
  ///
  /// In en, this message translates to:
  /// **'Scan Server'**
  String get gitScanServer;

  /// No description provided for @gitScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning for repositories...'**
  String get gitScanning;

  /// No description provided for @gitScanFound.
  ///
  /// In en, this message translates to:
  /// **'{count} repository(ies) discovered!'**
  String gitScanFound(int count);

  /// No description provided for @gitAddRepoPath.
  ///
  /// In en, this message translates to:
  /// **'Add Existing Path'**
  String get gitAddRepoPath;

  /// No description provided for @gitAddRepoPathTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Existing Repository'**
  String get gitAddRepoPathTitle;

  /// No description provided for @gitAddRepoPathPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. /var/www/my-app'**
  String get gitAddRepoPathPlaceholder;

  /// No description provided for @gitClone.
  ///
  /// In en, this message translates to:
  /// **'Clone Repository'**
  String get gitClone;

  /// No description provided for @gitCloneTitle.
  ///
  /// In en, this message translates to:
  /// **'Clone Git Repository'**
  String get gitCloneTitle;

  /// No description provided for @gitCloneUrl.
  ///
  /// In en, this message translates to:
  /// **'Repository URL (HTTPS or SSH)'**
  String get gitCloneUrl;

  /// No description provided for @gitCloneUrlPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. https://github.com/org/repo.git or git@github.com:org/repo.git'**
  String get gitCloneUrlPlaceholder;

  /// No description provided for @gitCloneDest.
  ///
  /// In en, this message translates to:
  /// **'Destination Directory'**
  String get gitCloneDest;

  /// No description provided for @gitCloneDestPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. /var/www/my-app'**
  String get gitCloneDestPlaceholder;

  /// No description provided for @gitCloneBranch.
  ///
  /// In en, this message translates to:
  /// **'Initial Branch (Optional)'**
  String get gitCloneBranch;

  /// No description provided for @gitCloneBranchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. main or production'**
  String get gitCloneBranchPlaceholder;

  /// No description provided for @gitCloneShallow.
  ///
  /// In en, this message translates to:
  /// **'Shallow clone (--depth 1, faster for deployments)'**
  String get gitCloneShallow;

  /// No description provided for @gitCloneSubmodules.
  ///
  /// In en, this message translates to:
  /// **'Recurse submodules'**
  String get gitCloneSubmodules;

  /// No description provided for @gitCloneSshNotice.
  ///
  /// In en, this message translates to:
  /// **'If cloning a private SSH repository, ensure this server\'s public Deploy Key is added to GitHub / GitLab.'**
  String get gitCloneSshNotice;

  /// No description provided for @gitSelectRepo.
  ///
  /// In en, this message translates to:
  /// **'Select Repository'**
  String get gitSelectRepo;

  /// No description provided for @gitRemoveTracked.
  ///
  /// In en, this message translates to:
  /// **'Untrack Repository'**
  String get gitRemoveTracked;

  /// No description provided for @gitRemoveTrackedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \'{name}\' from tracked repositories? (Remote files will not be deleted)'**
  String gitRemoveTrackedConfirm(String name);

  /// No description provided for @gitPull.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get gitPull;

  /// No description provided for @gitPulling.
  ///
  /// In en, this message translates to:
  /// **'Pulling changes...'**
  String get gitPulling;

  /// No description provided for @gitPullSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully pulled latest changes.'**
  String get gitPullSuccess;

  /// No description provided for @gitFetch.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get gitFetch;

  /// No description provided for @gitFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching remote refs...'**
  String get gitFetching;

  /// No description provided for @gitFetchSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully fetched remote refs.'**
  String get gitFetchSuccess;

  /// No description provided for @gitTerminalHere.
  ///
  /// In en, this message translates to:
  /// **'Terminal Here'**
  String get gitTerminalHere;

  /// No description provided for @gitExploreFiles.
  ///
  /// In en, this message translates to:
  /// **'Explore Files'**
  String get gitExploreFiles;

  /// No description provided for @gitStatusClean.
  ///
  /// In en, this message translates to:
  /// **'Working tree is clean'**
  String get gitStatusClean;

  /// No description provided for @gitStatusDirty.
  ///
  /// In en, this message translates to:
  /// **'Uncommitted changes ({count})'**
  String gitStatusDirty(int count);

  /// No description provided for @gitStatusAhead.
  ///
  /// In en, this message translates to:
  /// **'{count} commit(s) ahead'**
  String gitStatusAhead(int count);

  /// No description provided for @gitStatusBehind.
  ///
  /// In en, this message translates to:
  /// **'{count} commit(s) behind'**
  String gitStatusBehind(int count);

  /// No description provided for @gitStatusUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date with origin'**
  String get gitStatusUpToDate;

  /// No description provided for @gitStatusDetached.
  ///
  /// In en, this message translates to:
  /// **'Detached HEAD'**
  String get gitStatusDetached;

  /// No description provided for @gitTabStatus.
  ///
  /// In en, this message translates to:
  /// **'Status & Changes'**
  String get gitTabStatus;

  /// No description provided for @gitTabBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get gitTabBranches;

  /// No description provided for @gitTabHistory.
  ///
  /// In en, this message translates to:
  /// **'Commit History'**
  String get gitTabHistory;

  /// No description provided for @gitTabDeployKey.
  ///
  /// In en, this message translates to:
  /// **'Deploy Keys & Config'**
  String get gitTabDeployKey;

  /// No description provided for @gitDiscardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get gitDiscardChanges;

  /// No description provided for @gitDiscardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard all local modifications and untracked files? This action cannot be undone.'**
  String get gitDiscardConfirm;

  /// No description provided for @gitStash.
  ///
  /// In en, this message translates to:
  /// **'Stash Changes'**
  String get gitStash;

  /// No description provided for @gitStashPop.
  ///
  /// In en, this message translates to:
  /// **'Apply Stash (Pop)'**
  String get gitStashPop;

  /// No description provided for @gitCommit.
  ///
  /// In en, this message translates to:
  /// **'Commit & Push'**
  String get gitCommit;

  /// No description provided for @gitCommitTitle.
  ///
  /// In en, this message translates to:
  /// **'Commit & Push Changes'**
  String get gitCommitTitle;

  /// No description provided for @gitCommitMessage.
  ///
  /// In en, this message translates to:
  /// **'Commit Message'**
  String get gitCommitMessage;

  /// No description provided for @gitCommitMessagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe the changes...'**
  String get gitCommitMessagePlaceholder;

  /// No description provided for @gitPushAlso.
  ///
  /// In en, this message translates to:
  /// **'Push to remote immediately'**
  String get gitPushAlso;

  /// No description provided for @gitBranchCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current Branch'**
  String get gitBranchCurrent;

  /// No description provided for @gitBranchSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch Branch'**
  String get gitBranchSwitch;

  /// No description provided for @gitBranchNew.
  ///
  /// In en, this message translates to:
  /// **'New Branch'**
  String get gitBranchNew;

  /// No description provided for @gitBranchNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Create & Checkout Branch'**
  String get gitBranchNewTitle;

  /// No description provided for @gitBranchNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. feature/api-auth'**
  String get gitBranchNamePlaceholder;

  /// No description provided for @gitDeployKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Deploy Key (SSH)'**
  String get gitDeployKeyTitle;

  /// No description provided for @gitDeployKeyDesc.
  ///
  /// In en, this message translates to:
  /// **'Copy this public key and add it as a Deploy Key in GitHub / GitLab to clone and pull private repositories without credentials.'**
  String get gitDeployKeyDesc;

  /// No description provided for @gitDeployKeyGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate Deploy Key (ED25519)'**
  String get gitDeployKeyGenerate;

  /// No description provided for @gitDeployKeyCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy Public Key'**
  String get gitDeployKeyCopy;

  /// No description provided for @gitDeployKeyCopied.
  ///
  /// In en, this message translates to:
  /// **'Deploy key copied to clipboard!'**
  String get gitDeployKeyCopied;

  /// No description provided for @gitDeployKeyNone.
  ///
  /// In en, this message translates to:
  /// **'No SSH key pair found on this server. Generate one to enable private repo cloning.'**
  String get gitDeployKeyNone;

  /// No description provided for @gitConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Git Committer Identity'**
  String get gitConfigTitle;

  /// No description provided for @gitConfigName.
  ///
  /// In en, this message translates to:
  /// **'Git User Name'**
  String get gitConfigName;

  /// No description provided for @gitConfigEmail.
  ///
  /// In en, this message translates to:
  /// **'Git User Email'**
  String get gitConfigEmail;

  /// No description provided for @gitConfigSave.
  ///
  /// In en, this message translates to:
  /// **'Save Git Identity'**
  String get gitConfigSave;

  /// No description provided for @gitOpenFileInManager.
  ///
  /// In en, this message translates to:
  /// **'Open in Git'**
  String get gitOpenFileInManager;

  /// No description provided for @gitLocalBranchesCount.
  ///
  /// In en, this message translates to:
  /// **'Local Branches ({count})'**
  String gitLocalBranchesCount(Object count);

  /// No description provided for @gitRemoteBranchesCount.
  ///
  /// In en, this message translates to:
  /// **'Remote Tracking Branches ({count})'**
  String gitRemoteBranchesCount(Object count);

  /// No description provided for @gitHistoryCount.
  ///
  /// In en, this message translates to:
  /// **'Commit History ({count})'**
  String gitHistoryCount(Object count);

  /// No description provided for @gitNoCommits.
  ///
  /// In en, this message translates to:
  /// **'No commits found.'**
  String get gitNoCommits;

  /// No description provided for @gitCommitCopied.
  ///
  /// In en, this message translates to:
  /// **'Commit {hash} copied to clipboard.'**
  String gitCommitCopied(Object hash);

  /// No description provided for @dockerComposeDownConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop and remove all containers and networks for Compose project \'{path}\'?'**
  String dockerComposeDownConfirm(String path);

  /// No description provided for @servicesConfirmDisable.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disable service \"{unit}\"? It will no longer start automatically on system boot.'**
  String servicesConfirmDisable(String unit);

  /// No description provided for @servicesConfirmDisableCritical.
  ///
  /// In en, this message translates to:
  /// **'Warning: \"{unit}\" is a critical system service. Disabling it may render the remote server unreachable on reboot. Continue?'**
  String servicesConfirmDisableCritical(String unit);

  /// No description provided for @adminFirewallConfirmDisable.
  ///
  /// In en, this message translates to:
  /// **'Disabling the firewall exposes all open ports on your server to the Internet. Are you sure you want to disable the firewall?'**
  String get adminFirewallConfirmDisable;

  /// No description provided for @adminUserDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get adminUserDeleteTitle;

  /// No description provided for @adminUserDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete system user \'{username}\' and their home directory?'**
  String adminUserDeleteConfirm(String username);

  /// No description provided for @adminMaintenanceUpgradeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade System Packages'**
  String get adminMaintenanceUpgradeConfirmTitle;

  /// No description provided for @adminMaintenanceUpgradeConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will install updates for {count} system package(s) via APT. Essential services may restart. Continue?'**
  String adminMaintenanceUpgradeConfirm(int count);

  /// No description provided for @adminMaintenanceRebootDesc.
  ///
  /// In en, this message translates to:
  /// **'Send ACPI reboot signal to restart the remote VPS machine.'**
  String get adminMaintenanceRebootDesc;

  /// No description provided for @gitDeployKeyOverwriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Overwrite Deploy Key'**
  String get gitDeployKeyOverwriteTitle;

  /// No description provided for @gitDeployKeyOverwriteConfirm.
  ///
  /// In en, this message translates to:
  /// **'An SSH deploy key already exists on this server. Generating a new one will replace the existing key and break access for repositories using the old key. Do you want to continue?'**
  String get gitDeployKeyOverwriteConfirm;

  /// No description provided for @gitConfigSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Configuration Saved'**
  String get gitConfigSavedTitle;

  /// No description provided for @gitConfigSavedDesc.
  ///
  /// In en, this message translates to:
  /// **'Git committer name and email updated successfully.'**
  String get gitConfigSavedDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
