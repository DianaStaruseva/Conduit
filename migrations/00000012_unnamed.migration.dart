import 'dart:async';
import 'package:conduit_core/conduit_core.dart';   

class Migration12 extends Migration { 
  @override
  Future upgrade() async {
   		database.deleteTable("_Author");
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    