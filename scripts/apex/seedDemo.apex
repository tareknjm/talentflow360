// Only on the verified TFDev Developer Edition, with TF_DemoAdmin assigned.
Savepoint sp = Database.setSavepoint();
try {
    TF_DemoData.seed();
    System.debug(LoggingLevel.INFO, 'TF_DEMO_SEED=SUCCESS; BATCH=TF360-DEMO-V1');
} catch (Exception failure) {
    Database.rollback(sp);
    System.debug(LoggingLevel.ERROR, 'TF_DEMO_SEED=FAILED; TRANSACTION_ROLLED_BACK');
    throw failure;
}
