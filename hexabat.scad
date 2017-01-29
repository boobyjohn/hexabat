

batterylength = 65; // length of batteries
bmsheight = 13; // height of bms including insulation

battlength = batterylength + bmsheight;
capheight = 1;
plateheight = 1;

length = battlength + 2 * capheight + plateheight;

battdia = 18.5;

internalspacing = 2;
externalspacing = 4;
topbottomspacing = internalspacing;

boltdia = 8.5;
nutdia = 11.5;
side_bolt_dia = 7;

heightoffset = sqrt(pow(battdia, 2) - pow(battdia / 2, 2));

draw_top_bars = 1;

draw_left_module = 1;
draw_center_module = 1;
draw_right_module = 1;

space_between_modules = 0;

draw_side_plate = 0;


module triangle() {
     translate([battdia / 2 - battdia * 2, battdia / 2 -  heightoffset * 3 - battdia]) {
          for (i = [0:3])
               translate([battdia * i, 0])
                    circle(d=battdia);
          for (i = [0:2])
               translate([battdia * i + battdia/2, heightoffset])
                    circle(d=battdia);
          for (i = [0:1])
               translate([battdia * i + battdia, heightoffset * 2])
                    circle(d=battdia);
          translate([battdia * 1.5, heightoffset * 3])
               circle(d=battdia);
     }
}

module hollow_triangle() {
     union() {
          triangle();
          hull()
               offset(r=(-battdia / 4))
               triangle();
     }
}

module enclosing_triangle() {
     triangleheight = heightoffset * 3 + battdia;
     
     offset= 7;
     offset2 = sqrt(pow(battdia, 2) - pow(battdia / 2, 2));

     polygon([[0, offset2 - 7],
                   [-battdia * 2 - offset, -triangleheight],
                   [battdia * 2 + offset, -triangleheight]]);

}

module bolthole() {
     difference() {
          circle(d=boltdia + externalspacing * 4, $fn=6);
          
     }
}

module triangle_frame() {
     difference() {
          offset(r=externalspacing)
               enclosing_triangle();
          hollow_triangle();
          
     }
}

module triangle_frame_horizontal() {
     difference() {
          hull()
          offset(r=externalspacing)
               hollow_triangle();
          hollow_triangle();
          
     }
}


triangleoffset = -battdia / 2 - internalspacing;

module hexabatteries(elems) {
     union(){
          for (i = elems)
               rotate([0, 0, i * 60])
                    translate([0, triangleoffset])
                    hollow_triangle();
          circle(d=boltdia);
     }
}

module hexabat(elems, usehull) {
     difference() {
          union() {
               for (i = elems)
                    rotate([0, 0, i * 60])
                         translate([0, triangleoffset])
                         if (usehull == 1)
                              triangle_frame();
                         else
                              triangle_frame_horizontal();
               bolthole();
          }
          union()
               for (i = elems)
                    rotate([0, 0, i * 60])
                         translate([0, triangleoffset])
                         hollow_triangle();
          if (draw_side_plate == 0) {
               circle(d=nutdia, $fn=6);
          } else {
               circle(d=side_bolt_dia, $fn=60);
          }
     }
}

module horizontal_bolts() {
     rotate([0,90,0])
          linear_extrude(battdia * 4 + externalspacing * 2 + 2 * internalspacing, center=true) {
          translate([0, -boltdia/2 + (externalspacing - internalspacing)]) 
               intersection() {
               polygon([
                            [-100, boltdia / 2 - externalspacing + internalspacing],
                            [100, boltdia / 2 - externalspacing + internalspacing],
                            [100, -boltdia / 2 * sqrt(1) - internalspacing * 2],
                            [-100, -boltdia / 2 * sqrt(1) - internalspacing * 2]
                            ]);

               difference() {
                    translate([0, boltdia / 2])
                         circle(d=boltdia + externalspacing * 4 + 1 -1/4 + 1/8 , $fn=40);
                    circle(d=boltdia  * sqrt(1), $fn=40);
               }
          }
     }
}


module topbottombars() {
     if (draw_top_bars == 1) {
          mirror([0,1,0]) {
               translate([0, -(3 * heightoffset + battdia - triangleoffset) - externalspacing, (boltdia + externalspacing)])
                    horizontal_bolts();
               translate([0, -(3 * heightoffset + battdia - triangleoffset) - externalspacing, battlength - (boltdia + externalspacing)])
                    horizontal_bolts();
          }
          translate([0, -(3 * heightoffset + battdia - triangleoffset) - externalspacing, (boltdia + externalspacing)])
               horizontal_bolts();
          translate([0, -(3 * heightoffset + battdia - triangleoffset) - externalspacing, battlength - (boltdia + externalspacing)])
               horizontal_bolts();
     }          
}

if (draw_side_plate == 1) {
     !union() {
          difference() {
               union() {
                    intersection() {
                         hexabat([0:5], 1);
                         polygon([
                                      [-100, 100],
                                      [4 * battdia, 100],
                                      [4 * battdia, -100],
                                      [-100, -100],
                                      ]);
                    }
                    hexabat([0:5], 0);
               }
               for (i = [-1, 1])
                    translate([-2 * battdia - externalspacing - battdia / 2 - internalspacing,
                               (heightoffset * 3 + battdia + battdia/2 + externalspacing + externalspacing) * i])
                         square(battdia, center=true);
          }

          translate([4 * battdia + battdia + 1.5 * externalspacing - (1/4 + 1/16 + 1/32 - space_between_modules), 0]) {
               hexabat([0,3], 1);
          }
     
          translate([1 * (9 * battdia + battdia + 3 * externalspacing) - (1/4 + 1/16 + 1/32 - space_between_modules) * 2, 0]) {
               mirror() {
                    difference() {
                         union() {
                              intersection() {
                                   hexabat([0:5], 1);
                                   polygon([
                                                [-100, 100],
                                                [4 * battdia, 100],
                                                [4 * battdia, -100],
                                                [-100, -100],
                                                ]);
                              }
                              hexabat([0:5], 0);
                         }
                         for (i = [-1, 1])
                              translate([-2 * battdia - externalspacing - battdia /2 - internalspacing
                                         , (heightoffset * 3 + battdia + battdia/2 + externalspacing + internalspacing * 2) * i])
                                   square(battdia, center=true);
                    }
               }
          }
     }
}

difference() {

     union() {
          if (draw_left_module == 1) {
               union() {
                    topbottombars();          
                    linear_extrude(battlength) {
                         difference() {
                              union() {
                                   intersection() {
                                        hexabat([0:5], 1);
                                        polygon([
                                                     [-100, 100],
                                                     [4 * battdia, 100],
                                                     [4 * battdia, -100],
                                                     [-100, -100],
                                                     ]);
                                   }
                                   hexabat([0:5], 0);
                              }
                              for (i = [-1, 1])
                                   translate([-2 * battdia - externalspacing - battdia / 2 - internalspacing,
                                              (heightoffset * 3 + battdia + battdia/2 + externalspacing + externalspacing) * i])
                                        square(battdia, center=true);
                         }
                    }
               }               
          }

          if (draw_right_module == 1) {
               translate([1 * (9 * battdia + battdia + 3 * externalspacing) - (1/4 + 1/16 + 1/32 - space_between_modules) * 2, 0]) {
                    union() {
                         topbottombars();
                         linear_extrude(battlength) {
                              mirror() {
                                   difference() {
                                        union() {
                                             intersection() {
                                                  hexabat([0:5], 1);
                                                  polygon([
                                                               [-100, 100],
                                                               [4 * battdia, 100],
                                                               [4 * battdia, -100],
                                                               [-100, -100],
                                                               ]);
                                             }
                                             hexabat([0:5], 0);
                                        }
                                        for (i = [-1, 1])
                                             translate([-2 * battdia - externalspacing - battdia /2 - internalspacing
                                                        , (heightoffset * 3 + battdia + battdia/2 + externalspacing + internalspacing * 2) * i])
                                                  square(battdia, center=true);
                                   }
                              }
                         }
                    }
               }
          }

          if (draw_center_module == 1) {          
               translate([4 * battdia + battdia + 1.5 * externalspacing - (1/4 + 1/16 + 1/32 - space_between_modules), 0]) {
                    union() {
                         topbottombars();
                         linear_extrude(battlength) {
                              hexabat([0,3], 1);
                         }
                    }
               }
          }

     }

     if (draw_top_bars == 1) {
          translate([0, 3 * heightoffset + battdia - triangleoffset + boltdia / 2 + internalspacing, (boltdia + externalspacing)])
               rotate([0,90,0])
               cylinder(r=boltdia/2 * sqrt(1), h=1000, center=true, $fn=40);
     
          translate([0, 3 * heightoffset + battdia - triangleoffset + boltdia / 2 + internalspacing, battlength - (boltdia + externalspacing)])
               rotate([0,90,0])
               cylinder(r=boltdia/2 * sqrt(1), h=1000, center=true, $fn=40);

          translate([0, -(3 * heightoffset + battdia - triangleoffset + boltdia / 2 + internalspacing), (boltdia + externalspacing)])
               rotate([0,90,0])
               cylinder(r=boltdia/2 * sqrt(1), h=1000, center=true, $fn=40);
     
          translate([0, -(3 * heightoffset + battdia - triangleoffset + boltdia / 2 + internalspacing), battlength - (boltdia + externalspacing)])
               rotate([0,90,0])
               cylinder(r=boltdia/2 * sqrt(1), h=1000, center=true, $fn=40);
     }

     if (bmsheight > 0) {
          linear_extrude(bmsheight) {
               difference() {
                    offset(r=-externalspacing - internalspacing) {
                         hull() {
                              hexabat([0:5], 0);
                              translate([1 * (9 * battdia + battdia + 3 * externalspacing) - (1/4 + 1/16 + 1/32 - space_between_modules) * 2, 0]) {
                                   hexabat([0:5], 0);
                              }
                         }
                    }
               
                    /*
                      hull(){
                      bolthole();
                      }

                      translate([1 * (9 * battdia + battdia + 3 * externalspacing), 0]) {
                      hull(){
                      bolthole();
                      }
                      }

                      translate([4 * battdia + battdia + 1.5 * externalspacing, 0]) {
                      hull(){
                      bolthole();
                      }
                      }
                    */
               }
          }
     }
}


