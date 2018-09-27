# -*- coding: utf-8 -*-

from pyx import *
from pyx.graph import axis
import numpy as np
import sys


text.set(mode="latex")
unit.set(xscale=1)
c = canvas.canvas()
text.set(text.LatexRunner)
text.preamble(r"\usepackage{amsmath}")
unit.set(xscale=1.0)
import argparse
xgridpainter = axis.painter.regular(gridattrs=[attr.changelist([style.linestyle.dashed, None])])
ygridpainter = axis.painter.regular(gridattrs=[attr.changelist([style.linestyle.dashed, None])])


parser = argparse.ArgumentParser()
parser.add_argument("--infile", action = "store")
parser.add_argument("--outfile", action = "store")
parser.add_argument("--Xaxis", action = "store")
parser.add_argument("--Yaxis", action = "store")
parser.add_argument("--xlabel", action = "store")
parser.add_argument("--ylabel", action = "store")
parser.add_argument("--folder", action = "store")
args = parser.parse_args()

xaxis = int(args.Xaxis)
yaxis = int(args.Yaxis)
data = np.loadtxt(args.folder + "/" + args.infile, delimiter = ",")
S11_dB = 20*np.log10(abs(data[:, yaxis] + 1j*data[:, yaxis+1]))
S11_phase = np.angle(data[:,yaxis] + 1j*data[:,yaxis+1])
width = 8
gratio = 1.618
gbottom = c.insert(graph.graphxy(width=width, height = width/gratio/2,
		x = graph.axis.lin(painter=xgridpainter, title=args.xlabel),
		y = graph.axis.lin(title = "phase(%s)"%args.ylabel, 
                    min=-np.pi,max=np.pi, 
                    painter=ygridpainter),
		)
             )
gtop = c.insert(graph.graphxy(width=width, height=width/gratio,ypos = gbottom.height+0.5,
                x = graph.axis.linkedaxis(gbottom.axes["x"],
            axis.painter.regular(gridattrs=[attr.changelist([style.linestyle.dashed,None])])),
                y = graph.axis.lin(title="$20\log|$%s$|^2$"%args.ylabel,max=max(np.max(S11_dB),0),
                    painter=ygridpainter)
                )
             )

gtop.plot([graph.data.values(x = data[:, xaxis]/1e9, y = S11_dB)],
       [graph.style.line([color.rgb.black])])
gbottom.plot([graph.data.values(x = data[:, xaxis]/1e9, y = S11_phase)],
       [graph.style.line([color.rgb.black])])


c.writePDFfile(args.folder + "/" + args.outfile)
