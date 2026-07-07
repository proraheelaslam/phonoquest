import 'dart:typed_data';

/// Prepares gallery picks for `POST /profiles/me/avatar` (MIME + filename).
class ProfileImageUpload {
  const ProfileImageUpload({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String filename;
  final String mimeType;
}

ProfileImageUpload prepareProfileImageUpload({
  required List<int> bytes,
  String? originalName,
  String? pickedMimeType,
}) {
  final data = Uint8List.fromList(bytes);
  final mime = _resolveMimeType(data, pickedMimeType, originalName);
  final filename = _resolveFilename(originalName, mime);
  return ProfileImageUpload(bytes: data, filename: filename, mimeType: mime);
}

String _resolveMimeType(Uint8List data, String? pickedMimeType, String? name) {
  final picked = (pickedMimeType ?? '').split(';').first.trim().toLowerCase();
  if (_allowedMimes.contains(picked)) return picked;

  final sniffed = _sniffMime(data);
  if (sniffed != null) return sniffed;

  final fromName = _mimeFromFilename(name ?? '');
  if (fromName != null) return fromName;

  return 'image/jpeg';
}

String _resolveFilename(String? originalName, String mime) {
  final ext = _extensionForMime(mime);
  final raw = (originalName ?? '').trim().toLowerCase();
  if (raw.isNotEmpty && raw.contains('.')) {
    final base = raw.split('/').last.split('\\').last;
    if (_allowedExtensions.any((ext) => base.endsWith(ext))) {
      return base;
    }
  }
  return 'profile$ext';
}

const _allowedMimes = {
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
};

const _allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp', '.gif'];

String? _sniffMime(Uint8List data) {
  if (data.length >= 3 && data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF) {
    return 'image/jpeg';
  }
  if (data.length >= 8 &&
      data[0] == 0x89 &&
      data[1] == 0x50 &&
      data[2] == 0x4E &&
      data[3] == 0x47) {
    return 'image/png';
  }
  if (data.length >= 12 &&
      data[0] == 0x52 &&
      data[1] == 0x49 &&
      data[2] == 0x46 &&
      data[3] == 0x46 &&
      data[8] == 0x57 &&
      data[9] == 0x45 &&
      data[10] == 0x42 &&
      data[11] == 0x50) {
    return 'image/webp';
  }
  if (data.length >= 6) {
    final head = String.fromCharCodes(data.sublist(0, 6));
    if (head == 'GIF87a' || head == 'GIF89a') return 'image/gif';
  }
  return null;
}

String? _mimeFromFilename(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  return null;
}

String _extensionForMime(String mime) {
  switch (mime) {
    case 'image/png':
      return '.png';
    case 'image/webp':
      return '.webp';
    case 'image/gif':
      return '.gif';
    case 'image/jpeg':
    default:
      return '.jpg';
  }
}
