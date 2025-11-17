import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:p2mobile/core/utils/fuel_type_enum.dart';
import 'package:p2mobile/data/models/fueling_model.dart';
import 'package:p2mobile/data/models/vehicle_model.dart';
import 'package:p2mobile/viewmodels/fueling_viewmodel.dart';
import 'package:p2mobile/viewmodels/vehicle_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Para formatar a data

class AddFuelingScreen extends StatefulWidget {
  const AddFuelingScreen({super.key});

  @override
  State<AddFuelingScreen> createState() => _AddFuelingScreenState();
}

class _AddFuelingScreenState extends State<AddFuelingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _dateController = TextEditingController();
  final _litersController = TextEditingController();
  final _valueController = TextEditingController();
  final _kmController = TextEditingController();
  final _notesController = TextEditingController();

  // Valores selecionados
  Vehicle? _selectedVehicle;
  FuelType _selectedFuelType = FuelType.flex;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Define a data inicial no controlador
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _litersController.dispose();
    _valueController.dispose();
    _kmController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Validador de número
  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'O campo "$fieldName" é obrigatório.';
    }
    // Substitui vírgula por ponto para aceitar ambos
    final valueSanitized = value.replaceAll(',', '.');
    if (double.tryParse(valueSanitized) == null) {
      return 'Insira um número válido.';
    }
    if (double.parse(valueSanitized) <= 0) {
      return 'O valor deve ser maior que zero.';
    }
    return null;
  }

  // Validador de veículo
  String? _validateVehicle(Vehicle? value) {
    if (value == null) {
      return 'Selecione um veículo.';
    }
    return null;
  }

  // Exibe o DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }

  // Função de Salvar
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Cria o objeto Fueling
      final newFueling = Fueling(
        veiculoId: _selectedVehicle!.id!,
        data: Timestamp.fromDate(_selectedDate),
        quantidadeLitros: double.parse(
          _litersController.text.replaceAll(',', '.'),
        ),
        valorPago: double.parse(_valueController.text.replaceAll(',', '.')),
        quilometragem: int.parse(_kmController.text),
        tipoCombustivel: _selectedFuelType,
        observacao: _notesController.text.trim(),
      );

      final viewModel = context.read<FuelingViewModel>();

      final success = await viewModel.addFueling(context, newFueling);

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ouve o status do ViewModel de Abastecimento
    final fuelingStatus = context.watch<FuelingViewModel>().status;

    // Ouve o Stream de Veículos (para o Dropdown)
    final vehicleStream = context.watch<VehicleViewModel>().vehiclesStream;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Abastecimento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Dropdown de Veículos ---
              StreamBuilder<List<Vehicle>>(
                stream: vehicleStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Text('Carregando veículos...'));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro: ${snapshot.error}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'Você precisa cadastrar um veículo antes de abastecer.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  }

                  final vehicles = snapshot.data!;
                  // Garante que o veículo selecionado ainda existe
                  if (_selectedVehicle != null &&
                      !vehicles.any((v) => v.id == _selectedVehicle!.id)) {
                    _selectedVehicle = null;
                  }

                  return DropdownButtonFormField<Vehicle>(
                    initialValue: _selectedVehicle,
                    decoration: const InputDecoration(labelText: 'Veículo *'),
                    items: vehicles.map((Vehicle vehicle) {
                      return DropdownMenuItem<Vehicle>(
                        value: vehicle,
                        child: Text(
                          '${vehicle.marca} ${vehicle.modelo} (${vehicle.placa})',
                        ),
                      );
                    }).toList(),
                    onChanged: (Vehicle? newValue) {
                      setState(() {
                        _selectedVehicle = newValue;
                        // Auto-preenche o tipo de combustível
                        if (newValue != null) {
                          _selectedFuelType = newValue.tipoCombustivel;
                        }
                      });
                    },
                    validator: _validateVehicle,
                  );
                },
              ),
              const SizedBox(height: 20),

              // --- Data ---
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Data *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),

              // --- Quilometragem ---
              TextFormField(
                controller: _kmController,
                decoration: const InputDecoration(
                  labelText: 'Quilometragem (ex: 50123) *',
                  prefixIcon: Icon(Icons.speed),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => _validateNumber(value, 'Quilometragem'),
              ),
              const SizedBox(height: 20),

              // --- Litros e Valor Pago (Lado a Lado) ---
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _litersController,
                      decoration: const InputDecoration(labelText: 'Litros *'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) => _validateNumber(value, 'Litros'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _valueController,
                      decoration: const InputDecoration(
                        labelText: 'Valor Pago (R\$) *',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) =>
                          _validateNumber(value, 'Valor Pago'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Dropdown Tipo de Combustível ---
              DropdownButtonFormField<FuelType>(
                initialValue: _selectedFuelType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Combustível *',
                ),
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
              const SizedBox(height: 20),

              // --- Observação ---
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Observação (Opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // --- Botão Salvar ---
              ElevatedButton(
                onPressed:
                    fuelingStatus == FuelingStatus.loading ||
                        _selectedVehicle == null
                    ? null // Desabilita se estiver carregando ou sem veículo
                    : _submitForm,
                child: fuelingStatus == FuelingStatus.loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text('Salvar Abastecimento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
