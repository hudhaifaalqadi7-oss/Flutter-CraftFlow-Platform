class OrderStatuses {
  static const newOrder = 'جديد';
  static const inProgress = 'قيد التنفيذ';
  static const qualityCheck = 'الفحص والجودة';
  static const readyForDelivery = 'جاهز للتسليم';
  static const completed = 'مكتمل';
  static const cancelled = 'ملغي';

  static const all = [
    newOrder,
    inProgress,
    qualityCheck,
    readyForDelivery,
    completed,
    cancelled,
  ];

  static int progress(String status) {
    switch (status) {
      case inProgress:
        return 25;
      case qualityCheck:
        return 50;
      case readyForDelivery:
        return 75;
      case completed:
        return 100;
      default:
        return 0;
    }
  }
}
