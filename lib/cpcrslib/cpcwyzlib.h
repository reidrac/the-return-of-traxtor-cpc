	
#ifndef  __cpcwyzlib_h__
#define __cpcwyzlib_h__



extern void  			cpc_WyzLoadSong(unsigned char numero);
extern void     		cpc_WyzStartEffect(unsigned char canal, unsigned char efecto);
//extern void    			cpc_WyzSetPlayerOn(void);
// use WyzPlayerOn instead!
extern void     		cpc_WyzSetPlayerOff(void);
// WARNING: use WyzPlayerOff instead!
extern void  			cpc_WyzConfigurePlayer(unsigned char valor);
extern unsigned char 	cpc_WyzTestPlayer(void);
extern void 			cpc_WyzInitPlayer(unsigned char *sonidos[], unsigned char *pautas[], unsigned char *efectos[], unsigned char *canciones[]);
extern void				cpc_WyzSetTempo(unsigned char tempo);

#endif
