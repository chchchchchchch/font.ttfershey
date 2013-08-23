#!/bin/bash

#.---------------------------------------------------------------------.#
#. layers2ttf.sh (0.00)                                                 #
#. 								        #
#. Copyright (C) 2013 LAFKON/Christoph Haag			        #
#. 								        #
#. This is free software: you can redistribute it and/or modify         #
#. it under the terms of the GNU General Public License as published by #
#. the Free Software Foundation, either version 3 of the License, or    #
#. (at your option) any later version.				        #
#. 								        #
#. This file is distributed in the hope that it will be useful,	        #
#. but WITHOUT ANY WARRANTY; without even the implied warranty of       #
#. MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 	        #
#. See the GNU General Public License for more details.		        #
#.								        #
#.---------------------------------------------------------------------.#

  OUTPUTDIR=o
  FONTDIR=o
  TMPDIR=tmp

  BLANKFONT=i/utils/blank.sfd
  SVG=i/Hershey_Sans-1-Stroke.svg

  NAME=TTFershey_SANS


# ------------------------------------------------------------------------------- #
# SEPARATE SVG BODY FOR EASIER PARSING (BUG FOR EMPTY LAYERS SOLVED)
# ------------------------------------------------------------------------------- #

  sed 's/ / \n/g' $SVG | \
  sed '/^.$/d' | \
  sed -n '/<\/metadata>/,/<\/svg>/p' | sed '1d;$d' | \
  sed ':a;N;$!ba;s/\n/ /g' | \
  sed 's/<\/g>/\n<\/g>/g' | \
  sed 's/\/>/\n\/>\n/g' | \
  sed 's/\(<g.*inkscape:groupmode="layer"[^"]*"\)/QWERTZUIOP\1/g' | \
  sed ':a;N;$!ba;s/\n/ /g' | \
  sed 's/QWERTZUIOP/\n\n\n\n/g' | \
  sed 's/display:none/display:inline/g' > $TMPDIR/svg.tmp


  SVGHEADER=`tac $SVG | sed -n '/<\/metadata>/,$p' | tac`

  for LAYER in `cat $TMPDIR/svg.tmp | \
                sed 's/ /ASDFGHJKL/g' | \
                sed '/^.$/d' | \
                grep -v "label=\"XX_" | \
                sed 's/stroke:[^;]*;/stroke-width:none;/g' | \
                sed 's/fill:[^;]*;/fill:#00ff00;/g'`
   do
      LNAME=`echo $LAYER | \
             sed 's/ASDFGHJKL/ /g' | \
             sed 's/\" /\"\n/g' | \
             grep inkscape:label | grep -v XX | \
             cut -d "\"" -f 2 | sed 's/[[:space:]]\+//g'`

      LSVG=$TMPDIR/${LNAME}.svg

      echo $SVGHEADER                     >  $LSVG
      echo $LAYER | sed 's/ASDFGHJKL/ /g' >> $LSVG
      echo "</svg>"                       >> $LSVG

  done

  rm $TMPDIR/svg.tmp


  cp $BLANKFONT ${BLANKFONT%%.*}_backup.sfd 
  sed -i "s/XXXX/$NEWFONT/g" $BLANKFONT  

     ./svg2ttf-0.2.py

  mv ${BLANKFONT%%.*}_backup.sfd $BLANKFONT 
  cp output.ttf ${OUTPUTDIR}/${NAME}.ttf
  
  if [ -d "$FONTDIR" ]; then
  cp output.ttf ${FONTDIR}/${NAME}.ttf
  fi

  rm output.ttf

exit 0;
