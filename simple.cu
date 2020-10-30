#include <stdio.h>

#define N 32

__global__ void kernel(int* input, int* output){
	for(int i=0; i<N; i++)
		output[i] = 2 * input[i];
}
int main(void){
	int *h_input, *h_output;
	int *d_input, *d_output;
	
	h_input = (int*)malloc(N*sizeof(int));
	h_output = (int*)malloc(N*sizeof(int));
	
	cudaMalloc((void**)&d_input, N*sizeof(int));
	cudaMalloc((void**)&d_output, N*sizeof(int));
	
	for(int i=0; i<N; i++) h_input[i] = i+1;
	
	cudaMemcpy(d_input, h_input, N*sizeof(int), cudaMemcpyHostToDevice);
	
	kernel<<<1, 1>>> (d_input, d_output);
	
	cudaDeviceSynchronize();
	
	cudaMemcpy(h_output, d_output, N*sizeof(int), cudaMemcpyDeviceToHost);
	

	for(int i=0; i<N; i++) printf("%d -> %d\n", h_input[i], h_output[i]);
	
	free(h_input);
	free(h_output);
	cudaFree(d_input);
	cudaFree(d_output);

	return 0;
}