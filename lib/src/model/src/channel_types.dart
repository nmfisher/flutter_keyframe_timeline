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
abstract class ChannelValueType<V> {
  String get label;

  V get value;

  List<num> unwrap();

  ChannelValueType<V> interpolate(ChannelValueType<V> next, double ratio);
 
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
    return ScalarChannelValueType(value + (next.value - value) * ratio);
  }

  @override
  String get label => "SCALAR";


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
  factory Vector4ChannelValueType.fromUnwrapped(List<num> values) {
    if (values.length != 4) throw ArgumentError("Expected 4 values for Vector4");
    return Vector4ChannelValueType(Vector4(values[0].toDouble(), values[1].toDouble(), values[2].toDouble(), values[3].toDouble()));
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
  factory Vector3ChannelValueType.fromUnwrapped(List<num> values) {
    if (values.length != 3) throw ArgumentError("Expected 3 values for Vector3");
    return Vector3ChannelValueType(Vector3(values[0].toDouble(), values[1].toDouble(), values[2].toDouble()));
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
  Vector2 get zero => Vector2.zero();

  @override
  final String label = "VEC2";

  @override
  final Vector2 value;

  Vector2ChannelValueType(this.value);


  @override
  factory Vector2ChannelValueType.fromUnwrapped(List<num> values) {
    if (values.length != 2) throw ArgumentError("Expected 3 values for Vector3");
    return Vector2ChannelValueType(Vector2(values[0].toDouble(), values[1].toDouble()));
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

  @override
  final String label = "QUAT";

  QuaternionChannelValueType(this.value);

  @override
  factory QuaternionChannelValueType.fromUnwrapped(List<num> values) {
    if (values.length != 4) {
      throw ArgumentError("Expected 4 values for Quaternion");
    }
    return QuaternionChannelValueType(
      Quaternion(values[0].toDouble(), values[1].toDouble(), values[2].toDouble(), values[3].toDouble()),
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
    return [value.x, value.y, value.z, value.w];
  }


}
