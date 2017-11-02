<?php

for ($x=0 ; $x <16 ; $x++) {
    echo "    dw ";

  for ($y=0 ; $y <16 ; $y++) {
    $r= 15-$x;
    $g= (int)($y+$x)/2;
    $b= $y;
    printf("$0%X%X%X", $r,$g,$b);
    if ($y != 15) print ",";
  }
  echo "\n";

}
