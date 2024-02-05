import 'package:my_docs/client/socket_client.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketRepository{
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  void joinRoom(String documentID){
    _socketClient.emit('join',documentID);
  }

  void typing(Map<String, dynamic> data){
    _socketClient.emit('typing',data);
  }

  void autoSave (Map<String,dynamic> data){
    _socketClient.emit('save', data);
  }

  void changeListener({required Function(Map<String,dynamic>) converterFunction}){
    _socketClient.on('changes', (data) => converterFunction(data));
  }
}