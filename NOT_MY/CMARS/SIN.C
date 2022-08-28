#include	<stdio.h>
#include <math.h>

#define MagicNumber 128

int xsin[360];
int xcos[360];
main()
{
	int i,j;
	FILE *out;
  double sqrt2over128;
	sqrt2over128 = (sqrt(2)/MagicNumber)*65536L;
//	sqrt2over128 = (3.1415926536/256)*65536L;
	
  
	for (i=0; i <360; i++) {
		xsin[i] = sin((double)i*2*3.1415926/360)*32767;
		xcos[i] = cos((double)i*2*3.1415926/360)*32767;
	}
	out =fopen("sintab.asm","w");
	fprintf(out,"\t.model\tlarge\n\n");
	fprintf(out,"\t.data\n\n");
	fprintf(out,"\tPUBLIC\tsintable,costable,_B\n\n");
	fprintf(out,"_B	dw	0%04xh\n\n",(int)sqrt2over128);
	fprintf(out,"sintable	label	word\n");
	for (i=0; i < 360; i+=8) {
		fprintf(out,"\tdw\t");
		for (j=0; j <8; j++) {
			fprintf(out,"0%04xh",xsin[i+j]);
			if (j != 7)
				fprintf(out,", ");
		}
		fprintf(out,"\n");
	}
	fprintf(out,"costable	label	word\n");
	for (i=0; i < 360; i+=8) {
		fprintf(out,"\tdw\t");
		for (j=0; j <8; j++) {
			fprintf(out,"0%04xh",xcos[i+j]);
			if (j != 7)
				fprintf(out,", ");
		}
		fprintf(out,"\n");
	} 
	fprintf(out,"\n\n\tend\n");
	fclose(out);
}
		