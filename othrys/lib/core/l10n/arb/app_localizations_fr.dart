// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Othrys';

  @override
  String get navServers => 'Serveurs';

  @override
  String get navTerminal => 'Terminal';

  @override
  String get navFiles => 'Fichiers';

  @override
  String get navMonitoring => 'Surveillance';

  @override
  String get navDocker => 'Docker';

  @override
  String get navServices => 'Services';

  @override
  String get navTunnels => 'Tunnels';

  @override
  String get navActivity => 'Audit & Logs';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonRefresh => 'Actualiser';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonConnect => 'Connecter';

  @override
  String get commonDisconnect => 'Déconnecter';

  @override
  String get commonConnected => 'Connecté';

  @override
  String get commonDisconnected => 'Déconnecté';

  @override
  String get commonConnecting => 'Connexion en cours...';

  @override
  String get commonReconnecting => 'Reconnexion en cours...';

  @override
  String get commonError => 'Erreur';

  @override
  String get commonSuccess => 'Succès';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonSearch => 'Rechercher...';

  @override
  String get commonFilter => 'Filtrer';

  @override
  String get commonName => 'Nom';

  @override
  String get commonStatus => 'Statut';

  @override
  String get commonActions => 'Actions';

  @override
  String get commonClear => 'Effacer';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonCopied => 'Copié dans le presse-papiers';

  @override
  String get commonFieldRequired =>
      'Veuillez renseigner tous les champs obligatoires.';

  @override
  String get commonEmpty => 'Aucun élément trouvé.';

  @override
  String get windowExitConfirmTitle =>
      'Confirmer la fermeture de l\'application';

  @override
  String windowExitConfirmMessage(int count) {
    return '$count session(s) SSH active(s). Quitter fermera toutes les connexions distantes. Voulez-vous vraiment continuer ?';
  }

  @override
  String get windowExitDisconnect => 'Déconnecter et quitter';

  @override
  String get windowSearchActions => 'Rechercher une action...';

  @override
  String windowActiveCount(int count) {
    return '$count connecté(s)';
  }

  @override
  String tabErrorTitle(String tabName) {
    return 'Une erreur inattendue est survenue dans $tabName';
  }

  @override
  String get tabErrorReload => 'Recharger l\'onglet';

  @override
  String get serversTitle => 'Serveurs & Environnements';

  @override
  String get serversFilterPlaceholder => 'Filtrer les serveurs...';

  @override
  String get serversAdd => 'Ajouter un serveur';

  @override
  String get serversEdit => 'Modifier le serveur';

  @override
  String get serversEmptyTitle => 'Aucun serveur enregistré';

  @override
  String get serversEmptySubtitle =>
      'Ajoutez vos instances VPS distantes pour commencer la gestion de vos ressources.';

  @override
  String get serversAddFirst => 'Ajouter votre premier serveur';

  @override
  String get serversNeverConnected => 'Jamais connecté';

  @override
  String serversSeen(String time) {
    return 'Vu le $time';
  }

  @override
  String get serversDeleteConfirmTitle => 'Supprimer le profil serveur';

  @override
  String serversDeleteConfirmMessage(String name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ? Les identifiants et configurations de connexion seront effacés en toute sécurité.';
  }

  @override
  String get serversTestConnection => 'Tester la connexion';

  @override
  String get serversTesting => 'Test de connexion en cours...';

  @override
  String get serversTestSuccess => 'Connexion établie avec succès !';

  @override
  String serversTestFailed(String reason) {
    return 'Échec de connexion : $reason';
  }

  @override
  String get serversFieldHost => 'Hôte / Adresse IP';

  @override
  String get serversFieldPort => 'Port SSH';

  @override
  String get serversFieldUsername => 'Nom d\'utilisateur';

  @override
  String get serversFieldAuthType => 'Méthode d\'authentification';

  @override
  String get serversAuthPassword => 'Mot de passe';

  @override
  String get serversAuthKey => 'Clé privée';

  @override
  String get serversFieldPassword => 'Mot de passe';

  @override
  String get serversFieldPrivateKey => 'Clé privée (PEM/OpenSSH)';

  @override
  String get serversFieldPassphrase => 'Phrase secrète (optionnel)';

  @override
  String get serversSelectKeyFile => 'Parcourir...';

  @override
  String get serversShowPassword => 'Afficher le mot de passe';

  @override
  String get terminalNewTab => 'Nouvel onglet';

  @override
  String get terminalCloseTab => 'Fermer l\'onglet';

  @override
  String get terminalActiveTabs => 'Terminaux actifs';

  @override
  String get terminalClearBuffer => 'Effacer l\'écran';

  @override
  String get terminalCopy => 'Copier';

  @override
  String get terminalPaste => 'Coller';

  @override
  String get terminalSelectAll => 'Tout sélectionner';

  @override
  String get terminalOpenSession => 'Ouvrir une session terminal';

  @override
  String get terminalGuardMessage =>
      'Connectez-vous à un serveur depuis l\'onglet Serveurs pour ouvrir un terminal interactif.';

  @override
  String monitoringTitle(String serverName) {
    return '$serverName — Métriques système';
  }

  @override
  String monitoringUptimeLabel(String uptime) {
    return 'Actif depuis : $uptime';
  }

  @override
  String get monitoringWarning => 'Avertissement surveillance';

  @override
  String get monitoringCpuTitle => 'Charge CPU';

  @override
  String monitoringCpuKernel(String kernel) {
    return 'Noyau : $kernel';
  }

  @override
  String get monitoringRamTitle => 'Mémoire RAM';

  @override
  String get monitoringDiskTitle => 'Stockage Disque (Racine)';

  @override
  String get monitoringCpuTrend =>
      'Tendance de la charge CPU (60 dernières secondes)';

  @override
  String get monitoringCollecting => 'Collecte des métriques en cours...';

  @override
  String get monitoringGuardMessage =>
      'Connectez-vous à un serveur depuis l\'onglet Serveurs pour observer la télémétrie en temps réel.';

  @override
  String get dockerTitle => 'Gestion des conteneurs';

  @override
  String get dockerContainers => 'Conteneurs';

  @override
  String get dockerCompose => 'Docker Compose';

  @override
  String get dockerStart => 'Démarrer';

  @override
  String get dockerStop => 'Arrêter';

  @override
  String get dockerRestart => 'Redémarrer';

  @override
  String get dockerRemove => 'Supprimer';

  @override
  String get dockerLogs => 'Voir les journaux';

  @override
  String get dockerNoContainers =>
      'Aucun conteneur Docker détecté sur cet hôte.';

  @override
  String dockerConfirmRemove(String name) {
    return 'Êtes-vous sûr de vouloir supprimer le conteneur \'$name\' ?';
  }

  @override
  String dockerConfirmStop(String name) {
    return 'Êtes-vous sûr de vouloir arrêter le conteneur actif \'$name\' ?';
  }

  @override
  String get dockerGuardMessage =>
      'Connectez-vous à un serveur pour découvrir et gérer les conteneurs Docker.';

  @override
  String get dockerNotInstalledTitle => 'Docker n\'est pas installé';

  @override
  String get dockerNotInstalledSubtitle =>
      'Le moteur Docker est introuvable sur ce serveur. Vous pouvez exécuter le script officiel d\'installation automatique.';

  @override
  String get dockerInstallCommand => 'curl -fsSL https://get.docker.com | sh';

  @override
  String get dockerCopyCommand => 'Copier la commande d\'installation';

  @override
  String get dockerComposePath => 'Chemin du dossier Compose';

  @override
  String get dockerComposeUp => 'Démarrer Compose';

  @override
  String get dockerComposeDown => 'Arrêter Compose';

  @override
  String get dockerComposeLogs => 'Logs Compose';

  @override
  String get dockerLogsStreaming => 'Flux des journaux en direct';

  @override
  String get dockerLogsPause => 'Mettre en pause';

  @override
  String get dockerLogsResume => 'Reprendre le flux';

  @override
  String get dockerLogsCopy => 'Copier les journaux';

  @override
  String get servicesTitle => 'Services Systemd';

  @override
  String get servicesSearchPlaceholder => 'Filtrer les services par unité...';

  @override
  String get servicesStart => 'Démarrer';

  @override
  String get servicesStop => 'Arrêter';

  @override
  String get servicesRestart => 'Redémarrer';

  @override
  String get servicesReload => 'Recharger';

  @override
  String get servicesLogs => 'Voir les logs';

  @override
  String get servicesNoServices => 'Aucun service correspondant aux critères.';

  @override
  String servicesConfirmStopCritical(String unit) {
    return 'Attention : \'$unit\' est un service système critique. Son arrêt peut interrompre votre session SSH. Souhaitez-vous continuer ?';
  }

  @override
  String servicesConfirmStop(String unit) {
    return 'Êtes-vous sûr de vouloir arrêter le service \"$unit\" ?';
  }

  @override
  String get servicesEnable => 'Activer';

  @override
  String get servicesDisable => 'Désactiver';

  @override
  String get servicesEnabledBadge => 'Activé au démarrage';

  @override
  String get servicesDisabledBadge => 'Désactivé au démarrage';

  @override
  String get servicesGuardMessage =>
      'Connectez-vous à un serveur pour inspecter les services et unités systemd.';

  @override
  String get filesTitle => 'Explorateur de fichiers SFTP';

  @override
  String get filesNewFolder => 'Nouveau dossier';

  @override
  String get filesNewFile => 'Nouveau fichier';

  @override
  String get filesUpload => 'Téléverser';

  @override
  String get filesDownload => 'Télécharger';

  @override
  String get filesRename => 'Renommer';

  @override
  String get filesDelete => 'Supprimer';

  @override
  String get filesEdit => 'Éditer';

  @override
  String get filesSaveContent => 'Enregistrer le contenu';

  @override
  String filesDeleteConfirm(String name) {
    return 'Êtes-vous sûr de vouloir supprimer \'$name\' ?';
  }

  @override
  String get filesTooLarge =>
      'La taille du fichier dépasse 1 Mo, ouverture inline refusée.';

  @override
  String get filesBinaryWarning =>
      'Les fichiers binaires ne peuvent pas être ouverts dans l\'éditeur de texte.';

  @override
  String get filesGuardMessage =>
      'Connectez-vous à un serveur pour parcourir et gérer les fichiers distants via SFTP.';

  @override
  String filesUploadSuccess(String name) {
    return 'Fichier téléversé avec succès : $name';
  }

  @override
  String filesDownloadSuccess(String name) {
    return 'Fichier téléchargé avec succès : $name';
  }

  @override
  String filesRenameTitle(String name) {
    return 'Renommer : $name';
  }

  @override
  String get filesRenamePlaceholder => 'Entrez le nouveau nom...';

  @override
  String get filesUploadLimitExceeded =>
      'La taille du fichier dépasse la limite de 100 Mo.';

  @override
  String get filesDownloadLimitExceeded =>
      'La taille du fichier dépasse la limite de 100 Mo.';

  @override
  String get filesRootDirectory => 'Racine';

  @override
  String get tunnelsTitle => 'Tunnels SSH';

  @override
  String get tunnelsNew => 'Nouveau tunnel';

  @override
  String get tunnelsActive => 'Tunnels actifs';

  @override
  String get tunnelsNoTunnels => 'Aucun tunnel de redirection configuré.';

  @override
  String get tunnelsTypeLocal => 'Redirection Locale';

  @override
  String get tunnelsTypeRemote => 'Redirection Distante';

  @override
  String get tunnelsTypeDynamic => 'SOCKS5 Dynamique';

  @override
  String get tunnelsLocalPort => 'Port local';

  @override
  String get tunnelsRemoteHost => 'Hôte distant';

  @override
  String get tunnelsRemotePort => 'Port distant';

  @override
  String get tunnelsGuardMessage =>
      'Connectez-vous à un serveur pour gérer les tunnels de redirection de port.';

  @override
  String get activityTitle => 'Journal d\'audit & sécurité';

  @override
  String get activityClear => 'Effacer l\'historique';

  @override
  String get activityFilterAll => 'Toutes les catégories';

  @override
  String get activityFilterSsh => 'Connexions SSH';

  @override
  String get activityFilterDocker => 'Commandes Docker';

  @override
  String get activityFilterServices => 'Services système';

  @override
  String get activityFilterFiles => 'Opérations fichiers';

  @override
  String get activityFilterSecurity => 'Avertissements sécurité';

  @override
  String get activityNoLogs => 'Aucun journal d\'activité enregistré.';

  @override
  String filesHeader(String serverName) {
    return '$serverName — Fichiers SFTP';
  }

  @override
  String filesEditorTitle(String name) {
    return 'Édition : $name';
  }

  @override
  String get filesSaveFile => 'Enregistrer le fichier';

  @override
  String get filesCreateFolderTitle => 'Créer un dossier';

  @override
  String get filesCreateFileTitle => 'Créer un fichier';

  @override
  String get filesCreate => 'Créer';

  @override
  String get filesFolderPlaceholder => 'nom_dossier';

  @override
  String get filesFilePlaceholder => 'nom_fichier.txt';

  @override
  String get filesDeleteConfirmTitle => 'Confirmer la suppression';

  @override
  String get filesEmpty => 'Le dossier est vide';

  @override
  String get filesFolderType => 'Dossier';

  @override
  String get filesErrorTitle => 'Erreur SFTP';

  @override
  String get filesCannotOpen => 'Impossible d\'ouvrir le fichier';

  @override
  String get filesSaveFailed => 'Échec de l\'enregistrement';

  @override
  String get filesCreationFailed => 'Échec de la création';

  @override
  String get filesDeletionFailed => 'Échec de la suppression';

  @override
  String get filesLocation => 'Emplacement :';

  @override
  String get filesNameLabel => 'Nom';

  @override
  String get filesInvalidName =>
      'Le nom contient des caractères non autorisés (/ \\  )';

  @override
  String get filesNameAlreadyExists => 'Un élément avec ce nom existe déjà';

  @override
  String get tunnelsDialogTitle => 'Nouveau tunnel de redirection SSH';

  @override
  String get tunnelsNameLabel => 'Nom du tunnel';

  @override
  String get tunnelsLocalPortLabel => 'Port local (sur votre PC)';

  @override
  String get tunnelsRemotePortLabel => 'Port distant de destination';

  @override
  String get tunnelsRemoteHostLabel => 'Hôte de destination (relatif au VPS)';

  @override
  String get tunnelsStart => 'Démarrer le tunnel';

  @override
  String get tunnelsClose => 'Fermer';

  @override
  String get tunnelsErrorFailed => 'Échec de l\'établissement du tunnel';

  @override
  String get tunnelsEmptySubtitle =>
      'Redirigez vos ports locaux en toute sécurité via votre session SSH active.';

  @override
  String get activityFilterTunnels => 'Tunnels SSH';

  @override
  String get activityFilterSystem => 'Événements système';

  @override
  String get cmdPalettePlaceholder =>
      'Saisissez une commande, un serveur ou une action...';

  @override
  String get cmdPaletteEscToClose => 'Échap pour fermer';

  @override
  String get cmdPaletteSectionServers => 'SERVEURS';

  @override
  String get cmdPaletteSectionNavigation => 'NAVIGATION';

  @override
  String get cmdPaletteSectionActions => 'ACTIONS';

  @override
  String get cmdPaletteNoResults =>
      'Aucune commande ou serveur correspondant trouvé.';

  @override
  String get cmdPaletteDisconnect => 'Déconnecter la session active';

  @override
  String get serversAddTitle => 'Ajouter un profil de serveur';

  @override
  String get serversEditTitle => 'Modifier le profil du serveur';

  @override
  String get serversFieldName => 'Nom d\'affichage';

  @override
  String get serversFieldNamePlaceholder => 'ex: Serveur Web Production';

  @override
  String get serversFieldHostPlaceholder => '192.168.1.10 ou serveur.com';

  @override
  String get serversFieldGroup => 'Groupe / Catégorie';

  @override
  String get serversFieldGroupPlaceholder => 'ex: Production, Clients';

  @override
  String get serversFieldPasswordPlaceholder =>
      'Entrez le mot de passe utilisateur';

  @override
  String get serversFieldPassphrasePlaceholder =>
      'Phrase secrète de la clé si chiffrée';

  @override
  String get serversFieldBastion => 'Serveur Bastion / Passerelle (Optionnel)';

  @override
  String get serversBastionDirect => 'Connexion directe (sans bastion)';

  @override
  String get serversAddSubmit => 'Ajouter le serveur';

  @override
  String get serversEditSubmit => 'Enregistrer les modifications';

  @override
  String get settingsTitle => 'Paramètres de l\'application';

  @override
  String get settingsTheme => 'Thème de l\'interface';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLangFr => 'Français';

  @override
  String get settingsLangEn => 'English';

  @override
  String settingsTerminalFontSize(int size) {
    return 'Taille de police du terminal (${size}px)';
  }

  @override
  String settingsMonitoringInterval(int seconds) {
    return 'Intervalle d\'actualisation du monitoring (${seconds}s)';
  }

  @override
  String get settingsBackup => 'Sauvegarde & Restauration de configuration';

  @override
  String get settingsExport => 'Exporter la configuration';

  @override
  String get settingsExportDesc =>
      'Exporter les profils de serveurs et tunnels chiffrés en sauvegarde.';

  @override
  String get settingsExportSuccess => 'Configuration exportée avec succès.';

  @override
  String get settingsImport => 'Importer une configuration';

  @override
  String get settingsImportDesc =>
      'Restaurer les profils de serveurs et tunnels depuis un fichier de sauvegarde.';

  @override
  String get settingsImportSuccess => 'Configuration importée avec succès.';

  @override
  String get settingsLicense => 'Licence : MIT Open Source';

  @override
  String get settingsGitHub => 'Dépôt GitHub';

  @override
  String get settingsAbout => 'À propos d\'Othrys';

  @override
  String get settingsVersion => 'Version';

  @override
  String get onboardingWelcome => 'Bienvenue dans Othrys';

  @override
  String get onboardingSubtitle => 'Administration de serveurs Linux.';

  @override
  String get onboardingAddServer => 'Ajouter votre premier serveur';

  @override
  String get onboardingExplore => 'Explorer le tableau de bord';

  @override
  String get guardNoConnectionTitle => 'Aucune session SSH active';

  @override
  String get guardNoConnectionSubtitle =>
      'Sélectionnez un serveur et cliquez sur \'Connecter\' pour activer cette vue.';

  @override
  String get guardSelectServer => 'Aller aux serveurs';

  @override
  String get tunnelsEmptyTitle => 'Aucun tunnel actif';

  @override
  String get tunnelsDeleteConfirmTitle => 'Supprimer le tunnel';

  @override
  String tunnelsDeleteConfirmMessage(String name) {
    return 'Êtes-vous sûr de vouloir supprimer le tunnel \'$name\' ?';
  }

  @override
  String get roleRoot => 'Root (Superutilisateur)';

  @override
  String get roleSudoer => 'Admin (sudo)';

  @override
  String get roleStandard => 'Standard (Restreint)';

  @override
  String servicesPermissionRestricted(String username) {
    return 'Mode consultation : le compte connecté ($username) ne dispose pas des droits root ou sudo pour modifier les services.';
  }

  @override
  String dockerPermissionRestricted(String username) {
    return 'Accès restreint : le compte connecté ($username) n\'a pas accès au démon Docker (non-membre du groupe docker et sans sudo).';
  }

  @override
  String filesPermissionNotice(String username) {
    return 'Dossier système : le compte ($username) dispose de droits restreints hors de son répertoire personnel.';
  }

  @override
  String get filesOpenTerminal => 'Ouvrir le terminal ici';

  @override
  String get filesCloseTerminal => 'Fermer le terminal';

  @override
  String filesTerminalTitle(String path) {
    return 'Terminal — $path';
  }

  @override
  String get filesCopyPath => 'Copier le chemin d\'accès';

  @override
  String get filesPathCopied => 'Chemin copié dans le presse-papiers';

  @override
  String get filesCdHere => 'Synchroniser le terminal (cd)';

  @override
  String get filesNavigateBack => 'Dossier précédent';

  @override
  String get filesNavigateForward => 'Dossier suivant';

  @override
  String get filesNavigateUp => 'Dossier parent';

  @override
  String get filesEditPath => 'Modifier le chemin d\'accès';

  @override
  String get commonExpand => 'Agrandir';

  @override
  String get commonCollapse => 'Réduire';

  @override
  String get terminalNoConnection => 'Aucune session SSH active';

  @override
  String get navDatabases => 'Bases de données';

  @override
  String get navWebSites => 'Sites Web & SSL';

  @override
  String get servicesCreate => 'Nouveau service';

  @override
  String get servicesCreateTitle => 'Créer un service systemd';

  @override
  String get servicesNameLabel => 'Nom du service';

  @override
  String get servicesNamePlaceholder => 'ex. mon-api';

  @override
  String get servicesDescLabel => 'Description';

  @override
  String get servicesDescPlaceholder => 'ex. Service API Backend';

  @override
  String get servicesExecStartLabel => 'Commande d\'exécution (ExecStart)';

  @override
  String get servicesExecStartPlaceholder =>
      '/usr/bin/node /var/www/mon-api/index.js';

  @override
  String get servicesWorkDirLabel => 'Répertoire de travail';

  @override
  String get servicesWorkDirPlaceholder => '/var/www/mon-api';

  @override
  String get servicesUserLabel => 'Exécuter en tant que';

  @override
  String get servicesRestartPolicy => 'Politique de redémarrage';

  @override
  String get servicesEnvLabel => 'Variables d\'environnement (CLE=VALEUR)';

  @override
  String get servicesEnableBoot => 'Activer au démarrage';

  @override
  String get servicesStartNow => 'Démarrer immédiatement';

  @override
  String get servicesPreview => 'Aperçu du fichier d\'unité';

  @override
  String servicesCreateSuccess(String name) {
    return 'Service \'$name\' créé et déployé avec succès';
  }

  @override
  String servicesCreateError(String error) {
    return 'Échec de création du service : $error';
  }

  @override
  String get dbTitle => 'Bases de données';

  @override
  String get dbEngineSelect => 'Moteur de base de données';

  @override
  String get dbMysql => 'MySQL / MariaDB';

  @override
  String get dbPostgres => 'PostgreSQL';

  @override
  String dbNotInstalled(String engine) {
    return '$engine n\'est pas installé ou n\'est pas actif sur ce serveur';
  }

  @override
  String get dbTabDatabases => 'Bases de données';

  @override
  String get dbTabUsers => 'Utilisateurs & Droits';

  @override
  String get dbTabQuery => 'Console SQL';

  @override
  String get dbCreate => 'Nouvelle base';

  @override
  String get dbCreateTitle => 'Créer une base de données';

  @override
  String get dbName => 'Nom de la base';

  @override
  String get dbCollation => 'Jeu de caractères / Encodage';

  @override
  String dbDeleteConfirm(String name) {
    return 'Voulez-vous vraiment supprimer la base de données \'$name\' ? Cette action est irréversible.';
  }

  @override
  String get dbUserCreate => 'Nouvel utilisateur';

  @override
  String get dbUserCreateTitle => 'Créer un utilisateur de base de données';

  @override
  String get dbUsername => 'Nom d\'utilisateur';

  @override
  String get dbPassword => 'Mot de passe';

  @override
  String get dbHost => 'Hôte';

  @override
  String get dbPrivileges => 'Privilèges';

  @override
  String dbUserDeleteConfirm(String name) {
    return 'Voulez-vous vraiment supprimer l\'utilisateur \'$name\' ?';
  }

  @override
  String get dbQueryRun => 'Exécuter';

  @override
  String get dbQueryPlaceholder =>
      'Saisir une requête SQL (ex. SELECT * FROM table LIMIT 50;)...';

  @override
  String get dbQueryResults => 'Résultats';

  @override
  String get dbQueryEmpty =>
      'Requête exécutée avec succès, aucun résultat retourné.';

  @override
  String get dbExport => 'Exporter le dump SQL';

  @override
  String get dbImport => 'Importer un fichier SQL';

  @override
  String get webSitesTitle => 'Sites Web & SSL';

  @override
  String get webSitesNginxNotInstalled =>
      'Nginx n\'est pas installé sur ce serveur. Installez-le pour gérer vos sites web et reverse proxies.';

  @override
  String get webSitesInstallNginx => 'Installer Nginx';

  @override
  String get webSitesCreate => 'Nouveau site';

  @override
  String get webSitesCreateTitle => 'Configurer un nouveau site web';

  @override
  String get webSitesDomain => 'Nom de domaine ou sous-domaine';

  @override
  String get webSitesDomainPlaceholder =>
      'ex. api.mondomaine.com ou app.mondomaine.com';

  @override
  String get webSitesType => 'Type de site';

  @override
  String get webSitesTypeProxy => 'Reverse Proxy (API / Backend / Docker)';

  @override
  String get webSitesTypeStatic => 'Site Statique (HTML / SPA / Frontend)';

  @override
  String get webSitesTargetPort => 'Port local / URL cible';

  @override
  String get webSitesTargetPortPlaceholder =>
      'ex. 3000 ou http://127.0.0.1:8080';

  @override
  String get webSitesStaticRoot => 'Dossier racine du site';

  @override
  String get webSitesStaticRootPlaceholder => '/var/www/mon-site/dist';

  @override
  String get webSitesEnableSsl => 'Activer HTTPS avec Let\'s Encrypt (Certbot)';

  @override
  String get webSitesEmail =>
      'Email Let\'s Encrypt (pour alertes de renouvellement)';

  @override
  String get webSitesStatusEnabled => 'Activé';

  @override
  String get webSitesStatusDisabled => 'Désactivé';

  @override
  String get webSitesEnable => 'Activer le site';

  @override
  String get webSitesDisable => 'Désactiver le site';

  @override
  String webSitesDeleteConfirm(String domain) {
    return 'Voulez-vous vraiment supprimer le site \'$domain\' ?';
  }

  @override
  String get webSitesProvisionSsl => 'Activer SSL (HTTPS)';

  @override
  String get webSitesRenewSsl => 'Tester le renouvellement SSL';

  @override
  String get webSitesSslActive => 'Sécurisé HTTPS';

  @override
  String get webSitesSslInactive => 'HTTP uniquement';

  @override
  String get navSecurity => 'Sécurité & Admin';

  @override
  String get adminTitle => 'Administration & Sécurité du Serveur';

  @override
  String get adminTabFirewall => 'Pare-feu (UFW)';

  @override
  String get adminTabPorts => 'Ports d\'écoute';

  @override
  String get adminTabUsers => 'Comptes Système';

  @override
  String get adminTabMaintenance => 'Maintenance & Paramètres';

  @override
  String get adminFirewallStatus => 'Statut du pare-feu';

  @override
  String get adminFirewallActive => 'Le pare-feu est ACTIF';

  @override
  String get adminFirewallInactive => 'Le pare-feu est INACTIF';

  @override
  String get adminFirewallEnable => 'Activer le pare-feu';

  @override
  String get adminFirewallDisable => 'Désactiver le pare-feu';

  @override
  String get adminFirewallConfirmEnable =>
      'Activer le pare-feu sans règle SSH active peut vous déconnecter. Assurez-vous que le port 22 ou votre port SSH est bien autorisé. Continuer ?';

  @override
  String get adminFirewallAddRule => 'Ajouter une règle';

  @override
  String get adminFirewallAddRuleTitle => 'Ajouter une règle de pare-feu';

  @override
  String get adminFirewallRulePort => 'Port / Plage / Service';

  @override
  String get adminFirewallRulePortPlaceholder => 'ex. 22 ou 8080 ou 8000:8010';

  @override
  String get adminFirewallRuleProto => 'Protocole';

  @override
  String get adminFirewallRuleAction => 'Action';

  @override
  String get adminFirewallRuleSource => 'IP source / Sous-réseau (Optionnel)';

  @override
  String get adminFirewallRuleSourcePlaceholder =>
      'ex. Anywhere ou 192.168.1.0/24';

  @override
  String get adminFirewallPreset => 'Service prédéfini';

  @override
  String adminFirewallDeleteConfirm(int ruleNumber, String target) {
    return 'Supprimer la règle #$ruleNumber ($target) ?';
  }

  @override
  String get adminPortsTitle => 'Ports & Sockets ouverts';

  @override
  String get adminPortsProcess => 'Processus / Service';

  @override
  String get adminPortsAddress => 'Adresse locale';

  @override
  String get adminPortsPublic => 'Exposé publiquement';

  @override
  String get adminPortsLocal => 'Local uniquement (127.0.0.1)';

  @override
  String get adminPortsAllowInFirewall => 'Autoriser dans le pare-feu';

  @override
  String get adminUsersTitle => 'Comptes utilisateurs Linux';

  @override
  String get adminUsersAdd => 'Nouvel utilisateur';

  @override
  String get adminUsersAddTitle => 'Créer un utilisateur système';

  @override
  String get adminUsersUsername => 'Nom d\'utilisateur';

  @override
  String get adminUsersUsernamePlaceholder => 'ex. deployer';

  @override
  String get adminUsersPassword => 'Mot de passe initial';

  @override
  String get adminUsersPasswordPlaceholder => 'Mot de passe sécurisé';

  @override
  String get adminUsersShell => 'Shell de connexion';

  @override
  String get adminUsersGrantSudo => 'Accorder les droits administrateur (sudo)';

  @override
  String get adminUsersSshKeys => 'Clés SSH autorisées';

  @override
  String get adminUsersAddKey => 'Ajouter une clé SSH';

  @override
  String get adminUsersAddKeyTitle => 'Ajouter une clé publique autorisée';

  @override
  String get adminUsersKeyPlaceholder =>
      'Collez la clé publique (ssh-ed25519 ou ssh-rsa)...';

  @override
  String get adminMaintenanceUpdates =>
      'Mises à jour du système d\'exploitation';

  @override
  String adminMaintenanceUpdatesAvailable(int count) {
    return '$count paquet(s) peuvent être mis à niveau.';
  }

  @override
  String get adminMaintenanceUpdatesNone => 'Votre système est à jour.';

  @override
  String get adminMaintenanceApplyUpdates => 'Mettre à niveau le système';

  @override
  String get adminMaintenanceHostname => 'Nom d\'hôte du serveur';

  @override
  String get adminMaintenanceChangeHostname => 'Modifier le nom d\'hôte';

  @override
  String get adminMaintenanceReboot => 'Redémarrer le serveur';

  @override
  String get adminMaintenanceRebootConfirm =>
      'Le redémarrage fermera toutes les connexions et arrêtera temporairement les services. Voulez-vous vraiment redémarrer le serveur distant ?';

  @override
  String get navGit => 'Dépôts Git';

  @override
  String get gitTitle => 'Dépôts Git';

  @override
  String get gitSubtitle =>
      'Gérez, clonez, mettez à jour et supervisez vos projets Git sur le serveur.';

  @override
  String get gitNotInstalledTitle => 'Git n\'est pas installé';

  @override
  String get gitNotInstalledDesc =>
      'Le binaire de contrôle de version Git est introuvable sur ce serveur. Installez-le pour gérer vos dépôts.';

  @override
  String get gitInstallBtn => 'Installer Git';

  @override
  String get gitInstalling => 'Installation de Git...';

  @override
  String get gitInstalledSuccessTitle => 'Git installé';

  @override
  String get gitInstalledSuccessDesc =>
      'Git a été installé avec succès sur le serveur distant.';

  @override
  String get gitNoReposTitle => 'Aucun dépôt suivi';

  @override
  String get gitNoReposDesc =>
      'Scannez votre serveur pour détecter les projets existants ou clonez un nouveau dépôt.';

  @override
  String get gitScanServer => 'Scanner le serveur';

  @override
  String get gitScanning => 'Recherche de dépôts Git...';

  @override
  String gitScanFound(int count) {
    return '$count dépôt(s) découvert(s) !';
  }

  @override
  String get gitAddRepoPath => 'Ajouter un chemin';

  @override
  String get gitAddRepoPathTitle => 'Suivre un dépôt existant';

  @override
  String get gitAddRepoPathPlaceholder => 'ex. /var/www/mon-app';

  @override
  String get gitClone => 'Cloner un dépôt';

  @override
  String get gitCloneTitle => 'Cloner un dépôt Git';

  @override
  String get gitCloneUrl => 'URL du dépôt (HTTPS ou SSH)';

  @override
  String get gitCloneUrlPlaceholder =>
      'ex. https://github.com/org/repo.git ou git@github.com:org/repo.git';

  @override
  String get gitCloneDest => 'Répertoire de destination';

  @override
  String get gitCloneDestPlaceholder => 'ex. /var/www/mon-app';

  @override
  String get gitCloneBranch => 'Branche initiale (Optionnel)';

  @override
  String get gitCloneBranchPlaceholder => 'ex. main ou production';

  @override
  String get gitCloneShallow =>
      'Clonage superficiel (--depth 1, plus rapide pour déployer)';

  @override
  String get gitCloneSubmodules => 'Inclure les sous-modules (recurse)';

  @override
  String get gitCloneSshNotice =>
      'Pour cloner un dépôt privé en SSH, assurez-vous d\'avoir ajouté la clé de déploiement publique du serveur sur GitHub / GitLab.';

  @override
  String get gitSelectRepo => 'Sélectionner un dépôt';

  @override
  String get gitRemoveTracked => 'Ne plus suivre';

  @override
  String gitRemoveTrackedConfirm(String name) {
    return 'Retirer \'$name\' de la liste des dépôts suivis ? (Les fichiers distants ne seront pas supprimés)';
  }

  @override
  String get gitPull => 'Pull';

  @override
  String get gitPulling => 'Récupération des modifications...';

  @override
  String get gitPullSuccess => 'Dépôt mis à jour avec succès.';

  @override
  String get gitFetch => 'Fetch';

  @override
  String get gitFetching => 'Actualisation des références distantes...';

  @override
  String get gitFetchSuccess => 'Références distantes actualisées.';

  @override
  String get gitTerminalHere => 'Terminal ici';

  @override
  String get gitExploreFiles => 'Explorateur';

  @override
  String get gitStatusClean => 'L\'arbre de travail est propre';

  @override
  String gitStatusDirty(int count) {
    return 'Modifications non commitées ($count)';
  }

  @override
  String gitStatusAhead(int count) {
    return '$count commit(s) d\'avance';
  }

  @override
  String gitStatusBehind(int count) {
    return '$count commit(s) de retard';
  }

  @override
  String get gitStatusUpToDate => 'À jour avec origin';

  @override
  String get gitStatusDetached => 'HEAD détaché';

  @override
  String get gitTabStatus => 'Statut & Fichiers';

  @override
  String get gitTabBranches => 'Branches';

  @override
  String get gitTabHistory => 'Historique';

  @override
  String get gitTabDeployKey => 'Clés & Config';

  @override
  String get gitDiscardChanges => 'Annuler les modifications';

  @override
  String get gitDiscardConfirm =>
      'Annuler toutes les modifications locales et supprimer les fichiers non suivis ? Cette action est irréversible.';

  @override
  String get gitStash => 'Miser de côté (Stash)';

  @override
  String get gitStashPop => 'Restaurer le Stash (Pop)';

  @override
  String get gitCommit => 'Commiter & Pousser';

  @override
  String get gitCommitTitle => 'Enregistrer et pousser les modifications';

  @override
  String get gitCommitMessage => 'Message de commit';

  @override
  String get gitCommitMessagePlaceholder => 'Décrivez vos changements...';

  @override
  String get gitPushAlso => 'Pousser vers origin immédiatement';

  @override
  String get gitBranchCurrent => 'Branche active';

  @override
  String get gitBranchSwitch => 'Basculer de branche';

  @override
  String get gitBranchNew => 'Nouvelle branche';

  @override
  String get gitBranchNewTitle => 'Créer et basculer sur la branche';

  @override
  String get gitBranchNamePlaceholder => 'ex. feature/authentification';

  @override
  String get gitDeployKeyTitle => 'Clé de déploiement serveur (SSH)';

  @override
  String get gitDeployKeyDesc =>
      'Copiez cette clé publique et ajoutez-la comme Deploy Key dans GitHub / GitLab pour cloner et déployer vos dépôts privés sans mot de passe.';

  @override
  String get gitDeployKeyGenerate => 'Générer une clé de déploiement (ED25519)';

  @override
  String get gitDeployKeyCopy => 'Copier la clé publique';

  @override
  String get gitDeployKeyCopied =>
      'Clé de déploiement copiée dans le presse-papiers !';

  @override
  String get gitDeployKeyNone =>
      'Aucune paire de clés SSH trouvée sur ce serveur. Générez-en une pour cloner des dépôts privés.';

  @override
  String get gitConfigTitle => 'Identité Git de commit';

  @override
  String get gitConfigName => 'Nom d\'utilisateur Git';

  @override
  String get gitConfigEmail => 'Email Git';

  @override
  String get gitConfigSave => 'Enregistrer l\'identité';

  @override
  String get gitOpenFileInManager => 'Ouvrir dans Git';

  @override
  String gitLocalBranchesCount(Object count) {
    return 'Branches locales ($count)';
  }

  @override
  String gitRemoteBranchesCount(Object count) {
    return 'Branches distantes ($count)';
  }

  @override
  String gitHistoryCount(Object count) {
    return 'Historique des commits ($count)';
  }

  @override
  String get gitNoCommits => 'Aucun commit trouvé.';

  @override
  String gitCommitCopied(Object hash) {
    return 'Commit $hash copié dans le presse-papiers.';
  }

  @override
  String dockerComposeDownConfirm(String path) {
    return 'Voulez-vous vraiment arrêter et supprimer les conteneurs et réseaux du projet Compose \'$path\' ?';
  }

  @override
  String servicesConfirmDisable(String unit) {
    return 'Êtes-vous sûr de vouloir désactiver le service \"$unit\" ? Il ne démarrera plus automatiquement au démarrage.';
  }

  @override
  String servicesConfirmDisableCritical(String unit) {
    return 'Attention : \"$unit\" est un service système critique. Le désactiver peut rendre le serveur distant inaccessible au redémarrage. Continuer ?';
  }

  @override
  String get adminFirewallConfirmDisable =>
      'Désactiver le pare-feu expose tous les ports ouverts de votre serveur à Internet. Voulez-vous vraiment désactiver le pare-feu ?';

  @override
  String get adminUserDeleteTitle => 'Supprimer l\'utilisateur';

  @override
  String adminUserDeleteConfirm(String username) {
    return 'Êtes-vous sûr de vouloir supprimer définitivement l\'utilisateur système \'$username\' et son répertoire personnel ?';
  }

  @override
  String get adminMaintenanceUpgradeConfirmTitle =>
      'Mettre à niveau le système';

  @override
  String adminMaintenanceUpgradeConfirm(int count) {
    return 'Cette action va installer les mises à jour de $count paquet(s) système via APT. Des services peuvent redémarrer. Continuer ?';
  }

  @override
  String get adminMaintenanceRebootDesc =>
      'Envoyer un signal ACPI de redémarrage pour redémarrer la machine VPS distante.';

  @override
  String get gitDeployKeyOverwriteTitle => 'Écraser la clé de déploiement';

  @override
  String get gitDeployKeyOverwriteConfirm =>
      'Une clé de déploiement SSH existe déjà sur ce serveur. En générer une nouvelle remplacera la clé existante et révoquera les accès configurés. Voulez-vous continuer ?';

  @override
  String get gitConfigSavedTitle => 'Configuration enregistrée';

  @override
  String get gitConfigSavedDesc =>
      'Nom et email de l\'auteur Git mis à jour avec succès.';
}
