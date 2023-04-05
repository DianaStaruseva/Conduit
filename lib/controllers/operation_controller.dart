import 'dart:io';
import 'package:conduit/conduit.dart';

import '../models/category.dart';
import '../models/myOperation.dart';
import '../utils/app_response.dart';
import '../utils/app_util.dart';

class MyOperationController extends ResourceController {
  MyOperationController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getAll({@Bind.query('name') String? name, @Bind.query('count') int? count = 3, @Bind.query('end') int? end = 0}) async {
    
    final query = Query<MyOperation>(context)
      ..fetchLimit=count!
      ..offset=end!;

    if (name != null) {
      query.where((h) => h.name).contains(name, caseSensitive: false);
    }

    final myOperations = await query.fetch();
      

    return Response.ok(myOperations);
  }

  @Operation.get("id")
  Future<Response> getMyOperation(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final myOperation = await context.fetchObjectWithID<MyOperation>(id);
      if (myOperation == null) {
        return AppResponse.ok(message: "Пост не найден");
      }
      if (myOperation.category?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к посту");
      }
      myOperation.backing.removeProperty("author");
      return AppResponse.ok(
          body: myOperation.backing.contents, message: "Успешное создание поста");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка создания поста");
    }
  }

  @Operation.post()
  Future<Response> create(@Bind.body(ignore: ["id"]) MyOperation myOperation) async {
    final query = Query<MyOperation>(context)..values = myOperation;

    final inserted = await query.insert();

    return Response.ok(inserted);
  }

  @Operation.put('id')
  Future<Response> updateMyOperation(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id,
      @Bind.body() MyOperation bodyMyOperation) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final myOperation = await context.fetchObjectWithID<MyOperation>(id);

      if (myOperation == null) {
        return AppResponse.ok(message: "Пост не найден");
      }

      if (myOperation.category?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к посту");
      }
      final qUpdateMyOperation = Query<MyOperation>(context)
        ..where((x) => x.id).equalTo(id)
        ..values.name = bodyMyOperation.name;
      await qUpdateMyOperation.update();
      return AppResponse.ok(message: 'Пост успешно обновлен');
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.delete("id")
  Future<Response> deleteMyOperation(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final myOperation = await context.fetchObjectWithID<MyOperation>(id);
      if (myOperation == null) {
        return AppResponse.ok(message: "MyOperation not found");
      }
      if (myOperation.category?.id != currentAuthorId) {
        return AppResponse.ok(message: "No access to the myOperation");
      }
      final deletemyOperation = Query<MyOperation>(context)..where((x) => x.id).equalTo(id);

      await deletemyOperation.delete();

      return AppResponse.ok(message: "Successful myOperation deletion");
    } catch (error) {
      return AppResponse.serverError(error, message: "MyOperation deletion error");
    }
  }
}
