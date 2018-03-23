$fn=100;

// User settings:
    switch_width = 14;
    switch_mount_plate_width = switch_width * 1.07;
    switch_mount_plate_height = 1.5;
    switch_mount_height = 1.5;
    switch_mount_rounding = 0.3;

// Derived values:
key_stencil_width = switch_width+switch_mount_rounding;
key_stencil_height = switch_width+switch_mount_rounding;

module switch_stencil () {
    
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
// ------------------------------
// Orthagonal keyplate
// ------------------------------
    number_of_columns = 7;
    keys_per_column = [5,5,5,5,4,4,2]; //todo: add ammount check, should be same as num_of_col
    col_margin_top = [5, 5, 10, 15, 10, 5, 20]; //todo: add ammount check, should be same as num_of_col

    col_spacing_bottom = 10;  // todo: per col, sensible?
    spacing_top_bottom = 2; // todo: per row, modulo length
    spacing_left_right = 2; // todo: per col, modulo length
    // todo: leftmost border, rightmost border,
    // add a surrounding border...


module orthagonal_key_col (top_margin, keys)
{
    for(row=[0:keys-1])
    {
        // Place key switch stencil with top/bottom spacing
        translate([
            (row * (key_stencil_width + spacing_top_bottom))+ top_margin,
            0,
            0
        ])
        {
            switch_stencil();
        }
    }
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

module keys_plate_left() {
    for(col=[0:number_of_columns-1]) {
        top_margin = col_margin_top[col % len(col_margin_top)];

        translate([
            0,
            col * (key_stencil_width + (spacing_left_right*2)),
            0
        ]) {
            orthagonal_key_col(
                top_margin,
                keys_per_column[col]
            );
        };
    };
}

function calc_col_height(col) =
    (keys_per_column[col] * (key_stencil_height + spacing_top_bottom)) +
    col_margin_top[col] +
    col_spacing_bottom;

function max_col_height(col=0) = max(
    calc_col_height(col),
    (col < number_of_columns-1 ? max_col_height( col + 1) :0)
);


module key_plate() {
    plate_height = max_col_height();
    plate_width = (key_stencil_width + (spacing_left_right*2)) * number_of_columns;
    key_plate_thickness = (switch_mount_height + switch_mount_plate_height);

    difference() {
        // Create & position key plate
        translate ([
            (plate_height/2)-(key_stencil_height/2),
            (plate_width/2)-(key_stencil_width/2)- spacing_left_right,
            key_plate_thickness/2
        ]) {
            cube([
                plate_height,
                plate_width,
                switch_mount_height + switch_mount_plate_height
            ], center=true);

        };
        keys_plate_left();
    };
}

key_plate();
