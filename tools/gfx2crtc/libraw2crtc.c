/* GFX2CRTC - libraw2crtc.c
 * CloudStrife - 20080921
 * Diffusé sous licence libre CeCILL v2
 * Voire LICENCE
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

unsigned short addrCalc(unsigned char vcc, unsigned char rcc, unsigned char hcc, unsigned char cclk, unsigned char r1, unsigned char r12, unsigned char r13)
{
  unsigned short MA;
  unsigned short addr;

  //MA = vcc*r1 + hcc + (0x0C)*256;
  MA = vcc*r1 + hcc + r12*256 + r13;
  addr = cclk | ((MA & 0x03FF) << 1);
  addr = addr | ((rcc & 0x07) << 11);
  addr = addr | ((MA & 0x3000) << 2);

  return addr;
}

unsigned char mode0interlace(unsigned char *x)
{
  unsigned char mode0pixel[] = {0, 64, 4, 68, 16, 80, 20, 84, 1, 65, 5, 69, 17, 81, 21, 85};
  return mode0pixel[x[0]] << 1 | mode0pixel[x[1]];
}

unsigned char mode1interlace(unsigned char *x)
{
  unsigned char mode1pixel[] = {0, 16, 1, 17};
  return mode1pixel[x[0]] << 3 | mode1pixel[x[1]] << 2 | mode1pixel[x[2]] << 1 | mode1pixel[x[3]];
}

unsigned char mode2interlace(unsigned char *x)
{
  unsigned char out = 0;
  int i;
  for(i = 0; i < 8; i++) out += ((x[7-i]&1) << i);
  return out;
}

unsigned char mode3interlace(unsigned char *x)
{
  unsigned char mode3pixel[] = {0, 16, 1, 17};
  return mode3pixel[x[0]] << 3 | mode3pixel[x[1]] << 2;
}

unsigned char (*ptrMode)(unsigned char *x);

unsigned char *raw2crtc(unsigned char *input, unsigned short width, unsigned short height, unsigned char mode, unsigned char r9, unsigned long *outSize, unsigned char *r1, unsigned char r12, unsigned char r13, unsigned char* reg6)
{
  unsigned char *outBuffer;
  unsigned char *tmpBuffer;
  unsigned char *allocationBuffer;
  unsigned short minAddr = 0;
  unsigned char minAddrIsDefined = 0;
  unsigned short maxAddr;

  unsigned char nbPixPerByte;
  int y,x;

  switch(mode)
  {
    case 0:
    {
      *r1 = (width+3)/4;
      nbPixPerByte = 2;
      ptrMode = mode0interlace;
      break;
    }
    case 1:
    {
      *r1 = (width+7)/8;
      nbPixPerByte = 4;
      ptrMode = mode1interlace;
      break;
    }
    case 2:
    {
      *r1 = (width+15)/16;
      nbPixPerByte = 8;
      ptrMode = mode2interlace;
      break;
    }
    case 3:
    {
      *r1 = (width+3)/4;
      nbPixPerByte = 2;
      ptrMode = mode3interlace;
      break;
    }
    default:
    {
      exit(4);
    }
  }

  tmpBuffer = (unsigned char*)malloc(0xFFFF);
  if (tmpBuffer == NULL)
  {
    printf("Allocation tmpBuffer rat�\n");
    exit(4);
  }

  allocationBuffer = (unsigned char*)calloc(0xFFFF, 1);
  if(allocationBuffer == NULL)
  {
    printf("Allocation allocationBuffer rat�\n");
    exit(4);
  }

  {
	unsigned char r6;
	unsigned char vcc,rcc,hcc,cclk;
	r6 = (height+r9)/(r9+1);
	*reg6 = r6;
	
	for(vcc = 0; vcc < r6; vcc++)
	{
	    for(rcc = 0; rcc < (r9+1); rcc++)
	    {
	      for(hcc = 0; hcc < *r1; hcc++)
	      {
			for(cclk = 0; cclk < 2; cclk++)
			{
			  x = (hcc << 1 | cclk);
			  y = vcc*(r9+1) + rcc;
			  *(tmpBuffer + addrCalc(vcc, rcc, hcc, cclk, *r1, r12, r13)) = (*ptrMode)(input + y*width + x*nbPixPerByte);
			  *(allocationBuffer + addrCalc(vcc, rcc, hcc, cclk, *r1, r12, r13)) += 1;
			}
	      }
	    }
	}
  }

	{
	  unsigned short i;
	  for(i = 0; i < 0xFFFF; i++)
	  {
	    if(*(allocationBuffer + i) > 1)
	    {
	      printf("Attention : Ecriture multiple a l'adresse m�moire %d\n",i);
	    }
	    if(*(allocationBuffer + i) > 0)
	    {
	      maxAddr = i;
	    }
	    if((*(allocationBuffer + i) == 1) && (minAddrIsDefined == 0))
	    {
	      minAddr = i;
	      minAddrIsDefined = 1;
	    }
	  }
	}

  *outSize = (maxAddr + 1) - minAddr;

  outBuffer = (unsigned char*)malloc((*outSize));
  if (outBuffer == NULL)
  {
    printf("Allocation outBuffer rat�\n");
    exit(4);
  }

	{
	  unsigned char *ptrTmp;
	  unsigned char *ptrOut;
	  unsigned short i;
	  ptrTmp = tmpBuffer + minAddr;
	  ptrOut = outBuffer;
	
	  for(i = minAddr; i <= maxAddr; i++)
	  {
	    *(ptrOut++) = *(ptrTmp++);
	  }
	}
  free(tmpBuffer);
  tmpBuffer = NULL;
  free(allocationBuffer);
  allocationBuffer = NULL;
  
  return outBuffer;
}
