
// This macro is designed to analyze the average position of the various subcellular structures 
// of the immunological synapse generated by radAvgBatchCrop. It opens all images in each  
// condition folder within a parental folder and sequentially rotates them to create a  
// radial average of the fluorescence signals in the images. It then draws a line across the 
// image and measures the intensity. 

// Copyright (C) 2022, Kvalvaag project group - Oslo University Hospital 
// 
// radialAvg is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// radialAvg is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// <http://www.gnu.org/licenses/>

// Audun Kvalvaag, August 2020 (last modified 2022/03/09)

run("Close All");
dir=getDirectory("Choose a Input Directory"); 
print(dir);
dirList = getFileList(dir);

Dialog.create("Ch")
Dialog.addString("Channel", " "); //Name the channel to average
Dialog.show();
Channel = Dialog.getString();

Dialog.create("Folder0")
Dialog.addString("Parental folder ID", " "); //Name the parental folder of the cropped synapses
Dialog.show();
f0 = Dialog.getString();

Dialog.create("Folder1")
Dialog.addString("Condition folder ID", " "); //Name a unique identifier for the folders of the cropped synapses
Dialog.show();
f1 = Dialog.getString();

setBatchMode(true);
Array.print(dirList);

radAvgBatchHT();

function radAvgBatchHT() {
	for (gp = 0; gp < dirList.length; gp++) {
		if (startsWith(dirList[gp], f0)) {
			grandparent = dir + dirList[gp];
			gList = getFileList(grandparent);
			print("gList:");
			Array.print(gList);
			for (p = 0; p < gList.length; p++) {
				if (startsWith(gList[p], f1)) {
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
				if (startsWith(gList[p], f1)) {
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
	
