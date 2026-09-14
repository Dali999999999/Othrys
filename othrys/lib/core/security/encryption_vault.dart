import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/result.dart';

/// Cryptographic vault responsible for zero-leak local encryption of sensitive credentials.
class EncryptionVault {
  static final EncryptionVault instance = EncryptionVault();
  final FlutterSecureStorage _secureStorage;

  EncryptionVault({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(wOptions: WindowsOptions(useBackwardCompatibility: false));

  static const String _masterKeyAccount = 'othrys_master_encryption_key';
  static const String _legacyKeyAccount = 'vpsmanager_master_encryption_key';
  final AesGcm _aesGcm = AesGcm.with256bits();
  final Pbkdf2 _pbkdf2 = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 100000, bits: 256);

  Uint8List? _masterKeyBytes;
  bool _isInitialized = false;

  /// Returns whether the vault has loaded or generated the master key.
  bool get isInitialized => _isInitialized && _masterKeyBytes != null;

  Future<Result<Uint8List>> _getMasterKey() async {
    if (_masterKeyBytes != null) return Success(_masterKeyBytes!);
    try {
      var storedKeyHex = await _secureStorage.read(key: _masterKeyAccount);
      if (storedKeyHex == null || storedKeyHex.isEmpty) {
        // Fallback check for legacy key
        storedKeyHex = await _secureStorage.read(key: _legacyKeyAccount);
      }
      if (storedKeyHex != null && storedKeyHex.isNotEmpty) {
        _masterKeyBytes = Uint8List.fromList(hex.decode(storedKeyHex));
        // Persist under new account name
        await _secureStorage.write(key: _masterKeyAccount, value: storedKeyHex);
      } else {
        final secretKey = await _aesGcm.newSecretKey();
        _masterKeyBytes = Uint8List.fromList(await secretKey.extractBytes());
        await _secureStorage.write(key: _masterKeyAccount, value: hex.encode(_masterKeyBytes!));
      }
      _isInitialized = true;
      return Success(_masterKeyBytes!);
    } catch (e, st) {
      _masterKeyBytes = null;
      _isInitialized = false;
      return Failure('Failed to access secure storage master key', e, st);
    }
  }

  /// Initializes the vault with master key verification.
  Future<Result<void>> initialize() async {
    final keyRes = await _getMasterKey();
    return keyRes.fold(onSuccess: (_) => const Success(null), onFailure: (m, e, s) => Failure(m, e, s));
  }

  /// Encrypts plaintext with AES-256-GCM and unique salt.
  Future<Result<String>> encrypt(String plaintext) async {
    if (plaintext.isEmpty) return const Success('');
    final keyRes = await _getMasterKey();
    if (keyRes is Failure<Uint8List>) return Failure(keyRes.message, keyRes.exception, keyRes.stackTrace);

    try {
      final salt = SecretKeyData.random(length: 16).bytes;
      final nonce = _aesGcm.newNonce();
      final derivedKey = await _pbkdf2.deriveKey(secretKey: SecretKey((keyRes as Success<Uint8List>).data), nonce: salt);
      final box = await _aesGcm.encrypt(utf8.encode(plaintext), secretKey: derivedKey, nonce: nonce);
      return Success('${hex.encode(salt)}:${hex.encode(box.nonce)}:${hex.encode(box.cipherText)}:${hex.encode(box.mac.bytes)}');
    } catch (e, st) {
      return Failure('Encryption failed', e, st);
    }
  }

  /// Decrypts a previously encrypted token.
  Future<Result<String>> decrypt(String cipherString) async {
    if (cipherString.isEmpty) return const Success('');
    if (!isEncrypted(cipherString)) return Success(cipherString);
    final keyRes = await _getMasterKey();
    if (keyRes is Failure<Uint8List>) return Failure(keyRes.message, keyRes.exception, keyRes.stackTrace);

    try {
      final parts = cipherString.split(':');
      if (parts.length != 4) return const Failure('Invalid encrypted payload format');
      final derivedKey = await _pbkdf2.deriveKey(
        secretKey: SecretKey((keyRes as Success<Uint8List>).data),
        nonce: hex.decode(parts[0]),
      );
      final box = SecretBox(hex.decode(parts[2]), nonce: hex.decode(parts[1]), mac: Mac(hex.decode(parts[3])));
      final decryptedBytes = await _aesGcm.decrypt(box, secretKey: derivedKey);
      return Success(utf8.decode(decryptedBytes));
    } catch (e, st) {
      return Failure('Decryption failed', e, st);
    }
  }

  /// Checks if a given string matches the vault encrypted pattern.
  bool isEncrypted(String text) {
    if (text.isEmpty) return false;
    final parts = text.split(':');
    final hexRegExp = RegExp(r'^[0-9a-fA-F]+$');
    return parts.length == 4 && parts.every((p) => p.isNotEmpty && hexRegExp.hasMatch(p));
  }

  /// Wipes cached master key from memory and resets initialization status.
  void zeroize() {
    _masterKeyBytes?.fillRange(0, _masterKeyBytes!.length, 0);
    _masterKeyBytes = null;
    _isInitialized = false;
  }
}
