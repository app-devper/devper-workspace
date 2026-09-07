// Package imports:
import 'package:common/core/usecase/usecase.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/repositories/customer_repository.dart';

class UpdateCustomerByIdUseCase extends BaseUseCaseParam<CustomerUpdateParam, Customer> {
  final CustomerRepository customerRepo;

  UpdateCustomerByIdUseCase({required this.customerRepo});

  @override
  Future<Customer> call(CustomerUpdateParam param) =>
      customerRepo.updateCustomerById(param.customerId, param.param);
}
