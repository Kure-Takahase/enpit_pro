#include<stdio.h>
#include"io_wrapper.h"

__global__ void convert(const unsigned char* g_in, unsigned char* g_out)
{
	int gy = blockIdx.y*blockDim.y + threadIdx.y;
	int gx = blockIdx.x*blockDim.x + threadIdx.x;

	g_out[gy*512 + gx] = (255 - g_in[gy*512 + gx]);
}


int main(){
	unsigned char *h_in=NULL, *h_out=NULL;
	int H, W;
	FILE *fp0, *fp1;

	if(	((fp0 = fopen("lena.pgm", "r")) == NULL)
		|| ((fp1 = fopen("lena_converted.pgm", "w")) == NULL))
	{
		printf("file open error!\n");
		exit(1);
	}
	
	h_in = pgm_read(fp0, &H, &W);
	h_out = (unsigned char *)malloc(sizeof(unsigned char)*512*512);
	
	unsigned char *d_in, *d_out;
	
	cudaMalloc(&d_in, sizeof(unsigned char)*512*512);
	cudaMalloc(&d_out, sizeof(unsigned char)*512*512);
	
	cudaMemcpy(d_in, h_in, sizeof(unsigned char)*512*512, cudaMemcpyHostToDevice);
	
	dim3 grid(16, 16);
	dim3 block(32, 32);
	
	convert<<<grid, block>>>(d_in, d_out);
	
	cudaMemcpy(h_out, d_out, sizeof(unsigned char)*512*512, cudaMemcpyDeviceToHost);
	
	cudaFree(d_in);
	cudaFree(d_out);
	
	pgm_write(h_out, fp1, H, W);
	
	fclose(fp0);
	fclose(fp1);
	
	free(h_in);
	free(h_out);
	
	return 0;
}