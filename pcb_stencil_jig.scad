cut_delta = 0.01;
$fa = 1;
$fs = 0.5;

// keep untouched as this will affect also to the positioning 4 corner holes
// that are in container box, lidboard and stencil liftboard.
const_courner_hole_size	= 12.3;

module pcb_board(pcb_size_x, pcb_size_y, pcb_size_z) {
    linear_extrude(pcb_size_z)
        square([pcb_size_x, pcb_size_y]);
}

module pcb_board_centered(pcb_size_x,
                        pcb_size_y,
                        pcb_size_z,
                        wasteboard_size_x,
                        wasteboard_size_y,
                        wasteboard_size_z) {
    pcb_start_x = (wasteboard_size_x - pcb_size_x) / 2;
    pcb_start_y = (wasteboard_size_y - pcb_size_y) / 2;
    pcb_start_z = wasteboard_size_z - pcb_size_z - cut_delta;
    
    translate([pcb_start_x, pcb_start_y, pcb_start_z ]) {
        pcb_board(pcb_size_x, pcb_size_y, pcb_size_z + 2 * cut_delta);
    }
}

module pcb_holder_holes(box_size_x,
				box_size_y,
				pcb_holder_size_x,
				pcb_holder_size_y,
				box_clean_margin_x,
				box_clean_margin_y,
				hole_diameter,
				hole_size_z,
				hole_offset) {
    hole_area_width = pcb_holder_size_x - 2 * box_clean_margin_x;
    hole_area_height = pcb_holder_size_y - 2 * box_clean_margin_y;
    hole_count_x = floor(hole_area_width / hole_offset) + 1;
    hole_count_y = floor(hole_area_height / hole_offset) + 1;
        
    start_x = ((box_size_x - pcb_holder_size_x) / 2) + (pcb_holder_size_x - (hole_count_x - 0) * hole_offset) / 2;
    start_y = ((box_size_y - pcb_holder_size_y) / 2) + (pcb_holder_size_y - (hole_count_y - 0) * hole_offset) / 2;
    echo(box_size_x=box_size_x);
    echo(pcb_holder_size_x=pcb_holder_size_x);
    echo(hole_diameter=hole_diameter);
    echo(start_x=start_x);
    echo(start_y=start_y);
    echo(hole_count_x=hole_count_x);
    echo(hole_count_y=hole_count_y);
    echo(box_clean_margin_x=box_clean_margin_x);
    echo(box_clean_margin_y=box_clean_margin_y);
    echo(hole_offset=hole_offset);
    for(indx_x = [0:hole_count_x]) {
        center_x = start_x + indx_x * hole_offset;
        //echo(indx_x=indx_x);
        echo(center_x=center_x);
        for(indx_y = [0:hole_count_y]) {
            center_y = start_y + indx_y * hole_offset;
			//echo(center_y=center_y);
			translate([center_x, center_y, -1 * cut_delta])
			cylinder(d = hole_diameter, h = hole_size_z + 2 * cut_delta);
		}
    }
}

const_corner_hole_margin_hack = 19;

module margin_holes(box_size_x,
				box_size_y,
				box_clean_margin_x,
				box_clean_margin_y,
				hole_diameter,
				hole_size_z,
				hole_offset) {
    hole_area_width = box_size_x - 2 * box_clean_margin_x;
    hole_area_height = box_size_y - 2 * box_clean_margin_y;
    hole_count_x = floor(hole_area_width / hole_offset);
    hole_count_y = floor(hole_area_height / hole_offset);
    start_x = (box_size_x - (hole_count_x - 1) * hole_offset) / 2;
    start_y = (box_size_y - (hole_count_y - 1) * hole_offset) / 2;
    echo(box_size_x=box_size_x);
    echo(hole_diameter=hole_diameter);
    echo(start_x=start_x);
    echo(start_y=start_y);
    echo(hole_count_x=hole_count_x);
    echo(hole_count_y=hole_count_y);
    echo(box_clean_margin_x=box_clean_margin_x);

    for(indx_x = [0:hole_count_x - 1]) {
        center_x = start_x + indx_x * hole_offset;
        center_y = box_clean_margin_y;
        //echo(center_x=center_x)
        translate([center_x, center_y, -1 * cut_delta])
        cylinder(d = hole_diameter, h = hole_size_z + 2 * cut_delta);
    }
    for(indx_x = [0:hole_count_x]) {
        center_x = (start_x / 2) + (hole_offset / 2) + indx_x * hole_offset;
        center_y = box_clean_margin_y / 2;
        //echo(center_x=center_x)
        // hack to prevent the hole to come too close to corner hole
        // (at least on 122x122 board size case)
        if (center_x > box_size_x - const_corner_hole_margin_hack) {
            translate([box_size_x - const_corner_hole_margin_hack,
                        center_y,
                        -1 * cut_delta])
            cylinder(d = hole_diameter, h = hole_size_z + 2 * cut_delta);
        }
        else {
            if (center_x < const_corner_hole_margin_hack) {
                translate([const_corner_hole_margin_hack,
                        center_y,
                        -1 * cut_delta])
                cylinder(d = hole_diameter,
                        h = hole_size_z + 2 * cut_delta);
            }
            else {
                translate([center_x,
                        center_y,
                        -1 * cut_delta])
                cylinder(d = hole_diameter,
                        h = hole_size_z + 2 * cut_delta);
            }
        }
    }
    //echo(hole_count_x=hole_count_x);
    //echo(box_clean_margin_x=box_clean_margin_x);
    //echo(box_clean_margin_y=box_clean_margin_y);
    for(indx_x = [0:hole_count_x - 1]) {
        center_x = start_x + indx_x * hole_offset;
        center_y = box_size_y - box_clean_margin_y;
        translate([center_x, center_y, -1 * cut_delta])
        cylinder(d = hole_diameter, h = hole_size_z + 2 * cut_delta);
    }
    for(indx_x = [0:hole_count_x]) {
        center_x = (start_x / 2) + (hole_offset / 2) + indx_x * hole_offset;
        center_y = box_size_y - (box_clean_margin_y / 2);
        if (center_x > box_size_x - const_corner_hole_margin_hack) {
            translate([box_size_x - const_corner_hole_margin_hack,
                    center_y, -1 * cut_delta])
            cylinder(d = hole_diameter, h = hole_size_z + 2 * cut_delta);
        }
        else {
            if (center_x < const_corner_hole_margin_hack) {
                translate([const_corner_hole_margin_hack,
                        center_y,
                        -1 * cut_delta])
                cylinder(d = hole_diameter,
                        h = hole_size_z + 2 * cut_delta);
            }
            else {
                translate([center_x,
                            center_y,
                            -1 * cut_delta])
                cylinder(d = hole_diameter,
                        h = hole_size_z + 2 * cut_delta);
            }
        }
    }
    for(indx_y = [0:hole_count_y - 1]) {
        center_x = box_clean_margin_x;
        center_y = start_y + indx_y * hole_offset;
        translate([center_x, center_y, -1 * cut_delta])
        cylinder(d = hole_diameter, h = hole_size_z + 2 * cut_delta);
    }
    for(indx_y = [0:hole_count_y]) {
        center_x = box_clean_margin_x / 2;
        center_y = (start_y / 2) + (hole_offset / 2) + indx_y * hole_offset;
        echo(my_center_y=center_y);
        echo(box_size_x=box_size_x);
        if (center_y > box_size_y - const_corner_hole_margin_hack) {
            translate([center_x, box_size_y - const_corner_hole_margin_hack,
                        -1 * cut_delta])
            cylinder(d = hole_diameter, h = hole_size_z + 2 * cut_delta);
        }
        else {
            if (center_y < const_corner_hole_margin_hack) {
                translate([center_x,
                        const_corner_hole_margin_hack,
                        -1 * cut_delta])
                cylinder(d = hole_diameter, h = hole_size_z + 2 * cut_delta);
            }
            else {
                translate([center_x, center_y, -1 * cut_delta])
                cylinder(d = hole_diameter, h = hole_size_z + 2 * cut_delta);
            }
        }
    }
    for(indx_y = [0:hole_count_y - 1]) {
        center_x = box_size_x - box_clean_margin_x;
        center_y = start_y + indx_y * hole_offset;
        translate([center_x, center_y, -1 * cut_delta])
        cylinder(d = hole_diameter, h = hole_size_z + 2 * cut_delta);
    }
    for(indx_y = [0:hole_count_y]) {
        center_x = box_size_x - (box_clean_margin_x) / 2;
        center_y = (start_y / 2) + (hole_offset / 2) + indx_y * hole_offset;
        if (center_y > box_size_y - const_corner_hole_margin_hack) {
            translate([center_x,
                    box_size_y - const_corner_hole_margin_hack,
                    -1 * cut_delta])
            cylinder(d = hole_diameter, h = hole_size_z + 2 * cut_delta);
        }
        else {
            if (center_y < const_corner_hole_margin_hack) {
                translate([center_x,
                        center_y,
                        -1 * cut_delta])
                cylinder(d = hole_diameter, h = hole_size_z + 2 * cut_delta);
            }
            else {
                translate([center_x,
                        center_y,
                        -1 * cut_delta])
                cylinder(d = hole_diameter,
                        h = hole_size_z + 2 * cut_delta);
            }
        }
    }
    //center_x = box_size_x - (box_clean_margin_x) / 2;
    //center_y = 3 * start_y / 4;
    //translate([center_x, center_y, -1 * cut_delta])
    //cylinder(d = hole_diameter, h = hole_size_z + cut_delta);
}

module create_four_corner_cylinders(hole_center,
                                hole_diameter,
                                hole_height,
                                board_size) {
    echo(hole_center=hole_center);
    echo(hole_diameter=hole_diameter);
    echo(hole_height=hole_height);
    translate([hole_center,
               hole_center,
               -2 *cut_delta]) {
        cylinder(d = hole_diameter, h = hole_height + 2 * cut_delta);
    }
    translate([board_size - hole_center,
            hole_center,
            -2 * cut_delta]) {
        cylinder(d = hole_diameter, h = hole_height + 2 * cut_delta);
    }
    translate([hole_center,
            board_size - hole_center,
            -2 * cut_delta]) {
        cylinder(d = hole_diameter, h = hole_height + 2 * cut_delta);
    }
    translate([board_size - hole_center,
            board_size - hole_center,
            -2 * cut_delta]) {
        cylinder(d = hole_diameter, h = hole_height + 2 * cut_delta);
    }
}

/*
use ideal_cylinder_diameter as a help for finding the location where cylinder is placed.
Actual cylinder itself can be different size in cylinder_diameter parameter.
*/
module create_corner_cylinders(wall_end_x,
                            board_border_margin,
                            ideal_cylinder_diameter,
                            cylinder_diameter,
                            cylinder_height,
                            board_size) {
    cylinder_radius = const_courner_hole_size / 2;

    cylinder_center = wall_end_x + board_border_margin + cylinder_radius;
    echo(wall_end_x=wall_end_x);
    echo(board_border_margin=board_border_margin);
    echo(cylinder_radius=cylinder_radius);
    echo(cylinder_center=cylinder_center);

    create_four_corner_cylinders(cylinder_center,
                                cylinder_diameter,
                                cylinder_height,
                                board_size);
}

module rounded_box(param_x, param_y, param_z, param_r) {
    echo(param_x=param_x);
    echo(param_y=param_y);
    echo(param_z=param_z);
    echo(param_r=param_r);
    //hull() 
    //cylinder(x = param_x / 2, y  = param_y / 2, r=param_r, h=param_z);
    hull() {
        translate([param_r, param_r, 0])
            cylinder(r = param_r, h = param_z);
        translate([param_x - param_r, param_r, 0])
            cylinder(r = param_r, h = param_z);
        translate([param_r, param_y - param_r, 0])
            cylinder(r = param_r, h = param_z);
        translate([param_x - param_r, param_y - param_r, 0])
            cylinder(r = param_r, h = param_z);
    }
}

module wasteboard_frame(lidboard_size_x,
                        lidboard_size_y,
                        lidboard_size_z,
                        corner_round_d) {
    rounded_box(lidboard_size_x,
                lidboard_size_y,
                lidboard_size_z,
                corner_round_d);
}

module pcb_stencil_liftboard_frame(lidboard_size_x,
        lidboard_size_y,
        lidboard_size_z,
        corner_round_d,
        wall_end_x,
        lift_hole_margin,
        lift_hole_diameter,
        cylinder_diameter,
        cylinder_height,
        lidboard_size_x) {
    wasteboard_frame(lidboard_size_x,
                    lidboard_size_y,
                    lidboard_size_z,
                    corner_round_d);
    // add 4 cylinder legs, visible height outside 2.5mm, r=6.15
    translate([0, 0, cut_delta]) {
        create_corner_cylinders(wall_end_x,
                        lift_hole_margin,
                        lift_hole_diameter,
                        cylinder_diameter,
                        cylinder_height - cut_delta,
                        lidboard_size_x);
    }
}

module pcb_lidboard_frame(lidboard_size_x,
                    lidboard_size_y,
                    lidboard_size_z,
                    corner_round_d,
                    wall_margin,
                    wall_width,
                    wall_height) {
    wasteboard_frame(lidboard_size_x,
                     lidboard_size_y,
                     lidboard_size_z,
                     corner_round_d);
    wall_board_size_x = lidboard_size_x - 2 * wall_margin;
    wall_board_size_y = lidboard_size_y - 2 * wall_margin;
    wall_board_cut_size_x = wall_board_size_x - 2 * wall_width;
    wall_board_cut_size_y = wall_board_size_y - 2 * wall_width;

    difference() {
        translate([wall_margin,
                wall_margin,
                lidboard_size_z - cut_delta]) {
            rounded_box(wall_board_size_x,
                        wall_board_size_y,
                        wall_height + cut_delta,
                        corner_round_d);
        }
        translate([wall_margin + wall_width,
                wall_margin + wall_width, lidboard_size_z - 2 * cut_delta]) {
            rounded_box(wall_board_cut_size_x,
                        wall_board_cut_size_y,
                        wall_height + 3 * cut_delta,
                        corner_round_d);
        }
    }
}

module pcb_lidboard(lidboard_size_x,
				lidboard_size_y,
				lidboard_size_z,
				wasteboard_corner_round_d,
                pcb_holder_hole_positioning_width_x,
                pcb_holder_hole_positioning_width_y,
				wall_margin,
				wall_width,
				wall_height,
				lift_hole_margin,
				lift_hole_diameter,
				stencil_lifter_hole_diameter,
				stencil_lifter_hole_size_z,
				stencil_lifter_hole_offset,
				pcb_holder_hole_offset,
				pcb_holder_size_x,
				pcb_holder_size_y,
				pcb_holder_hole_marginal,
                lift_hole_fitting_marginal) {
    difference() {
        pcb_lidboard_frame(lidboard_size_x,
                        lidboard_size_y,
                        lidboard_size_z,
                        wasteboard_corner_round_d,
                        wall_margin,
                        wall_width, wall_height);
        wall_end_x = wall_margin + wall_width;
        echo(pcb_holder_hole_marginal=pcb_holder_hole_marginal);
        /*
            calculate hole_center by using ideal 12.3 mm value 
            but add tolerance by making little larger (add 0.2mm to diameter)
        */
        create_corner_cylinders(wall_end_x,
                            lift_hole_margin,
                            lift_hole_diameter,
                            lift_hole_diameter + lift_hole_fitting_marginal,
                            lidboard_size_z + 2 * cut_delta,
                            lidboard_size_x);
        pcb_holder_holes(lidboard_size_x,
					lidboard_size_y,
					pcb_holder_hole_positioning_width_x,
					pcb_holder_hole_positioning_width_y,
					pcb_holder_hole_marginal,
					pcb_holder_hole_marginal,
					stencil_lifter_hole_diameter,
					stencil_lifter_hole_size_z,
					pcb_holder_hole_offset);
        margin_holes(lidboard_size_x,
					lidboard_size_y,
					stencil_lifter_hole_offset,
					stencil_lifter_hole_offset,
					stencil_lifter_hole_diameter,
					stencil_lifter_hole_size_z,
					stencil_lifter_hole_offset);
    }
}

module pcb_stencil_liftboard(lidboard_size_x,
							lidboard_size_y,
							lidboard_size_z,
							wasteboard_corner_round_d,
                            pcb_holder_hole_positioning_width_x,
                            pcb_holder_hole_positioning_width_y,
							wall_margin,
							wall_width,
							lift_hole_margin,
							lift_hole_diameter,
							screw_head_hole_diameter,
							screw_head_hole_height,
							screw_body_hole_diameter,
							screw_body_hole_height,
							stencil_lifter_hole_diameter,
							stencil_lifter_hole_offset,
							pcb_holder_hole_offset,
							pcb_holder_size_x,
							pcb_holder_size_y,
							pcb_holder_hole_marginal,
							pcb_board_fitting_marginal,
                            lift_hole_fitting_marginal) {
    wall_end_x = wall_margin + wall_width;
    margin_x = (lidboard_size_x - pcb_holder_size_x) / 2;
    margin_y = (lidboard_size_y - pcb_holder_size_y) / 2;
    difference() {
       pcb_stencil_liftboard_frame(lidboard_size_x,
                            lidboard_size_y,
                            lidboard_size_z,
                            wasteboard_corner_round_d,
                            wall_end_x,
                            lift_hole_margin,
                            lift_hole_diameter,
                            lift_hole_diameter - lift_hole_fitting_marginal,
                            screw_body_hole_height,
                            lidboard_size_x);
        pcb_holder_holes(lidboard_size_x,
						lidboard_size_y,
						pcb_holder_hole_positioning_width_x,
						pcb_holder_hole_positioning_width_y,
						pcb_holder_hole_marginal,
						pcb_holder_hole_marginal,
						stencil_lifter_hole_diameter,
						lidboard_size_z,
						pcb_holder_hole_offset);
        // screw head area
        translate([0, 0, -cut_delta]) {
			create_corner_cylinders(wall_end_x,
                                lift_hole_margin,
                                lift_hole_diameter,
                                screw_head_hole_diameter,
                                screw_head_hole_height + -cut_delta,
                                lidboard_size_x);
        }
        // screw body area
        create_corner_cylinders(wall_end_x,
                            lift_hole_margin,
                            lift_hole_diameter,
                            screw_body_hole_diameter,
                            screw_body_hole_height + cut_delta,
                            lidboard_size_x);
        margin_holes(lidboard_size_x,
                    lidboard_size_y,
                    stencil_lifter_hole_offset,
                    stencil_lifter_hole_offset,
                    stencil_lifter_hole_diameter,
                    lidboard_size_z,
                    stencil_lifter_hole_offset);
        translate([margin_x, margin_y, -cut_delta]) {
            cube([pcb_holder_size_x + 2 * pcb_board_fitting_marginal,
                  pcb_holder_size_y + 2 * pcb_board_fitting_marginal, 8]);
        }
        /*
        */
    }
}

module pcb_holderboard_frames_to_remove(lidboard_size_x,
                                    lidboard_size_y,
                                    lidboard_size_z,
                                    pcb_holder_size_x,
                                    pcb_holder_size_y,
                                    pcb_holder_board_fitting_marginal) {
    
    margin_x = (lidboard_size_x - pcb_holder_size_x) / 2;
    margin_y = (lidboard_size_y - pcb_holder_size_y) / 2;
    difference() {
        cube([lidboard_size_x + cut_delta, lidboard_size_y, 8.0]);
        translate([margin_x + pcb_holder_board_fitting_marginal,
                    margin_y + pcb_holder_board_fitting_marginal,
                    -cut_delta]) {
            cube([pcb_holder_size_x,
                  pcb_holder_size_y,
                  lidboard_size_z + cut_delta]);
        }
    }
}

module pcb_holderboard(lidboard_size_x,
					lidboard_size_y,
					lidboard_size_z,
					wasteboard_corner_round_d,
                    pcb_holder_hole_positioning_width_x,
                    pcb_holder_hole_positioning_width_y,
					wall_margin,
					wall_width,
					lift_hole_margin,
					lift_hole_diameter,
					screw_head_hole_diameter,
					screw_head_hole_height,
					screw_body_hole_diameter,
					screw_body_hole_height,
					stencil_lifter_hole_diameter,
					stencil_lifter_hole_offset,
					pcb_holder_hole_offset,
					pcb_holder_size_x,
					pcb_holder_size_y,
					pcb_holder_size_z,
					pcb_size_x,
					pcb_size_y,
					pcb_size_z,
                    pcb_holder_board_hole_marginal,
                    pcb_holder_board_fitting_marginal) {
    echo(lidboard_size_z=lidboard_size_z);
    echo(pcb_holder_size_z=pcb_holder_size_z);
    echo(pcb_size_z=pcb_size_z);
    wall_end_x = wall_margin + wall_width;
    difference() {
        pcb_stencil_liftboard_frame(lidboard_size_x,
                        lidboard_size_y,
                        pcb_holder_size_z,
                        wasteboard_corner_round_d,
                        wall_end_x,
                        lift_hole_margin,
                        lift_hole_diameter,
                        lift_hole_diameter,
                        screw_body_hole_height,
                        lidboard_size_x);
        pcb_holder_holes(lidboard_size_x,
						lidboard_size_y,
						pcb_holder_hole_positioning_width_x,
						pcb_holder_hole_positioning_width_y,
                        pcb_holder_board_hole_marginal,
                        pcb_holder_board_hole_marginal,
						stencil_lifter_hole_diameter,
						pcb_holder_size_z,
						pcb_holder_hole_offset);
        margin_holes(lidboard_size_x,
                        lidboard_size_y,
                        stencil_lifter_hole_offset,
                        stencil_lifter_hole_offset,
                        stencil_lifter_hole_diameter,
                        pcb_holder_size_z,
                        stencil_lifter_hole_offset);
        translate([0, 0, 2 * -cut_delta]) {
            pcb_holderboard_frames_to_remove(lidboard_size_x,
                            lidboard_size_y,
                            lidboard_size_z,
                            pcb_holder_size_x,
                            pcb_holder_size_y,
                            pcb_holder_board_fitting_marginal);
        }
        pcb_board_centered(pcb_size_x + pcb_holder_board_fitting_marginal,
                        pcb_size_y + pcb_holder_board_fitting_marginal,
                        pcb_size_z,
                        lidboard_size_x,
                        lidboard_size_y,
                        pcb_holder_size_z);
    }
}

module container_box(size_x,
                    size_y,
                    size_z,
                    rounding_diameter,
                    wall_width,
                    wall_margin,
                    spring_stand_height,
                    spring_stand_radius,
                    spring_holder_outer_height,
                    spring_holder_outer_radius,
                    spring_holder_inner_height,
                    spring_holder_inner_radius,
                    vacuum_pipe_hole_radius_mm)
{
    wall_end_x = wall_margin + wall_width;

    difference() {
        rounded_box(size_x, size_y, size_z, rounding_diameter);
        translate([wall_width, wall_width, wall_width]) {
            rounded_box(size_x - 2 * wall_width,
                        size_y  - 2 * wall_width,
                        size_z  - 1 * wall_width + cut_delta,
                        rounding_diameter);
        }
        translate([-cut_delta, size_x / 2, size_z / 2]) {
            rotate([0, 90, 0]) {
                cylinder(h=wall_width + wall_margin * cut_delta,
                        r=vacuum_pipe_hole_radius_mm,
                        center=false);
            }
        }
    }
    translate([0, 0, wall_width - cut_delta]) {
        create_corner_cylinders(wall_end_x,
                            wall_margin,
                            spring_stand_radius,
                            spring_stand_radius,
                            spring_stand_height + cut_delta,
                            size_x);
    }
    difference() {
    translate([0, 0, wall_width - cut_delta]) {
        create_corner_cylinders(wall_end_x,
                                wall_margin,
                                spring_stand_radius,
                                spring_holder_outer_radius,
                                spring_holder_outer_height + cut_delta,
                                size_x);
    }
    translate([0, 0, wall_width + spring_holder_outer_height - spring_holder_inner_height]) {
        create_corner_cylinders(wall_end_x,
                                wall_margin,
                                spring_stand_radius,
                                spring_holder_inner_radius,
                                spring_holder_inner_height + cut_delta,
                                size_x);
    }}
}

module test_holes(size_x,
				size_y,
                size_z,
				margin_x,
				margin_y,
				hole_diameter,
				hole_count_x,
                hole_count_y) {
    start_x = margin_x / 2;
    start_y = margin_y / 2;

    center_x = start_x;
    center_y = start_y;
    hole_offset_x    = floor(size_x - margin_x) / hole_count_x;
    hole_offset_y    = floor(size_y - margin_y) / hole_count_y;
    for(indx_x = [0:hole_count_x]) {
        center_x = start_x + indx_x * hole_offset_x;
        center_y = start_y;
        translate([center_x, center_y, -1 * cut_delta])
        cylinder(d = hole_diameter, h = size_z + 2 * cut_delta);
    }
    for(indx_x = [0:hole_count_x]) {
        center_x = start_x + indx_x * hole_offset_x;
        center_y = size_y - start_y;
        translate([center_x, center_y, -1 * cut_delta])
        cylinder(d = hole_diameter, h = size_z + 2 * cut_delta);
    }
    for(indx_y = [0:hole_count_y]) {
        center_x = start_x;
        center_y = start_y + indx_y * hole_offset_y;
        translate([center_x, center_y, -1 * cut_delta])
        cylinder(d = hole_diameter, h = size_z + 2 * cut_delta);
    }
    for(indx_y = [0:hole_count_y]) {
        center_x = size_x - start_y;
        center_y = start_y + indx_y * hole_offset_y;
        translate([center_x, center_y, -1 * cut_delta])
        cylinder(d = hole_diameter, h = size_z + 2 * cut_delta);
    }
}

module test_circles(size_x,
                    size_y,
                    size_z,
                    hole_diameter,
                    margin) {
    difference() {
        rounded_box(size_x, size_y, size_z, 8);
        translate([margin, margin, -cut_delta]) {
            rounded_box(size_x - 2 * margin,
                    size_y - 2 * margin,
                    size_z + 2 * cut_delta,
                    8);
        }
        test_holes(size_x,
                   size_y,
                   size_z,
                    margin,
                    margin,
                    hole_diameter,
                    4,
                    4);
    }
}

// specify value between 1-4 to generate different project part
jig_output_module        = 4;
jig_size_x               = 162;
jig_size_y               = 162;
liftboard_frame_width    = 82;
pcb_size_x               = 40;
pcb_size_y               = 40;

module main() {
    jig_lid_size_z	= 4;
    // pcb width not yet retrieved automatically from kicad project
    pcb_size_z      = 1.60;

/*
 * These are wanted to keep constant so that holes will
   always be on same place on lidboard, liftboard and holderboard
   even if the frame size of liftboard changes. (and thus also the holderboard
   size that is inside of liftboard)
 */
    pcb_holder_hole_positioning_width_x = jig_size_x - 42;   // 42 is the meaning of life
    pcb_holder_hole_positioning_width_y = jig_size_y - 42;
   // liftboard_frame_width
    pcb_holder_size_z   = jig_lid_size_z;
    pcb_holder_size_x   = jig_size_x - liftboard_frame_width;
    pcb_holder_size_y   = jig_size_y - liftboard_frame_width;
    /* real pcb size that is fitted to pcb_holder */
    rounding_diameter   = 8;
    wasteboard_margin_size = 14.75;
    stencil_lifter_hole_diameter = 3.5;
    stencil_lifter_hole_offset = 15;
    pcb_holder_hole_offset = 10;
    pcb_holder_board_hole_marginal = 8;
    lidboard_wall_margin = 2;
    lidboard_wall_thickness = 2;
    lidboard_wall_height = 5;
    lift_hole_margin_from_wall = lidboard_wall_margin;
    lift_hole_diameter = 12.3;
    screw_head_hole_diameter  = 5.7;
    screw_head_hole_height  = 3.5;
    screw_body_hole_diameter  = 3.1;
    screw_body_hole_height  = 7.5;
    pcb_holder_board_fitting_marginal = 1.0;
    lift_hole_fitting_marginal = 1.0;
    container_x = jig_size_x;
    container_y = jig_size_y;
    container_z = 38;
    container_wall_width = lidboard_wall_thickness;
    container_wall_margin = lidboard_wall_margin;
    spring_stand_height = 3.0;
    spring_stand_radius = const_courner_hole_size;
    /* 4 corner cylinders to hold the springs on container */
    spring_holder_outer_height = 35;
    spring_holder_outer_radius = 7;
    spring_holder_inner_height = 10;
    spring_holder_inner_radius = 3.1;
    /* size of the hole reserver for vacuum pipe adapter on container */
    vacuum_pipe_hole_radius_mm  = 10;
	
	if (jig_output_module == 1) {
		container_box(container_x,
			container_y,
			container_z,
			rounding_diameter,
			container_wall_width,
			container_wall_margin,
			spring_stand_height,
			spring_stand_radius,
			spring_holder_outer_height,
			spring_holder_outer_radius,
			spring_holder_inner_height,
			spring_holder_inner_radius,
			vacuum_pipe_hole_radius_mm);
	}
	if (jig_output_module == 2) {
		pcb_lidboard(jig_size_x,
			jig_size_y,
			jig_lid_size_z,
			rounding_diameter,
			pcb_holder_hole_positioning_width_x,
			pcb_holder_hole_positioning_width_y,
			lidboard_wall_margin,
			lidboard_wall_thickness,
			lidboard_wall_height,
			lift_hole_margin_from_wall,
			lift_hole_diameter,
			stencil_lifter_hole_diameter,
			jig_lid_size_z,
			stencil_lifter_hole_offset,
			pcb_holder_hole_offset,
			pcb_holder_size_x,
			pcb_holder_size_y,
            pcb_holder_board_hole_marginal,
			lift_hole_fitting_marginal);
	}
	if (jig_output_module == 3) {	
		pcb_stencil_liftboard(jig_size_x,
			jig_size_y,
			jig_lid_size_z,
			rounding_diameter,
			pcb_holder_hole_positioning_width_x,
			pcb_holder_hole_positioning_width_y,
			lidboard_wall_margin,
			lidboard_wall_thickness,
			lift_hole_margin_from_wall,
			lift_hole_diameter,
			screw_head_hole_diameter,
			screw_head_hole_height,
			screw_body_hole_diameter,
			screw_body_hole_height,
			stencil_lifter_hole_diameter,
			stencil_lifter_hole_offset,
			pcb_holder_hole_offset,
			pcb_holder_size_x,
			pcb_holder_size_y,
            pcb_holder_board_hole_marginal,
			pcb_holder_board_fitting_marginal,
			lift_hole_fitting_marginal);
	}
	if (jig_output_module == 4) {
		pcb_holderboard(jig_size_x,
			jig_size_y,
			jig_lid_size_z,
			rounding_diameter,
			pcb_holder_hole_positioning_width_x,
			pcb_holder_hole_positioning_width_y,
			lidboard_wall_margin,
			lidboard_wall_thickness,
			lift_hole_margin_from_wall,
			lift_hole_diameter,
			screw_head_hole_diameter,
			screw_head_hole_height,
			screw_body_hole_diameter,
			screw_body_hole_height,
			stencil_lifter_hole_diameter,
			stencil_lifter_hole_offset,
			pcb_holder_hole_offset,
			pcb_holder_size_x,
			pcb_holder_size_y,
			pcb_holder_size_z,
			pcb_size_x,
			pcb_size_y,
			pcb_size_z,
            pcb_holder_board_hole_marginal,
			pcb_holder_board_fitting_marginal);
	}
/*
    test_circles(jig_size_x,
                jig_size_y,
                0.4,
                stencil_lifter_hole_diameter,
                8);
*/
}

main();
