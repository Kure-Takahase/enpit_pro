#include<stdio.h>
#include<stdlib.h>
#include<cublas_v2.h>

#define N 1024

int main(){
	float *A, *B, *C;
	float *g_A, *g_B, *g_C;
	
	const float alpha = 1.0f;
	const float beta = 0.0f;
	
	A=(float*)malloc(sizeof(float)*N*N);
	B=(float*)malloc(sizeof(float)*N*N);
	C=(float*)malloc(sizeof(float)*N*N);
	for(int i=0;i<N*N;i++){
		A[i]=1.0f; B[i]=1.0f; C[i]=-1.0f;
	}
	
	cudaMalloc((void**)&g_A,sizeof(float)*N*N);
	cudaMalloc((void**)&g_B,sizeof(float)*N*N);
	cudaMalloc((void**)&g_C,sizeof(float)*N*N);
	
	cudaMemcpy(g_A,A,sizeof(float)*N*N,cudaMemcpyHostToDevice);
	cudaMemcpy(g_B,B,sizeof(float)*N*N,cudaMemcpyHostToDevice);
	cudaMemcpy(g_C,C,sizeof(float)*N*N,cudaMemcpyHostToDevice);
	
	cublasHandle_t handle;
	cublasCreate(&handle);
	cublasSgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, N, N, N,
				&alpha, g_A, N, g_B, N, &beta, g_C, N);
	cublasDestroy(handle);
	cudaMemcpy(C,g_C,sizeof(float)*N*N,cudaMemcpyDeviceToHost);
}