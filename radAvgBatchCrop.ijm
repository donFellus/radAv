// This macro is designed to crop cells from micrographs based on the cSMAC signal for subsequent 
// radial averaging with radAvBatchHT of each channel in the micrograph. The macro must be applied
// to all condition folders

dir=getDirectory("Choose an Input Directory"); 
print(dir);

Dialog.create("Crop")
Dialog.addString("cSMAC channel", " "); //set cSMAC channel
Dialog.show();
Channel = Dialog.getString();
mF = 1.5; //set bounding box multiplication factor

print("Mask Channel: ", Channel);

setBatchMode(false);

list = getFileList(dir);
Array.print(list);

batchCrop(dir);

function batchCrop(dir) {
	for (i = 0; i < list.length; i++) {
		folder = dir+list[i];
		print(folder);
		files = getFileList(folder);
		print("files: ");
		Array.print(files);
		if (roiManager("count") > 0) {
			roiManager("deselect");
			roiManager("delete");
			print("ROImanager Cleared!");
		}

		for (k = 0; k < files.length; k++) {
			if (endsWith(files[k], Channel + ".tif")) {
//set filetype
				file = folder + files[k];
				print("file: ", file);
				open(file);
				img = getTitle();
				print("img: ", img);
				run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
				run("Duplicate...", " ");
				mask = getTitle();
				print("mask: ", mask);
				run("Subtract Background...", "rolling=50");
				run("Subtract...", "value=50");
				setOption("BlackBackground", true);
				run("Make Binary");
				run("Dilate");
				run("Dilate");
				run("Fill Holes");
				run("Analyze Particles...", "size=200-20000 circularity=0.10-1.00 exclude include add");
// set cSMAC size limits
				selectWindow(img);
				img = File.nameWithoutExtension;
				saveDir = getDirectory("Image");
				run("Close");
				selectWindow(mask);
				saveAs("Tiff", saveDir + File.separator + img + "_mask");
				close();
			}
		}
		for (j = 0; j < files.length; j++) {
			if (roiManager("count") > 0) {
				file2 = folder + files[j];
				if (endsWith(file2, ".tif")) {
				s2 = files[j];
				print("file2: ", file2);
				open(file2);
				dirOut=getDirectory("Image");
				print("dirOut: ", dirOut);
				img2 = getTitle();
				print("img2: ", img2);
		
		i2 = replace(img2, ".tif", "_files");
				outFolder = dirOut + File.separator + "fiji_" + i2; 
				print("outFolder: ", outFolder); 
				File.makeDirectory(outFolder);
				run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
				setBatchMode(true);
				wait(50);
				name = File.getName(outFolder);
				for (n = 0; n < roiManager("count"); n++) {
					selectWindow(img2);
					roiManager("select", n);
					roiManager("measure");
						if (j==0) {	
							Roi.getBounds(x,y,w,h);
  							a = maxOf(w, h);
  							b = minOf(w, h);
  							c = a-b;
  							d = c/2;
  							if (w == b) {
  								x = x-d;
  							}
  							if (h == b) {
  								y = y-d;
  							}
  							makeRectangle(x, y, a, a);	
  							roiManager("update");
							Roi.getBounds(x,y,w,h);
							hw = h*mF;
							print(hw);
							makeRectangle(x-((hw-h)/2), y-((hw-h)/2), hw, hw);
							roiManager("update");
							print("ROIs updated!");
						}
						selectWindow(img2);
						run("Duplicate...", "duplicate");
						cell = getTitle();
						saveAs("Tiff", outFolder + File.separator + "_" + n + "_" + cell);
						close();
				}	
				selectWindow("Results");
				saveAs("Results.txt", outFolder + File.separator + name);
				run("Close");
				if (roiManager("count") < 10) {
					print("WARNING - Low cell count in image " + img2);
				}
				selectWindow(img2);
				run("Close");
				run("Collect Garbage");
				}
			}
		}
	}
}

		
