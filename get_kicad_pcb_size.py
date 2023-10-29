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
		size_w_mm	= (max_x - min_x) / 1000000;
		size_h_mm	= (max_y - min_y) / 1000000;
		print("width:", round(size_w_mm, 1), "mm")
		print("height:", round(size_h_mm, 1), "mm")
	else:
		raise Exception("No Edge.Cuts Element found")
else:
	print("One parameter needed: path to kicad_pcb file with 'Edge.Cuts' layer to find pcp file dimensions")
