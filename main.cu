//main.cu

        //------------------------------------import original image
	Mat originalimage;
	originalimage = imread("l0001.jpg", 1);
	namedWindow("originalimage", CV_WINDOW_AUTOSIZE);
	imshow("originalimage", originalimage);
	waitKey(0);

	//-------------------------------------save image's raw data into pointer
	unsigned char *h_imagedata = (unsigned char *)calloc(width * height * imagechannelnum, sizeof(unsigned char));
	h_imagedata = originalimage.data;

	//------------------------------------copy to device
	unsigned char *d_imagedata;
	cudaMalloc(&d_imagedata, width * height * imagechannelnum);
	cudaMemcpy(d_imagedata, h_imagedata, width * height * imagechannelnum, cudaMemcpyHostToDevice);

	//------------------------------------declare device's outputs
	unsigned char *d_rchannel, *d_gchannel, *d_bchannel;
	cudaMalloc(&d_rchannel, width * height);
	cudaMalloc(&d_gchannel, width * height);
	cudaMalloc(&d_bchannel, width * height);

	dim3 blocks(width * height / threadnum);
	dim3 threads(threadnum);

	//------------------------------------time and launch kernel
	float time_elapsed = 0;
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);
	split << <blocks, threads >> >(d_imagedata, d_rchannel, d_gchannel, d_bchannel);
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(start);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&time_elapsed, start, stop);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	printf("time:%f ms\n", time_elapsed);

	//------------------------------------copy the results to host
	unsigned char *h_rchannel = (unsigned char *)calloc(width * height, sizeof(unsigned char));
	unsigned char *h_gchannel = (unsigned char *)calloc(width * height, sizeof(unsigned char));
	unsigned char *h_bchannel = (unsigned char *)calloc(width * height, sizeof(unsigned char));
	cudaMemcpy(h_rchannel, d_rchannel, width * height, cudaMemcpyDeviceToHost);
	cudaMemcpy(h_gchannel, d_gchannel, width * height, cudaMemcpyDeviceToHost);
	cudaMemcpy(h_bchannel, d_bchannel, width * height, cudaMemcpyDeviceToHost);

	//------------------------------------show results
	Mat red(height, width, CV_8UC1, (unsigned char*)h_rchannel);
	vector<Mat> channels;
	Mat empty;
	empty = Mat::zeros(Size(width, height), CV_8UC1);
	channels.push_back(empty);
	channels.push_back(empty);
	channels.push_back(red);
	Mat redimage;
	merge(channels, redimage);
	namedWindow("red", CV_WINDOW_AUTOSIZE);
	imshow("red", redimage);

	Mat green(height, width, CV_8UC1, (unsigned char*)h_gchannel);
	channels.clear();
	channels.push_back(empty);
	channels.push_back(green);
	channels.push_back(empty);
	Mat greenimage;
	merge(channels, greenimage);
	namedWindow("green", CV_WINDOW_AUTOSIZE);
	imshow("green", greenimage);


	Mat blue(height, width, CV_8UC1, (unsigned char*)h_bchannel);
	channels.clear();
	channels.push_back(blue);
	channels.push_back(empty);
	channels.push_back(empty);
	Mat blueimage;
	merge(channels, blueimage);
	namedWindow("blue", CV_WINDOW_AUTOSIZE);
	imshow("blue", blueimage);
	waitKey(0);
