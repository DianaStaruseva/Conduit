import 'package:conduit/conduit.dart';
import 'myOperation.dart';

class Category extends ManagedObject<_Category> implements _Category {}

class _Category {
  @primaryKey
  int? id;

  @Column(unique: true, indexed: true)
  String? title;
  
  ManagedSet<MyOperation>? postList;
}
