<?php

for ($x=0 ; $x <16 ; $x++) {
    echo "    dw ";

    for ($y=0 ; $y <16 ; $y++) {
      switch ($y) {
        case 0:
        case 2:
        case 4:
        case 6:
        case 8:
        case 10:
        case 12:
        case 14:
          $r=$g=$b=0;
          break;
        case 1:
          $r=$x;
          $g=$b=0;
          break;
        case 3:
          $g=$x;
          $r=$b=0;
          break;
        case 5:
          $b=$x;
          $r=$g=0;
          break;
        case 7:
          $r=$g=$x;
          $b=0;
          break;
        case 9:
          $r=$b=$x;
          $g=0;
          break;
        case 11:
          $g=$b=$x;
          $r=0;
          break;
        case 13:
          $r=$g=$b=$x;
          break;
        case 15:
          $r= 15-$x;
          $g=$x;
          $b= 15-(int)($x/2);
          break;
      }
    printf("$0%X%X%X", $r,$g,$b);
    if ($y != 15) print ",";
  }
  echo "\n";

}
