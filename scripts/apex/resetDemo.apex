// Destructive only within the exact synthetic lot; requires TF_DemoTools.
// Verify the target before running. The service refuses foreign dependencies.
Savepoint sp = Database.setSavepoint();
try {
    TF_DemoData.reset('TF360-DEMO-V1');
    System.debug(LoggingLevel.INFO, 'TF_DEMO_RESET=SUCCESS; BATCH=TF360-DEMO-V1');
} catch (Exception failure) {
    Database.rollback(sp);
    System.debug(LoggingLevel.ERROR, 'TF_DEMO_RESET=FAILED; TRANSACTION_ROLLED_BACK');
    throw failure;
}
