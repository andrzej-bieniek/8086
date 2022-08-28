#include <stdio.h>
#include <conio.h>
#include <dos.h>
#include <stdlib.h>
#include <fcntl.h>		/* added for the MAP Save stuff */
#include <io.h>			/* added for the MAP Save stuff */
#include <sys\stat.h>		/* added for the MAP Save stuff */

#include "cmars.h"

/* Generic routine to update the view */
void UpdateView(void)
{
/* you might want to modify this so you can set your own view coord */
	UpdateViewCoord();	
/* These draw the sky and the mountains... */
	UpdateSky();
	UpdateMountains();
}
/* Routine to set the palette.  I've the assembly language version
 * intact, the two should have identical results
 */
void MakePalette(PALETTE palette[])
{
  int i;
	/* Mountains, grey shading */
  for (i=0; i < 64; i++) {
		palette[i].red = i;
		palette[i].green = i;
		palette[i].blue = i;
	}
	/* Sky, blue shading.  Can only send values up to 63 to palette regs */
  for (i=64; i < 128; i++) {		/* clouds from 74-84 */
		palette[i].red = 0;
		palette[i].green = 0;
		palette[i].blue = i&63;
	}
	/* Midband, green shading */
  for (i=128; i < 192; i++) {
		palette[i].red = 0;
		palette[i].green = i&63;
		palette[i].blue = 0;
	}
	/* Unused */
  for (i=192; i < 256; i++) {
		palette[i].red = 0;
		palette[i].green = 0;
		palette[i].blue = 0;
	}
	PaletteOut(palette);
}

int NormalizedAngle(int angle)
{
	if (angle > 359)
		return(angle-360);
	if (angle < 0)
		return(angle+360);
	return(angle);
}
/*****************************************************************************/
int main(int argc, char *argv[])
{
int fh;
int keys=0;
unsigned int basemem;
unsigned char far * marsmap;

  /* Initialize far data pointers */
	basemem = RetFARData();
	if (basemem == 0)
	{
		printf("Can't Allocate enough Memory ... Bye\n");
		exit(0);
	}
	Map_Seg += basemem;
	Color_Seg += basemem;
	Sky_Seg += basemem;
  	InternalScreen_Seg += basemem;

	while (kbhit())		/* clear keyboard buffer */
		getch();

  /* Read the text mode palette & save */
	ReadPalette(&BiosPal);
	FadeOut(&BiosPal);

  /* Switch to graphics mode, read graphics palette (never used)
   * and clear the palette to all black
   */
  printf("at 1\n");
	SwitchToGraphics();
	ReadPalette(&BiosPal);
	ClearPAL();

  /* Initialize for MARS */
	MakeMakeTable();
	InitRandom();

  /* Make mars palette */
	MakePalette(&MarsPal);
	ClearPAL();

  /* Calculate the maps and set initial pos */
	CalcSky();
	CalcMountains();

if (argc > 1)
{
   if ((fh = open(argv[1], O_BINARY | O_RDONLY, S_IREAD)) != -1)
   {
	marsmap = MK_FP(Map_Seg, 0);
	for (keys=0; keys < 64; keys++)
	{
	   read(fh, marsmap, 1024);
	   marsmap += 1024;
	}
	close(fh);
marsmap = MK_FP(Color_Seg, 0);
for (keys=0; keys < 31488; keys++)
{
	*marsmap++ += 98;
}
   }
}


	Map_X = 1024;
	Map_Y = 1024;
	Map_X = 400;
	Map_Y = 400;

  /* Update and draw the first view, then fade it in */
	UpdateView();
	DrawView();
	FadeIn(&MarsPal);

	FlyHeight = 0;

  /* Update view pos & view & draw it until done */
	while (1)
	{
		keys = getch();
		switch (keys)
		{
				case 'a':
					Angle = NormalizedAngle(Angle+15);
					break;
				case 's':
					Angle = NormalizedAngle(Angle-15);
					break;
		    case 'h':
					DeltaMove(32,NormalizedAngle(Angle + 180));
					break;

		    case 'l': 
					DeltaMove(32,NormalizedAngle(Angle + 0));
			 		break;

		    case 'j': 
					DeltaMove(32,NormalizedAngle(Angle+270));
					break;

		    case 'k':
					DeltaMove(32,NormalizedAngle(Angle+90));
			 		break;

		    case 'u': 
			 if (FlyHeight == 0)
			 {
			    FlyHeight = MountHeight / 256;
			    break;
			 }
			 FlyHeight += 20;
			 if (FlyHeight > 230)
			    FlyHeight = 230;
			 break;

		    case 'd': FlyHeight -= 20;
			 if (FlyHeight > 230)
			    FlyHeight = MountHeight / 256;
			 break;

		    case 'x':
		    case 'q':
			 FadeOut(&MarsPal);
			 SwitchToText();
			 ReleaseFarData(basemem);
			 exit(0);
		}
		UpdateView();
		DrawView();
	}
}