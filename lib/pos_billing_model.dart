enum PaymentMethod { cash, kpay, wavePay, split }

class POSCartItem {
  final String id;
  final String title;
  final double priceUSD;
  final double priceMMK;
  int quantity;
  final bool isServiceLabor;

  POSCartItem({
    required this.id,
    required this.title,
    required this.priceUSD,
    required this.priceMMK,
    this.quantity = 1,
    this.isServiceLabor = false,
  });
}

class AIVisionDetectedPart {
  final String partCode;
  final String partName;
  final double detectedPriceUSD;
  final double confidenceScore;

  AIVisionDetectedPart({
    required this.partCode,
    required this.partName,
    required this.detectedPriceUSD,
    required this.confidenceScore,
  });
}

class AIOCRSlipResult {
  final String transactionId;
  final double amountMMK;
  final bool isValid;
  final String provider;

  AIOCRSlipResult({
    required this.transactionId,
    required this.amountMMK,
    required this.isValid,
    required this.provider,
  });
}