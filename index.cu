#include <stdio.h>

__global__ void kernel(){
	int gId = blockIdx.x * blockDim.x + threadIdx.x;
	printf("bId=%d,tId=%d,gId=%d¥n", blockIdx.x, threadIdx.x, gId);
}

int main(void){
	kernel<<<3, 4>>>();
	cudaDeviceSynchronize();
	return 0;
}