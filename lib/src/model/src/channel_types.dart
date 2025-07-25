import 'package:vector_math/vector_math_64.dart';

//
// The [ChannelValue] interface specifies the underlying type of an
// animatable channel:
// - Vector2
// - Vector3
// - Quaternion
// - scalar
// and so on.
//
// This is distinct from the channel itself (e.g. the translation channel
// and the scale channel will probably share the same ChannelValue, even though
// they are distinct channels.).
///
abstract class ChannelValue<V> {
  V get value;

  List<num> unwrap();

  ChannelValue<V> interpolate(ChannelValue<V> next, double ratio);

  ChannelValue<V> copyWith(int index, num value);
}

abstract class ChannelValueFactory {
  V create<V extends ChannelValue>(List<num>? values);
  const ChannelValueFactory();
}

class DefaultChannelValueFactory extends ChannelValueFactory {
  const DefaultChannelValueFactory();

  @override
  V create<V extends ChannelValue>(List<num>? values) {
    switch (V) {
      case const (ScalarChannelValue):
        values ??= [0.0];
        return ScalarChannelValue(values[0].toDouble()) as V;
      case const (Vector2ChannelValue):
        values ??= [0.0, 0.0];
        return Vector2ChannelValue(
                Vector2(values[0].toDouble(), values[1].toDouble())) as V;
      case const (Vector3ChannelValue):
        values ??= [0.0, 0.0, 0.0];
        return Vector3ChannelValue(Vector3(values[0].toDouble(),
            values[1].toDouble(), values[2].toDouble())) as V;
      case const (Vector4ChannelValue):
        values ??= [0.0, 0.0, 0.0, 0.0];
        return Vector4ChannelValue(Vector4(
            values[0].toDouble(),
            values[1].toDouble(),
            values[2].toDouble(),
            values[3].toDouble())) as V;
      case const (QuaternionChannelValue):
        values ??= [0.0, 0.0, 0.0, 1.0];
        return QuaternionChannelValue(Quaternion(
            values[0].toDouble(),
            values[1].toDouble(),
            values[2].toDouble(),
            values[3].toDouble())) as V;
      default:
        throw Exception("Unrecognized type $V");
    }
  }
}

class ScalarChannelValue extends ChannelValue<double> {
  @override
  final double value;

  ScalarChannelValue(this.value);

  @override
  ChannelValue<double> interpolate(
    ChannelValue<double> next,
    double ratio,
  ) {
    return ScalarChannelValue(value + (next.value - value) * ratio);
  }

  @override
  List<num> unwrap() {
    return [value];
  }

  @override
  ChannelValue<double> copyWith(int index, num value) {
    return ScalarChannelValue(value.toDouble());
  }
}

class Vector4ChannelValue extends ChannelValue<Vector4> {
  @override
  final Vector4 value;

  Vector4ChannelValue(this.value);

  @override
  factory Vector4ChannelValue.fromUnwrapped(List<num> values) {
    if (values.length != 4)
      throw ArgumentError("Expected 4 values for Vector4");
    return Vector4ChannelValue(Vector4(values[0].toDouble(),
        values[1].toDouble(), values[2].toDouble(), values[3].toDouble()));
  }

  @override
  ChannelValue<Vector4> interpolate(
    ChannelValue<Vector4> next,
    double ratio,
  ) {
    return Vector4ChannelValue(
      value.scaled(1 - ratio) + next.value.scaled(ratio),
    );
  }

  @override
  List<num> unwrap() {
    return value.storage;
  }

  @override
  ChannelValue<Vector4> copyWith(int index, num value) {
    var raw = this.value.storage.sublist(0);
    raw[index] = value.toDouble();
    return Vector4ChannelValue(Vector4.fromFloat64List(raw));
  }
}

class Vector3ChannelValue extends ChannelValue<Vector3> {
  @override
  final Vector3 value;

  Vector3ChannelValue(this.value);

  @override
  factory Vector3ChannelValue.fromUnwrapped(List<num> values) {
    if (values.length != 3)
      throw ArgumentError("Expected 3 values for Vector3");
    return Vector3ChannelValue(Vector3(
        values[0].toDouble(), values[1].toDouble(), values[2].toDouble()));
  }

  @override
  ChannelValue<Vector3> interpolate(
    ChannelValue<Vector3> next,
    double ratio,
  ) {
    return Vector3ChannelValue(
      value.scaled(1 - ratio) + next.value.scaled(ratio),
    );
  }

  @override
  List<num> unwrap() {
    return value.storage;
  }

  @override
  ChannelValue<Vector3> copyWith(int index, num value) {
    var raw = this.value.storage.sublist(0);
    raw[index] = value.toDouble();
    return Vector3ChannelValue(Vector3.fromFloat64List(raw));
  }
}

class Vector2ChannelValue extends ChannelValue<Vector2> {
  @override
  final String label = "VEC2";

  @override
  final Vector2 value;

  Vector2ChannelValue(this.value);

  @override
  factory Vector2ChannelValue.fromUnwrapped(List<num> values) {
    if (values.length != 2)
      throw ArgumentError("Expected 3 values for Vector3");
    return Vector2ChannelValue(
        Vector2(values[0].toDouble(), values[1].toDouble()));
  }

  @override
  ChannelValue<Vector2> interpolate(
    ChannelValue<Vector2> next,
    double ratio,
  ) {
    return Vector2ChannelValue(
      value.scaled(1 - ratio) + next.value.scaled(ratio),
    );
  }

  @override
  List<num> unwrap() {
    return value.storage;
  }

  @override
  ChannelValue<Vector2> copyWith(int index, num value) {
    var raw = this.value.storage.sublist(0);
    raw[index] = value.toDouble();
    return Vector2ChannelValue(Vector2.fromFloat64List(raw));
  }
}

class QuaternionChannelValue extends ChannelValue<Quaternion> {
  @override
  final Quaternion value;

  @override
  final String label = "QUAT";

  QuaternionChannelValue(this.value);

  @override
  factory QuaternionChannelValue.fromUnwrapped(List<num> values) {
    if (values.length != 4) {
      throw ArgumentError("Expected 4 values for Quaternion");
    }
    return QuaternionChannelValue(
      Quaternion(values[0].toDouble(), values[1].toDouble(),
          values[2].toDouble(), values[3].toDouble()),
    );
  }

  @override
  QuaternionChannelValue interpolate(
    ChannelValue<Quaternion> next,
    double ratio,
  ) {
    return QuaternionChannelValue(
      (value.scaled(1 - ratio) + next.value.scaled(ratio)).normalized()
    );
  }

  @override
  List<num> unwrap() {
    return [value.x, value.y, value.z, value.w];
  }

  @override
  ChannelValue<Quaternion> copyWith(int index, num value) {
    var raw = this.value.storage.sublist(0);
    raw[index] = value.toDouble();
    return QuaternionChannelValue(Quaternion.fromFloat64List(raw));
  }
}
