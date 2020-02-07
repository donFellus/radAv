run("Close All");
dir=getDirectory("Choose a Input Directory"); 
print(dir);
list = getFileList(dir);
Ch = File.getName(dir);

setBatchMode(true);
Array.print(list);

for (i = 0; i < list.length; i++) {
		if (endsWith(list[i], ".tif")) {
			file = dir+list[i];
			run("Bio-Formats Importer", "open=[file]");
			img = getTitle();
			width = getWidth();
			height = getHeight();
			for(n=0; n < 360; n++){
				selectWindow(img);
				run("Duplicate...", "title=[n]");
				run("Rotate... ", "angle=[n] grid=1 interpolation=Bilinear");
				}
				close(img);
				run("Images to Stack", "name=Stack title=[] use");
				run("Z Project...", "projection=[Average Intensity]");
				saveAs("Tiff", dir + File.separator + img + "_radAv");
				makeLine(0,0,width,height);
				run("Clear Results");
				profile = getProfile();
				for (k=0; k<profile.length; k++) {
					setResult("Value", k, profile[k]);
				}
				updateResults();
				saveAs("Measurements", dir + File.separator + Ch + "_profile_" + i + ".txt");
				}
		}
