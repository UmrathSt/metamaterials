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
xgridpainter = axis.painter.regular(gridattrs=[attr.changelist([style.linestyle.dashed, None])])
ygridpainter = axis.painter.regular(gridattrs=[attr.changelist([style.linestyle.dashed, None])])
xgridpainter = axis.painter.regular(gridattrs=None)
ygridpainter = axis.painter.regular(gridattrs=None)

dataA = np.loadtxt("S11__w1_1.5_w2_0.5_eps_4.2_kappa_0.05_EXACT_lz_2_Absorber", delimiter = ",")
dataR = np.loadtxt("S11__w1_1.5_w2_0.5_eps_4.2_kappa_0.05_EXACT_lz_2", delimiter = ",")
dataS = np.loadtxt("S11__w1_1.5_w2_0.5_eps_4.2_kappa_0.05_EXACT_lz_2_DoubleSlots", delimiter = ",")
f = dataR[:,0]
fA = dataA[:,0]
width = 8
gratio = 1.618
gbottom = c.insert(graph.graphxy(width=width, height = width/gratio,
		x = graph.axis.lin(painter=xgridpainter, title="$f$ [GHz]",
                    min=1,max=8),
		y = graph.axis.lin(title = "Transmissionskoeffizient $|T|^2$", 
                    min=0,max=1, 
                    painter=ygridpainter),
		)
             )
gtop = c.insert(graph.graphxy(width=width, height=width/gratio,ypos=gbottom.height+0.5,
                x = graph.axis.linkedaxis(gbottom.axes["x"],
                   axis.painter.regular(gridattrs=[attr.changelist([style.linestyle.dashed,None])])),
                y = graph.axis.lin(title="Reflexionskoeffizient $|R|^2$",max=1,min=0,
                    painter=ygridpainter)
                )
             )

gtop.plot([graph.data.values(x = fA/1e9, y = abs(dataA[:,1]+1j*dataA[:,2])**2)],
       [graph.style.line([color.rgb.black, style.linewidth.thick])])
gtop.plot([graph.data.values(x = f/1e9, y = abs(dataR[:,1]+1j*dataR[:,2])**2)],
       [graph.style.line([color.rgb.blue, style.linewidth.thick])])
gbottom.plot([graph.data.values(x = f/1e9, y = abs(dataR[:,3]+1j*dataR[:,4])**2)],
       [graph.style.line([color.rgb.red, style.linewidth.thick])])
gbottom.plot([graph.data.values(x = fA/1e9, y = abs(dataA[:,3]+1j*dataA[:,4])**2)],
       [graph.style.line([color.rgb.black, style.linewidth.thick])])
gtop.plot([graph.data.values(x = f/1e9, y = abs(dataS[:,1]+1j*dataS[:,2])**2)],
       [graph.style.line([color.rgb.red, style.linewidth.thick])])
gbottom.plot([graph.data.values(x = f/1e9, y = abs(dataS[:,3]+1j*dataS[:,4])**2)],
       [graph.style.line([color.rgb.blue, style.linewidth.thick])])


c.writePDFfile("plot.pdf")
