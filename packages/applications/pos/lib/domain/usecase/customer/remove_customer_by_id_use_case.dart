// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/repositories/customer_repository.dart';

class RemoveCustomerByIdUseCase extends BaseUseCaseParam<String, Customer> {
  final CustomerRepository customerRepo;

  RemoveCustomerByIdUseCase({required this.customerRepo});

  @override
  Future<Customer> call(String customerId) => customerRepo.removeCustomerById(customerId);
}
