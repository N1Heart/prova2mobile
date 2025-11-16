// Enum para garantir a consistência dos dados
enum FuelType {
  gasolina,
  etanol,
  diesel,
  gnv,
  eletrico,
  flex, // Gasolina/Etanol
}

// Extensão para obter um nome "amigável" para exibir na UI
extension FuelTypeExtension on FuelType {
  String get displayName {
    switch (this) {
      case FuelType.gasolina:
        return 'Gasolina';
      case FuelType.etanol:
        return 'Etanol (Álcool)';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.gnv:
        return 'GNV';
      case FuelType.eletrico:
        return 'Elétrico';
      case FuelType.flex:
        return 'Flex (Gasolina/Etanol)';
    }
  }
}
