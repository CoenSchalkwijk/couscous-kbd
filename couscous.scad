// ----------------------------
//  OpenSCAD settings
// ----------------------------
$fn=100;

// ----------------------------
//  User settings
// ----------------------------
switch_width = 14;
switch_height = switch_width;
switch_mount_plate_width = switch_width * 1.07;
switch_mount_plate_height = 1.5;
switch_mount_height = 1.5;
switch_mount_rounding = 0.3;
    
// ----------------------------
//  Derived settings
// ----------------------------
key_stencil_width = switch_width+switch_mount_rounding;
key_stencil_height = switch_width+switch_mount_rounding;

module switch_stencil (txt="..") {
    translate([
        -switch_mount_plate_height/.3,
        -switch_mount_plate_height/.5,
        3
    ])
    {
        color("red") text(txt, font="Liberation Mono", size = 3);
    }
    // Bottom
    translate([0,0,switch_mount_plate_height/2])
    {
        minkowski()
        {
            cube ([
                switch_mount_plate_width - switch_mount_rounding,
                switch_mount_plate_width - switch_mount_rounding,
                switch_mount_plate_height/1.99
            ],center=true);
            cylinder(
                r=switch_mount_rounding,
                h=switch_mount_plate_height/2,
                center=true
            );
        }
    };
    
    // Top
    translate([0, 0, switch_mount_plate_height + switch_mount_height/2])
    {
        minkowski()
        {
            cube ([
                switch_width - switch_mount_rounding,
                switch_width - switch_mount_rounding,
                // Minkowski totals height of objects
                switch_mount_height/1.99 
            ],center=true);
            cylinder(
                r=switch_mount_rounding,
                h=switch_mount_height/2,
                center=true
            );
        };
    };
}


// ---------------------
// Screw & hole template
// ---------------------
screw_width = 1.5; // [mm]
screw_height = 4.0; // [mm] todo: base plate height + bottomplate height - some_margin?
screw_head_width = 3; // [mm]
screw_plate_flesh = 1.0; // [mm] minimal leftover height of baseplate to hold screw

screw_hole_width = screw_width - 0.2; // [mm]
screw_holder_height = screw_height - screw_plate_flesh; // [mm] or use bottom plate height?
screw_holder_width = 3; // [mm]

module screw() {
    translate([0,0, screw_height]) {
        cylinder(screw_height, d=screw_head_width, center=true);
    };
    cylinder(screw_height, d=screw_width, center=true);
}

module screw_hole() {
    translate([0,0,screw_holder_height/2]) {
        difference() {
            cylinder(screw_holder_height, d=screw_holder_width, center=true);
            translate([0, 0, screw_plate_flesh/2]) {
                screw();
            };
        };
    };
}

function findOffsetX(def, row, max_col, col=0) = 
    def[col][row][2][0] + (col < max_col ? findOffsetX(def, row, max_col, col + 1) :0);

// Expects an X by Y grid
// todo: mark key as skipable? to support other configurations

key_plate_def = [
    /* [
            x,
            y,
            margins[left, top, right, bottom ],
            tilt (clockwise, in deg),
            label/tag
        ]
    */
    [
        /* First column: function keys */
        [0, 0, [4,4], 0, "F5"],
        [0, 1, [4,4], 0, "F4"],
        [0, 2, [4,4], 0, "F3"],
        [0, 3, [4,4], 0, "F2"],
        [0, 4, [4,4], 0, "F1"], 
    ],
    [
        /* Second column: control keys */
        [1, 0, [4,4], 0, "CTRL"],
        [1, 1, [6,4], 0, "SHFT"],
        [1, 2, [8,4], 0, "`~"],
        [1, 3, [8,4], 0, "TAB"],
        [1, 4, [10,4], 0, "ESC"],
    ],
    [
        /* Third column: mostly alpha-num #1 */
        [2, 0, [4,4], 0, "ALT"],
        [2, 1, [4,4], 0, "Z"],
        [2, 2, [4,4], 0, "A"],
        [2, 3, [4,4], 0, "Q"],
        [2, 4, [4,4], 0, "1!"],
    ],
    [
        /* Fourth column: mostly alpha-num #1 */
        [3, 0, [4,4], 0, "-_"],
        [3, 1, [4,4], 0, "X"],
        [3, 2, [4,4], 0, "S"],
        [3, 3, [4,4], 0, "W"],
        [3, 4, [4,4], 0, "2@"],
    ],
    [
        /* Fifth column: mostly alpha-num #1 */
        [4, 0, [4,4], 0, "=+"],
        [4, 1, [4,4], 0, "C"],
        [4, 2, [4,4], 0, "D"],
        [4, 3, [4,4], 0, "E"],
        [4, 4, [4,4], 0, "3#"],
    ],
    [
        /* Sixth column: mostly alpha-num #1 */
        [5, 0, [4,4], 0, "SPC"],
        [5, 1, [4,4], 0, "V"],
        [5, 2, [4,4], 0, "F"],
        [5, 3, [4,4], 0, "R"],
        [5, 4, [4,4], 0, "4$"],
    ],
    [
        /* Seventh column: mostly alpha-num #1, first thumb ([T]) key*/
        [6, 0, [6,4], 20, "[T]"],
        [6, 1, [4,4], 0, "B"],
        [6, 2, [4,4], 0, "G"],
        [6, 3, [4,4], 0, "T"],
        [6, 4, [4,4], 0, "5%"],
    ],
    [
        /* Eight column: special keys */
        [7, 0, [6,4], 30, "[MU]"],  // Mute 🔇
        [7, 1, [6,4], 30, "[V+]"],
        [7, 2, [6,4], 30, "[V-]"],
        [7, 3, [6,4], 0, "[\u2193]"], // Layer down, Down arrow
        [7, 4, [6,4], 0, "[\u2191]"], // Layer up, Up arrow
    ]
];

margin_left = 0;
margin_top = 1;
margin_right = 2;
margin_bottom = 3;

module keys_for_plate(def) {
    
    for(col=[0:len(def)-1]) {
        for(row=[0:len(def[col])-1]) {
            x_pos = def[col][row][0];
            y_pos = def[col][row][1];

            key_margins = def[col][row][2];
                  
            echo("::", def[col][row][0]);
            translate([
                findOffsetX(def, row, col) + ((x_pos +1) * switch_width),
                (y_pos +1) * (key_margins[margin_top] + switch_height),
                0]) { 
                    rotate(-def[col][row][3]){
                        switch_stencil(def[col][row][4]);
                    }
            }
        }
    }
}

keys_for_plate(key_plate_def);