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

// Orthagonal keyboard
    number_of_columns = 7;
    keys_per_column = 5;
    row_spacing_top = 5; // todo per col, rename col spa
    row_spacing_bottom = 10; // todo: per col, rename col spa
    spacing_top_bottom = 2; // todo: per row, modulo length
    spacing_left_right = 2; // todo: per col, modulo length
    // todo: leftmost border, rightmost border,
    // add a surrounding border...

module orthagonal_key_row () {
    difference(){
        key_plate_thickness = (switch_mount_height + switch_mount_plate_height);
        plate_height = (keys_per_column * (key_stencil_width + spacing_top_bottom)) + row_spacing_top + row_spacing_bottom;
        
        // Create & position key plate
        translate ([(plate_height/2)-(key_stencil_height/2)-row_spacing_top,0,key_plate_thickness/2])
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
                translate([row * (key_stencil_width + spacing_top_bottom),0,0])
                {
                    switch_stencil();
                }
            }
        }
    };
} // orthagonal_key_row

for(col=[0:number_of_columns-1])
{
    translate([0, col * (key_stencil_width + (spacing_left_right*2)),0])
    {
        orthagonal_key_row();
    }
}