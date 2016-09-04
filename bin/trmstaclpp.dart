library trmstaclpp.bin;

import "package:trmsta/trmsta.dart";

import 'package:args/args.dart';

import "dart:io";

const String name = 'trmstaclpp';
const String version = '0.2.0';

main(List<String> arguments) async {
  ArgParser parser = _createArgsParser();
  ArgResults args;
  try {
    args = parser.parse(arguments);
  } on FormatException catch (e) {
    print(e.message);
    print("");
    _printUsageAndExit(parser, exitCode: 64);
  }

  if(args["help"]) {
    _printHelp(parser);
  }

  if(args["version"]) {
    print("$name version: $version");
    exit(0);
  }

  int summaxbar = int.parse(args["summaxbar"]);

  Downloaded down = await download();
  List<AllSta> tabl = down.ParseAll();
  print("Liczba rowerów na stacjach TRM: "+down.time.toString());
  int sumrow = 0;
  int sumwol = 0;
  int maxlenaddr = 0;
  for(final AllSta infb in tabl) {
    if( infb.data.addr.length > maxlenaddr ){
      maxlenaddr = infb.data.addr.length;
    }
  }
  for(final b in tabl) {
    StringBuffer buffer = new StringBuffer();
    buffer.write(" ");
    buffer.write((b.locrow.stanum+1).toString());
    buffer.write(". ");
    buffer.write(b.locrow.stanum<9?" ":"");
    buffer.write(b.data.addr);
    int olen =b.data.addr.length;
    buffer.write(" "*(maxlenaddr-olen));
    buffer.write(" | ");
    buffer.write("▉"*b.locrow.row.dostrow);
    buffer.write("▒"*b.locrow.row.wolrow);
    buffer.write(" ");
    buffer.write(b.locrow.row.dostrow.toString());
    buffer.write("/");
    buffer.write((b.locrow.row.dostrow+b.locrow.row.wolrow).toString());
    buffer.write(" (");
    buffer.write(b.locrow.row.wolrow.toString());
    buffer.write(" empty)");
    print(buffer.toString());
    sumrow += b.locrow.row.dostrow;
    sumwol += b.locrow.row.wolrow;
  }
  print("—"*100);
  StringBuffer buffer = new StringBuffer();
  buffer.write(" SUMA   | ");
  bool scalingsum = sumrow+sumwol>summaxbar;
  int ourmaxbar = scalingsum?summaxbar:sumrow+sumwol;
  int sumscale = scalingsum?summaxbar/(sumrow+sumwol):1;
  int lproc = sumrow*sumscale;
    buffer.write("▉"*lproc);
    buffer.write("▒"*(ourmaxbar-lproc));
  buffer.write(" ");
  buffer.write(sumrow.toString());
  buffer.write("/");
  buffer.write((sumrow+sumwol).toString());
  buffer.write(" (");
  buffer.write(sumwol.toString());
  buffer.write(") — AVG ");
  buffer.write((sumrow~/tabl.length).toString());
  buffer.write(" (");
  buffer.write((sumwol~/tabl.length).toString());
  buffer.write(") ");
  print(buffer.toString());
  print(" ");
}

ArgParser _createArgsParser() {
  final ArgParser parser = new ArgParser()
  ..addFlag("help",
      abbr: "h", negatable: false, help: "Show command help.")
  ..addFlag("version",
      help: "Display the version for $name.", negatable: false)
  ..addOption("summaxbar", abbr: "s", defaultsTo: "80", help: "Max lenght of the sum bar");
  return parser;
}

void _printHelp(ArgParser parser, {int exitCode: 0}) {
  print("Command-line pretty-printing TRM station info.\n");
  _printUsageAndExit(parser, exitCode: exitCode);
}

void _printUsageAndExit(ArgParser parser, {int exitCode: 0}) {
  print("Usage: trmstaclppb [OPTIONS]\n");
  print(parser.usage);
  exit(exitCode);
}
