#include<stdio.h>
#include"io_wrapper.h"

//Laplacian Filter 3x3
__device__ const float d_f[3][3] = { {1.0f, 1.0f, 1.0f},
						{1.0f, -8.0f, 1.0f},
						{1.0f, 1.0f, 1.0f} };

__global__ void filter(const unsigned char* g_in, unsigned char* g_out) {
	int gy = blockIdx.y*blockDim.y + threadIdx.y;
	int gx = blockIdx.x*blockDim.x + threadIdx.x;
	
	if(gy == 0 || gx == 0 || gy == 511 || gx == 511){
		g_out[gy*512 + gx] = 0;
	}else{
		float val = 0.0f;
		for(int y=-1;y <= 1;++y){
			for(int x=-1;x <= 1;++x){
				val += g_in[(gy+y)*512+(gx+x)] * d_f[y+1][x+1];
			}
		}
		val = fabsf(val);
		g_out[gy*512 + gx] = (val > 255 ? 255 : (unsigned char)val);
	}
}

int main(){
	unsigned char *h_in=NULL, *h_out=NULL;
	int H, W;
	FILE *fp0, *fp1;

	if(	((fp0 = fopen("lena.pgm", "r")) == NULL)
		|| ((fp1 = fopen("lena_filtered.pgm", "w")) == NULL)) {
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
	
	filter<<<grid, block>>>(d_in, d_out);
	
	cudaMemcpy(h_out, d_out, sizeof(unsigned char)*512*512, cudaMemcpyDeviceToHost);
	
	cudaFree(d_in);
	cudaFree(d_out);
	
	pgm_write(h_out, fp1, 512, 512);
	
	fclose(fp0);
	fclose(fp1);
	
	free(h_in);
	free(h_out);
	
	return 0;
}