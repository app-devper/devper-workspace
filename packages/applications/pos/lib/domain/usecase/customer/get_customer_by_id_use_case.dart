// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/repositories/customer_repository.dart';

class GetCustomerByIdUseCase extends BaseUseCaseParam<String, Customer> {
  final CustomerRepository customerRepo;

  GetCustomerByIdUseCase({required this.customerRepo});

  @override
  Future<Customer> call(String customerId) => customerRepo.getCustomerById(customerId);
}
