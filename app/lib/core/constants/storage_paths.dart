/// Firebase Storage path builders. All paths are tenant-scoped.
class StoragePaths {
  StoragePaths._();

  static String unitPhoto(String tenantId, String unitId, String fileName) =>
      '$tenantId/storageUnits/$unitId/exterior/$fileName';

  static String itemPhoto(String tenantId, String itemId, String fileName) =>
      '$tenantId/items/$itemId/$fileName';

  static String jobPhoto(String tenantId, String jobId, String fileName) =>
      '$tenantId/jobs/$jobId/driver-photos/$fileName';

  static String jobSignature(String tenantId, String jobId) =>
      '$tenantId/jobs/$jobId/signature.png';

  static String driverProfile(String tenantId, String uid) =>
      '$tenantId/drivers/$uid/profile.jpg';

  static String issuePhoto(String tenantId, String reportId, String fileName) =>
      '$tenantId/issueReports/$reportId/$fileName';
}
