// constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Finanapp';

  // Asset Paths
  static const String happyPigImage = 'assets/images/porquinho_feliz.png';
  static const String sadPigImage = 'assets/images/porquinho_triste.png';
  static const String neutralPigImage = 'assets/images/porquinho_neutro.png';

  // UI Text
  static const String currentBalanceLabel = 'Saldo Atual';
  static const String newTransactionTitle = 'Nova Transação';
  static const String titleFieldLabel = 'Título *';
  static const String titleFieldHint = 'Ex: Compra no supermercado';
  static const String valueFieldLabel = 'Valor (R\$) *';
  static const String valueFieldHint = '0,00';
  static const String expenseLabel = 'Despesa';
  static const String incomeLabel = 'Receita';
  static const String expenseSubtitle = 'Saída de dinheiro';
  static const String incomeSubtitle = 'Entrada de dinheiro';
  static const String transactionTypeLabel = 'Tipo de transação:';

  // Button Labels
  static const String saveButton = 'Salvar';
  static const String savingButton = 'Salvando...';
  static const String cancelButton = 'Cancelar';
  static const String clearButton = 'Limpar';
  static const String deleteButton = 'Excluir';
  static const String confirmButton = 'OK';
  static const String retryButton = 'Tentar Novamente';
  static const String detailsButton = 'Ver Detalhes';
  static const String firstTransactionButton = 'Primeira Transação';
  static const String refreshTooltip = 'Atualizar';
  static const String addTransactionTooltip = 'Adicionar transação';
  static const String closeTooltip = 'Fechar';

  // Messages
  static const String loadingTransactions = 'Carregando transações...';
  static const String errorTitle = 'Ops! Algo deu errado';
  static const String noTransactionsTitle = 'Nenhuma transação ainda';
  static const String noTransactionsMessage =
      'Comece adicionando sua primeira transação\ntocando no botão + abaixo';
  static const String confirmDeleteTitle = 'Confirmar exclusão';
  static const String attentionTitle = 'Atenção';
  static const String errorDetailsTitle = 'Detalhes do Erro';
  static const String noDetailsAvailable = 'Nenhum detalhe disponível';
  static const String closeAction = 'Fechar';

  // Success Messages
  static const String expenseAddedSuccess = 'DESPESA adicionada com sucesso!';
  static const String incomeAddedSuccess = 'RECEITA adicionada com sucesso!';
  static const String transactionRemovedSuccess =
      'Transação removida com sucesso!';

  // Validation Messages
  static const String titleRequiredError = 'Por favor, insira um título';
  static const String titleTooLongError =
      'Título muito longo (máximo 100 caracteres)';
  static const String valueRequiredError = 'Por favor, insira um valor';
  static const String valueInvalidError =
      'Por favor, insira um valor numérico válido';
  static const String valueZeroError = 'O valor deve ser maior que zero';
  static const String valueTooHighError = 'Valor muito alto';
  static const String fillAllFieldsError =
      'Por favor, preencha todos os campos corretamente';

  // Database Messages
  static const String databaseInitSuccess =
      'DatabaseService inicializado com sucesso';
  static const String bankInitializingMessage =
      'Iniciando inicialização do banco...';
  static const String bankSuccessMessage = 'Banco inicializado com sucesso!';
  static const String initErrorMessage = 'Erro ao inicializar aplicação';

  // Validation Constants
  static const int maxTitleLength = 100;
  static const double maxTransactionValue = 999999999.99;
  static const int recentTransactionsDays = 30;

  // UI Dimensions
  static const double defaultPadding = 16.0;
  static const double largePadding = 20.0;
  static const double smallPadding = 8.0;
  static const double extraSmallPadding = 4.0;
  static const double balanceImageHeight = 150.0;
  static const double cardElevation = 3.0;
  static const double borderRadius = 10.0;
  static const double largeIconSize = 80.0;
  static const double mediumIconSize = 64.0;
  static const double smallIconSize = 20.0;

  // Text Sizes
  static const double balanceLabelFontSize = 16.0;
  static const double balanceValueFontSize = 32.0;
  static const double transactionValueFontSize = 14.0;

  // Animation Durations
  static const Duration snackBarDuration = Duration(seconds: 4);
  static const Duration successSnackBarDuration = Duration(seconds: 3);

  // Currency
  static const String currencySymbol = 'R\$';
  static const String currencyPrefix = 'R\$ ';

  // Date Format
  static const String dateFormat = 'dd/MM/yyyy';

  // Responsive helpers
  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return largePadding; // Tablet/Desktop
    return defaultPadding; // Mobile
  }

  static double getResponsiveIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 100.0; // Tablet/Desktop
    return largeIconSize; // Mobile (80)
  }

  static double getBalanceImageHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.2; // 20% of screen height, max 200, min 120
  }
}

// Color Constants (if you want to add custom colors later)
class AppColors {
  static const Color primaryBlue = Color(0xFF448AFF);
  // Add more custom colors here if needed
}
