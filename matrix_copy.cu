#include<stdio.h>
#include<stdlib.h>

#define N 1024 //N*N行列

__global__ void matrix_copy(int *g_A, int *g_B)
{
	int gx = blockIdx.x*blockDim.x + threadIdx.x;
	int gy = blockIdx.y*blockDim.y + threadIdx.y;
	g_B[gy * N + gx] = g_A[gy * N + gx];
}

int main()
{
	int *h_A, *h_B, *d_A, *d_B;
	
	h_A = (int*)malloc(N*N*sizeof(int));
	h_B = (int*)malloc(N*N*sizeof(int));
	
	cudaMalloc(&d_A, N*N*sizeof(int));
	cudaMalloc(&d_B, N*N*sizeof(int));
	
	for(int i=0; i<N*N; i++) h_A[i] = i;
	
	cudaMemcpy(d_A, h_A, N*N*sizeof(int), cudaMemcpyHostToDevice);
	
	dim3 grid(32, 32);
	dim3 block(32, 32);
	
	matrix_copy<<< grid, block >>>(d_A, d_B);
	
	cudaMemcpy(h_B, d_B, N*N*sizeof(int), cudaMemcpyDeviceToHost);
	
	int flag = 0;
	for(int y=0;y<N;y++)
		for(int x=0;x<N;x++)
			if(h_A[y*N+x]!=h_B[y*N+x]){
				flag = 1;
				break;
			}
	
	if(flag==0)
		printf("OK\n");
	else
		printf("NG\n");
	

	free(h_A);
	free(h_B);
	
	cudaFree(d_A);
	cudaFree(d_B);
}