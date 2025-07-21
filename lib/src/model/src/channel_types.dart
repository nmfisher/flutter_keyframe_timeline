import 'package:vector_math/vector_math_64.dart';

//
// The [ChannelValueType] interface specifies the underlying type of an
// animatable channel:
// - Vector2
// - Vector3
// - Quaternion
// - scalar
// and so on.
//
// This is distinct from the channel itself (e.g. the translation channel
// and the scale channel will probably share the same ChannelValueType, even though
// they are distinct channels.).
///
sealed class ChannelValueType<V> {
  String get label;

  V get value;

  List<num> unwrap();

  dynamic toJson();

  static V fromJson<V extends ChannelValueType>(dynamic json) {
    switch (V) {
      case const (ScalarChannelValueType):
        return ScalarChannelValueType((json as List<double>).first) as V;
      case const (Vector2ChannelValueType):
        return Vector2ChannelValueType.fromJson(json as List<double>) as V;
      case const (Vector3ChannelValueType):
        return Vector3ChannelValueType.fromJson(json as List<double>) as V;
      case const (QuaternionChannelValueType):
        return QuaternionChannelValueType.fromJson(json as List<double>) as V;
    }
    throw Exception("TODO");
  }

  ChannelValueType<V> interpolate(ChannelValueType<V> next, double ratio);

  static zero<V extends ChannelValueType>() {
    switch (V) {
      case const (ScalarChannelValueType):
        return ScalarChannelValueType(0.0);
      case const (Vector4ChannelValueType):
        return Vector4ChannelValueType(Vector4.zero());
      case const (Vector3ChannelValueType):
        return Vector3ChannelValueType(Vector3.zero());
      case const (Vector2ChannelValueType):
        return Vector2ChannelValueType(Vector2.zero());
      case const (QuaternionChannelValueType):
        return QuaternionChannelValueType(Quaternion.identity());
    }
  }
}

class ScalarChannelValueType extends ChannelValueType<double> {
  @override
  final double value;

  ScalarChannelValueType(this.value);

  @override
  ChannelValueType<double> interpolate(
    ChannelValueType<double> next,
    double ratio,
  ) {
    return ScalarChannelValueType(0.0);
  }

  @override
  String get label => "SCALAR";

  @override
  dynamic toJson() {
    return value;
  }

  @override
  List<num> unwrap() {
    return [value];
  }
}

class Vector4ChannelValueType extends ChannelValueType<Vector4> {
  Vector4 get zero => Vector4.zero();

  @override
  final String label = "VEC4";

  @override
  final Vector4 value;

  Vector4ChannelValueType(this.value);

  @override
  List<double> toJson() {
    return [value.x, value.y, value.z];
  }

  @override
  factory Vector4ChannelValueType.fromJson(List<double> json) {
    if (json.length != 4) throw ArgumentError("Expected 4 values for Vector4");
    return Vector4ChannelValueType(Vector4(json[0], json[1], json[2], json[3]));
  }

  @override
  ChannelValueType<Vector4> interpolate(
    ChannelValueType<Vector4> next,
    double ratio,
  ) {
    return Vector4ChannelValueType(
      value.scaled(1 - ratio) + next.value.scaled(ratio),
    );
  }

  @override
  List<num> unwrap() {
    return value.storage;
  }
}

class Vector3ChannelValueType extends ChannelValueType<Vector3> {
  Vector3 get zero => Vector3.zero();

  @override
  final String label = "VEC3";

  @override
  final Vector3 value;

  Vector3ChannelValueType(this.value);

  @override
  List<double> toJson() {
    return [value.x, value.y, value.z];
  }

  @override
  factory Vector3ChannelValueType.fromJson(List<double> json) {
    if (json.length != 3) throw ArgumentError("Expected 3 values for Vector3");
    return Vector3ChannelValueType(Vector3(json[0], json[1], json[2]));
  }

  @override
  ChannelValueType<Vector3> interpolate(
    ChannelValueType<Vector3> next,
    double ratio,
  ) {
    return Vector3ChannelValueType(
      value.scaled(1 - ratio) + next.value.scaled(ratio),
    );
  }

  @override
  List<num> unwrap() {
    return value.storage;
  }
}

class Vector2ChannelValueType extends ChannelValueType<Vector2> {
  Vector3 get zero => Vector3.zero();

  @override
  final String label = "VEC2";

  @override
  final Vector2 value;

  Vector2ChannelValueType(this.value);

  @override
  List<double> toJson() {
    return [value.x, value.y];
  }

  @override
  factory Vector2ChannelValueType.fromJson(List<double> json) {
    if (json.length != 2) throw ArgumentError("Expected 3 values for Vector3");
    return Vector2ChannelValueType(Vector2(json[0], json[1]));
  }

  @override
  ChannelValueType<Vector2> interpolate(
    ChannelValueType<Vector2> next,
    double ratio,
  ) {
    return Vector2ChannelValueType(
      value.scaled(1 - ratio) + next.value.scaled(ratio),
    );
  }

  @override
  List<num> unwrap() {
    return value.storage;
  }
}

class QuaternionChannelValueType extends ChannelValueType<Quaternion> {
  Quaternion get zero => Quaternion.identity();

  @override
  final Quaternion value;

  final String label = "QUAT";

  QuaternionChannelValueType(this.value);

  @override
  List<double> toJson() {
    return [value.x, value.y, value.z, value.w];
  }

  @override
  factory QuaternionChannelValueType.fromJson(List<double> json) {
    if (json.length != 4) {
      throw ArgumentError("Expected 4 values for Quaternion");
    }
    return QuaternionChannelValueType(
      Quaternion(json[0], json[1], json[2], json[3]),
    );
  }

  @override
  QuaternionChannelValueType interpolate(
    ChannelValueType<Quaternion> next,
    double ratio,
  ) {
    return QuaternionChannelValueType(
      value.scaled(1 - ratio) + next.value.scaled(ratio),
    );
  }

  @override
  List<num> unwrap() {
    return value.storage;
  }
}
