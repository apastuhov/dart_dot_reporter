enum State {
  Success,
  Skipped,
  Failure,
}

class TestModel {
  int id;
  String name;
  String message;
  State state;

  @override
  bool operator ==(dynamic other) {
    if (other is TestModel) {
      return id == other.id &&
          name == other.name &&
          message == other.message &&
          state == other.state;
    }
    return false;
  }

  @override
  String toString() {
    return 'TestModel { $id $state $name $message }';
  }
}
