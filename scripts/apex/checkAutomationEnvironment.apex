Profile actorProfile = [SELECT Name FROM Profile WHERE Id=:UserInfo.getProfileId() WITH USER_MODE];
System.debug(LoggingLevel.INFO,'TF_OPERATOR_ADMIN=' + (actorProfile.Name=='System Administrator'));
System.debug(LoggingLevel.INFO,'TF_ORG_LOCAL_TIME=' + System.now().format('yyyy-MM-dd HH:mm:ss','America/Los_Angeles'));
System.debug(LoggingLevel.INFO,'TF_DEMO_PERMISSION=' + FeatureManagement.checkPermission('TF_DemoTools'));
