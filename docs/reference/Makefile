# Copyright (c) 2012 Taylor Hutt, Logic Magicians Software
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

%.ps: %.dvi
	dvips  -D 600 -Z $(LATEX_PAGELIST) -o $@ $<

THIS_DOC	= lmsbw



TEX		= $(filter-out $(addsuffix .tex,$(THIS_DOC)),$(wildcard *.tex))

PACKAGES	= $(TEXINPUTS)

all:		$(THIS_DOC).ps

$(THIS_DOC).ps:		$(THIS_DOC).dvi
$(THIS_DOC).tex:
$(THIS_DOC).dvi:	$(THIS_DOC).ind
	latex $(<:.ind=.tex)

$(THIS_DOC).ind:	$(THIS_DOC).tex $(TEX)
	latex $<
	makeindex $<
clean:
	rm *.aux *.log *.toc *.ps *.dvi
