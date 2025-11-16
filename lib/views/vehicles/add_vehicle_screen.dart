import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:p2mobile/core/utils/fuel_type_enum.dart';
import 'package:p2mobile/data/models/vehicle_model.dart';
import 'package:p2mobile/viewmodels/vehicle_viewmodel.dart';
import 'package:provider/provider.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modeloController = TextEditingController();
  final _marcaController = TextEditingController();
  final _placaController = TextEditingController();
  final _anoController = TextEditingController();

  // Valor inicial para o Dropdown
  FuelType _selectedFuelType = FuelType.flex;

  @override
  void dispose() {
    _modeloController.dispose();
    _marcaController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    super.dispose();
  }

  // Validador simples de "não pode estar vazio"
  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'O campo "$fieldName" é obrigatório.';
    }
    return null;
  }

  // Validador de ano
  String? _validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'O campo "Ano" é obrigatório.';
    }
    final year = int.tryParse(value);
    if (year == null || year < 1950 || year > DateTime.now().year + 1) {
      return 'Insira um ano válido.';
    }
    return null;
  }

  // Função de Salvar
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Cria o objeto Vehicle
      final newVehicle = Vehicle(
        modelo: _modeloController.text.trim(),
        marca: _marcaController.text.trim(),
        placa: _placaController.text.trim().toUpperCase(),
        ano: int.parse(_anoController.text),
        tipoCombustivel: _selectedFuelType,
      );

      // Chama o ViewModel
      final success = await context.read<VehicleViewModel>().addVehicle(
        context,
        newVehicle,
      );

      if (success && context.mounted) {
        // Se salvou, fecha a tela
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModelStatus = context.watch<VehicleViewModel>().status;

    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Novo Veículo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(
                  labelText: 'Marca (ex: Fiat)',
                ),
                validator: (value) => _validateNotEmpty(value, 'Marca'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _modeloController,
                decoration: const InputDecoration(
                  labelText: 'Modelo (ex: Uno)',
                ),
                validator: (value) => _validateNotEmpty(value, 'Modelo'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(
                  labelText: 'Placa (ex: ABC1D23)',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) => _validateNotEmpty(value, 'Placa'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _anoController,
                decoration: const InputDecoration(labelText: 'Ano (ex: 2020)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validateYear,
              ),
              const SizedBox(height: 20),

              // Dropdown para Tipo de Combustível
              DropdownButtonFormField<FuelType>(
                value: _selectedFuelType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Combustível',
                ),
                // Mapeia o Enum para os Itens do Dropdown
                items: FuelType.values.map((FuelType type) {
                  return DropdownMenuItem<FuelType>(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (FuelType? newValue) {
                  setState(() {
                    _selectedFuelType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Botão Salvar
              ElevatedButton(
                onPressed: viewModelStatus == VehicleStatus.loading
                    ? null
                    : _submitForm,
                child: viewModelStatus == VehicleStatus.loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text('Salvar Veículo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
