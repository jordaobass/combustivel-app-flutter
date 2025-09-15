/// AppStrings - Strings centralizadas do app
class AppStrings {
  AppStrings._();

  // App Info
  static const String appName = 'Fuel Track';
  static const String appDescription = 'Monitor de Combustível';

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String vehicles = 'Veículos';
  static const String fuelRecords = 'Abastecimentos';
  static const String analytics = 'Análises';
  static const String settings = 'Configurações';

  // Dashboard
  static const String currentConsumption = 'Consumo Atual';
  static const String monthlySpending = 'Gasto Mensal';
  static const String averageConsumption = 'Consumo Médio';
  static const String lastRefuel = 'Último Abastecimento';
  static const String nextRefuel = 'Próximo Abastecimento';
  static const String totalSpent = 'Total Gasto';
  static const String economyStatus = 'Status Econômico';

  // Fuel Types
  static const String gasoline = 'Gasolina';
  static const String ethanol = 'Etanol';
  static const String diesel = 'Diesel';
  static const String gnv = 'GNV';

  // Vehicle
  static const String addVehicle = 'Adicionar Veículo';
  static const String editVehicle = 'Editar Veículo';
  static const String vehicleBrand = 'Marca';
  static const String vehicleModel = 'Modelo';
  static const String vehicleYear = 'Ano';
  static const String tankCapacity = 'Capacidade do Tanque (L)';
  static const String expectedConsumption = 'Consumo Esperado (km/L)';
  static const String vehicleColor = 'Cor de Identificação';
  static const String vehicleImage = 'Foto do Veículo';

  // Fuel Records
  static const String addFuelRecord = 'Registrar Abastecimento';
  static const String editFuelRecord = 'Editar Abastecimento';
  static const String fuelDate = 'Data';
  static const String odometer = 'Quilometragem';
  static const String liters = 'Litros';
  static const String pricePerLiter = 'Preço por Litro';
  static const String totalCost = 'Valor Total';
  static const String gasStation = 'Posto';
  static const String fuelType = 'Tipo de Combustível';
  static const String fullTank = 'Tanque Completo';
  static const String partialTank = 'Abastecimento Parcial';
  static const String receiptPhoto = 'Foto do Cupom';
  static const String notes = 'Observações';

  // Calculations
  static const String consumption = 'Consumo';
  static const String kmPerLiter = 'km/L';
  static const String costPerKm = 'Custo por km';
  static const String efficiency = 'Eficiência';
  static const String autonomy = 'Autonomia';
  static const String trend = 'Tendência';

  // Economy Status
  static const String economical = 'Econômico';
  static const String expensive = 'Caro';
  static const String average = 'Médio';
  static const String improving = 'Melhorando';
  static const String worsening = 'Piorando';
  static const String stable = 'Estável';

  // Analytics
  static const String monthlyReport = 'Relatório Mensal';
  static const String yearlyReport = 'Relatório Anual';
  static const String consumptionHistory = 'Histórico de Consumo';
  static const String spendingHistory = 'Histórico de Gastos';
  static const String bestConsumption = 'Melhor Consumo';
  static const String worstConsumption = 'Pior Consumo';
  static const String averagePrice = 'Preço Médio';
  static const String bestPrice = 'Melhor Preço';
  static const String worstPrice = 'Pior Preço';
  static const String favoriteGasStation = 'Posto Favorito';
  static const String bestDayToRefuel = 'Melhor Dia para Abastecer';

  // Maintenance
  static const String maintenance = 'Manutenção';
  static const String addMaintenance = 'Registrar Manutenção';
  static const String maintenanceType = 'Tipo de Manutenção';
  static const String maintenanceDate = 'Data';
  static const String maintenanceCost = 'Custo';
  static const String maintenanceLocation = 'Local';
  static const String nextMaintenance = 'Próxima Manutenção';
  static const String maintenanceOverdue = 'Manutenção Atrasada';
  static const String maintenanceDueSoon = 'Manutenção em Breve';

  // OCR
  static const String scanReceipt = 'Escanear Cupom';
  static const String ocrProcessing = 'Processando imagem...';
  static const String ocrSuccess = 'Dados extraídos com sucesso';
  static const String ocrError = 'Erro ao processar imagem';
  static const String reviewData = 'Revisar dados extraídos';

  // GPS
  static const String currentLocation = 'Localização Atual';
  static const String gpsPermissionRequired = 'Permissão de localização necessária';
  static const String gpsNotAvailable = 'GPS não disponível';

  // Actions
  static const String save = 'Salvar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Excluir';
  static const String edit = 'Editar';
  static const String add = 'Adicionar';
  static const String confirm = 'Confirmar';
  static const String retry = 'Tentar Novamente';
  static const String close = 'Fechar';
  static const String ok = 'OK';
  static const String yes = 'Sim';
  static const String no = 'Não';

  // Validation Messages
  static const String requiredField = 'Campo obrigatório';
  static const String invalidValue = 'Valor inválido';
  static const String invalidEmail = 'Email inválido';
  static const String invalidDate = 'Data inválida';
  static const String invalidNumber = 'Número inválido';
  static const String minLength = 'Mínimo de 3 caracteres';
  static const String maxLength = 'Máximo de 100 caracteres';
  static const String odometerMustIncrease = 'Quilometragem deve ser maior que a anterior';

  // Error Messages
  static const String genericError = 'Ocorreu um erro inesperado';
  static const String networkError = 'Erro de conexão';
  static const String storageError = 'Erro ao salvar dados';
  static const String cameraError = 'Erro ao acessar câmera';
  static const String permissionDenied = 'Permissão negada';
  static const String noDataFound = 'Nenhum dado encontrado';

  // Success Messages
  static const String savedSuccessfully = 'Salvo com sucesso';
  static const String deletedSuccessfully = 'Excluído com sucesso';
  static const String updatedSuccessfully = 'Atualizado com sucesso';

  // Filters and Sorting
  static const String filterBy = 'Filtrar por';
  static const String sortBy = 'Ordenar por';
  static const String allVehicles = 'Todos os Veículos';
  static const String lastWeek = 'Última Semana';
  static const String lastMonth = 'Último Mês';
  static const String lastYear = 'Último Ano';
  static const String custom = 'Personalizado';

  // Units
  static const String km = 'km';
  static const String litersUnit = 'L';
  static const String currency = 'R\$';
  static const String currencyPerLiter = 'R\$/L';
  static const String currencyPerKm = 'R\$/km';

  // Tips and Insights
  static const String tip = 'Dica';
  static const String insight = 'Insight';
  static const String recommendation = 'Recomendação';
  static const String congratulations = 'Parabéns!';
  static const String attention = 'Atenção';

  // Settings
  static const String darkMode = 'Modo Escuro';
  static const String notifications = 'Notificações';
  static const String language = 'Idioma';
  static const String backup = 'Backup';
  static const String exportData = 'Exportar Dados';
  static const String importData = 'Importar Dados';
  static const String about = 'Sobre';
  static const String version = 'Versão';
  static const String privacyPolicy = 'Política de Privacidade';
  static const String terms = 'Termos de Uso';

  // Empty States
  static const String noVehicles = 'Nenhum veículo cadastrado';
  static const String noFuelRecords = 'Nenhum abastecimento registrado';
  static const String noMaintenanceRecords = 'Nenhuma manutenção registrada';
  static const String addFirstVehicle = 'Adicione seu primeiro veículo';
  static const String addFirstFuelRecord = 'Registre seu primeiro abastecimento';

  // Onboarding
  static const String welcome = 'Bem-vindo';
  static const String getStarted = 'Começar';
  static const String skip = 'Pular';
  static const String next = 'Próximo';
  static const String finish = 'Finalizar';
}