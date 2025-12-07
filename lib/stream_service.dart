import 'dart:async';

class StreamService {
  // ===========================
  // BROADCAST STREAM CONTROLLER
  // ===========================
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  // ===========================
  // STREAM UNTUK DIDENGARKAN
  // ===========================
  Stream<String> get messageStream => _messageController.stream;

  // ===========================
  // KIRIM DATA KE STREAM
  // ===========================
  void sendMessage(String message) {
    _messageController.sink.add(message);
  }

  // ===========================
  // TUTUP STREAM (WAJIB)
  // ===========================
  void dispose() {
    _messageController.close();
  }
}
