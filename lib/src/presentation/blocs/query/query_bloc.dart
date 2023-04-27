import 'package:flutter_bloc/flutter_bloc.dart';

//domain
import '../../../domain/repositories/database_repository.dart';

part 'query_event.dart';
part 'query_state.dart';

class QueryBloc extends Bloc<QueryEvent, QueryState> {
  final DatabaseRepository databaseRepository;

  QueryBloc({
    required this.databaseRepository,
  }) : super(QueryInitial());


}
