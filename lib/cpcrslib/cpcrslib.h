
#ifndef  __cpcrslib_h__
#define __cpcrslib_h__







void						cpc_UnExo(char *origen, int destino);
void						cpc_Uncrunch(char *origen, int destino);


void 						cpc_SetMode( char color);
void 						cpc_SetModo( char x);
void 						cpc_SetColour(unsigned char num,  char color);
void  						cpc_SetInk(unsigned char num,  unsigned char color);
void  						cpc_SetBorder( char color);
unsigned char 				cpc_Random(void);

void 						cpc_ClrScr(void);

void 						cpc_PutSprite(char *sprite, int posicion);
void 						cpc_PutSp(char *sprite, char height, char width, int address);
void						cpc_PutSp4x14(char *sprite, int address);
void 						cpc_PutSpriteXOR(char *sprite, int posicion);
void 						cpc_PutSpXOR(char *sprite, char height, char width, int address);
void 						cpc_PutSpriteTr(char *sprite, int *posicion);
void 						cpc_PutSpTr(char *sprite, char height, char width, int address);
void						cpc_GetSp(char *sprite, char alto, char ancho, int posicion);
void 						cpc_PutMaskSprite(char *sprite,unsigned int addr);
//void 						cpc_PutMaskSprite(struct sprite *spr,unsigned int *addr);
void    					cpc_PutMaskSp(char *sprite, char alto, char ancho, int posicion);
void 						cpc_PutMaskSp4x16(char *sprite,unsigned int addr);
void 						cpc_PutMaskSp2x8(char *sprite,unsigned int addr);


unsigned char				cpc_CollSp(char *sprite, char *sprite2);


// TILE MAP:
void						cpc_InitTileMap(void);
void 						cpc_SetTile(unsigned char x, unsigned char y, unsigned char b);
void						cpc_ShowTileMap();
void						cpc_ShowTileMap2(void);
void						cpc_ResetTouchedTiles(void);

void						cpc_PutSpTileMap(char *sprite);
void						cpc_PutSpTileMapF(char *sprite);
void						cpc_UpdScr(void);
void						cpc_PutSpTileMap2b(char *sprite);
void						cpc_PutMaskSpTileMap2b(char *sprite);
void						cpc_PutMaskInkSpTileMap2b(char *sprite);
void						cpc_PutTrSpTileMap2b(char *sprite);
void						cpc_PutTrSpriteTileMap2b(char *sprite);


void						cpc_SpUpdY(char *sprite, char valor);
void						cpc_SpUpdX(char *sprite, char valor);

void						cpc_ScrollRight00(void);
void						cpc_ScrollRight01(void);
void						cpc_ScrollLeft00(void);
void						cpc_ScrollLeft01(void);
void						cpc_ScrollRight(void);
void						cpc_ScrollLeft(void);

void						cpc_SetTouchTileXY(unsigned char x, unsigned char y, unsigned char t);
unsigned char				cpc_ReadTile(unsigned char x, unsigned char y);
void						cpc_SuperbufferAddress(char *sprite);

// ****************






void     					cpc_RRI(unsigned int pos, unsigned char w, unsigned char h);
void  		   				cpc_RLI(unsigned int pos, unsigned char w, unsigned char h);


int 						cpc_AnyKeyPressed(void);
void 						cpc_ScanKeyboard(void);
char 						cpc_TestKeyF(char number);
void						cpc_DeleteKeys(void);
void 						cpc_AssignKey(unsigned char tecla, int valor);
unsigned char 				cpc_TestKey(unsigned char tecla);
void 						cpc_RedefineKey(unsigned char tecla);

int							cpc_GetScrAddress(char x, char y);

void 						cpc_PrintStr(char *text);

void						cpc_EnableFirmware(void);
void						cpc_DisableFirmware(void);

void						cpc_SetFont(unsigned char first_char, unsigned char *font_def);

void						cpc_PrintGphStr(char *text, int destino);
void						cpc_PrintGphStrM1(char *text, int destino);
void						cpc_PrintGphStr2X(char *text, int destino);
void						cpc_PrintGphStrM12X(char *text, int destino);

void						cpc_PrintGphStrXY(char *text, unsigned char a, unsigned char b);
void						cpc_PrintGphStrXYM1(char *text, unsigned char a, unsigned char b);
void						cpc_PrintGphStrXY2X(char *text, unsigned char a, unsigned char b);
void						cpc_PrintGphStrXYM12X(char *text, unsigned char a, unsigned char b);
void						cpc_SetInkGphStr(unsigned char a, unsigned char b);
void						cpc_SetInkGphStrM1(unsigned char a, unsigned char b);

void     					cpc_PrintGphStrStd(char color, char *cadena, int destino);
void  		   				cpc_PrintGphStrStdXY(char color, char *cadena, char x, char y);

#endif /* __cpcrslib_h__ */
