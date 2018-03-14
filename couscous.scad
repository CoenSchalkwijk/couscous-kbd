/* Switch stencil */
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
    number_of_columns = 7; // todo: amount per col with 'mod trick'
    keys_per_column = 5;

    col_margin_top = [5, 5, 10, 10, 10, 10, 10];

    col_spacing_bottom = 10;  // todo: per col, sensible?
    spacing_top_bottom = 2; // todo: per row, modulo length
    spacing_left_right = 2; // todo: per col, modulo length
    // todo: leftmost border, rightmost border,
    // add a surrounding border...


module orthagonal_key_row (top_margin) {
    difference(){
        key_plate_thickness = (switch_mount_height + switch_mount_plate_height);

        // todo: remove usage of max(col_margin_top), should be provided as param.
        plate_height = (keys_per_column * (key_stencil_width + spacing_top_bottom)) + max(col_margin_top) + col_spacing_bottom;

        // Create & position key plate
        translate ([
            (plate_height/2)-(key_stencil_height/2),
            0,
            key_plate_thickness/2
        ])
        {
            cube([
                plate_height,
                key_stencil_width + (spacing_left_right*2),
                switch_mount_height + switch_mount_plate_height
            ], center=true);   
        };
        
        // Build key stencils
        union(){
            for(row=[0:keys_per_column-1]) 
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
    };
} // orthagonal_key_row


for(col=[0:number_of_columns-1])
{
    top_margin = col_margin_top[col % len(col_margin_top)];

    translate([
        0,
        col * (key_stencil_width + (spacing_left_right*2)),
        0
    ])
    {
        orthagonal_key_row(
            top_margin
        );
    }

    // Hm: OpenSCAD does not support/do a = a + 1; kind of assignments.
}
