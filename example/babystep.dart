import "package:dart2asm/def.dart" as asm;
export "package:dart2asm/def.dart";

four() => 4;

hang() {
  asm.raw("cli");
  asm.jmp(hang);
}