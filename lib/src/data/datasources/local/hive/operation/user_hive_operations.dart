//domain
import '../../../../../domain/models/user.dart';

//core
import '../core/hive_operations.dart';


/// The class `UserHiveOperation` is a subclass of `HiveDatabaseOperation` specifically designed for performing operations
/// on `User` objects in a Hive database.
class UserHiveOperation extends HiveDatabaseOperation<User> {
  UserHiveOperation({required super.primitiveDatabase});
}