typedef unsigned char BYTE;

typedef struct {
   BYTE red;
   BYTE green; 
   BYTE blue;
} PALETTE;

extern unsigned int Map_Seg, Color_Seg,Sky_Seg, InternalScreen_Seg;
extern unsigned int MapMakeTable[60];
extern int AddCXTable[4], AddDXTable[4];
extern int MapCoord[4];
extern unsigned int W_Divider;
extern unsigned int MountHeight;
extern unsigned int Map_X, Map_Y;
extern unsigned int RandomSeed;
extern PALETTE BiosPal[256], MarsPal[256];
extern int Count_Loop;
extern BYTE FlyHeight;
extern int Angle;

 unsigned RetFARData(void);
 void FadeOut(BYTE *table);
 void FadeIn(BYTE *table);
 void PaletteOut(PALETTE *palette);
 void ClearPAL(void);
 ReadPalette(BYTE *table);
 void SwitchToGraphics(void);
 void SwitchToText(void);
 void MakeMakeTable(void);
 void MakeMarsPalette(void);
 void InitRandom(void);
 void DrawView(void);
 CalcFractal(unsigned seg);
 void CalcSky(void);
 void CalcMountains(void);
 void UpdateViewCoord(void);
 void UpdateSky(void);
 void UpdateMountains(void);
 void DeltaMove(int delta, int angle);
 void ReleaseFarData(unsigned theseg); 