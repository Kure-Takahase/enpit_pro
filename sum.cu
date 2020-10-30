#include<stdio.h>

#define N (1024*1024)

__global__ void local_sum(int *g_A, int *g_B){
	__shared__ int s_A[1024];
	
	s_A[threadIdx.x]=g_A[threadIdx.x+1024*blockIdx.x];
	__syncthreads();
	for(int i=512;i>0;i>>=1){
		if(threadIdx.x<i){
			s_A[threadIdx.x]+=s_A[threadIdx.x+i];
		}
		__syncthreads();
	}

	if(threadIdx.x==0){
		g_B[blockIdx.x]=s_A[0];
	}
}
int main()
{
	int *h_A, *h_C;
	int *d_A, *d_B, *d_C;
	int ans;

	h_A = (int*)malloc(N*sizeof(int));
	h_C = (int*)malloc(sizeof(int));

	ans = 0;
	for (int i = 0; i < N; i++){
		h_A[i] = 1;
		ans += h_A[i];
	}

	cudaMalloc((void**)&d_A, N*sizeof(int));
	cudaMalloc((void**)&d_B, 1024*sizeof(int));
	cudaMalloc((void**)&d_C, sizeof(int));

	cudaMemcpy(d_A,h_A,N*sizeof(int),cudaMemcpyHostToDevice);
	local_sum<<<1024, 1024>>>(d_A, d_B);
	local_sum<<< 1, 1024>>>(d_B, d_C);
	cudaMemcpy(h_C,d_C,sizeof(int),cudaMemcpyDeviceToHost);

	printf("%d %d\n",ans,h_C[0]);

	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
	free(h_A);
	free(h_C);
}