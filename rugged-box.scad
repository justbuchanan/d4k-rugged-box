/*
 * Customizable and Parametric Rugged Storage Box
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Parametric rugged storage box model
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <rugged-box-library.scad>;

INC = 0.001; // tiny increment
INCH = 2.54;

// Dimensions below are of the form `<actual size> + <tolerance>`

// emisar d4k flashlight
total_flashlight_len = 103.1 + 1.8;
flashlight_outer_d = 28 + 0.8;

// 21700 flat top lithium battery
battery_d = 21.4 + 0.6;
battery_h = 70 + 1.0;

gap_between_battery_and_flashlight = 6.5;
cutout_total_width = total_flashlight_len;
cutout_total_len = battery_d + gap_between_battery_and_flashlight + flashlight_outer_d;
margin_btw_cutout_and_walls = 1.5;

misc_box_depth = flashlight_outer_d / 2 + 3;

/* [Dimensions] */
// All units in millimeters

// Interior side-to-side size in millimeters
Width = cutout_total_width + margin_btw_cutout_and_walls*2; // [20:1:300]

// Interior front-to-back size in millimeters
Length = cutout_total_len + margin_btw_cutout_and_walls*2; // [20:1:300]

// Interior bottom height in millimeters
Bottom_Height = misc_box_depth; // [0:1:300]

// Interior top height in millimeters
Top_Height = Bottom_Height; // [0:1:300]

// Interior corner radius in millimeters. Reduces interior storage space.
Corner_Radius = 5; // [0:0.1:20]

// Proportion of Corner Radius to chamfer outer top and bottom edges. Reduces interior storage space.
Edge_Chamfer_Proportion = 0.4; // [0:0.1:1]

/* [Features] */
// Type or shape of seal to use, if desired
Lip_Seal_Type = "wedge"; // [none: None, wedge: Wedge ▽, square: Square □, "filament-1.75mm": 1.75mm Filament ○]

// Make the corners as thick as the box lip
Reinforced_Corners = false;

// Add a front grip to the box top (for boxes with two latches)
Top_Grip = false;

// Add end stops to the hinges on the box bottom
Hinge_End_Stops = false;

// Latch style
Latch_Type = "clip"; // [clip: Clip, draw: Draw]

// Optional handle for sufficiently wide boxes
Handle = false;

// Optional label for sufficiently wide boxes
Label = false;

// Custom text for optional label
Label_Text = "Label";

// Approximate height of text for optional label in millimeters
Label_Text_Size = 10; // [5:0.1:25]

// Include flashlight graphic on the top piece
Include_Graphic = true;

/* [Advanced Size Adjustments] */
// Base wall thickness in millimeters for most of the box
Wall_Thickness = 3.0; // [0.4:0.1:10]

// Thickness in millimeters to add to the wall thickness for the box lip
Lip_Thickness = 3.0; // [0.4:0.1:10]

// Base thickness in millimeters of the support ribs. The latch ribs are this thick, while the hinge and side ribs are twice this thick.
Rib_Width = 5; // [1:0.1:20]

// Latch width in millimeters
Latch_Width = 20; // [5:1:50]

// Distance in millimeters between the latch hinge and catch screws which determines the latch vertical size
Latch_Screw_Separation = 15; // [5:1:40]

// Width in millimeters subtracted from latches for fit
// NOTE: I initially had this at 0.2, but found the fit kind of loose. I tested
// with 0 and it's much better.
Size_Tolerance = 0.0; // [0:0.01:1]

module __end_customizer_options__() { }

// Modules

// part can be "bottom", "top", or "latch"
module flashlight_box(part="bottom") {
    rbox(
        Width,
        Length,
        Bottom_Height,
        Top_Height,
        corner_radius=Corner_Radius,
        edge_chamfer_proportion=Edge_Chamfer_Proportion,
        lip_seal_type=Lip_Seal_Type,
        reinforced_corners=Reinforced_Corners,
        latch_type=Latch_Type,
        top_grip=Top_Grip,
        hinge_end_stops=Hinge_End_Stops,
        handle=Handle,
        label=Label,
        label_text=Label_Text,
        label_text_size=Label_Text_Size
    )
    rbox_size_adjustments(
        wall_thickness=Wall_Thickness,
        lip_thickness=Lip_Thickness,
        rib_width=Rib_Width,
        latch_width=Latch_Width,
        latch_screw_separation=Latch_Screw_Separation,
        size_tolerance=Size_Tolerance
    ) {
        if (part == "bottom") {
            rbox_bottom() {
                difference() {
                    rbox_interior();

                    translate([0, 0, Wall_Thickness+Bottom_Height])
                    cutouts("bottom", $fn=200);
                }
            }
        } else if (part == "top") {
            difference() {
                rbox_top() {
                    difference() {
                        rbox_interior();

                        translate([0, 0, Wall_Thickness+Top_Height])
                        // rotate([180, 0, 0])
                        rotate([0, 180, 0])
                        cutouts("top", $fn=200);
                    }
                }

                if (Include_Graphic) {
                    linear_extrude(0.6)
                    flashlight_graphic();
                }
            }
        } else if (part == "latch") {
            rbox_latch();
        } else {
            assert(false, str("invalid part type: ", part));
        }
    }
}

module cutouts(part="bottom") {
    if (part != "bottom" && part != "top") {
        assert(false, str("invalid part type: ", part));
    }

    x_bottom_cutout_y_dim = flashlight_outer_d + battery_d + gap_between_battery_and_flashlight;

    // center it
    translate([
        -total_flashlight_len/2,
        -x_bottom_cutout_y_dim/2 + flashlight_outer_d/2,
        0
    ]) {
        // flashlight cutout
        rotate([0, 90, 0])
        cylinder(r=flashlight_outer_d/2, h=total_flashlight_len);

        if (part == "top") {
            // cutouts for button and button housing
            // there's a cutout on both sides to allow for the flashlight being placed both ways.
            width_including_button_and_housing = 31.7;
            cutout_r_including_button_housing = width_including_button_and_housing/2 + 1.5;
            // total amount of x length added to the button housing cutout
            button_housing_x_tol = 3.0;
            button_housing_length = 19 + button_housing_x_tol;
            button_housing_x_offset = 8;
            // add a cutout on each side
            for (x = [button_housing_x_offset, total_flashlight_len-button_housing_length-button_housing_x_offset]) {
                translate([x-button_housing_x_tol/2, 0, 0])
                rotate([0, 90, 0])
                cylinder(r=cutout_r_including_button_housing, h=button_housing_length+button_housing_x_tol);
            }
        }

        // battery cutout
        batt_y_offset = flashlight_outer_d/2+ battery_d/2+gap_between_battery_and_flashlight;
        translate([total_flashlight_len - battery_h, batt_y_offset, 0])
        rotate([0, 90, 0])
        cylinder(r=battery_d/2, h=battery_h);

        // misc storage
        misc_box_top_margin = 1;
        misc_box_w = battery_d+9;
        translate([
            0,
            batt_y_offset-battery_d/2,
            -misc_box_depth
        ])
        if (part == "bottom") {
            cube([misc_box_w, battery_d, 40]);
        } else if (part == "top") {
            translate([-0.5, -1, 0])
            cube([misc_box_w+misc_box_top_margin*2, battery_d+misc_box_top_margin*2, misc_box_depth*2]);
        } else {
            assert(false);
        }
    }
}

module preview() {
    flashlight_box("bottom");

    rotate([0,0,180])
    translate([0, -Width+10, 0])
    flashlight_box("top");
}

module thin_square(size, thick, center=false) {
    difference() {
        square(size, center=center);
        tx = center ? [0, 0] : [thick, thick];
        translate(tx)
        square([size[0]-thick*2, size[1]-thick*2], center=center);
    }
}

module thin_circle(outer_r, thick) {
    difference() {
        circle(outer_r);
        circle(outer_r-thick);
    }
}

// 2d image of a flashlight to add to the top of the box
// flashlight parallel with X axis
module flashlight_graphic() {
    th = 2;
    body_len = 45;
    body_w = 15;
    head_w = 20;

    // rays
    ray_len = 20;
    ray_th = 2;
    module ray() {
        translate([10, -ray_th/2, 0])
        square([ray_len, ray_th]);
    }

    translate([-21.5, 0, 0]) {
        // body
        thin_square([body_len, body_w], th, center=true);

        // head
        translate([body_len/2 + head_w/2 - th, 0, 0])
        thin_square([head_w, head_w], th, center=true);

        // power button
        translate([body_len/2 + head_w/2 - th, 0, 0])
        thin_circle(5, 2);

        // light rays
        translate([3 + body_len/2 + head_w/2, 0, 0]) {
            ray();
            rotate([0, 0, 30])
            ray();
            rotate([0, 0, -30])
            ray();
        };
    }
}

// flashlight_graphic();
// preview();
