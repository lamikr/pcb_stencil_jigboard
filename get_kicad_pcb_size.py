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
import pcbnew
import math
import subprocess

def roundup_twenty(x):
    return math.ceil(x / 20.0) * 20

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
		pcb_board_size	= roundup_twenty(pcb_size_max)
		if ((pcb_board_size - pcb_size_max) < 5):
			pcb_board_size	= pcb_board_size + 20
		print("pcb_board_size:", round(pcb_board_size, 1), "mm")
		liftboard_frame_width	= 62;
		jig_size_x	= pcb_board_size + liftboard_frame_width;
		print("jig_size_x:", round(jig_size_x, 1), "mm")
		openscad_exec = 'openscad'
		param_jig_size_x = '-D jig_size_x=' + str(jig_size_x);
		param_jig_size_y = '-D jig_size_y=' + str(jig_size_x);
		param_liftboard_frame_width = '-D liftboard_frame_width=' + str(liftboard_frame_width);
		param_pcb_size_x = '-D pcb_size_x=' + str(pcb_size_x_mm);
		param_pcb_size_y = '-D pcb_size_y=' + str(pcb_size_y_mm);
		param_output_base = str(jig_size_x) + 'x' + str(jig_size_x);
		param_cntr_box_name_base = 'container_box_' + param_output_base;
		param_lidboard_name_base = 'lidboard_' + param_output_base;
		param_stencil_lifter_name_base = 'stencil_lifter_' + param_output_base + '_' + str(liftboard_frame_width);
		param_pcb_holder_name_base = 'pcb_holder_' + param_output_base + '_' + str(liftboard_frame_width) + '_' + str(int(pcb_size_x_mm)) + 'x' + str(int(pcb_size_y_mm));
		
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
