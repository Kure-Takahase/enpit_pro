#include <stdio.h>
#include <stdlib.h>

#define N 1024

__global__ void matrix_product(int *g_A, int *g_B, int *g_C) {
	int gx = threadIdx.x + blockIdx.x * 32;
	int gy = threadIdx.y + blockIdx.y * 32;
	int c = 0;
	int k;
	for (k = 0; k < N; k++) {
		c += g_A[k + gy*N] * g_B[gx + k*N];
	}
	g_C[gx + gy*N] = c;
}


int main() {
	int i;
	int *h_A, *h_B, *h_C, *d_A, *d_B, *d_C;
	
	h_A = (int*)malloc(sizeof(int)*N*N);
	h_B = (int*)malloc(sizeof(int)*N*N);
	h_C = (int*)malloc(sizeof(int)*N*N);
	
	cudaMalloc(&d_A, sizeof(int)*N*N);
	cudaMalloc(&d_B, sizeof(int)*N*N);
	cudaMalloc(&d_C, sizeof(int)*N*N);
	
	for (i = 0; i < N*N; i++) {
		h_A[i] = h_B[i] = 1;
	}
	
	cudaMemcpy(d_A, h_A, sizeof(int)*N*N, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, h_B, sizeof(int)*N*N, cudaMemcpyHostToDevice);
	cudaMemset(d_C, 0, sizeof(int)*N*N);
	
	dim3 grid(32, 32);
	dim3 block(32, 32);
	

	matrix_product<<< grid, block >>> (d_A, d_B, d_C);
	
	cudaMemcpy(h_C, d_C, sizeof(int)*N*N, cudaMemcpyDeviceToHost);
	
	int flag = 0;
		for(int y=0; y<N; y++){
			for(int x=0; x<N; x++){
				int c = 0;
				for(int k=0; k<N; k++){
					c += h_A[y*N + k] * h_B[k*N + x];
				}
				if(h_C[y*N + x] != c){
					flag = 1;
				}
			}
		}
	if(flag==0)
		printf("OK\n");
	else
		printf("NG\n");
		
	free(h_A);
	free(h_B);
	free(h_C);
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
}