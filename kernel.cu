//kernel.cu

split(unsigned char *image, unsigned char *r, unsigned char *g, unsigned char *b)
{
	int i = blockIdx.x*K + threadIdx.x;
	int j = blockIdx.y*K + threadIdx.y;

	r[j * width + i] = image[(j * width + i) * imagechannelnum];
	g[j * width + i] = image[(j * width + i) * imagechannelnum + 1];
	b[j * width + i] = image[(j * width + i) * imagechannelnum + 2];
}
