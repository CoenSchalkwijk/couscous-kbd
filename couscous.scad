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
    // Lettering
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
    def[col][row][margins][0] + (col < max_col ? findOffsetX(def, row, max_col, col + 1) :0);

function findOffsetY(def, col, max_row, row=0) = 
    def[col][row][margins][1] + (row < max_row ? findOffsetY(def, col, max_row, row + 1) :0);

// Expects an X by Y grid

// Defaults:
u1 = [4,4]; // todo: return to [2,2,2,2]: left bottom right top, will enable u1_5, u2 etc.
// todo: u1_5 (and rotated version) [L] and BCK

_HIDDEN_ = [u1, 0, "", 1];

key_plate_def = [
    /* [
            margins[left, bottom],
            tilt (clockwise, in deg),
            label/tag,
            hidden (1), visible (default:0)
        ]
    */
    [
        /*control keys */
        [u1, 0, "CTRL"],
        [u1, 0, "SHFT"],
        [u1, 0, "`~"],
        [u1, 0, "TAB"],
        [u1, 0, "ESC"],
    ],
    [
        /* Mostly alpha-num #1 */
        [u1, 0, "ALT"],
        [u1, 0, "Z"],
        [u1, 0, "A"],
        [u1, 0, "Q"],
        [u1, 0, "1!"],
    ],
    [
        /* Mostly alpha-num #2 */
        [u1 + [0,5], 0, "-_"],
        [u1, 0, "X"],
        [u1, 0, "S"],
        [u1, 0, "W"],
        [u1, 0, "2@"],
    ],
    [
        /* Mostly alpha-num #3 */
        [u1 + [0,7], 0, "=+"],
        [u1, 0, "C"],
        [u1, 0, "D"],
        [u1, 0, "E"],
        [u1, 0, "3#"],
    ],
    [
        /* Alpha-num #4 */
        _HIDDEN_,
        [u1 + [0,5], 0, "V"],
        [u1, 0, "F"],
        [u1, 0, "R"],
        [u1, 0, "4$"],
    ],
    [
        /* Alpha-num #5 */
        _HIDDEN_,
        [u1 + [0,3], 0, "B"],
        [u1, 0, "G"],
        [u1, 0, "T"],
        [u1, 0, "5%"],
    ],
    [
        /* Special layer keys */
        _HIDDEN_,
        _HIDDEN_,
        _HIDDEN_,
        [u1 + [4,-8], 0, "[\u2193]"], // Layer down, Down arrow
        [u1 + [4,0], 0, "[\u2191]"], // Layer up, Up arrow
    ],
    [
        // Separate row for SPACE, makes for easy placement :)
        [[-43,8], 12, "SPC"],
        _HIDDEN_,
        _HIDDEN_,
        _HIDDEN_,
        _HIDDEN_
    ]
];


thumb_plate_def = [
    [
        // HOME & Temp layer shift
        [u1, 0, "[L]"],  // key is u1_5, but is compensated in next margin? todo: turn this around!
        [u1 + [0,4], 0, "HOME"]
    ],
        [
        /* END & BACKSPACE */
        [u1, 0, "BCK"], // key is u1_5, todo: see above
        [u1 + [0,4], 0, "END"] 
    ],
 ];

 
// Indices
margins = 0;
tilt = 1;
tag = 2;
margin_left = 0;
margin_top = 1;
invisible= 3;

min_x =100;

// Build plate for key plate definition.
module keys_for_plate(def) {
    
    for(col=[0:len(def)-1]) {
        for(row=[0:len(def[col])-1]) {
            
            if (!def[col][row][invisible]) {
                key_margins = def[col][row][margins];
                
                translate([
                    findOffsetX(def, row, col) + (col * switch_width),
                    findOffsetY(def, col, row) + (row * switch_height),
                    0]
                ) { 
                    rotate(-def[col][row][tilt]){
                        switch_stencil(def[col][row][tag]);
                    }
                }
            }
        }
    }
}

function max_x(def, row=0) =
    max(
        findOffsetX(def, row, len(def)-1),
        row<len(def[0])-1 ? max_x(def, row+1):0
    );

function max_y(def, col=0) =
    max(
        findOffsetY(def, col, len(def[0])-1),
        col<len(def)-1 ? max_y(def, col+1):0
    );

module plate(def) {
    cols = len(def);
    rows = len(def[0]);

    max_x = max_x(def);
    max_y = max_y(def);
    
    
    // Please note: 
    // Alignment is done with top element of key stencil!
    // So when no margins applied, the plate is smaller than a full key stencil.
    width = max_x + (cols * switch_width);
    height = max_y + (rows * switch_height);
    
    translate([-switch_width/2, -switch_width/2,-0]){
        square([width, height]);
    }
}

color("red") plate(key_plate_def);
// Draw left hand key plate:
keys_for_plate(key_plate_def);

// Todo: check if translation values can be derived.
translate([101,-1,0]){
    rotate(-25) {
        keys_for_plate(thumb_plate_def);
    }
}

echo("MIN X:", min_x);