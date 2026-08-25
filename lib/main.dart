import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MHApp());
}

class MHApp extends StatelessWidget {
  const MHApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Maquina Hiladora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF33C3BC),
        scaffoldBackgroundColor: const Color(0xFF0B1E2D),
      ),
      home: const ControlScreen(),
    );
  }
}

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  BluetoothConnection? _connection;
  bool _isConnected = false;
  String _status = 'Desconectado';
  String _speedText = 'Velocidad: 0 RPM';
  StreamSubscription<Uint8List>? _dataSubscription;

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _connection?.dispose();
    super.dispose();
  }

  // ---------- PERMISOS EN RUNTIME ----------

  Future<bool> _ensurePermissions() async {
    final statuses = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();

    final denied = statuses.values.any((s) => s.isDenied || s.isPermanentlyDenied);
    if (denied) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se necesitan permisos de Bluetooth para conectar')),
      );
      return false;
    }
    return true;
  }

  // ---------- SELECCION DE DISPOSITIVO ----------

  Future<void> _pickAndConnect() async {
    final permitido = await _ensurePermissions();
    if (!permitido) return;

    final enabled = await FlutterBluetoothSerial.instance.isEnabled ?? false;
    if (!enabled) {
      await FlutterBluetoothSerial.instance.requestEnable();
    }

    List<BluetoothDevice> devices = [];
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al listar dispositivos: $e')),
      );
      return;
    }

    if (!mounted) return;

    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay dispositivos emparejados. Empareja el HC-05 en Ajustes > Bluetooth primero.')),
      );
      return;
    }

    final selected = await showDialog<BluetoothDevice>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Elegi tu modulo HC-05'),
        children: devices.map((d) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, d),
            child: Text('${d.name ?? "Desconocido"}\n${d.address}'),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      _connectTo(selected);
    }
  }

  // ---------- CONEXION ----------

  Future<void> _connectTo(BluetoothDevice device) async {
    setState(() {
      _status = 'Conectando...';
    });

    try {
      final connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        _connection = connection;
        _isConnected = true;
        _status = 'Conectado';
      });

      _dataSubscription = connection.input!.listen(
        (Uint8List data) {
          final text = String.fromCharCodes(data).trim();
          if (text.isNotEmpty) {
            setState(() {
              _speedText = 'Velocidad: $text RPM';
            });
          }
        },
        onDone: () {
          setState(() {
            _isConnected = false;
            _status = 'Desconectado';
          });
        },
      );
    } catch (e) {
      setState(() {
        _isConnected = false;
        _status = 'Desconectado';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar: $e')),
      );
    }
  }

  // ---------- ENVIO DE COMANDOS ----------

  void _sendCommand(String command) {
    if (_connection == null || !_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No conectado')),
      );
      return;
    }
    _connection!.output.add(Uint8List.fromList(command.codeUnits));
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final statusColor = _isConnected ? const Color(0xFF00C853) : const Color(0xFFFF5252);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'CONTROL DE LA\nMAQUINA HILADORA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF33C3BC),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                _status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pickAndConnect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const Text('Conectar Bluetooth'),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _sendCommand('0'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF455A64),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Text('Apagar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _sendCommand('1'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Text('Encender'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _sendCommand('A'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Text('Acelerar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _sendCommand('L'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0288D1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Text('Lentear'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _sendCommand('F'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Text('Frenar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF102841),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _speedText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
