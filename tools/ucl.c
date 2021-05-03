/*
ucl compression tool
Copyright (C) 2015 by Juan J. Martinez - usebox.net

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#include <stdio.h>
#include <string.h>

#include <ucl/ucl.h>

#define MAX_MEM	65536

ucl_byte buffer[MAX_MEM];

int
main()
{
	ucl_uint in_len = 0;
	ucl_uint out_len;
	ucl_byte *in;
	ucl_byte *out;

	if (ucl_init() != UCL_E_OK)
	{
		fprintf(stderr, "ucl: failed to init UCL\n");
		return 1;
	}

	while(!feof(stdin))
	{
		buffer[in_len++] = getc(stdin);
		if (in_len > MAX_MEM)
		{
			fprintf(stderr, "input too large (limit %i)\n", MAX_MEM);
			return 1;
		}
	}
	in_len--;

	out_len = in_len + in_len / 8 + 256;

	in = ucl_malloc(in_len + 8192);
	out = ucl_malloc(out_len + 8192);
	if (!in || !out)
	{
		fprintf(stderr, "ucl: out of memory\n");
		return 1;
	}

	memcpy(in, buffer, in_len);

	if (ucl_nrv2b_99_compress(in, in_len, out, &out_len, NULL, 10, NULL, NULL) != UCL_E_OK)
	{
		fprintf(stderr, "ucl: compress error\n");
		return 1;
	}

	if (out_len >= in_len)
	{
		fprintf(stderr, "ucl: content can't be compressed\n");
		return 1;
	}

	fwrite(out, 1, out_len, stdout);
	fclose(stdout);

	ucl_free(out);
	ucl_free(in);

	fprintf(stderr, "ucl: %i bytes compressed into %i bytes\n", in_len, out_len);

	return 0;
}



