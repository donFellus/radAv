
// This macro is designed to analyze the average position of the various subcellular structures 
// of the immunological synapse. It opens all images in an input folder sequentially and rotates 
// them to create a radial average of the fluorescence signals in the images. It then draws 
// a line across the image and measures the intensity. One cell positioned in the center 
// of each image is therefore required.

run("Close All");
dir=getDirectory("Choose a Input Directory"); 
print(dir);
dirList = getFileList(dir);

Dialog.create("Ch")
Dialog.addString("Channel", " ");
Dialog.show();
Channel = Dialog.getString();

setBatchMode(true);
Array.print(dirList);

radAvgBatchHT();

function radAvgBatchHT() {
	for (gp = 0; gp < dirList.length; gp++) {
		if (startsWith(dirList[gp], "res")) {
			grandparent = dir + dirList[gp];
			gList = getFileList(grandparent);
			print("gList:");
			Array.print(gList);
			for (p = 0; p < gList.length; p++) {
				if (startsWith(gList[p], "Process")) {
					parent = dir + dirList[gp] + gList[p];
					print("parent:", parent);
					list = getFileList(parent);
					print("list:");
					Array.print(list);
					for (i = 0; i < list.length; i++) {
						if (startsWith(list[i], "fiji_" + Channel)) {
							folder = parent+list[i];
							print(folder);
							files = getFileList(folder);
							print("files: ");
							Array.print(files);
							file = dir+list[i];
							if (roiManager("count") > 0) {
								roiManager("deselect");
								roiManager("delete");
								print("ROImanager Cleared!");
							}
							for (k = 0; k < files.length; k++) {
								if (endsWith(files[k], Channel + "-1.tif")) {
									file = folder + files[k];
									print("file: ", file);
									open(file);
//									run("Bio-Formats Importer", "open=[file]");
									img = getTitle();
//									print("title:");
//									print(img);
									for(n=0; n < 360; n++){
										selectWindow(img);
										run("Duplicate...", "title=[n]");
										run("Rotate... ", "angle=[n] grid=1 interpolation=Bicubic");
									}
									close(img);
									run("Images to Stack", "name=Stack title=[] use");
									run("Z Project...", "projection=[Average Intensity]");
									saveAs("Tiff", folder + File.separator + img + "_radAv");
								}
								run("Close All");
							}
						}	
					}
				}
			}
			for (p = 0; p < gList.length; p++) {
				if (startsWith(gList[p], "Process")) {
					parent = dir + dirList[gp] + gList[p];
					list = getFileList(parent);
					Array.print(list);
					for (i = 0; i < list.length; i++) {
						if (startsWith(list[i], "fiji_" + Channel)) {
							folder = parent+list[i];
							print(folder);
							newFiles = getFileList(folder);
							for (f = 0; f < newFiles.length; f++) {
								if (endsWith(newFiles[f], "radAv.tif")) {
								newFile = folder+newFiles[f];
//								files = getFileList(folder);
//								Array.print(file);
//								Array.reverse(files);
//								file = folder + files[0];
								run("Bio-Formats Importer", "open=[newFile]");
								getDimensions(width, height, channels, slices, frames);
								print("w:", width);
								print("h:", height);
								if (width != height) {
									close();
								}
							}
						}
					}	
				}
			}
		}
		run("Images to Stack", "[Scale (largest)] name=Stack title=[] use");
		slices = nSlices;
		rootSlices = sqrt(slices);
		c = round(rootSlices);
		r = floor(rootSlices);
		saveAs("Tiff", grandparent + File.separator + Channel + "_radStack");
		run("Make Montage...", "columns=[c] rows=[r] scale=1");
		saveAs("Tiff", grandparent + File.separator + Channel + "_radMontage");
		close();
		run("Z Project...", "projection=[Average Intensity]");
		saveAs("Tiff", grandparent + File.separator + Channel + "_radTotAv");
		run("Close All");
		}
	}
}
	
