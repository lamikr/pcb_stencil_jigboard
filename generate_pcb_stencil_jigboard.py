#!/bin/python

# code to find the pcb board max width and height in millimeters from kicad_pcb file. 
# (tested with pcb files from kicad 7 project)
# it uses the kicad_pcb file as a parameter, for example:
# ./get_kicad_pcb_size.py ldo_test_pcb.kicad_pcb
# 
# and will output results like:
# width: 60.2 mm
# height: 29.0 mm

import sys
import os
import pcbnew
import math
import subprocess

CONST_MAX_JIG_SIZE_MM=162
CONST_DEFAULT_FRAME_SIZE_MM=82
CONST_MIN_FRAME_SIZE_MM=42
CONST_SIZE_ADJUST_MM=20

def round_up_by_twenty(x):
    return math.ceil(x / 20.0) * 20

def round_down_by_ten(x):
    return math.floor(x / 10.0) * 10

def round_down_by_ten_remainder(x):
    return x - math.floor(x / 10) * 10

edge_found	= 0
if len(sys.argv) == 2:
	f_name	= sys.argv[1]
	board	= pcbnew.LoadBoard(f_name)
	min_x	= (1<<33)
	min_y	= (1<<33)
	max_x	=-(1<<33)
	max_y	=-(1<<33)
	for d in board.GetDrawings():
		if d.GetLayer() == pcbnew.Edge_Cuts:
			edge_found	= 1
			box			= d.GetBoundingBox()
			min_x		= min(box.GetLeft(), min_x)
			min_y		= min(box.GetTop(), min_y)
			max_x		= max(box.GetRight(), max_x)
			max_y   	= max(box.GetBottom(), max_y)
	if edge_found:
		#print("min_x", min_x)
		#print("min_y", min_y)
		#print("max_x", max_x)
		#print("max_y", max_y)
		pcb_size_x_mm	= (max_x - min_x) / 1000000;
		pcb_size_y_mm	= (max_y - min_y) / 1000000;
		print("pcb_width:", round(pcb_size_x_mm, 1), "mm")
		print("pcb_height:", round(pcb_size_y_mm, 1), "mm")
		pcb_size_x_mm	= round((pcb_size_x_mm + 2), 0);
		pcb_size_y_mm	= round((pcb_size_y_mm + 2), 0);
		pcb_size_max	= max(pcb_size_x_mm, pcb_size_y_mm)
		print("pcb_size_max:", round(pcb_size_max, 1), "mm")
		pcb_boardholder_size	= round_up_by_twenty(pcb_size_max)
		if ((pcb_boardholder_size - pcb_size_max) < 5):
			pcb_boardholder_size	= pcb_boardholder_size + CONST_SIZE_ADJUST_MM
		print("pcb_boardholder_size:", round(pcb_boardholder_size, 1), "mm")
		jig_size_set = False
		liftboard_frame_width = CONST_DEFAULT_FRAME_SIZE_MM;
		while (True):
			temp_size_x = pcb_boardholder_size + liftboard_frame_width;
			temp_sz_x_div = round_down_by_ten(temp_size_x);
			temp_sz_x_rem = round_down_by_ten_remainder(temp_size_x);
			jig_size_x	= round_up_by_twenty(temp_sz_x_div) + temp_sz_x_rem;
			if (jig_size_x > CONST_MAX_JIG_SIZE_MM):
				liftboard_frame_width = liftboard_frame_width - CONST_SIZE_ADJUST_MM;
				if (liftboard_frame_width < CONST_MIN_FRAME_SIZE_MM):
					print("Error, max jig size:", CONST_MAX_JIG_SIZE_MM, "mm")
					print("  liftboard_frame_width:", (liftboard_frame_width + CONST_SIZE_ADJUST_MM), "mm")
					print("  min liftboard_frame_width:", CONST_MIN_FRAME_SIZE_MM, "mm")
					print("  jig_size = pcb_boardholder_size + liftboard_frame_width =", (pcb_boardholder_size + liftboard_frame_width + CONST_SIZE_ADJUST_MM), "mm")
					os._exit(1)
			else:
				# success, exit from while loop
				break
		print("temp_size_x: ", temp_size_x, ", temp_sz_x_div: ", temp_sz_x_div, ", temp_sz_x_rem: ", temp_sz_x_rem, ", jig_size_x: ", jig_size_x);
		print("liftboard_frame_width:", liftboard_frame_width, "mm")
		print("jig_size_x:", round(jig_size_x, 1), "mm")
		os._exit(0)
		openscad_exec = 'openscad'
		param_jig_size_x = '-D jig_size_x=' + str(jig_size_x);
		param_jig_size_y = '-D jig_size_y=' + str(jig_size_x);
		param_liftboard_frame_width = '-D liftboard_frame_width=' + str(liftboard_frame_width);
		param_pcb_size_x = '-D pcb_size_x=' + str(pcb_size_x_mm);
		param_pcb_size_y = '-D pcb_size_y=' + str(pcb_size_y_mm);
		param_output_base = str(jig_size_x) + 'x' + str(jig_size_x);
		param_cntr_box_name_base = 'container_box_' + param_output_base;
		param_lidboard_name_base = 'lidboard_' + param_output_base;
		param_stencil_lifter_name_base = 'stencil_lifter_frame_' + param_output_base + '_' + str(liftboard_frame_width);
		param_pcb_holder_name_base = 'pcb_holderboard_' + param_output_base + '_' + str(liftboard_frame_width) + '_' + str(int(pcb_size_x_mm)) + 'x' + str(int(pcb_size_y_mm));
		
		subprocess.Popen([openscad_exec,
					param_jig_size_x,
					param_jig_size_y,
					param_liftboard_frame_width,
					param_pcb_size_x,
					param_pcb_size_y,
					'-Djig_output_module=1',
					'-o' + param_cntr_box_name_base + '.png',
					'pcb_stencil_jig.scad'])
		subprocess.Popen([openscad_exec,
					param_jig_size_x,
					param_jig_size_y,
					param_liftboard_frame_width,
					param_pcb_size_x,
					param_pcb_size_y,
					'-Djig_output_module=1',
					'-o' + param_cntr_box_name_base + '.stl',
					'pcb_stencil_jig.scad'])
		subprocess.Popen([openscad_exec,
					param_jig_size_x,
					param_jig_size_y,
					param_liftboard_frame_width,
					param_pcb_size_x,
					param_pcb_size_y,
					'-Djig_output_module=2',
					'-o' + param_lidboard_name_base + '.png',
					'pcb_stencil_jig.scad'])
		subprocess.Popen([openscad_exec,
					param_jig_size_x,
					param_jig_size_y,
					param_liftboard_frame_width,
					param_pcb_size_x,
					param_pcb_size_y,
					'-Djig_output_module=2',
					'-o' + param_lidboard_name_base + '.stl',
					'pcb_stencil_jig.scad'])
		subprocess.Popen([openscad_exec,
					param_jig_size_x,
					param_jig_size_y,
					param_liftboard_frame_width,
					param_pcb_size_x,
					param_pcb_size_y,
					'-Djig_output_module=3',
					'-o' + param_stencil_lifter_name_base + '.png',
					'pcb_stencil_jig.scad'])
		subprocess.Popen([openscad_exec,
					param_jig_size_x,
					param_jig_size_y,
					param_liftboard_frame_width,
					param_pcb_size_x,
					param_pcb_size_y,
					'-Djig_output_module=3',
					'-o' + param_stencil_lifter_name_base + '.stl',
					'pcb_stencil_jig.scad'])
		subprocess.Popen([openscad_exec,
					param_jig_size_x,
					param_jig_size_y,
					param_liftboard_frame_width,
					param_pcb_size_x,
					param_pcb_size_y,
					'-Djig_output_module=4',
					'-o' + param_pcb_holder_name_base + '.png',
					'pcb_stencil_jig.scad'])
		subprocess.Popen([openscad_exec,
					param_jig_size_x,
					param_jig_size_y,
					param_liftboard_frame_width,
					param_pcb_size_x,
					param_pcb_size_y,
					'-Djig_output_module=4',
					'-o' + param_pcb_holder_name_base + '.stl',
					'pcb_stencil_jig.scad'])					
	else:
		raise Exception("No board borders defined in Edge.Cuts layer of kicad_pcb file")
else:
	print("One parameter needed: path to kicad_pcb file with 'Edge.Cuts' layer to find pcp file dimensions")
