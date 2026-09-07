// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/repositories/customer_repository.dart';

class CreateCustomerUseCase extends BaseUseCaseParam<CustomerParam, Customer> {
  final CustomerRepository customerRepo;

  CreateCustomerUseCase({required this.customerRepo});

  @override
  Future<Customer> call(CustomerParam param) => customerRepo.createCustomer(param);
}
