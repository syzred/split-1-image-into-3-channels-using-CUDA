//kernel.cu

__global__ void
split(unsigned char *image, unsigned char *r, unsigned char *g, unsigned char *b)
{
	int p = blockIdx.x*threadnum + threadIdx.x;

	r[p] = image[p * imagechannelnum];
	g[p] = image[p * imagechannelnum + 1];
	b[p] = image[p * imagechannelnum + 2];
}
