#include<stdio.h>

__global__ void add1(int *g_A){
	atomicAdd(&g_A[0], 1);
}

int main()
{
	int *h_A;
	int *d_A;

	h_A = (int*)malloc(sizeof(int));

	cudaMalloc((void**)&d_A, sizeof(int));
	cudaMemset(d_A,0,sizeof(int));

	add1<<<1024, 1024>>>(d_A);

	cudaMemcpy(h_A,d_A,sizeof(int),cudaMemcpyDeviceToHost);

	printf("%d\n",h_A[0]);

	cudaFree(d_A);
	free(h_A);
	
	return 0;
}