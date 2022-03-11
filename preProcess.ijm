// This macro is designed to automatically segment, subtract 
// the background and measure standard parameters from 2D 
// micrographs of the immunological synapse based on a  
// brightfield (BF) image.

// The macro first prompts you to select the parent folder 
// of the raw microgaphs. Then you are prompted to select
// a reference file from the raw data to denote the various 
// channels. Finally you are prompted to select an output
// folder in which you want to save the segmented TIFF files.
//
// The reference file will then automatically open along with
// a dialog box. Fill in the channel names in the correct order
// (according to the reference file). The BF channel must 
// be denoted BF. The rest of the channels you are free to 
// call whatever you want. The macro will then analyse and save
// the images accordingly.

// Written by Audun Kvalvaag. Last modified
// 04.09.2019.

// Select input and output directories
dir=getDirectory("Choose a Input Directory"); 
print(dir);
setBatchMode(false);
dirOut = getDirectory("Choose a Output Directory");

subfolders = getFileList(dir);
Array.print(subfolders);

folder = dir+subfolders[0];
files = getFileList(folder);
Array.print(files);


Dialog.create("Filetype")
Dialog.addString("select filetype", " "); //set cSMAC channel
Dialog.show();
filetype = Dialog.getString();

// Array.reverse(files);

// Select a reference file to denote the channel names. The 
// BF channel must be called BF, while the other channels 
// have no restrictions

for (i = 0; i < files.length; i++) {
	if (endsWith(files[i], filetype)) {
	ch_file = folder + files[i];
	}
}

run("Bio-Formats Importer", "open=[ch_file]");

nC = nSlices();
print(nC);
Channels = newArray(nC);
Array.print(Channels);

Dialog.create("Channels")
for (c=0; c < nC; c++) {
	Dialog.addString("Ch" + c, " ");
}
Dialog.show();

close();
run("Close All");

for (c=0; c < nC; c++) {
	Channels[c] = Dialog.getString();
}

Array.print(Channels);

sortCh(dir);

function sortCh(dir) {
	for (sf=0; sf < subfolders.length; sf++) {
		subfolder = dir+subfolders[sf];
		datafiles = getFileList(subfolder);
		Array.print(datafiles);
		resFolder = dirOut + File.separator + "res_" + subfolders[sf];
		print(resFolder); 
		File.makeDirectory(resFolder);
		Name = File.getName(resFolder);
		print(Name); 
		for (i = 0; i < datafiles.length; i++) {
			if (endsWith(datafiles[i], filetype)) {
			file = subfolder + datafiles[i];
			run("Bio-Formats Importer", "open=[file]");
			Img = resFolder + File.separator + datafiles[i]; 
			print(Img); 
			File.makeDirectory(Img);
			run("Split Channels");
			ImgArray = getList("image.titles");
			for (s = 0; s < nC; s++) {
				selectWindow(ImgArray[s]);
				rename(Channels[s]); 
				}
			selectWindow("BF");
			run("Duplicate...", " ");
			saveAs("Tiff", Img + File.separator + "BF");
			close;

			run("Subtract Background...", "rolling=50");
			run("Enhance Contrast...", "saturated=2");
			run("Despeckle");
			run("Despeckle");
			run("Despeckle");
			run("Remove Outliers...", "radius=2 threshold=20 which=Bright");
			run("Find Edges");
			run("Gaussian Blur...", "sigma=10");
			run("Enhance Contrast...", "saturated=0.1");
			run("Convert to Mask");
			run("Fill Holes");
			run("Watershed");
			run("Analyze Particles...", "size=50-Infinity add");
			saveAs("Tiff", Img + File.separator + "masks");
			close;
			n = nImages;
			print(n);
			for (m = 0; m < n; m++) {
				run("Subtract Background...", "rolling=50");
				ImgName = getTitle();
				saveAs("Tiff", Img + File.separator + ImgName);
				if (roiManager("count") > 0){
				roiManager("measure");
				}
				close;
			}
			if (roiManager("count") > 0){
			roiManager("deselect");
			roiManager("delete");
			}
		}
	}
	
	selectWindow("Results");
	saveAs("text", resFolder + File.separator + Name);
	
	run("Close");
}
}
