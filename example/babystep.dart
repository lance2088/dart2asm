import "package:dart2asm/def.dart";

four() => 4;

hang() {
  raw("cli");
  jmp(hang);
  four();
}