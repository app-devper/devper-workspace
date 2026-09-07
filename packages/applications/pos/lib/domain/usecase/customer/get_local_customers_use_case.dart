// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/repositories/customer_repository.dart';

class GetLocalCustomersUseCase extends BaseUseCase<List<Customer>> {
  final CustomerRepository customerRepo;

  GetLocalCustomersUseCase({required this.customerRepo});

  @override
  Future<List<Customer>> call() => customerRepo.getLocalCustomers();
}
