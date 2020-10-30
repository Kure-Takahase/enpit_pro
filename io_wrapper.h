#ifndef IO_WRAPPER_HPP
#define IO_WRAPPER_HPP
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

unsigned char* pgm_read(FILE* fp, int* H, int* W)
{
	char type[256];
	fread(type, sizeof(char), 3, fp);
	type[3] = '\0';
	if(strcmp("P2\n", type) != 0)
	{
		printf("P2 format only\n");
		exit(1);
	}
	
	int pos=ftell(fp);
	while(fgetc(fp)=='#')
	{
		while(fgetc(fp)!='\n');
		pos = ftell(fp);
	}
	fseek(fp, pos, SEEK_SET);
	
	int depth, height, width;
	fscanf(fp, "%d %d %d\n", &width, &height, &depth);
	
	if(depth!=255)
	{
		printf("8-bit only\n");
		exit(1);
	}
	
	*H = height;
	*W = width;
	unsigned char* in =
		(unsigned char *)malloc(sizeof(unsigned char)*width*height);
	
	for(int y=0;y < height;++y)
	{
		for(int x=0;x < width;++x)
		{
			int c;
			fscanf(fp, "%d", &c);
			in[y*width + x] = c;
		}
	}
	
	return in;
}

void pgm_write(unsigned char* out, FILE* fp,
				const int H, const int W)
{
	fprintf(fp, "P2\n%d %d\n255\n", (int)W, (int)H);

	for(int y=0;y < H;++y)
	{
		for(int x=0;x < W;++x)
		{
			fprintf(fp, "%d ", out[y*W + x]);
		}
		fprintf(fp, "\n");
	}
}

#endif